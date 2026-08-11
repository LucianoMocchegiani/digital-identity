import type { NextConfig } from 'next'

const billingUrl = process.env.BILLING_URL ?? 'http://localhost:9000'
const issuerUrl = process.env.ISSUER_URL ?? 'http://localhost:9001'
const verifierUrl = process.env.VERIFIER_URL ?? 'http://localhost:9002'

/**
 * Configuración de Next.js para Kuatia.
 *
 * Rewrites same-origin evitan CORS en el browser:
 * - `/api/billing/:path*` → `{BILLING_URL}/v1/:path*`
 * - `/api/issuer/:path*` → `{ISSUER_URL}/:path*`
 * - `/api/verifier/:path*` → `{VERIFIER_URL}/:path*`
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
      {
        source: '/api/issuer/:path*',
        destination: `${issuerUrl}/:path*`,
      },
      {
        source: '/api/verifier/:path*',
        destination: `${verifierUrl}/:path*`,
      },
    ]
  },
}

export default nextConfig
