import { DocsCode, DocsEndpoint, DocsLead, DocsTitle } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'DID Document',
}

export default function DocsDidPage() {
  return (
    <>
      <DocsTitle>DID Document</DocsTitle>
      <DocsLead>
        Identidad pública (<code className="text-sm">did:web</code>) del producto. Útil para
        depuración; las wallets también lo resuelven.
      </DocsLead>

      <DocsEndpoint method="GET" path="/{walletId}/did.json" auth="Pública">
        <DocsCode>{`GET {ISSUER_URL}/{walletId}/did.json`}</DocsCode>
        <p>Misma forma en el verifier.</p>
      </DocsEndpoint>
    </>
  )
}
