/** Formato permitido para walletId / issuerId / verifierId. */
export const WALLET_ID_REGEX = /^[a-zA-Z0-9][a-zA-Z0-9._-]*$/

/** Mensaje de validación class-validator para walletId. */
export const WALLET_ID_VALIDATION_MESSAGE =
  'walletId debe ser alfanumérico (permite . _ -) y no empezar con símbolo'
