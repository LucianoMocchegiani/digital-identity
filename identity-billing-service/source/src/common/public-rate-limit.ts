import type { NextFunction, Request, Response } from 'express'

type Bucket = {
  name: string
  match: (path: string) => boolean
  windowMs: number
  max: number
}

type WindowState = { count: number; resetAt: number }

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
 * Rate limit por IP para rutas públicas de billing (health; auth queda más estricto en D8).
 */
export function createBillingPublicRateLimitMiddleware() {
  const enabled = (process.env.PUBLIC_RATE_LIMIT_ENABLED ?? 'true').toLowerCase() !== 'false'
  const trustProxy = (process.env.PUBLIC_RATE_LIMIT_TRUST_PROXY ?? 'true').toLowerCase() !== 'false'
  const healthRpm = Number(process.env.PUBLIC_RATE_LIMIT_HEALTH_RPM ?? 300)
  const max = Number.isFinite(healthRpm) && healthRpm > 0 ? healthRpm : 300
  const buckets: Bucket[] = [
    {
      name: 'health',
      windowMs: 60_000,
      max,
      match: (path) => path === '/health' || path === '/v1/health',
    },
  ]
  const windows = new Map<string, WindowState>()

  return (req: Request, res: Response, next: NextFunction): void => {
    if (!enabled) {
      next()
      return
    }
    const path = requestPath(req)
    const bucket = buckets.find((b) => b.match(path))
    if (!bucket) {
      next()
      return
    }
    const ip = clientIp(req, trustProxy)
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
      res.status(429).json({
        statusCode: 429,
        message: 'Too many requests',
        bucket: bucket.name,
        retryAfterSec,
      })
      return
    }
    next()
  }
}
