import { RequestMethod } from '@nestjs/common'

/**
 * Rutas sin prefijo `/v1`.
 *
 * - `did.json` público del tenant.
 * - Short URL OOB (RFC 0434): la wallet/Credo hace GET con `Accept: application/json`.
 */
export const GLOBAL_PREFIX_EXCLUDE = [
  { path: ':walletId/did.json', method: RequestMethod.GET },
  { path: 'oob/:invitationId', method: RequestMethod.GET },
]
