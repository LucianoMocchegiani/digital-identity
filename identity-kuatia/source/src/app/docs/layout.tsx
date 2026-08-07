import { DocsShell } from '@/modules/docs/components/DocsShell'
import type { Metadata } from 'next'
import type { ReactNode } from 'react'

export const metadata: Metadata = {
  title: {
    template: '%s — Docs Kuatia',
    default: 'Documentación — Kuatia',
  },
  description:
    'Documentación Kuatia: OpenID4VC, recomendaciones de uso y referencia de la API.',
}

/** Layout compartido de `/docs/*` con sidebar. */
export default function DocsLayout({ children }: { children: ReactNode }) {
  return <DocsShell>{children}</DocsShell>
}
