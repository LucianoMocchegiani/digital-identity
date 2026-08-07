import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Verificar',
}

export default function DocsVerificarPage() {
  return (
    <>
      <DocsTitle>Verificar</DocsTitle>
      <DocsLead>
        Pedí una presentación OID4VP y consultá el resultado. Usá dcqlQuery (SD-JWT) o
        presentationDefinition (PEX), no ambos.
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
        { "path": ["email"] },
        { "path": ["role"] }
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
