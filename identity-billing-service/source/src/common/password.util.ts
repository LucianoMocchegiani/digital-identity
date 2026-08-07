import { randomBytes, scryptSync, timingSafeEqual } from 'crypto'

const SCRYPT_KEYLEN = 64

/**
 * Hash con scrypt (`salt:hex`).
 * @param password - Texto plano
 * @returns `salt:hash` en hex
 */
export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString('hex')
  const hash = scryptSync(password, salt, SCRYPT_KEYLEN).toString('hex')
  return `${salt}:${hash}`
}

/**
 * Verifica password contra hash almacenado (comparación timing-safe).
 * @returns false si el formato es inválido o no coincide
 */
export function verifyPassword(password: string, stored: string): boolean {
  const [salt, hash] = stored.split(':')
  if (!salt || !hash) return false
  const computed = scryptSync(password, salt, SCRYPT_KEYLEN)
  const expected = Buffer.from(hash, 'hex')
  if (expected.length !== computed.length) return false
  return timingSafeEqual(computed, expected)
}
