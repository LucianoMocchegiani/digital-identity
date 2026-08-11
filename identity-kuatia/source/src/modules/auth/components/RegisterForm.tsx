'use client'

import { Alert, Button, Field, Input, PasswordInput } from '@/design-system'
import { ApiError } from '@/shared/api/client'
import { useAuth } from '@/shared/auth/AuthProvider'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState, type FormEvent } from 'react'
import { AuthShell } from './AuthShell'

/** Alta self-serve (plan Free). */
export function RegisterForm() {
  const { register } = useAuth()
  const router = useRouter()
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [pending, setPending] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setPending(true)
    try {
      await register(name, email, password)
      router.replace('/app/productos')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo crear la cuenta')
    } finally {
      setPending(false)
    }
  }

  return (
    <AuthShell
      title="Crear cuenta"
      subtitle={
        <>
          Plan{' '}
          <span className="font-semibold text-[var(--kuatia-accent)]">Free</span>: creá productos
          issuer o verifier y obtené tu API key.
        </>
      }
      footer={
        <>
          ¿Ya tenés cuenta?{' '}
          <Link href="/login" className="font-medium text-[var(--kuatia-accent)] hover:underline">
            Ingresar
          </Link>
        </>
      }
    >
      <form className="space-y-4" onSubmit={onSubmit}>
        {error ? <Alert>{error}</Alert> : null}
        <Field label="Nombre" htmlFor="name">
          <Input
            id="name"
            required
            minLength={2}
            placeholder="Tu nombre"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </Field>
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
        <Field label="Contraseña" htmlFor="password" hint="Mínimo 8 caracteres.">
          <PasswordInput
            id="password"
            autoComplete="new-password"
            required
            minLength={8}
            placeholder="Mínimo 8 caracteres"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </Field>
        <Button type="submit" size="lg" className="w-full" disabled={pending}>
          {pending ? 'Creando…' : 'Crear cuenta'}
        </Button>
      </form>
    </AuthShell>
  )
}
