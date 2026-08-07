import { DocsCode, DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Primeros pasos',
}

export default function DocsEmpezarPage() {
  return (
    <>
      <DocsTitle>Primeros pasos</DocsTitle>
      <DocsLead>
        De la consola Kuatia a tu primera oferta o verificación en unos minutos.
      </DocsLead>

      <DocsH2>Conceptos de producto</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Producto</span> — un issuer o un verifier
          creado en la{' '}
          <Link href="/app/productos" className="text-[var(--kuatia-accent)] hover:underline">
            consola
          </Link>
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">walletId</span> — id del producto
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">API key</span> —{' '}
          <code className="text-sm">iss_live_…</code> / <code className="text-sm">ver_live_…</code>
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">{'{ISSUER_URL}'}</span> /{' '}
          <span className="text-[var(--kuatia-text)]">{'{VERIFIER_URL}'}</span> — URL pública HTTPS
          de cada servicio
        </li>
      </DocsUl>

      <DocsH2>Flujo típico</DocsH2>
      <DocsUl>
        <li>Crear producto → guardar API key y walletId</li>
        <li>
          GET well-known → anotar <code className="text-sm">credentialConfigurationId</code> y{' '}
          <code className="text-sm">vct</code>
        </li>
        <li>PATCH branding (logo / colores)</li>
        <li>POST offer o request → mostrar QR</li>
        <li>(Verifier) poll de session hasta done</li>
      </DocsUl>

      <DocsH2>Resumen de endpoints</DocsH2>
      <DocsP>Issuer</DocsP>
      <DocsCode>{`GET  /v1/health
GET  /v1/health/ready
GET  /{walletId}/did.json
GET  /openid4vc-flow/{walletId}/.well-known/openid-credential-issuer
PATCH /v1/issuers/{walletId}/records/metadata
POST /v1/issuers/{walletId}/openid4vc/offer`}</DocsCode>
      <DocsP>Verifier</DocsP>
      <DocsCode>{`GET  /v1/health
GET  /v1/health/ready
GET  /{walletId}/did.json
GET  /openid4vc-auth/{walletId}/.well-known/oauth-authorization-server
PATCH /v1/verifiers/{walletId}/records/metadata
POST /v1/verifiers/{walletId}/openid4vc/request
GET  /v1/verifiers/{walletId}/openid4vc/session/{id}`}</DocsCode>
    </>
  )
}
