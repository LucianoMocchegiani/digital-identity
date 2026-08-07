'use client'

/**
 * Uso actual: card de transacciones + rate limit (mockup 05).
 */
import { Alert, Panel, Progress } from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import type { Usage } from '@/shared/types/billing'
import Link from 'next/link'
import { useEffect, useState } from 'react'

export function UsagePanel() {
  const [usage, setUsage] = useState<Usage | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    void (async () => {
      try {
        setUsage(await billingApi.usage())
      } catch (err) {
        setError(err instanceof ApiError ? err.message : 'Error al cargar uso')
      }
    })()
  }, [])

  return (
    <div>
      <PageHeader
        title="Uso"
        description="Cuota mensual y rate limit de tu cuenta."
        action={
          usage ? (
            <div className="rounded-xl border border-white/10 px-3 py-2 text-sm text-[var(--kuatia-muted)]">
              Período <span className="text-[var(--kuatia-text)]">{usage.periodKey}</span>
            </div>
          ) : null
        }
      />
      {error ? <Alert className="mb-4">{error}</Alert> : null}
      {usage ? (
        <div className="grid gap-4 lg:grid-cols-2">
          <Panel className="space-y-4">
            <p className="text-base text-[var(--kuatia-muted)]">Transacciones del mes</p>
            <p className="font-display text-4xl font-semibold text-[var(--kuatia-accent)]">
              {usage.monthlyTxUsed.toLocaleString('es-AR')}{' '}
              <span className="text-2xl text-[var(--kuatia-muted)]">
                / {usage.monthlyTxQuota.toLocaleString('es-AR')} tx
              </span>
            </p>
            <Progress value={usage.monthlyTxUsed} max={usage.monthlyTxQuota} />
          </Panel>
          <Panel className="relative overflow-hidden space-y-3">
            <p className="text-base text-[var(--kuatia-muted)]">Límite de tasa</p>
            <p className="font-display text-4xl font-semibold text-[var(--kuatia-accent)]">
              {usage.rateLimitRpm} <span className="text-2xl">rpm</span>
            </p>
            <p className="text-base text-[var(--kuatia-muted)]">
              Aplica al pool de API keys de la cuenta.
            </p>
            <p className="text-base text-[var(--kuatia-muted)]">
              Máx. productos: <strong className="text-[var(--kuatia-text)]">{usage.maxProducts}</strong>
            </p>
            <Link href="/app/plan" className="inline-block text-[var(--kuatia-accent)] hover:underline">
              Ver plan →
            </Link>
          </Panel>
        </div>
      ) : !error ? (
        <p className="text-base text-[var(--kuatia-muted)]">Cargando…</p>
      ) : null}
    </div>
  )
}
