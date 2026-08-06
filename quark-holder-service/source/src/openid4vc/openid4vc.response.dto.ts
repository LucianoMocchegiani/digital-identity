/**
 * DTOs de respuesta del controller OID4VC.
 *
 * Definen el contrato HTTP estable consumido por el wallet.
 * Los tipos internos de Credo-TS (OpenId4VciCredentialResponse, etc.) se
 * exponen como `Record<string, unknown>` para evitar filtrar detalles del
 * framework al cliente; el wallet solo depende de este envelope.
 */

/** Registro de credencial recibida e indexada en la wallet del holder. */
export interface ReceivedCredentialDto {
  /** Registro crudo devuelto por Credo-TS (SdJwtVcRecord | W3cCredentialRecord serializado). */
  record: Record<string, unknown>
  /** Metadatos adicionales devueltos por el endpoint de credentials del issuer. */
  [key: string]: unknown
}

/** Credencial cuya emisión quedó diferida (deferred issuance del issuer). */
export interface DeferredCredentialDto {
  /** Identificador del transaction/deferred credential devuelto por el issuer. */
  transactionId?: string
  [key: string]: unknown
}

/** Respuesta de `POST /openid4vc/receive-offer`. */
export class ReceiveOfferResponseDto {
  /** Credenciales emitidas y almacenadas inmediatamente. */
  credentials!: ReceivedCredentialDto[]

  /** Credenciales con emisión diferida (pendientes de recuperar posteriormente). */
  deferredCredentials!: DeferredCredentialDto[]
}

/** Respuesta de `POST /openid4vc/present`. */
export class PresentResponseDto {
  /** `true` si el verifier aceptó la presentación. */
  ok!: boolean

  /**
   * Respuesta cruda del verifier tras procesar la presentación.
   * Shape dependiente del verifier (response_mode: direct_post, etc.).
   */
  verifierResponse?: Record<string, unknown>
}
