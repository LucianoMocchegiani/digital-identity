'use client'

/**
 * Header de marketing.
 * - Visitante: Ingresar + Empezar gratis
 * - Sesión: Ir a la app (sin chrome de consola: no botón “?”)
 */
import { BrandMark, Button } from '@/design-system'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'

type Props = {
  /** En auth, los anclas `#` apuntan a la home. */
  homeAnchors?: boolean
}

export function MarketingHeader({ homeAnchors = false }: Props) {
  const { account, loading } = useAuth()
  const prefix = homeAnchors ? '/' : ''

  return (
    <MarketingShell
      as="header"
      className="relative z-20 flex flex-wrap items-center justify-between gap-3 py-4 sm:gap-y-2 sm:py-5"
    >
      <BrandMark />
      <nav className="order-3 hidden w-full items-center justify-center gap-6 text-base text-[var(--kuatia-muted)] sm:order-none sm:flex sm:w-auto md:gap-8 lg:gap-10">
        <Link href={`${prefix}#producto`} className="hover:text-[var(--kuatia-text)]">
          Producto
        </Link>
        <Link href={`${prefix}#precios`} className="hover:text-[var(--kuatia-text)]">
          Precios
        </Link>
        <Link href={`${prefix}#estandares`} className="hover:text-[var(--kuatia-text)]">
          Docs
        </Link>
      </nav>
      <div className="flex items-center gap-2 sm:gap-3">
        {loading ? (
          <span className="h-10 w-28 animate-pulse rounded-xl bg-white/5" aria-hidden />
        ) : account ? (
          <Link href="/app/productos">
            <Button size="md" className="px-4 text-sm sm:px-6 sm:text-base">
              Ir a la app
            </Button>
          </Link>
        ) : (
          <>
            <Link
              href="/login"
              className="text-sm text-[var(--kuatia-muted)] hover:text-[var(--kuatia-text)] sm:text-base"
            >
              Ingresar
            </Link>
            <Link href="/register">
              <Button size="md" className="px-4 text-sm sm:px-6 sm:text-base">
                <span className="sm:hidden">Empezar</span>
                <span className="hidden sm:inline">Empezar gratis</span>
              </Button>
            </Link>
          </>
        )}
      </div>
    </MarketingShell>
  )
}
