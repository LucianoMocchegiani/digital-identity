import { DocsShell } from '@/modules/docs/components/DocsShell'
import { absoluteUrl, SITE_NAME } from '@/shared/seo/site'
import type { Metadata } from 'next'
import type { ReactNode } from 'react'

const docsDescription =
  'Documentación Kuatia: OpenID4VC, recomendaciones de uso y referencia de la API issuer/verifier.'

export const metadata: Metadata = {
  title: {
    template: `%s — Docs ${SITE_NAME}`,
    default: `Documentación — ${SITE_NAME}`,
  },
  description: docsDescription,
  openGraph: {
    title: `Documentación — ${SITE_NAME}`,
    description: docsDescription,
    url: absoluteUrl('/docs/introduccion'),
    siteName: SITE_NAME,
    locale: 'es',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: `Documentación — ${SITE_NAME}`,
    description: docsDescription,
  },
}

/** Layout compartido de `/docs/*` con sidebar. */
export default function DocsLayout({ children }: { children: ReactNode }) {
  return <DocsShell>{children}</DocsShell>
}
