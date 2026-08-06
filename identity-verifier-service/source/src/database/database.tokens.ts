/**
 * Token del único {@link import('pg').Pool} del proceso Nest.
 *
 * Lo provee {@link DatabaseModule}. Lo consume el sidecar BBS.
 * Askar store usa `DATABASE_URL` por su cuenta (no este pool).
 */
export const DATABASE_POOL = Symbol('DatabasePool')
