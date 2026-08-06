/**
 * Códigos de error de dominio OID4VC retornados al wallet en el campo `errorCode`.
 *
 * El wallet usa estos códigos para branching en la UI sin parsear mensajes.
 */
export const OpenId4VcErrorCode = {
  /** El agente holder aún no está inicializado (arranque en curso o fallo de bootstrap). */
  AGENT_NOT_READY: 'OID4VC_AGENT_NOT_READY',
  /** Ninguna credencial almacenada satisface el authorization request del verifier. */
  NO_MATCHING_CREDENTIAL: 'OID4VC_NO_MATCHING_CREDENTIAL',
} as const

export type OpenId4VcErrorCode = (typeof OpenId4VcErrorCode)[keyof typeof OpenId4VcErrorCode]
