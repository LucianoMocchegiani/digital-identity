import { DocsCode, DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('empezar')

/**
 * Quickstart: consola (emitir/verificar) + API/curl.
 */
export default function DocsEmpezarPage() {
  return (
    <>
      <DocsTitle>Primera credencial</DocsTitle>
      <DocsLead>
        Probá emisión y verificación desde la consola, o integrá la misma API desde tu backend. La{' '}
        <Link href="/docs/wallet" className="text-[var(--kuatia-accent)] hover:underline">
          wallet
        </Link>{' '}
        completa el lado del titular.
      </DocsLead>

      <DocsH2>1. Productos</DocsH2>
      <DocsUl>
        <li>
          Creá una cuenta en{' '}
          <Link href="/register" className="text-[var(--kuatia-accent)] hover:underline">
            Kuatia
          </Link>{' '}
          (plan Free alcanza).
        </li>
        <li>
          En{' '}
          <Link href="/app/productos" className="text-[var(--kuatia-accent)] hover:underline">
            Productos
          </Link>
          , creá un <strong className="font-medium text-[var(--kuatia-text)]">issuer</strong> y un{' '}
          <strong className="font-medium text-[var(--kuatia-text)]">verifier</strong>.
        </li>
        <li>
          Guardá cada API key (
          <code className="text-sm">iss_live_…</code> / <code className="text-sm">ver_live_…</code>
          ); solo se muestran una vez.
        </li>
      </DocsUl>

      <DocsH2>2. Probar en la consola</DocsH2>
      <DocsP>
        En{' '}
        <Link href="/app/credenciales" className="text-[var(--kuatia-accent)] hover:underline">
          Credenciales
        </Link>{' '}
        hay dos pestañas:
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Emitir</span> — elegí el issuer, pegá la API
          key, completá claims (hay un ejemplo) y generá la oferta. La consola muestra el QR / URI
          para escanear con la wallet.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Verificar</span> — elegí el verifier, pegá la
          API key, definí qué pedir (DCQL de ejemplo incluido) y generá el request. Escaneá el QR
          desde la wallet; la consola hace poll de la sesión hasta el resultado.
        </li>
      </DocsUl>
      <DocsP>
        Sirve para validar el flujo extremo a extremo sin escribir código. Cuando integres tu
        sistema, usás los mismos endpoints por API.
      </DocsP>

      <DocsH2>3. Integrar por API (opcional)</DocsH2>
      <DocsP>
        Auth:{' '}
        <Link href="/docs/autenticacion" className="text-[var(--kuatia-accent)] hover:underline">
          Autenticación
        </Link>{' '}
        — header <code className="text-sm">X-API-Key</code>.
      </DocsP>

      <DocsP>Health (opcional)</DocsP>
      <DocsCode>{`curl -sS "{ISSUER_URL}/v1/health"`}</DocsCode>

      <DocsP>
        Metadata — anotá <code className="text-sm">credentialConfigurationId</code> y{' '}
        <code className="text-sm">vct</code> (
        <Link href="/docs/metadata" className="text-[var(--kuatia-accent)] hover:underline">
          Metadata
        </Link>
        ):
      </DocsP>
      <DocsCode>{`curl -sS "{ISSUER_URL}/openid4vc-flow/{walletId}/.well-known/openid-credential-issuer"`}</DocsCode>

      <DocsP>
        Oferta (
        <Link href="/docs/emitir" className="text-[var(--kuatia-accent)] hover:underline">
          Emitir
        </Link>
        ):
      </DocsP>
      <DocsCode>{`curl -sS -X POST "{ISSUER_URL}/v1/issuers/{walletId}/openid4vc/offer" \\
  -H "Content-Type: application/json" \\
  -H "X-API-Key: iss_live_…" \\
  -d '{
    "credentialConfigurationId": "membership_card",
    "vct": "MembershipCredential",
    "claims": {
      "name": "Ana Pérez",
      "role": "member",
      "organization": "Club Norte",
      "validFrom": "2026-08-01"
    },
    "disclosureFrame": {
      "_sd": ["role", "organization", "validFrom"]
    }
  }'`}</DocsCode>
      <DocsP>
        Respuesta típica: <code className="text-sm">offerUri</code> +{' '}
        <code className="text-sm">issuanceSessionId</code>.
      </DocsP>
      <DocsP>
        Verificación (
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          Verificar
        </Link>
        ): <code className="text-sm">POST …/openid4vc/request</code> → QR → la wallet presenta →{' '}
        <code className="text-sm">GET …/session/{'{id}'}</code> hasta{' '}
        <code className="text-sm">done</code>.
      </DocsP>

      <DocsH2>Mapa de endpoints</DocsH2>
      <DocsP>Issuer</DocsP>
      <DocsCode>{`GET  /v1/health
GET  /{walletId}/did.json
GET  /openid4vc-flow/{walletId}/.well-known/openid-credential-issuer
PATCH /v1/issuers/{walletId}/records/metadata
GET  /v1/issuers/{walletId}/records/types
GET  /v1/issuers/{walletId}/records?type=…
POST /v1/issuers/{walletId}/openid4vc/offer`}</DocsCode>
      <DocsP>Verifier</DocsP>
      <DocsCode>{`GET  /v1/health
PATCH /v1/verifiers/{walletId}/records/metadata
GET  /v1/verifiers/{walletId}/records/types
GET  /v1/verifiers/{walletId}/records?type=…
POST /v1/verifiers/{walletId}/openid4vc/request
GET  /v1/verifiers/{walletId}/openid4vc/session/{id}`}</DocsCode>
    </>
  )
}
