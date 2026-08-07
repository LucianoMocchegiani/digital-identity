'use client'

import { IconDoc, ThemeToggle } from '@/design-system'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'

/** Barra superior de consola (tema + docs + avatar). */
export function AppTopBar() {
  const { account } = useAuth()
  const initials = (account?.name || 'U')
    .split(/\s+/)
    .map((p) => p[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <header className="mb-6 flex items-center justify-end gap-3 border-b border-[var(--kuatia-border-subtle)] pb-4">
      <ThemeToggle />
      <Link
        href="/docs"
        className="inline-flex h-10 items-center gap-2 rounded-full px-3 text-sm text-[var(--kuatia-muted)] hover:bg-[var(--kuatia-hover)] hover:text-[var(--kuatia-text)] sm:text-base"
        title="Documentación"
      >
        <IconDoc size={18} />
        <span className="hidden sm:inline">Docs</span>
      </Link>
      <Link
        href="/app/cuenta"
        className="inline-flex items-center gap-2 rounded-full border border-[var(--kuatia-border)] py-1 pl-1 pr-3 hover:bg-[var(--kuatia-hover)]"
      >
        <span className="grid h-8 w-8 place-items-center rounded-full bg-[var(--kuatia-accent)] text-sm font-semibold text-[var(--kuatia-ink)]">
          {initials}
        </span>
        <span className="hidden text-sm text-[var(--kuatia-muted)] sm:inline">
          {account?.name?.split(' ')[0] ?? 'Cuenta'}
        </span>
      </Link>
    </header>
  )
}
