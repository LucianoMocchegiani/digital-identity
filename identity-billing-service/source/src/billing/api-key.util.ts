import { createHash, randomBytes } from 'crypto'
import type { ResourceService } from '../entities/resource.entity'

export function hashApiKey(rawKey: string): string {
  return createHash('sha256').update(rawKey).digest('hex')
}

export function generateApiKey(service: ResourceService): { raw: string; prefix: string } {
  const prefixTag = service === 'issuer' ? 'iss' : 'ver'
  const secret = randomBytes(24).toString('base64url')
  const raw = `${prefixTag}_live_${secret}`
  const prefix = raw.slice(0, 16)
  return { raw, prefix }
}
