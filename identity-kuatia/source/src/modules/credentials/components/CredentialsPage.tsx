'use client'

/**
 * Consola `/app/credenciales`: emitir (offer + QR) y verificar (request + QR + poll).
 */
import { Alert } from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import type { Product } from '@/shared/types/billing'
import { useSearchParams } from 'next/navigation'
import { Suspense, useEffect, useMemo, useState, type ReactNode } from 'react'
import { IssueOfferPanel } from './IssueOfferPanel'
import { VerifyRequestPanel } from './VerifyRequestPanel'

type Tab = 'emitir' | 'verificar'

/** Wrapper con Suspense por `useSearchParams`. */
export function CredentialsPage() {
  return (
    <Suspense fallback={<p className="text-base text-[var(--kuatia-muted)]">Cargando…</p>}>
      <CredentialsPageInner />
    </Suspense>
  )
}

function CredentialsPageInner() {
  const searchParams = useSearchParams()
  const initialProductId = searchParams.get('productId') ?? ''
  const initialTabParam = searchParams.get('tab')
  const initialTab: Tab =
    initialTabParam === 'verificar' || initialTabParam === 'emitir'
      ? initialTabParam
      : 'emitir'

  const [tab, setTab] = useState<Tab>(initialTab)
  const [products, setProducts] = useState<Product[]>([])
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    void (async () => {
      try {
        const list = await billingApi.listProducts()
        setProducts(list)
      } catch (err) {
        setError(err instanceof ApiError ? err.message : 'No se pudieron cargar los productos')
      } finally {
        setLoading(false)
      }
    })()
  }, [])

  // Si llega ?productId= de un verifier/issuer, abrir el tab coherente.
  useEffect(() => {
    if (!initialProductId || products.length === 0) return
    if (initialTabParam === 'emitir' || initialTabParam === 'verificar') return
    const p = products.find((x) => x.id === initialProductId)
    const service = p?.service ?? p?.resource?.service
    if (service === 'verifier') setTab('verificar')
    else if (service === 'issuer') setTab('emitir')
  }, [initialProductId, initialTabParam, products])

  const defaultIssuerId = useMemo(() => {
    if (initialProductId) {
      const p = products.find((x) => x.id === initialProductId)
      if ((p?.service ?? p?.resource?.service) === 'issuer') return initialProductId
    }
    const issuers = products.filter((p) => (p.service ?? p.resource?.service) === 'issuer')
    return issuers.length === 1 ? issuers[0].id : ''
  }, [products, initialProductId])

  const defaultVerifierId = useMemo(() => {
    if (initialProductId) {
      const p = products.find((x) => x.id === initialProductId)
      if ((p?.service ?? p?.resource?.service) === 'verifier') return initialProductId
    }
    const verifiers = products.filter((p) => (p.service ?? p.resource?.service) === 'verifier')
    return verifiers.length === 1 ? verifiers[0].id : ''
  }, [products, initialProductId])

  return (
    <div>
      <PageHeader
        title="Credenciales"
        description="Emití y verificá desde la web con OpenID4VC usando tus productos issuer y verifier."
      />

      <div className="mb-6 flex flex-wrap gap-2 border-b border-[var(--kuatia-border)] pb-3">
        <TabButton active={tab === 'emitir'} onClick={() => setTab('emitir')}>
          Emitir
        </TabButton>
        <TabButton active={tab === 'verificar'} onClick={() => setTab('verificar')}>
          Verificar
        </TabButton>
      </div>

      {error ? <Alert className="mb-4">{error}</Alert> : null}
      {loading ? (
        <p className="text-base text-[var(--kuatia-muted)]">Cargando productos…</p>
      ) : tab === 'emitir' ? (
        <IssueOfferPanel products={products} initialProductId={defaultIssuerId} />
      ) : (
        <VerifyRequestPanel products={products} initialProductId={defaultVerifierId} />
      )}
    </div>
  )
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: ReactNode
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={
        active
          ? 'rounded-xl bg-[var(--kuatia-accent)]/15 px-4 py-2 text-base font-semibold text-[var(--kuatia-accent)]'
          : 'rounded-xl px-4 py-2 text-base text-[var(--kuatia-muted)] hover:bg-[var(--kuatia-hover)] hover:text-[var(--kuatia-text)]'
      }
    >
      {children}
    </button>
  )
}
