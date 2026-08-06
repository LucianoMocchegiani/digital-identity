import {
  StatusList,
  createHeaderAndPayload,
  getListFromStatusListJWT,
  getStatusListFromJWT,
} from '@sd-jwt/jwt-status-list';

import {
  BitsPerStatus,
  StatusListEntry,
  SignerOptions,
  StatusType,
} from './status-list.types'
import { InvalidStatusListJwtError } from './revocation.errors'
import { defaultLogger, type CredoLogger } from '../types/logger.types';
import { JwtPayload } from '@credo-ts/core';

/**
 * Capa de manipulación de la bitstring Token Status List (TSL).
 *
 * Encapsula las operaciones puras sobre la `StatusList` (crear, comprimir,
 * descomprimir, leer/escribir bits) y la firma/verificación del JWT. No toca
 * persistencia: la responsabilidad de guardar la lista vive en el adapter
 * `StatusListStorage`. `RevocationService` compone ambos.
 *
 * Usa `@sd-jwt/jwt-status-list` para el formato de bitstring y JWT, y delega
 * la firma criptográfica a un `Kms` provisto por el consumidor (no hace
 * operaciones con claves propias).
 */
export class StatusListService {
  private logger: CredoLogger = defaultLogger;

  /**
   * Inyecta un logger Credo-TS para los mensajes internos del servicio.
   *
   * @param logger - Logger estilo Credo-TS.
   */
  setLogger(logger: CredoLogger): void {
    this.logger = logger;
  }

  /**
   * Crea una `StatusList` vacía con todos los bits en `0` (estado válido).
   *
   * @param bits - Bits por entrada (`1`, `2`, `4` u `8`). Default `1`.
   * @param capacity - Cantidad máxima de credenciales indexables. Default `16384`.
   * @returns Lista vacía lista para comprimir y persistir.
   */
  createEmptyList(bits: BitsPerStatus = 1, capacity: number = 16384): StatusList {
    return new StatusList(new Array(capacity).fill(0), bits);
  }

  /**
   * Marca el índice con el estado indicado (`0` válida, `1` revocada, etc.).
   *
   * @param list - Lista en memoria.
   * @param index - Posición a modificar.
   * @param value - Estado a setear.
   */
  setStatus(list: StatusList, index: number, value: StatusType): void {
    list.setStatus(index, value);
  }

  /**
   * Lee el estado de un índice de la lista.
   *
   * @param list - Lista en memoria.
   * @param index - Posición a leer.
   * @returns Estado (`0`/`1`/`2`/`15`).
   */
  getStatus(list: StatusList, index: number): StatusType {
    return list.getStatus(index) as StatusType;
  }

  /**
   * Devuelve la cantidad de bits por entrada configurada en la lista.
   *
   * @param list - Lista en memoria.
   * @returns Bits por entrada (`1`, `2`, `4` u `8`).
   */
  getBitsPerStatus(list: StatusList): BitsPerStatus {
    return list.getBitsPerStatus() as BitsPerStatus;
  }

  /**
   * Comprime la bitstring al formato TSL (DEFLATE+base64url).
   *
   * @param list - Lista en memoria.
   * @returns Bitstring comprimida lista para persistir o firmar.
   */
  compress(list: StatusList): string {
    return list.compressStatusList();
  }

  /**
   * Reconstruye una `StatusList` desde la bitstring comprimida persistida.
   *
   * @param compressed - Bitstring comprimida (formato TSL).
   * @param bits - Bits por entrada con que se comprimió originalmente.
   * @returns Lista en memoria.
   */
  decompress(compressed: string, bits: BitsPerStatus): StatusList {
    return StatusList.decompressStatusList(compressed, bits);
  }

  /**
   * Devuelve la cantidad de entradas de la lista (capacidad).
   *
   * @param list - Lista en memoria.
   * @returns Cantidad de índices reservables.
   */
  getCapacity(list: StatusList): number {
    return list.statusList.length;
  }

  /**
   * Busca el próximo índice con estado `0` (libre) a partir de `fromIndex`.
   *
   * @param list - Lista en memoria.
   * @param fromIndex - Posición inicial de búsqueda (inclusiva). Default `0`.
   * @returns Índice libre o `null` si la lista está completa desde `fromIndex`.
   */
  findFreeIndex(list: StatusList, fromIndex = 0): number | null {
    const capacity = list.statusList.length;
    for (let i = fromIndex; i < capacity; i++) {
      if (list.getStatus(i) === 0) {
        return i;
      }
    }
    return null;
  }

  /**
   * Firma la lista como JWT compacto con `typ: statuslist+jwt`.
   *
   * Construye el header y payload con `createHeaderAndPayload` de
   * `@sd-jwt/jwt-status-list` y delega la firma al `Kms` del consumidor. El
   * `alg` por defecto es `ES256` si el `signer` no especifica uno.
   *
   * @param list - Lista en memoria.
   * @param signer - Opciones de firma (DID, keyId, kid, alg, kms).
   * @param options.uri - URI pública de la lista (se inyecta como claim `sub`).
   * @param options.ttl - TTL en segundos para el claim `ttl` (opcional).
   * @param options.exp - Timestamp Unix de expiración absoluta (opcional).
   * @returns JWT compacto (`header.payload.signature`).
   */
  async signAsJwt(
    list: StatusList,
    signer: SignerOptions,
    options: {
      uri: string;
      ttl?: number;
      exp?: number;
    },
  ): Promise<string> {
    const now = Math.floor(Date.now() / 1000);
    const payload: Record<string, unknown> = {
      iss: signer.did,
      sub: options.uri,
      iat: now,
    };

    if (options.ttl) {
      payload.ttl = options.ttl;
    }

    if (options.exp) {
      payload.exp = options.exp;
    }

    const alg = signer.alg || 'ES256';
    const header = { alg, typ: 'statuslist+jwt' as const };

    const { header: jwtHeader, payload: jwtPayload } = createHeaderAndPayload(
      list,
      payload,
      header,
    );

    const headerB64 = Buffer.from(JSON.stringify(jwtHeader)).toString('base64url');
    const payloadB64 = Buffer.from(JSON.stringify(jwtPayload)).toString('base64url');
    const signInput = new TextEncoder().encode(`${headerB64}.${payloadB64}`);

    const { signature } = await signer.kms.sign({
      keyId: signer.keyId,
      algorithm: alg,
      data: signInput,
    });

    const signatureB64 = Buffer.from(signature).toString('base64url');
    return `${headerB64}.${payloadB64}.${signatureB64}`;
  }

  /**
   * Decodifica un JWT de StatusList y devuelve la lista y el payload.
   *
   * **No** verifica la firma criptográfica — esa responsabilidad queda en el
   * consumidor, que conoce el `Kms` y la clave pública del emisor. Este
   * método solo parsea header/payload y reconstruye la bitstring.
   *
   * @param jwt - JWT compacto de StatusList.
   * @returns Lista reconstruida y payload JWT decodificado.
   * @throws {InvalidStatusListJwtError} Si el JWT no se puede parsear o el
   *   payload no tiene la estructura esperada.
   */
  decodeJwt(jwt: string): { list: StatusList; payload: JwtPayload } {
    try {
      const list = getListFromStatusListJWT(jwt);
      const payloadB64 = jwt.split('.')[1];
      const payload = JSON.parse(
        Buffer.from(payloadB64, 'base64url').toString(),
      ) as JwtPayload;
      return { list, payload };
    } catch (error) {
      throw new InvalidStatusListJwtError(
        error instanceof Error ? error.message : 'Unknown error',
      );
    }
  }

  /**
   * Extrae `{ idx, uri }` desde el claim `status_list` de una credencial SD-JWT.
   *
   * Helper que se usa típicamente del lado del verifier para resolver qué
   * StatusList consultar a partir de la credencial presentada.
   *
   * @param credentialJwt - JWT de la credencial SD-JWT VC.
   * @returns Entrada de referencia a la StatusList (`idx` + `uri`).
   */
  extractReference(credentialJwt: string): StatusListEntry {
    return getStatusListFromJWT(credentialJwt);
  }

  /**
   * Construye el objeto `status_list` listo para inyectar como claim en una
   * credencial SD-JWT VC.
   *
   * @param idx - Índice reservado para la credencial.
   * @param uri - URI pública de la StatusList.
   * @returns Claim `status_list` con la forma `{ status_list: { idx, uri } }`.
   */
  buildStatusClaim(idx: number, uri: string): { status_list: StatusListEntry } {
    return {
      status_list: {
        idx,
        uri,
      },
    };
  }
}