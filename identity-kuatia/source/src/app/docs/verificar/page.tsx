import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('verificar')

export default function DocsVerificarPage() {
  return (
    <>
      <DocsTitle>Verificar</DocsTitle>
      <DocsLead>
        Pedí una presentación (
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OID4VP
        </Link>
        ) y consultá el resultado. Usá <code className="text-sm">dcqlQuery</code> (SD-JWT) o{' '}
        <code className="text-sm">presentationDefinition</code> (PEX), no ambos.
      </DocsLead>

      <DocsEndpoint
        method="POST"
        path="/v1/verifiers/{walletId}/openid4vc/request"
        auth="X-API-Key (verifier)"
      >
        <DocsCode>{`POST {VERIFIER_URL}/v1/verifiers/{walletId}/openid4vc/request
X-API-Key: ver_live_…

{
  "dcqlQuery": {
    "credentials": [{
      "id": "membership",
      "format": "dc+sd-jwt",
      "meta": { "vct_values": ["MembershipCredential"] },
      "claims": [
        { "path": ["name"] },
        { "path": ["role"] },
        { "path": ["organization"] }
      ]
    }]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}

→ { "requestUri": "openid4vp://…", "verificationSessionId": "…" }`}</DocsCode>
        <p>
          Para crear el QR de la wallet web, usá el enlace HTTPS con la ruta <code className="text-sm">/present</code>
          y conservá todos los parámetros de <code className="text-sm">requestUri</code>:
        </p>
        <DocsCode>{`openid4vp://...?PARAMS
  → https://wallet.kuatia.xyz/present?PARAMS`}</DocsCode>
        <p>
          En la consola de Kuatia se generan automáticamente el QR original y el de wallet web. Al
          abrirlo, el titular revisa la solicitud, elige qué credencial presentar y confirma el
          envío; escanear el QR no comparte datos automáticamente.
        </p>
      </DocsEndpoint>

      <DocsEndpoint
        method="GET"
        path="/v1/verifiers/{walletId}/openid4vc/session/{id}"
        auth="X-API-Key (verifier)"
      >
        <p>
          Poll hasta <code className="text-sm">done</code> o <code className="text-sm">error</code>.
          Estados: created → request-sent → response-received → done.
        </p>
        <DocsCode>{`GET {VERIFIER_URL}/v1/verifiers/{walletId}/openid4vc/session/{verificationSessionId}
X-API-Key: ver_live_…`}</DocsCode>
      </DocsEndpoint>
    </>
  )
}
