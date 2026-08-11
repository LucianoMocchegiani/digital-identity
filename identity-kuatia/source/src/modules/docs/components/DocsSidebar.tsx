'use client'

import { DOCS_NAV } from '@/modules/docs/nav'
import { cn } from '@/shared/lib/cn'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'

/** Sidebar de documentación + menú móvil. */
export function DocsSidebar() {
  const pathname = usePathname()
  const [open, setOpen] = useState(false)

  const nav = (
    <nav className="space-y-8 text-base text-[var(--kuatia-muted)]">
      <div className="flex flex-wrap items-center gap-2">
        <span className="rounded-md border border-[var(--kuatia-accent)]/40 bg-[var(--kuatia-accent)]/10 px-2.5 py-1 font-mono text-xs font-semibold tracking-wide text-[var(--kuatia-accent)]">
          API v1
        </span>
        <Link
          href="/docs/versionado"
          onClick={() => setOpen(false)}
          className="text-sm text-[var(--kuatia-muted)] hover:text-[var(--kuatia-accent)] hover:underline"
        >
          Política
        </Link>
      </div>
      {DOCS_NAV.map((section) => (
        <div key={section.title}>
          <p className="mb-2 text-sm font-semibold uppercase tracking-[0.12em] text-[var(--kuatia-muted)]">
            {section.title}
          </p>
          <ul className="space-y-0.5 border-l border-[var(--kuatia-border)]">
            {section.items.map((item) => {
              const active = pathname === item.href
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    onClick={() => setOpen(false)}
                    className={cn(
                      '-ml-px block border-l py-1.5 pl-3 transition-colors hover:text-[var(--kuatia-text)]',
                      active
                        ? 'border-[var(--kuatia-accent)] font-medium text-[var(--kuatia-accent)]'
                        : 'border-transparent hover:border-[var(--kuatia-border)]',
                    )}
                  >
                    {item.label}
                  </Link>
                </li>
              )
            })}
          </ul>
        </div>
      ))}
    </nav>
  )

  return (
    <>
      <div className="mb-4 lg:hidden">
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          className="flex w-full items-center justify-between rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/60 px-4 py-3 text-base text-[var(--kuatia-text)]"
        >
          <span>Menú de documentación</span>
          <span className="text-[var(--kuatia-muted)]">{open ? '▲' : '▼'}</span>
        </button>
        {open ? (
          <div className="mt-3 rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/80 p-4 backdrop-blur">
            {nav}
          </div>
        ) : null}
      </div>
      <aside className="hidden w-60 shrink-0 lg:block xl:w-72">
        <div className="sticky top-24 max-h-[calc(100vh-7rem)] overflow-y-auto pr-2">{nav}</div>
      </aside>
    </>
  )
}
