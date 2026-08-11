import { DocsCode, DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('empezar')

export default function DocsEmpezarPage() {
  return (
    <>
      <DocsTitle>Primeros pasos</DocsTitle>
      <DocsLead>
        De la consola Kuatia a tu primera oferta o verificación en unos minutos. Si una palabra no
        te suena, mirá el{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          glosario
        </Link>
        .
      </DocsLead>

      <DocsH2>Conceptos de producto</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Producto</span> — un{' '}
          <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
            issuer
          </Link>{' '}
          o un{' '}
          <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
            verifier
          </Link>{' '}
          creado en la{' '}
          <Link href="/app/productos" className="text-[var(--kuatia-accent)] hover:underline">
            consola
          </Link>
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">walletId</span> — id del producto (aparece en
          las URLs de la API)
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">API key</span> — secreto{' '}
          <code className="text-sm">iss_live_…</code> / <code className="text-sm">ver_live_…</code>{' '}
          para autenticar tu backend
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
        <li>PATCH branding (logo / colores) si querés personalizar la card</li>
        <li>POST offer o request → mostrar QR o deep link</li>
        <li>(Verifier) consultar la sesión hasta estado done</li>
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

      <DocsP>
        Detalle de auth:{' '}
        <Link href="/docs/autenticacion" className="text-[var(--kuatia-accent)] hover:underline">
          Autenticación
        </Link>
        .
      </DocsP>
    </>
  )
}
