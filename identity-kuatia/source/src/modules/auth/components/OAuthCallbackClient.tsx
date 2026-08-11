'use client'

/**
 * Recibe `accessToken` del callback OAuth (billing → redirect) y abre sesión.
 */
import { useAuth } from '@/shared/auth/AuthProvider'
import { useRouter, useSearchParams } from 'next/navigation'
import { Suspense, useEffect, useState } from 'react'
import { AuthShell } from '@/modules/auth/components/AuthShell'
import { Alert } from '@/design-system'
import Link from 'next/link'

function OAuthCallbackInner() {
  const { loginWithToken } = useAuth()
  const router = useRouter()
  const params = useSearchParams()
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const token = params.get('accessToken')
    if (!token) {
      setError('Falta el token de sesión. Volvé a intentar el login social.')
      return
    }
    void (async () => {
      try {
        await loginWithToken(token)
        router.replace('/app/productos')
      } catch {
        setError('No se pudo completar el ingreso con OAuth.')
      }
    })()
  }, [params, loginWithToken, router])

  return (
    <AuthShell title="Ingresando…" subtitle="Validando tu sesión OAuth.">
      {error ? (
        <div className="space-y-4">
          <Alert>{error}</Alert>
          <Link href="/login" className="font-medium text-[var(--kuatia-accent)] hover:underline">
            Volver al login
          </Link>
        </div>
      ) : (
        <p className="text-sm text-[var(--kuatia-muted)]">Un momento…</p>
      )}
    </AuthShell>
  )
}

export function OAuthCallbackClient() {
  return (
    <Suspense
      fallback={
        <AuthShell title="Ingresando…" subtitle="Validando tu sesión OAuth.">
          <p className="text-sm text-[var(--kuatia-muted)]">Un momento…</p>
        </AuthShell>
      }
    >
      <OAuthCallbackInner />
    </Suspense>
  )
}
