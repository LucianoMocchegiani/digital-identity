import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Emitir',
}

export default function DocsEmitirPage() {
  return (
    <>
      <DocsTitle>Emitir</DocsTitle>
      <DocsLead>
        Creá una oferta OID4VCI pre-autorizada. Mostrá la URI como QR; la wallet completa el flujo.
        Cada offer consume cuota del plan.
      </DocsLead>

      <DocsEndpoint
        method="POST"
        path="/v1/issuers/{walletId}/openid4vc/offer"
        auth="X-API-Key (issuer)"
      >
        <DocsCode>{`POST {ISSUER_URL}/v1/issuers/{walletId}/openid4vc/offer
X-API-Key: iss_live_…

{
  "credentialConfigurationId": "membership_card",
  "vct": "MembershipCredential",
  "claims": {
    "name": "Ana Pérez",
    "email": "ana@ejemplo.com",
    "role": "member",
    "organization": "Club Norte",
    "validFrom": "2026-08-01"
  },
  "disclosureFrame": {
    "_sd": ["email", "role", "organization", "validFrom"]
  },
  "claimsDisplay": {
    "name": { "name": "Nombre completo", "locale": "es" },
    "email": { "name": "Correo", "locale": "es" }
  }
}

→ { "offerUri": "openid-credential-offer://…", "issuanceSessionId": "…" }`}</DocsCode>
        <p>
          <code className="text-sm">credentialConfigurationId</code> debe existir en el well-known.{' '}
          <code className="text-sm">disclosureFrame._sd</code> marca claims ocultables al presentar.
          Tu backend no llama a /token ni /credential.
        </p>
      </DocsEndpoint>
    </>
  )
}
