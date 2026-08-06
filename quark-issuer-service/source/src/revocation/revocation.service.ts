import { Inject, Injectable } from '@nestjs/common'
import type { RevocationIssuer } from '@quarkid/identity-core'
import { REVOCATION_ISSUER } from './revocation.tokens'

/**
 * Fachada fina NestJS sobre la clase de alto nivel `RevocationIssuer`
 * del core (`@quarkid/identity-core`).
 *
 * Esta clase **no** implementa lógica de revocación propia: solo delega
 * cada método al `RevocationIssuer` cableado en `RevocationIssuerModule`
 * a través del token `REVOCATION_ISSUER`. La lógica de:
 *
 *  - Resolución del firmante (DID + KMS del tenant), vive en `CredoWalletSignerProvider`.
 *  - Construcción de la URI pública HTTP, vive en `HttpStatusListUriBuilder`.
 *  - Orquestación create / allocate / revoke / getStatus / getStatusListJwt,
 *    vive en el core (`RevocationService` + `RevocationIssuer`).
 *
 * Existe como capa Nest para:
 *  1. Preservar la inyección por tipo para `OpenId4VcService` (que sigue
 *     pidiendo `RevocationIssuerService` por su tipo concreto).
 *  2. Aislar el barrel del core: el resto del issuer no necesita importar
 *     `RevocationIssuer` directamente.
 *
 * @see {@link RevocationIssuer} — fachada de alto nivel del core.
 * @see {@link OpenId4VcService#createOffer} — integración automática al crear offers SD-JWT.
 */
@Injectable()
export class RevocationIssuerService {
  constructor(
    @Inject(REVOCATION_ISSUER)
    private readonly issuer: RevocationIssuer,
  ) {}

  /**
   * Crea (o recupera si ya existe) la StatusList del par `(walletId, vct)`.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `bits` y `capacity` opcionales.
   * @returns `listId` interno y URI HTTP pública para publicar el JWT.
   */
  createStatusList(
    walletId: string,
    vct: string,
    options: { bits?: 1 | 2 | 4 | 8; capacity?: number } = {},
  ): Promise<{ listId: string; uri: string }> {
    return this.issuer.createStatusList(walletId, vct, options)
  }

  /**
   * Asigna un índice libre en la StatusList para vincular una credencial emitida.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `credentialId` y `preferredIndex` opcionales.
   * @returns Índice asignado y URI HTTP de la StatusList.
   */
  allocateIndex(
    walletId: string,
    vct: string,
    options: { credentialId?: string; preferredIndex?: number } = {},
  ): Promise<{ index: number; uri: string }> {
    return this.issuer.allocateIndex(walletId, vct, options)
  }

  /**
   * Revoca la credencial asociada al índice indicado en la StatusList.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param index - Posición en la StatusList (el mismo `idx` de la credencial emitida).
   * @param options - `reason` y `revokedBy` opcionales.
   * @returns Fecha de revocación y código de estado (`1` = inválida/revocada).
   */
  revoke(
    walletId: string,
    vct: string,
    index: number,
    options: { reason?: string; revokedBy?: string } = {},
  ): Promise<{ revokedAt: Date; status: number }> {
    return this.issuer.revoke(walletId, vct, index, options)
  }

  /**
   * Genera y devuelve el JWT firmado de la StatusList lista para publicar.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param options - `ttl` y `exp` opcionales.
   * @returns JWT compacto y URI HTTP pública de la lista.
   */
  getStatusListJwt(
    walletId: string,
    vct: string,
    options: { ttl?: number; exp?: number } = {},
  ): Promise<{ jwt: string; uri: string }> {
    return this.issuer.getStatusListJwt(walletId, vct, options)
  }

  /**
   * Consulta el estado de revocación de un índice concreto en la StatusList.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type de la lista.
   * @param index - Posición a consultar.
   * @returns Estado (`0` = válida, `1` = revocada) y fecha de última actualización.
   */
  getStatus(
    walletId: string,
    vct: string,
    index: number,
  ): Promise<{ status: number; updatedAt?: Date }> {
    return this.issuer.getStatus(walletId, vct, index)
  }
}
