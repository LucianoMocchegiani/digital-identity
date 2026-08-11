'use client'

/**
 * Detalle de producto: editar nombre, rotar/revocar key (mockup 07).
 */
import { Alert, Badge, Button, Field, Input, Panel } from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import { setStoredApiKey } from '@/shared/credentials/apiKeyStore'
import type { Product } from '@/shared/types/billing'
import Link from 'next/link'
import { useParams, useRouter } from 'next/navigation'
import { useEffect, useState, type FormEvent } from 'react'

export function ProductDetail() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()
  const [product, setProduct] = useState<Product | null>(null)
  const [name, setName] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [info, setInfo] = useState<string | null>(null)
  const [newKey, setNewKey] = useState<string | null>(null)
  const [pending, setPending] = useState(false)

  useEffect(() => {
    void (async () => {
      try {
        const p = await billingApi.getProduct(id)
        setProduct(p)
        setName(p.name)
      } catch (err) {
        setError(err instanceof ApiError ? err.message : 'No se pudo cargar')
      }
    })()
  }, [id])

  async function onSave(e: FormEvent) {
    e.preventDefault()
    setPending(true)
    setError(null)
    try {
      const updated = await billingApi.updateProduct(id, { name })
      setProduct(updated)
      setInfo('Cambios guardados')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Error al guardar')
    } finally {
      setPending(false)
    }
  }

  async function onRotate() {
    if (!product?.resource?.id) return
    setPending(true)
    setError(null)
    try {
      const res = await billingApi.rotateKey(product.resource.id)
      setNewKey(res.apiKey)
      setStoredApiKey(id, res.apiKey)
      setProduct(await billingApi.getProduct(id))
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo rotar la key')
    } finally {
      setPending(false)
    }
  }

  async function onRevoke() {
    const keyId = product?.resource?.apiKeys?.[0]?.id
    if (!keyId) return
    if (!window.confirm('¿Revocar la API key activa?')) return
    setPending(true)
    try {
      await billingApi.revokeKey(keyId)
      setProduct(await billingApi.getProduct(id))
      setInfo('Key revocada')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo revocar')
    } finally {
      setPending(false)
    }
  }

  async function onDelete() {
    if (!window.confirm('¿Eliminar este producto?')) return
    setPending(true)
    try {
      await billingApi.deleteProduct(id)
      router.replace('/app/productos')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'No se pudo eliminar')
      setPending(false)
    }
  }

  if (!product && !error) {
    return <p className="text-base text-[var(--kuatia-muted)]">Cargando…</p>
  }

  const prefix = product?.resource?.apiKeys?.[0]?.prefix

  return (
    <div>
      <p className="mb-3 text-sm text-[var(--kuatia-muted)]">
        <Link href="/app/productos" className="hover:text-[var(--kuatia-text)]">
          Productos
        </Link>
        {' › '}
        <span className="text-[var(--kuatia-text)]">{product?.name ?? '…'}</span>
      </p>
      <PageHeader
        title={product?.name ?? 'Producto'}
        description="Editá el nombre, rotá o revocá la API key."
        action={
          product ? (
            <div className="flex flex-wrap gap-2">
              <Badge tone={product.status === 'active' ? 'success' : 'neutral'}>
                {product.status === 'active' ? 'Activo' : product.status}
              </Badge>
              {product.service ? <Badge tone="accent">Servicio: {product.service}</Badge> : null}
            </div>
          ) : null
        }
      />
      {error ? <Alert className="mb-4">{error}</Alert> : null}
      {info ? (
        <Alert tone="success" className="mb-4">
          {info}
        </Alert>
      ) : null}
      {newKey ? (
        <Alert tone="info" className="mb-4">
          <p>
            Nueva key (una sola vez): <code className="break-all">{newKey}</code>
          </p>
          <Button
            className="mt-3"
            size="sm"
            variant="secondary"
            onClick={() => {
              setStoredApiKey(id, newKey)
              router.push(`/app/credenciales?productId=${encodeURIComponent(id)}`)
            }}
          >
            Usar en Credenciales
          </Button>
        </Alert>
      ) : null}

      {product ? (
        <Panel className="max-w-2xl space-y-5">
          <h2 className="font-display text-xl font-semibold">Detalles del producto</h2>
          <div>
            <p className="text-base text-[var(--kuatia-muted)]">API key</p>
            <div className="mt-2 flex flex-col gap-3 sm:flex-row sm:items-center">
              <code className="flex-1 rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-code-bg)] px-3 py-3 font-mono text-sm">
                {prefix ? `${prefix}••••••••` : 'Sin key activa'}
              </code>
              <div className="flex flex-wrap gap-2">
                <Button variant="secondary" disabled={pending} onClick={() => void onRotate()}>
                  Rotar clave
                </Button>
                <Button variant="danger" disabled={pending} onClick={() => void onRevoke()}>
                  Revocar
                </Button>
              </div>
            </div>
          </div>
          <form className="space-y-4" onSubmit={onSave}>
            <Field label="Nombre del producto" htmlFor="name">
              <Input id="name" value={name} onChange={(e) => setName(e.target.value)} />
            </Field>
            <p className="text-base text-[var(--kuatia-muted)]">
              Wallet:{' '}
              <span className="break-all font-mono text-[var(--kuatia-text)]">{product.walletId}</span>
            </p>
            <div className="flex flex-wrap justify-end gap-3">
              <Button type="button" variant="ghost" onClick={() => router.push('/app/productos')}>
                Cancelar
              </Button>
              <Button type="submit" disabled={pending}>
                Guardar cambios
              </Button>
            </div>
          </form>
          <div className="border-t border-[var(--kuatia-border)] pt-4">
            <Button variant="ghost" disabled={pending} onClick={() => void onDelete()}>
              Eliminar producto
            </Button>
          </div>
        </Panel>
      ) : null}
    </div>
  )
}
