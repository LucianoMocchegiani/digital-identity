/**
 * Token del único {@link import('pg').Pool} del proceso Nest.
 *
 * Lo provee {@link DatabaseModule}. Lo consumen BBS (`BbsKeyManagementService`),
 * StatusList (issuer) y cualquier otro adapter SQL del servicio.
 * Askar store usa `DATABASE_URL` por su cuenta (no este pool).
 */
export const DATABASE_POOL = Symbol('DatabasePool')
