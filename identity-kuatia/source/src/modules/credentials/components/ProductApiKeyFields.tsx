'use client'

/**
 * Selector de producto + API key para flujos Emitir / Verificar.
 */
import { Alert, Field, PasswordInput } from '@/design-system'
import {
  clearStoredApiKey,
  getStoredApiKey,
  setStoredApiKey,
} from '@/shared/credentials/apiKeyStore'
import type { Product } from '@/shared/types/billing'
import Link from 'next/link'
import { useEffect, useState } from 'react'

const selectClass =
  'h-12 w-full rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-4 text-base text-[var(--kuatia-text)] focus:border-[var(--kuatia-accent)]/60 focus:outline-none focus:ring-2 focus:ring-[var(--kuatia-accent)]/25'

export function ProductApiKeyFields({
  products,
  productId,
  onProductIdChange,
  apiKey,
  onApiKeyChange,
  emptyHint,
}: {
  products: Product[]
  productId: string
  onProductIdChange: (id: string) => void
  apiKey: string
  onApiKeyChange: (key: string) => void
  emptyHint: string
}) {
  const [remember, setRemember] = useState(true)
  const selected = products.find((p) => p.id === productId) ?? null
  const prefix = selected?.resource?.apiKeys?.[0]?.prefix
  const walletId = selected?.walletId ?? selected?.resource?.walletId ?? null

  useEffect(() => {
    if (!productId) return
    const stored = getStoredApiKey(productId)
    // Preferir key guardada; si no hay, no pisar lo que el usuario ya pegó.
    if (stored) onApiKeyChange(stored)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productId])

  function persistIfNeeded(nextKey: string) {
    onApiKeyChange(nextKey)
    if (!productId) return
    if (remember && nextKey.trim()) setStoredApiKey(productId, nextKey.trim())
    if (!remember) clearStoredApiKey(productId)
  }

  if (products.length === 0) {
    return (
      <Alert tone="info">
        {emptyHint}{' '}
        <Link href="/app/productos/nuevo" className="text-[var(--kuatia-accent)] hover:underline">
          Crear producto
        </Link>
      </Alert>
    )
  }

  return (
    <div className="space-y-4">
      <Field label="Producto" htmlFor="cred-product">
        <select
          id="cred-product"
          className={selectClass}
          value={productId}
          onChange={(e) => onProductIdChange(e.target.value)}
        >
          <option value="">Seleccionar…</option>
          {products.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
              {p.walletId ? ` · ${p.walletId}` : ''}
            </option>
          ))}
        </select>
      </Field>

      {selected ? (
        <p className="text-sm text-[var(--kuatia-muted)]">
          Wallet:{' '}
          <span className="font-mono text-[var(--kuatia-text)]">{walletId ?? '—'}</span>
          {prefix ? (
            <>
              {' · '}
              Key: <span className="font-mono text-[var(--kuatia-text)]">{prefix}••••</span>
            </>
          ) : null}
        </p>
      ) : null}

      <Field
        label="API key"
        htmlFor="cred-api-key"
        hint="Se muestra una sola vez al crear o rotar la key en Productos."
      >
        <PasswordInput
          id="cred-api-key"
          autoComplete="off"
          placeholder="iss_live_… / ver_live_…"
          value={apiKey}
          onChange={(e) => persistIfNeeded(e.target.value)}
        />
      </Field>

      <label className="flex items-center gap-2 text-sm text-[var(--kuatia-muted)]">
        <input
          type="checkbox"
          className="size-4 rounded border-[var(--kuatia-border)]"
          checked={remember}
          onChange={(e) => {
            const on = e.target.checked
            setRemember(on)
            if (!productId) return
            if (on && apiKey.trim()) setStoredApiKey(productId, apiKey.trim())
            else clearStoredApiKey(productId)
          }}
        />
        Recordar en este navegador (solo esta sesión)
      </label>

      <p className="text-sm text-[var(--kuatia-muted)]">
        ¿No tenés la key?{' '}
        <Link
          href={productId ? `/app/productos/${productId}` : '/app/productos'}
          className="text-[var(--kuatia-accent)] hover:underline"
        >
          Rotá o creá una en Productos
        </Link>
        .
      </p>
    </div>
  )
}
