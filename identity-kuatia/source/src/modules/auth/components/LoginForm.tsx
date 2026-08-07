'use client'

import { Alert, Button, Field, Input, PasswordInput } from '@/design-system'
import { ApiError } from '@/shared/api/client'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState, type FormEvent } from 'react'
import { AuthShell } from './AuthShell'

/** Pantalla de ingreso a la consola. */
export function LoginForm() {
  const { login } = useAuth()
  const router = useRouter()
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

  return (
    <AuthShell
      title="Ingresar"
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
        {error ? <Alert>{error}</Alert> : null}
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
    </AuthShell>
  )
}
