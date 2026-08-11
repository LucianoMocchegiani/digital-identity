/**
 * Layout de `/app/*` — envuelve la consola con `AppShell` (sidebar + guard de sesión).
 */
import { AppShell } from '@/modules/console/components/AppShell'
import type { Metadata } from 'next'
import type { ReactNode } from 'react'

/** Consola privada: no indexar. */
export const metadata: Metadata = {
  title: {
    default: 'Consola',
    template: '%s — Kuatia',
  },
  robots: {
    index: false,
    follow: false,
    googleBot: {
      index: false,
      follow: false,
      noimageindex: true,
    },
  },
}

export default function ConsoleLayout({ children }: { children: ReactNode }) {
  return <AppShell>{children}</AppShell>
}
