'use client'

/**
 * Plan actual + upgrade (mockup uso/plan).
 */
import {
  Alert,
  Badge,
  Button,
  CheckList,
  IconRocket,
  Panel,
} from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { billingApi } from '@/shared/api/billing'
import { ApiError } from '@/shared/api/client'
import { useAuth } from '@/shared/auth/AuthProvider'
import type { PlanInfo } from '@/shared/types/billing'
import { useEffect, useState } from 'react'

export function PlanPanel() {
  const { account, refresh } = useAuth()
  const [plans, setPlans] = useState<PlanInfo[]>([])
  const [error, setError] = useState<string | null>(null)
  const [info, setInfo] = useState<string | null>(null)
  const [pending, setPending] = useState<string | null>(null)

  useEffect(() => {
    void (async () => {
      try {
        setPlans(await billingApi.plans())
      } catch (err) {
        setError(err instanceof ApiError ? err.message : 'Error al cargar planes')
      }
    })()
  }, [])

  async function checkout(plan: string) {
    setPending(plan)
    setError(null)
    setInfo(null)
    try {
      const res = await billingApi.checkout(plan)
      setInfo(
        typeof res === 'object' && res && 'message' in res
          ? String((res as { message: string }).message)
          : `Checkout solicitado para ${plan} (provider manual).`,
      )
      await refresh()
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Error en checkout')
    } finally {
      setPending(null)
    }
  }

  const current = plans.find((p) => p.id === account?.plan)

  return (
    <div>
      <PageHeader
        title="Plan"
        description={
          account ? (
            <>
              Tu plan actual:{' '}
              <Badge tone="accent" className="align-middle">
                {account.plan}
              </Badge>
            </>
          ) : (
            'Elegí o mejorá tu plan.'
          )
        }
      />
      {error ? <Alert className="mb-4">{error}</Alert> : null}
      {info ? (
        <Alert tone="info" className="mb-4">
          {info}
        </Alert>
      ) : null}

      {current ? (
        <Panel className="mb-6 flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <div className="flex items-center gap-3">
              <IconRocket size={28} className="text-[var(--kuatia-accent)]" />
              <h2 className="font-display text-3xl">{current.label ?? current.id}</h2>
              <Badge tone="accent">Plan actual</Badge>
            </div>
            <CheckList
              items={[
                `${current.maxProducts} productos`,
                `${current.rateLimitRpm} rpm`,
                `${current.monthlyTxQuota.toLocaleString('es-AR')} tx/mes`,
              ]}
            />
          </div>
          {account?.plan === 'free' ? (
            <div className="rounded-2xl border border-[var(--kuatia-accent)]/40 bg-[var(--kuatia-accent)]/10 p-5 lg:max-w-xs">
              <p className="font-medium">Mejorá tu experiencia</p>
              <p className="mt-1 text-sm text-[var(--kuatia-muted)]">
                Más productos, más rpm y más cuota mensual.
              </p>
              <Button
                className="mt-4 w-full"
                size="lg"
                disabled={pending === 'pro'}
                onClick={() => void checkout('pro')}
              >
                {pending === 'pro' ? '…' : 'Mejorar a Pro'}
              </Button>
            </div>
          ) : null}
        </Panel>
      ) : null}

      <div className="grid gap-4 md:grid-cols-3">
        {plans.map((plan) => {
          const isCurrent = account?.plan === plan.id
          return (
            <Panel key={plan.id} className={isCurrent ? 'border-[var(--kuatia-accent)]/50' : undefined}>
              <div className="flex items-center justify-between">
                <h3 className="font-display text-2xl">{plan.label ?? plan.id}</h3>
                {isCurrent ? <Badge tone="accent">Actual</Badge> : null}
              </div>
              <ul className="mt-4 space-y-2 text-base text-[var(--kuatia-muted)]">
                <li>{plan.maxProducts} productos</li>
                <li>{plan.rateLimitRpm} rpm</li>
                <li>{plan.monthlyTxQuota.toLocaleString('es-AR')} tx/mes</li>
              </ul>
              {!isCurrent && plan.id !== 'free' ? (
                <Button
                  className="mt-5 w-full"
                  disabled={pending === plan.id}
                  onClick={() => void checkout(String(plan.id))}
                >
                  {pending === plan.id ? '…' : `Elegir ${plan.label ?? plan.id}`}
                </Button>
              ) : null}
            </Panel>
          )
        })}
      </div>
    </div>
  )
}
