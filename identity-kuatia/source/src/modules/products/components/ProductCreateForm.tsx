'use client'

/**
 * Formulario de alta de producto (página o contenido de modal).
 * Si walletId queda vacío, se genera desde el nombre.
 */
import { Alert, Button, Field, Input } from '@/design-system'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import type { ResourceService } from '@/shared/types/billing'
import { useRouter } from 'next/navigation'
import { useState, type FormEvent } from 'react'
import { ServiceTypePicker } from './ServiceTypePicker'

function slugWalletId(name: string): string {
  const base =
    name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 40) || 'product'
  return `${base}-${Math.random().toString(36).slice(2, 6)}`
}

export function ProductCreateForm({
  onDone,
  onCancel,
}: {
  onDone?: () => void
  onCancel?: () => void
}) {
  const router = useRouter()
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [service, setService] = useState<ResourceService>('issuer')
  const [walletId, setWalletId] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [secret, setSecret] = useState<string | null>(null)
  const [pending, setPending] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setPending(true)
    try {
      const res = await billingApi.createProduct({
        name,
        description: description || undefined,
        service,
        walletId: walletId.trim() || slugWalletId(name),
      })
      setSecret(res.product.apiKey)
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo crear el producto')
    } finally {
      setPending(false)
    }
  }

  if (secret) {
    return (
      <div className="space-y-4">
        <Alert tone="info">Guardá esta API key ahora: no se vuelve a mostrar.</Alert>
        <code className="block break-all rounded-xl bg-black/40 p-3 text-base text-[var(--kuatia-accent)]">
          {secret}
        </code>
        <Button
          size="lg"
          onClick={() => {
            onDone?.()
            router.push('/app/productos')
            router.refresh()
          }}
        >
          Ir a productos
        </Button>
      </div>
    )
  }

  return (
    <form className="space-y-4" onSubmit={onSubmit}>
      {error ? <Alert>{error}</Alert> : null}
      <Field label="Nombre del producto" htmlFor="name">
        <Input
          id="name"
          required
          minLength={2}
          placeholder="Ej: Membresía Platino"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </Field>
      <Field label="Descripción" htmlFor="description">
        <Input
          id="description"
          placeholder="Opcional"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </Field>
      <Field label="Tipo de servicio">
        <ServiceTypePicker value={service} onChange={setService} />
      </Field>
      <Field
        label="Wallet ID"
        htmlFor="walletId"
        hint="Opcional: si lo dejás vacío generamos uno a partir del nombre."
      >
        <Input
          id="walletId"
          placeholder="Ej: atlantico-issuer"
          pattern="[a-zA-Z0-9][a-zA-Z0-9._-]*"
          value={walletId}
          onChange={(e) => setWalletId(e.target.value)}
        />
      </Field>
      <Alert tone="info">La API key se muestra una sola vez. Guardala en un lugar seguro.</Alert>
      <div className="flex flex-wrap justify-end gap-3 pt-2">
        {onCancel ? (
          <Button type="button" variant="ghost" onClick={onCancel}>
            Cancelar
          </Button>
        ) : null}
        <Button type="submit" size="lg" disabled={pending}>
          {pending ? 'Creando…' : 'Crear producto'}
        </Button>
      </div>
    </form>
  )
}
