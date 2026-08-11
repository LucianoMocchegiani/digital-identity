'use client'

import { Alert, Button, Field, Input, PasswordInput } from '@/design-system'
import { ApiError } from '@/shared/api/client'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import { Suspense, useState, type FormEvent } from 'react'
import { AuthShell } from './AuthShell'
import { OAuthButtons } from './OAuthButtons'

/** Pantalla de ingreso a la consola. */
function LoginFormInner() {
  const { login } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()
  const oauthError = searchParams.get('oauthError')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [pending, setPending] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setPending(true)
    try {
      await login(email, password)
      router.replace('/app/productos')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo ingresar')
    } finally {
      setPending(false)
    }
  }

  const displayError = error ?? (oauthError ? `OAuth: ${oauthError}` : null)

  return (
    <AuthShell
      title="Ingresar"
      subtitle="Accedé a la consola para gestionar productos e API keys."
      footer={
        <>
          ¿No tenés cuenta?{' '}
          <Link href="/register" className="font-medium text-[var(--kuatia-accent)] hover:underline">
            Crear cuenta
          </Link>
        </>
      }
    >
      <form className="space-y-4" onSubmit={onSubmit}>
        {displayError ? <Alert>{displayError}</Alert> : null}
        <Field label="Email" htmlFor="email">
          <Input
            id="email"
            type="email"
            autoComplete="email"
            required
            placeholder="tu@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </Field>
        <Field label="Contraseña" htmlFor="password">
          <PasswordInput
            id="password"
            autoComplete="current-password"
            required
            minLength={8}
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </Field>
        <Button type="submit" size="lg" className="w-full" disabled={pending}>
          {pending ? 'Ingresando…' : 'Ingresar'}
        </Button>
      </form>
      <div className="mt-4">
        <OAuthButtons />
      </div>
    </AuthShell>
  )
}

export function LoginForm() {
  return (
    <Suspense
      fallback={
        <AuthShell title="Ingresar" subtitle="Accedé a la consola para gestionar productos e API keys.">
          <p className="text-sm text-[var(--kuatia-muted)]">Cargando…</p>
        </AuthShell>
      }
    >
      <LoginFormInner />
    </Suspense>
  )
}
