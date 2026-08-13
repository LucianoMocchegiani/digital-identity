import { DocsCode, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('autenticacion')

export default function DocsAuthPage() {
  return (
    <>
      <DocsTitle>Autenticación</DocsTitle>
      <DocsLead>
        Las rutas de administración (offers, requests, branding) usan API key. Health, did.json y
        well-known son públicos para wallets y probes.
      </DocsLead>

      <DocsP>Header en rutas admin:</DocsP>
      <DocsCode>{`X-API-Key: iss_live_…`}</DocsCode>
      <DocsP>
        También se acepta <code className="text-sm">Authorization: Bearer</code> con el mismo
        secreto.
      </DocsP>

      <DocsUl>
        <li>
          Issuer: <code className="text-sm">iss_live_…</code>
        </li>
        <li>
          Verifier: <code className="text-sm">ver_live_…</code>
        </li>
      </DocsUl>

      <DocsP>
        Usá la key del producto correcto. Guardala como secreto de backend — nunca en un cliente
        público ni en un repositorio. Ver también{' '}
        <Link href="/docs/seguridad" className="text-[var(--kuatia-accent)] hover:underline">
          Seguridad y confianza
        </Link>
        .
      </DocsP>
    </>
  )
}
