'use client'

import { docsNeighbors } from '@/modules/docs/nav'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

/** Enlaces Anterior / Siguiente al pie de cada doc. */
export function DocsPager() {
  const pathname = usePathname()
  const { prev, next } = docsNeighbors(pathname)

  if (!prev && !next) return null

  return (
    <nav className="mt-16 grid gap-3 border-t border-[var(--kuatia-border)] pt-8 sm:grid-cols-2">
      {prev ? (
        <Link
          href={prev.href}
          className="rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/40 px-4 py-3 text-sm text-[var(--kuatia-muted)] transition hover:border-[var(--kuatia-accent)]/40 hover:text-[var(--kuatia-text)]"
        >
          <span className="block text-xs uppercase tracking-wide">Anterior</span>
          <span className="mt-1 block font-medium text-[var(--kuatia-text)]">{prev.label}</span>
        </Link>
      ) : (
        <span />
      )}
      {next ? (
        <Link
          href={next.href}
          className="rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/40 px-4 py-3 text-right text-sm text-[var(--kuatia-muted)] transition hover:border-[var(--kuatia-accent)]/40 hover:text-[var(--kuatia-text)]"
        >
          <span className="block text-xs uppercase tracking-wide">Siguiente</span>
          <span className="mt-1 block font-medium text-[var(--kuatia-text)]">{next.label}</span>
        </Link>
      ) : null}
    </nav>
  )
}
