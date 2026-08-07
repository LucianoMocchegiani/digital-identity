'use client'

import { IconHelp } from '@/design-system'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'

/** Barra superior de consola (ayuda + avatar). */
export function AppTopBar() {
  const { account } = useAuth()
  const initials = (account?.name || 'U')
    .split(/\s+/)
    .map((p) => p[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <header className="mb-6 flex items-center justify-end gap-3 border-b border-white/5 pb-4">
      <a
        href="#estandares"
        className="grid h-10 w-10 place-items-center rounded-full text-[var(--kuatia-muted)] hover:bg-white/5 hover:text-[var(--kuatia-text)]"
        title="Ayuda"
        onClick={(e) => {
          e.preventDefault()
          window.open('mailto:hola@kuatia.xyz', '_blank')
        }}
      >
        <IconHelp size={20} />
      </a>
      <Link
        href="/app/cuenta"
        className="inline-flex items-center gap-2 rounded-full border border-white/10 py-1 pl-1 pr-3 hover:bg-white/5"
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
