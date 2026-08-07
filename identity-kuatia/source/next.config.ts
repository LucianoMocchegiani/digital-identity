import type { NextConfig } from 'next'

const billingUrl = process.env.BILLING_URL ?? 'http://localhost:9000'

/**
 * Configuración de Next.js para Kuatia.
 *
 * El rewrite same-origin `/api/billing/:path*` → `{BILLING_URL}/v1/:path*`
 * permite que el browser llame a billing sin CORS y que `billingFetch`
 * use rutas relativas. `BILLING_URL` apunta al servicio de billing (default local).
 */
const nextConfig: NextConfig = {
  /** Imagen Docker más chica (`node server.js` desde `.next/standalone`). */
  output: 'standalone',
  async rewrites() {
    return [
      {
        source: '/api/billing/:path*',
        destination: `${billingUrl}/v1/:path*`,
      },
    ]
  },
}

export default nextConfig
