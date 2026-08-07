'use client'

/**
 * Layout autenticado: sidebar + top bar + main.
 */
import { Atmosphere } from '@/design-system'
import { useAuth } from '@/shared/auth/AuthProvider'
import { useRouter } from 'next/navigation'
import { useEffect, type ReactNode } from 'react'
import { AppSidebar } from './AppSidebar'
import { AppTopBar } from './AppTopBar'

/** Shell de `/app/*` con guard de sesión. */
export function AppShell({ children }: { children: ReactNode }) {
  const { account, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading && !account) {
      router.replace('/login')
    }
  }, [account, loading, router])

  if (loading || !account) {
    return (
      <div className="grid min-h-screen place-items-center bg-[var(--kuatia-bg)] text-base text-[var(--kuatia-muted)]">
        Cargando…
      </div>
    )
  }

  return (
    <div className="relative flex min-h-screen flex-col bg-[var(--kuatia-bg)] text-[var(--kuatia-text)] md:flex-row">
      <Atmosphere soft />
      <AppSidebar />
      <div className="relative z-10 flex min-w-0 flex-1 flex-col">
        <div className="px-4 pt-4 sm:px-6 md:px-8 lg:px-10">
          <AppTopBar />
        </div>
        <main className="flex-1 overflow-auto px-4 pb-8 sm:px-6 md:px-8 md:pb-10 lg:px-10">
          {children}
        </main>
      </div>
    </div>
  )
}
