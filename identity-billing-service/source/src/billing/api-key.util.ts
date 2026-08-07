import { createHash, randomBytes } from 'crypto'
import type { ResourceService } from '../entities/resource.entity'

/**
 * Hash SHA-256 de una API key en claro (solo se persiste el hash).
 * @param rawKey - Key completa en texto plano
 */
export function hashApiKey(rawKey: string): string {
  return createHash('sha256').update(rawKey).digest('hex')
}

/**
 * Genera una API key con prefijo `iss_live_` / `ver_live_`.
 * @param service - issuer | verifier
 * @returns `raw` (mostrar una sola vez) y `prefix` (visible en UI)
 */
export function generateApiKey(service: ResourceService): { raw: string; prefix: string } {
  const prefixTag = service === 'issuer' ? 'iss' : 'ver'
  const secret = randomBytes(24).toString('base64url')
  const raw = `${prefixTag}_live_${secret}`
  const prefix = raw.slice(0, 16)
  return { raw, prefix }
}
