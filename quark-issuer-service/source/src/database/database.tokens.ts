/**
 * Token del único {@link import('pg').Pool} del proceso Nest.
 *
 * Lo provee {@link DatabaseModule}. Lo consumen BBS, StatusList y otros adapters SQL.
 * Askar store usa `DATABASE_URL` por su cuenta (no este pool).
 */
export const DATABASE_POOL = Symbol('DatabasePool')
