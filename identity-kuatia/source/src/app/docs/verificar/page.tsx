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
