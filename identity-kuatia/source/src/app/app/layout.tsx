/**
 * Layout de `/app/*` — envuelve la consola con `AppShell` (sidebar + guard de sesión).
 */
import { AppShell } from '@/modules/console/components/AppShell'
import type { ReactNode } from 'react'

export default function ConsoleLayout({ children }: { children: ReactNode }) {
  return <AppShell>{children}</AppShell>
}
