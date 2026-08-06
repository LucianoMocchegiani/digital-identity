import type { RevocationService } from './revocation.service';
import type {
  BitsPerStatus,
  GetStatusResult,
  GetStatusListJwtResult,
} from './status-list.types'

/**
 * Opciones de creación de una StatusList.
 *
 * Coinciden con `CreateStatusListParams` del orquestador de bajo nivel
 * (`RevocationService`), pero se exponen en esta capa para que los
 * consumidores no necesiten importar el módulo interno.
 */
export interface CreateStatusListOptions {
  /** Bits por entrada en la bitstring (`1`, `2`, `4` u `8`). Default `1`. */
  bits?: BitsPerStatus;
  /** Cantidad máxima de credenciales indexables. Default `16384`. */
  capacity?: number;
}

/**
 * Opciones de asignación de índice.
 */
export interface AllocateIndexOptions {
  /** Identificador opcional de la credencial (trazabilidad en `status_list_revocations`). */
  credentialId?: string;
  /** Índice preferido si está libre; si no, se busca el siguiente libre. */
  preferredIndex?: number;
}

/**
 * Opciones de revocación.
 */
export interface RevokeOptions {
  /** Motivo de la revocación (almacenado en la fila de auditoría). */
  reason?: string;
  /** Identificador de quien revoca. */
  revokedBy?: string;
}

/**
 * Opciones del JWT firmado de la StatusList.
 */
export interface GetStatusListJwtOptions {
  /** TTL en segundos para el claim `ttl` (opcional). */
  ttl?: number;
  /** Timestamp Unix de expiración absoluta (opcional; tiene prioridad sobre `ttl`). */
  exp?: number;
}

/**
 * Fachada de alto nivel para consumidores que emiten credenciales SD-JWT VC
 * y quieren gestionar el ciclo de vida de una StatusList (crear lista,
 * asignar índice al emitir, revocar, consultar, publicar JWT) **sin** tener
 * que construir un `SignerOptions` a mano.
 *
 * La clase es un wrapper de {@link RevocationService}: no agrega lógica
 * propia, pero ofrece tres beneficios sobre inyectar el orquestador directo:
 *
 *  1. **Naming semántico**: el issuer quiere `RevocationIssuer`, no `RevocationService`.
 *  2. **Punto único de inyección**: un solo token en el DI de Nest.
 *  3. **Extensibilidad**: si en el futuro aparecen flujos específicos de issuer
 *     (p. ej. métricas, hooks previos a la firma), se agregan aquí sin tocar
 *     el orquestador genérico.
 *
 * Para consumidores que no son issuers (verifiers, herramientas de admin, tests)
 * usar {@link RevocationService} directamente.
 *
 * @see {@link createRevocationIssuer} — factory que arma esta clase con sus dependencias.
 */
export class RevocationIssuer {
  constructor(private readonly revocation: RevocationService) {}

  /**
   * Crea (o recupera si ya existe) la StatusList para `(walletId, vct)`.
   *
   * Internamente invoca `RevocationService.createStatusList`, que ya
   * resuelve el `SignerOptions` vía el `SignerProvider` y construye la
   * URI pública vía el `StatusListUriBuilder` configurados.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `bits` y `capacity` opcionales.
   * @returns `listId` interno y URI pública lista para publicar.
   */
  async createStatusList(
    walletId: string,
    vct: string,
    options: CreateStatusListOptions = {},
  ): Promise<{ listId: string; uri: string }> {
    return this.revocation.createStatusList({
      walletId,
      vct,
      bits: options.bits,
      capacity: options.capacity,
    });
  }

  /**
   * Asigna un índice libre en la StatusList para vincular una credencial emitida.
   *
   * Crea la lista automáticamente si no existe. El `uri` devuelto debe
   * inyectarse en `status.status_list` al firmar la SD-JWT VC.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `credentialId` y `preferredIndex` opcionales.
   * @returns Índice asignado y URI pública de la StatusList.
   */
  async allocateIndex(
    walletId: string,
    vct: string,
    options: AllocateIndexOptions = {},
  ): Promise<{ index: number; uri: string }> {
    return this.revocation.allocateIndex({
      walletId,
      vct,
      credentialId: options.credentialId,
      preferredIndex: options.preferredIndex,
    });
  }

  /**
   * Marca la credencial asociada al índice como revocada.
   *
   * Operación atómica: actualiza la bitstring, incrementa el contador y
   * registra la fila de auditoría en una sola transacción.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param index - Posición en la StatusList.
   * @param options - `reason` y `revokedBy` opcionales.
   * @returns Fecha de revocación y código de estado (`1` = inválida/revocada).
   */
  async revoke(
    walletId: string,
    vct: string,
    index: number,
    options: RevokeOptions = {},
  ): Promise<{ revokedAt: Date; status: number }> {
    return this.revocation.revoke({
      walletId,
      vct,
      index,
      reason: options.reason,
      revokedBy: options.revokedBy,
    });
  }

  /**
   * Consulta el estado de revocación de un índice.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param index - Posición a consultar.
   * @returns Estado (`0` válida, `1` revocada, `2` suspendida, `15` no reconocida) y fecha de actualización.
   */
  getStatus(
    walletId: string,
    vct: string,
    index: number,
  ): Promise<GetStatusResult> {
    return this.revocation.getStatus(walletId, vct, index);
  }

  /**
   * Genera y devuelve el JWT firmado de la StatusList listo para publicar.
   *
   * Usa el formato `typ: statuslist+jwt` definido en el draft IETF TSL.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `ttl` y `exp` opcionales.
   * @returns JWT compacto y URI pública de la lista.
   */
  getStatusListJwt(
    walletId: string,
    vct: string,
    options: GetStatusListJwtOptions = {},
  ): Promise<GetStatusListJwtResult> {
    return this.revocation.getStatusListJwt(walletId, vct, {
      ttl: options.ttl,
      exp: options.exp,
    });
  }
}
