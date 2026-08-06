import { StatusListService } from './status-list.service';
import type { StatusListStorage } from './status-list-storage.interface'
import type { SignerProvider, StatusListUriBuilder } from './ports'
import {
  BitsPerStatus,
  CreateStatusListParams,
  AllocateIndexParams,
  RevokeParams,
  StatusListInfo,
  GetStatusResult,
  GetStatusListJwtResult,
  STATUS_TYPE_VALID,
  STATUS_TYPE_INVALID,
} from './status-list.types'
import {
  StatusListNotFoundError,
  NoFreeIndexError,
  IndexOutOfBoundsError,
} from './revocation.errors'
import { defaultLogger, type CredoLogger } from '../types/logger.types';
import type { MessagingService } from './messaging.interface';

/**
 * Orquestador de revocación de credenciales SD-JWT VC usando Token Status List (TSL).
 *
 * Esta clase no depende de NestJS ni de un transporte de mensajes: recibe
 * `StatusListStorage` (puerto de persistencia), `SignerProvider` (puerto para
 * resolver el firmante por tenant), `StatusListUriBuilder` (puerto para
 * construir la URI pública) y `MessagingService` (puerto de eventos) por
 * constructor. Eso la hace portable entre el issuer, el verifier o cualquier
 * consumidor sin acoplarse a la lógica de aplicación de cada uno.
 *
 * Flujo típico:
 *  1. `createStatusList` crea (o recupera) la lista para `(walletId, vct)`.
 *  2. `allocateIndex` reserva un índice al emitir una credencial.
 *  3. `revoke` invalida el bit del índice; `getStatus` consulta el estado.
 *  4. `getStatusListJwt` produce el JWT firmado que los verificadores consumen.
 *
 * Si no se inyecta `MessagingService`, los `publishEvent` se vuelven no-op
 * (el emisor funciona sin un bus de eventos). El core no impone el transporte:
 * el consumidor decide si el adapter es RabbitMQ, Kafka, una cola in-memory, etc.
 *
 * Para consumidores que solo quieren invocar métodos concretos por `walletId`
 * (sin construir el signer a mano) existe {@link RevocationIssuer} de alto nivel.
 */
export class RevocationService {
  private logger: CredoLogger = defaultLogger;

  constructor(
    private readonly statusListService: StatusListService,
    private readonly repository: StatusListStorage,
    private readonly signers: SignerProvider,
    private readonly uriBuilder: StatusListUriBuilder,
    private readonly messaging?: MessagingService,
  ) {}

  /**
   * Inyecta un logger Credo-TS. Propaga también al `StatusListService`
   * interno para que los logs de bitstring y JWT firmados usen la misma
   * instancia.
   *
   * @param logger - Logger estilo Credo-TS.
   */
  setLogger(logger: CredoLogger): void {
    this.logger = logger;
    this.statusListService.setLogger(logger);
  }

  /**
   * Crea una StatusList vacía para el par `(walletId, vct)` o devuelve la
   * existente si ya hay una (operación idempotente).
   *
   * Persiste la bitstring comprimida inicial (todos los bits en `0`) y emite
   * el evento `revocation.status-list.created` solo cuando se crea una lista
   * nueva (no cuando se recupera una existente).
   *
   * @param params - Parámetros de creación (`walletId`, `vct`, `bits`, `capacity`).
   * @returns `listId` interno y `uri` pública de la lista (formato decidido por el `StatusListUriBuilder`).
   */
  async createStatusList(
    params: CreateStatusListParams,
  ): Promise<{ listId: string; uri: string }> {
    const { walletId, vct, bits = 1, capacity = 16384 } = params;
    const signer = await this.signers.resolveSigner(walletId);

    const existing = await this.repository.findByWalletAndVct(walletId, vct);
    if (existing) {
      return {
        listId: existing.id,
        uri: this.uriBuilder.build(walletId, vct, signer.did),
      };
    }

    const list = this.statusListService.createEmptyList(bits as BitsPerStatus, capacity);
    const compressedBitstring = this.statusListService.compress(list);

    const created = await this.repository.create({
      walletId,
      vct,
      bits: bits as BitsPerStatus,
      capacity,
      compressedBitstring,
      nextIndex: 0,
    });

    const uri = this.uriBuilder.build(walletId, vct, signer.did);

    await this.publishEvent('revocation.status-list.created', {
      walletId,
      vct,
      listId: created.id,
      uri,
      bits,
      capacity,
      timestamp: new Date().toISOString(),
    });

    return { listId: created.id, uri };
  }

  /**
   * Asigna un índice libre en la StatusList para vincularlo a una credencial.
   *
   * Crea la lista automáticamente si no existe. Estrategia de selección:
   *  1. Si `preferredIndex` está libre, se usa ese.
   *  2. Si no, busca el siguiente índice libre a partir de `preferredIndex + 1`.
   *  3. Si no, usa el cursor `nextIndex` y, si está agotado, busca cualquier
   *     hueco libre desde el inicio.
   *
   * Marca el bit como `STATUS_TYPE_VALID`, comprime la bitstring y persiste
   * ambos cambios dentro de una transacción. Si se pasa `credentialId`, se
   * registra una fila de auditoría en `status_list_revocations` con `reason`
   * y `revokedBy` vacíos (la fila se completará cuando se revoque).
   *
   * @param params - Parámetros de asignación.
   * @returns Índice asignado y URI pública de la StatusList.
   * @throws {StatusListNotFoundError} Si la creación implícita de la lista falla.
   * @throws {NoFreeIndexError} Si la lista alcanzó su capacidad sin índices libres.
   */
  async allocateIndex(
    params: AllocateIndexParams,
  ): Promise<{ index: number; uri: string }> {
    const { walletId, vct, credentialId, preferredIndex } = params;
    const signer = await this.signers.resolveSigner(walletId);

    let statusList = await this.repository.findByWalletAndVct(walletId, vct);
    if (!statusList) {
      await this.createStatusList({ walletId, vct });
      statusList = await this.repository.findByWalletAndVct(walletId, vct);
      if (!statusList) {
        throw new StatusListNotFoundError(walletId, vct);
      }
    }

    const list = this.statusListService.decompress(
      statusList.compressedBitstring,
      statusList.bits,
    );
    const capacity = statusList.capacity;

    let index: number;
    if (preferredIndex !== undefined && preferredIndex >= 0 && preferredIndex < capacity) {
      if (this.statusListService.getStatus(list, preferredIndex) === STATUS_TYPE_VALID) {
        index = preferredIndex;
      } else {
        const freeIndex = this.statusListService.findFreeIndex(list, preferredIndex + 1);
        if (freeIndex === null) {
          throw new NoFreeIndexError(walletId, vct, capacity);
        }
        index = freeIndex;
      }
    } else {
      index = statusList.nextIndex;
      if (index >= capacity) {
        const freeIndex = this.statusListService.findFreeIndex(list);
        if (freeIndex === null) {
          throw new NoFreeIndexError(walletId, vct, capacity);
        }
        index = freeIndex;
      }
    }

    this.statusListService.setStatus(list, index, STATUS_TYPE_VALID);
    const compressed = this.statusListService.compress(list);
    const nextIndex = index + 1;

    // El updateCompressedBitstring y el eventual saveRevocation (audit de
    // asignación) deben ser atómicos. El saveRevocation para allocateIndex
    // no choca con `CredentialAlreadyRevokedError` porque el índice aún está
    // en `valid`; lo protegemos igual dentro de la transacción para
    // consistencia con revoke.
    await this.repository.withTransaction(async (tx) => {
      await tx.updateCompressedBitstring(statusList.id, compressed, nextIndex);

      if (credentialId) {
        await tx.saveRevocation({
          statusListId: statusList.id,
          index,
          credentialId,
        });
      }
    });

    const uri = this.uriBuilder.build(walletId, vct, signer.did);

    await this.publishEvent('revocation.status-list.allocated', {
      walletId,
      vct,
      listId: statusList.id,
      index,
      credentialId,
      timestamp: new Date().toISOString(),
    });

    return { index, uri };
  }

  /**
   * Revoca la credencial asociada al índice indicado.
   *
   * Marca el bit como `STATUS_TYPE_INVALID`, recomprime la bitstring, incrementa
   * `revoked_count` y registra (o actualiza, si ya existía) la fila de auditoría
   * en `status_list_revocations`. Todo en una transacción para garantizar
   * atomicidad ante fallos parciales.
   *
   * Emite el evento `credential.revoked` con `reason` y `revokedBy` después
   * de commitear la transacción.
   *
   * @param params - Parámetros de revocación.
   * @returns Fecha de revocación y código de estado (`1` = inválida/revocada).
   * @throws {StatusListNotFoundError} Si no existe lista para `(walletId, vct)`.
   * @throws {IndexOutOfBoundsError} Si `index` está fuera de `[0, capacity)`.
   * @throws {CredentialAlreadyRevokedError} Si el índice ya estaba revocado y
   *   el adapter falla con constraint UNIQUE (mapeo de `23505`).
   */
  async revoke(
    params: RevokeParams,
  ): Promise<{ revokedAt: Date; status: number }> {
    const { walletId, vct, index, reason, revokedBy } = params;

    const statusList = await this.repository.findByWalletAndVct(walletId, vct);
    if (!statusList) {
      throw new StatusListNotFoundError(walletId, vct);
    }

    const list = this.statusListService.decompress(
      statusList.compressedBitstring,
      statusList.bits,
    );

    if (index < 0 || index >= statusList.capacity) {
      throw new IndexOutOfBoundsError(index, statusList.capacity);
    }

    this.statusListService.setStatus(list, index, STATUS_TYPE_INVALID);
    const compressed = this.statusListService.compress(list);

    // Transacción atómica: actualizar bitstring + incrementar contador +
    // registrar/actualizar fila de auditoría. Si algo falla, se hace rollback
    // y el bit no queda inconsistente con el log.
    await this.repository.withTransaction(async (tx) => {
      await tx.updateCompressedBitstring(statusList.id, compressed, statusList.nextIndex);
      await tx.incrementRevokedCount(statusList.id);

      const existing = await tx.findRevocation(statusList.id, index);
      if (existing) {
        await tx.updateRevocation({
          statusListId: statusList.id,
          index,
          reason,
          revokedBy,
        });
      } else {
        await tx.saveRevocation({
          statusListId: statusList.id,
          index,
          reason,
          revokedBy,
        });
      }
    });

    const revokedAt = new Date();

    await this.publishEvent('credential.revoked', {
      walletId,
      vct,
      listId: statusList.id,
      index,
      reason,
      revokedBy,
      timestamp: revokedAt.toISOString(),
    });

    return { revokedAt, status: STATUS_TYPE_INVALID };
  }

  /**
   * Consulta el estado de revocación de un índice en la StatusList.
   *
   * Descomprime la bitstring persistida y lee el bit en la posición
   * indicada. La operación no toca la base de datos más allá de leer la
   * fila de la lista.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param index - Posición a consultar.
   * @returns Estado (`0` válida, `1` revocada, `2` suspendida, `15` no reconocido)
   *   y fecha de última actualización de la lista.
   * @throws {StatusListNotFoundError} Si no existe lista para `(walletId, vct)`.
   * @throws {IndexOutOfBoundsError} Si `index` está fuera de `[0, capacity)`.
   */
  async getStatus(
    walletId: string,
    vct: string,
    index: number,
  ): Promise<GetStatusResult> {
    const statusList = await this.repository.findByWalletAndVct(walletId, vct);
    if (!statusList) {
      throw new StatusListNotFoundError(walletId, vct);
    }

    const list = this.statusListService.decompress(
      statusList.compressedBitstring,
      statusList.bits,
    );

    if (index < 0 || index >= statusList.capacity) {
      throw new IndexOutOfBoundsError(index, statusList.capacity);
    }

    const status = this.statusListService.getStatus(list, index);

    return {
      status,
      updatedAt: statusList.lastUpdatedAt || undefined,
    };
  }

  /**
   * Genera y devuelve el JWT firmado de la StatusList listo para publicar.
   *
   * Usa el formato `typ: statuslist+jwt` definido en el draft IETF TSL. La
   * firma se delega al `SignerProvider` que se inyectó por constructor. La
   * URI pública de la lista (formato decidido por el `StatusListUriBuilder`)
   * se inyecta como claim `sub`.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options.ttl - TTL en segundos para el claim `ttl` (opcional).
   * @param options.exp - Timestamp Unix de expiración absoluta (opcional;
   *   tiene prioridad sobre `ttl`).
   * @returns JWT compacto y URI pública de la lista.
   * @throws {StatusListNotFoundError} Si no existe lista para `(walletId, vct)`.
   */
  async getStatusListJwt(
    walletId: string,
    vct: string,
    options: { ttl?: number; exp?: number } = {},
  ): Promise<GetStatusListJwtResult> {
    const statusList = await this.repository.findByWalletAndVct(walletId, vct);
    if (!statusList) {
      throw new StatusListNotFoundError(walletId, vct);
    }

    const list = this.statusListService.decompress(
      statusList.compressedBitstring,
      statusList.bits,
    );

    const signer = await this.signers.resolveSigner(walletId);
    const uri = this.uriBuilder.build(walletId, vct, signer.did);

    const jwt = await this.statusListService.signAsJwt(list, signer, {
      uri,
      ttl: options.ttl,
      exp: options.exp,
    });

    return { jwt, uri };
  }

  /**
   * Devuelve la metadata persistida de la StatusList sin descomprimir la bitstring.
   *
   * Útil para endpoints de admin que necesitan exponer `bits`, `capacity`,
   * `revokedCount`, `nextIndex` y fechas sin pagar el costo de decompress.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @returns `StatusListInfo` o `null` si no existe lista para ese par.
   */
  async getStatusListInfo(
    walletId: string,
    vct: string,
  ): Promise<StatusListInfo | null> {
    return this.repository.findByWalletAndVct(walletId, vct);
  }

  private async publishEvent(
    routingKey: string,
    payload: Record<string, unknown>,
  ): Promise<void> {
    if (this.messaging) {
      try {
        await this.messaging.publish(routingKey, payload);
      } catch (error) {
        this.logger.error(`Failed to publish event ${routingKey}`, error);
      }
    }
  }
}
