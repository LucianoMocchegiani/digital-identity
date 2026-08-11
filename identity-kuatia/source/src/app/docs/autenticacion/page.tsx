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
        well-known son públicos para wallets y probes de infraestructura.
      </DocsLead>

      <DocsP>Header en rutas admin:</DocsP>
      <DocsCode>{`X-API-Key: iss_live_…`}</DocsCode>

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
        público ni en un repositorio. Contexto de seguridad:{' '}
        <Link href="/docs/seguridad" className="text-[var(--kuatia-accent)] hover:underline">
          Seguridad y confianza
        </Link>
        . Términos en el{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          glosario
        </Link>
        .
      </DocsP>
    </>
  )
}
