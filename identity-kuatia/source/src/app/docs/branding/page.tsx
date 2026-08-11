import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsP,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('branding')

export default function DocsBrandingPage() {
  return (
    <>
      <DocsTitle>Branding</DocsTitle>
      <DocsLead>
        En la práctica, cambiá solo lo visual. format, vct y algoritmos los define Kuatia al
        provisionar; no los modifiques desde tu integración. Nuevos tipos de credencial: contactá a
        Kuatia.
      </DocsLead>

      <DocsEndpoint
        method="PATCH"
        path="/v1/issuers/{walletId}/records/metadata"
        auth="X-API-Key (issuer)"
      >
        <p>
          <code className="text-sm">display</code> → marca del emisor ·{' '}
          <code className="text-sm">credentialConfigurationsSupported.&lt;id&gt;.display</code> →
          card de la credencial (nombre, colores, logo, background_image).
        </p>
        <DocsCode>{`PATCH {ISSUER_URL}/v1/issuers/{walletId}/records/metadata
X-API-Key: iss_live_…

{
  "display": [{
    "name": "Club Norte",
    "locale": "es",
    "logo": {
      "uri": "https://cdn.ejemplo.com/logo-club.png",
      "alt_text": "Logo Club Norte"
    }
  }],
  "credentialConfigurationsSupported": {
    "membership_card": {
      "display": [{
        "name": "Membresía",
        "locale": "es",
        "background_color": "#0f766e",
        "text_color": "#ffffff",
        "logo": {
          "uri": "https://cdn.ejemplo.com/cred-icon.png",
          "alt_text": "Icono membresía"
        },
        "background_image": {
          "uri": "https://cdn.ejemplo.com/cred-bg.png"
        }
      }]
    }
  }
}`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint
        method="PATCH"
        path="/v1/verifiers/{walletId}/records/metadata"
        auth="X-API-Key (verifier)"
      >
        <p>Nombre y logo del verificador (lo que ve el holder al presentar).</p>
        <DocsCode>{`PATCH {VERIFIER_URL}/v1/verifiers/{walletId}/records/metadata
X-API-Key: ver_live_…

{
  "clientMetadata": {
    "client_name": "Control de acceso Club Norte",
    "logo_uri": "https://cdn.ejemplo.com/logo-club.png"
  }
}`}</DocsCode>
      </DocsEndpoint>

      <DocsP>Después del PATCH, volvé a consultar el well-known para verificar el display.</DocsP>
    </>
  )
}
