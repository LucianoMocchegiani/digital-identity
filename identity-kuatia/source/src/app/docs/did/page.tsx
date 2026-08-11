import { DocsCode, DocsEndpoint, DocsLead, DocsTitle } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('did')

export default function DocsDidPage() {
  return (
    <>
      <DocsTitle>DID Document</DocsTitle>
      <DocsLead>
        Identidad pública (
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          DID
        </Link>
        , <code className="text-sm">did:web</code>) del producto. Útil para depuración; las wallets
        también lo resuelven.
      </DocsLead>

      <DocsEndpoint method="GET" path="/{walletId}/did.json" auth="Pública">
        <DocsCode>{`GET {ISSUER_URL}/{walletId}/did.json`}</DocsCode>
        <p>Misma forma en el verifier.</p>
      </DocsEndpoint>
    </>
  )
}
