import type { NextFunction, Request, Response } from 'express'

export type PublicRateLimitBucket = {
  name: string
  /** true si este request cae en el bucket. */
  match: (path: string, method: string) => boolean
  /** Ventana en ms (típicamente 60_000). */
  windowMs: number
  /** Máximo de requests por IP en la ventana. */
  max: number
}

export type PublicRateLimitOptions = {
  enabled: boolean
  /** Usar X-Forwarded-For (primer hop) cuando hay proxy TLS. */
  trustProxy: boolean
  buckets: PublicRateLimitBucket[]
}

type WindowState = { count: number; resetAt: number }

function hasProductApiKey(req: Request): boolean {
  const apiKey = req.header('x-api-key')?.trim()
  if (apiKey) return true
  const auth = req.header('authorization')?.trim() ?? ''
  if (/^bearer\s+(iss_|ver_)/i.test(auth)) return true
  return false
}

function clientIp(req: Request, trustProxy: boolean): string {
  if (trustProxy) {
    const forwarded = req.header('x-forwarded-for')
    if (forwarded) {
      const first = forwarded.split(',')[0]?.trim()
      if (first) return first
    }
  }
  return req.socket.remoteAddress ?? 'unknown'
}

function requestPath(req: Request): string {
  const raw = req.originalUrl || req.url || req.path || '/'
  const q = raw.indexOf('?')
  return q >= 0 ? raw.slice(0, q) : raw
}

/**
 * Rate limit por IP para rutas públicas (health, discovery, OID4VC, DIDComm).
 * Omite requests con API key de producto: ahí mandan los cupos del plan vía billing.
 *
 * En memoria de proceso (fase 1 / una réplica). 429 + Retry-After si se excede.
 */
export function createPublicRateLimitMiddleware(options: PublicRateLimitOptions) {
  const windows = new Map<string, WindowState>()

  return function publicRateLimit(req: Request, res: Response, next: NextFunction): void {
    if (!options.enabled) {
      next()
      return
    }
    if (hasProductApiKey(req)) {
      next()
      return
    }

    const path = requestPath(req)
    const method = (req.method || 'GET').toUpperCase()
    const bucket = options.buckets.find((b) => b.match(path, method))
    if (!bucket) {
      next()
      return
    }

    const ip = clientIp(req, options.trustProxy)
    const key = `${bucket.name}:${ip}`
    const now = Date.now()
    let state = windows.get(key)
    if (!state || now >= state.resetAt) {
      state = { count: 0, resetAt: now + bucket.windowMs }
      windows.set(key, state)
    }

    state.count += 1
    if (state.count > bucket.max) {
      const retryAfterSec = Math.max(1, Math.ceil((state.resetAt - now) / 1000))
      res.setHeader('Retry-After', String(retryAfterSec))
      res.setHeader('X-RateLimit-Limit', String(bucket.max))
      res.setHeader('X-RateLimit-Remaining', '0')
      res.status(429).json({
        statusCode: 429,
        message: 'Too many requests',
        bucket: bucket.name,
        retryAfterSec,
      })
      return
    }

    res.setHeader('X-RateLimit-Limit', String(bucket.max))
    res.setHeader('X-RateLimit-Remaining', String(Math.max(0, bucket.max - state.count)))
    next()
  }
}

/** Defaults orientados a no romper wallets (burst OID4VC) ni probes de health. */
export function defaultPublicRateLimitBuckets(rpm: {
  health: number
  discovery: number
  protocol: number
}): PublicRateLimitBucket[] {
  const windowMs = 60_000
  return [
    {
      name: 'health',
      windowMs,
      max: rpm.health,
      match: (path) =>
        path === '/v1/health' ||
        path === '/v1/health/ready' ||
        path === '/health' ||
        path === '/health/ready',
    },
    {
      name: 'discovery',
      windowMs,
      max: rpm.discovery,
      match: (path, method) => {
        if (method !== 'GET' && method !== 'HEAD') return false
        if (path.endsWith('/did.json')) return true
        if (path.startsWith('/oob/')) return true
        if (path.includes('/.well-known/')) return true
        if (path.includes('/revocation/status-list/')) return true
        return false
      },
    },
    {
      name: 'protocol',
      windowMs,
      max: rpm.protocol,
      match: (path) =>
        path === '/didcomm' ||
        path.startsWith('/didcomm/') ||
        path.startsWith('/openid4vc-flow/') ||
        path.startsWith('/openid4vc-auth/'),
    },
  ]
}

export function publicRateLimitConfigFromEnv(env: NodeJS.ProcessEnv = process.env): PublicRateLimitOptions {
  const enabled = (env.PUBLIC_RATE_LIMIT_ENABLED ?? 'true').toLowerCase() !== 'false'
  const trustProxy = (env.PUBLIC_RATE_LIMIT_TRUST_PROXY ?? 'true').toLowerCase() !== 'false'
  const health = Number(env.PUBLIC_RATE_LIMIT_HEALTH_RPM ?? 300)
  const discovery = Number(env.PUBLIC_RATE_LIMIT_DISCOVERY_RPM ?? 120)
  const protocol = Number(env.PUBLIC_RATE_LIMIT_PROTOCOL_RPM ?? 180)
  return {
    enabled,
    trustProxy,
    buckets: defaultPublicRateLimitBuckets({
      health: Number.isFinite(health) && health > 0 ? health : 300,
      discovery: Number.isFinite(discovery) && discovery > 0 ? discovery : 120,
      protocol: Number.isFinite(protocol) && protocol > 0 ? protocol : 180,
    }),
  }
}
