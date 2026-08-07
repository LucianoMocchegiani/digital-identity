'use client'

/**
 * Tabla de productos issuer/verifier (consola), fiel al mockup.
 */
import {
  Alert,
  Badge,
  Button,
  IconCopy,
  IconMore,
  IconPlus,
  Modal,
  Panel,
} from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import type { Product } from '@/shared/types/billing'
import Link from 'next/link'
import { useCallback, useEffect, useState } from 'react'
import { ProductCreateForm } from './ProductCreateForm'

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleDateString('es-AR')
  } catch {
    return iso
  }
}

/** Vista de listado en `/app/productos`. */
export function ProductList() {
  const [products, setProducts] = useState<Product[]>([])
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [open, setOpen] = useState(false)

  const load = useCallback(async () => {
    try {
      setProducts(await billingApi.listProducts())
      setError(null)
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Error al cargar productos')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  async function copyText(value: string) {
    try {
      await navigator.clipboard.writeText(value)
    } catch {
      /* ignore */
    }
  }

  return (
    <div>
      <PageHeader
        title="Productos"
        description="Cada producto es un issuer o un verifier."
        action={
          <Button onClick={() => setOpen(true)}>
            <IconPlus size={18} />
            Nuevo producto
          </Button>
        }
      />

      {error ? <Alert className="mb-4">{error}</Alert> : null}
      {loading ? <p className="text-base text-[var(--kuatia-muted)]">Cargando…</p> : null}

      {!loading && products.length === 0 ? (
        <Panel>
          <p className="text-base text-[var(--kuatia-muted)]">
            Todavía no tenés productos. Creá un issuer o un verifier para empezar.
          </p>
          <Button className="mt-4" onClick={() => setOpen(true)}>
            <IconPlus size={18} />
            Nuevo producto
          </Button>
        </Panel>
      ) : null}

      {products.length > 0 ? (
        <Panel className="overflow-x-auto p-0">
          <table className="w-full min-w-[720px] text-left text-base">
            <thead className="border-b border-white/10 text-sm uppercase tracking-wide text-[var(--kuatia-muted)]">
              <tr>
                <th className="px-4 py-3 font-medium">Nombre</th>
                <th className="px-4 py-3 font-medium">Tipo</th>
                <th className="px-4 py-3 font-medium">Estado</th>
                <th className="px-4 py-3 font-medium">API key</th>
                <th className="px-4 py-3 font-medium">Creado</th>
                <th className="px-4 py-3 font-medium">Acciones</th>
              </tr>
            </thead>
            <tbody>
              {products.map((p) => {
                const keyPrefix = p.resource?.apiKeys?.[0]?.prefix
                return (
                  <tr key={p.id} className="border-b border-white/5 last:border-0">
                    <td className="px-4 py-4">
                      <p className="font-medium">{p.name}</p>
                      <p className="text-sm text-[var(--kuatia-muted)]">
                        {p.description ||
                          (p.service === 'issuer' ? 'Emisión de credenciales' : 'Verificación')}
                      </p>
                    </td>
                    <td className="px-4 py-4">
                      {p.service ? <Badge tone="accent">{p.service}</Badge> : '—'}
                    </td>
                    <td className="px-4 py-4">
                      <span className="inline-flex items-center gap-2">
                        <span
                          className={
                            p.status === 'active'
                              ? 'h-2 w-2 rounded-full bg-emerald-400'
                              : 'h-2 w-2 rounded-full bg-white/30'
                          }
                        />
                        {p.status === 'active' ? 'Activo' : p.status}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <button
                        type="button"
                        className="inline-flex items-center gap-2 font-mono text-sm text-[var(--kuatia-muted)] hover:text-[var(--kuatia-text)]"
                        onClick={() => void copyText(keyPrefix ?? p.id)}
                        title="Copiar"
                      >
                        {keyPrefix ? `${keyPrefix}…` : `${p.id.slice(0, 8)}…`}
                        <IconCopy size={14} />
                      </button>
                    </td>
                    <td className="px-4 py-4 text-[var(--kuatia-muted)]">{formatDate(p.createdAt)}</td>
                    <td className="px-4 py-4">
                      <Link
                        href={`/app/productos/${p.id}`}
                        className="inline-flex rounded-lg p-2 text-[var(--kuatia-muted)] hover:bg-white/5 hover:text-[var(--kuatia-text)]"
                        aria-label="Ver producto"
                      >
                        <IconMore size={18} />
                      </Link>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </Panel>
      ) : null}

      <Modal
        open={open}
        onClose={() => setOpen(false)}
        title="Nuevo producto"
        description="Creá un issuer o verifier con su API key."
      >
        <ProductCreateForm
          onCancel={() => setOpen(false)}
          onDone={() => {
            setOpen(false)
            setLoading(true)
            void load()
          }}
        />
      </Modal>
    </div>
  )
}
