'use client'

/**
 * Navegación de consola con íconos + bloque de usuario (mockup).
 */
import { BrandMark, IconDoc } from '@/design-system'
import { useAuth } from '@/shared/auth/AuthProvider'
import { cn } from '@/shared/lib/cn'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { consoleNav } from '../nav'

/** Navegación de `/app/*` (responsive). */
export function AppSidebar() {
  const pathname = usePathname()
  const { account } = useAuth()
  const initials = (account?.name || 'U')
    .split(/\s+/)
    .map((p) => p[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <aside
      className={cn(
        'relative z-10 border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/60 backdrop-blur',
        'flex flex-col border-b px-4 py-4 md:w-64 md:shrink-0 md:border-b-0 md:border-r md:py-6 lg:w-72',
      )}
    >
      <BrandMark href="/app/productos" size="sm" />
      <nav
        className={cn(
          'mt-4 flex gap-1 overflow-x-auto pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden',
          'md:mt-8 md:flex-1 md:flex-col md:overflow-visible md:pb-0',
        )}
      >
        {consoleNav.map((item) => {
          const active = pathname === item.href || pathname.startsWith(`${item.href}/`)
          const Icon = item.Icon
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'inline-flex items-center gap-2.5 whitespace-nowrap rounded-xl px-3 py-2.5 text-base transition md:w-full md:px-3.5 md:py-3',
                active
                  ? 'bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)]'
                  : 'text-[var(--kuatia-muted)] hover:bg-[var(--kuatia-hover)] hover:text-[var(--kuatia-text)]',
              )}
            >
              <Icon size={18} />
              <span className="flex flex-1 items-center justify-between gap-2">
                {item.label}
                {item.soon ? (
                  <span className="hidden text-xs uppercase tracking-wide opacity-70 md:inline">
                    pronto
                  </span>
                ) : null}
              </span>
            </Link>
          )
        })}
      </nav>

      <Link
        href="/docs"
        className={cn(
          'mt-2 inline-flex items-center gap-2.5 whitespace-nowrap rounded-xl px-3 py-2.5 text-base transition',
          'text-[var(--kuatia-muted)] hover:bg-[var(--kuatia-hover)] hover:text-[var(--kuatia-text)]',
          'md:mt-auto md:w-full md:px-3.5 md:py-3',
          pathname.startsWith('/docs') && 'bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)]',
        )}
      >
        <IconDoc size={18} />
        Docs
      </Link>

      {account ? (
        <Link
          href="/app/cuenta"
          className="mt-3 hidden items-center gap-3 rounded-xl border border-[var(--kuatia-border)] p-3 hover:bg-[var(--kuatia-hover)] md:flex"
        >
          <span className="grid h-10 w-10 place-items-center rounded-full bg-[var(--kuatia-accent)] font-semibold text-[var(--kuatia-ink)]">
            {initials}
          </span>
          <span className="min-w-0">
            <span className="block truncate text-sm font-medium">{account.name}</span>
            <span className="block truncate text-sm text-[var(--kuatia-muted)]">
              Plan {account.plan}
            </span>
          </span>
        </Link>
      ) : null}
    </aside>
  )
}
