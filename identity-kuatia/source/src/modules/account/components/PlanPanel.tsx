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
import { mailtoSales } from '@/shared/config/site'
import type { PlanInfo } from '@/shared/types/billing'
import { useEffect, useState } from 'react'

function planFeatures(plan: PlanInfo): string[] {
  if (plan.id === 'business') {
    return [
      'Instalación en tu servidor o red',
      'Despliegue asistido (gobiernos y grandes orgs)',
      'Cupos, SLA y soporte acordados',
    ]
  }
  if (plan.id === 'pro_double') {
    return [
      `Hasta ${plan.maxProducts} productos`,
      `${plan.rateLimitRpm.toLocaleString('es-AR')} solicitudes / min`,
      `${plan.monthlyTxQuota.toLocaleString('es-AR')} transacciones / mes`,
    ]
  }
  return [
    `${plan.maxProducts} productos`,
    `${plan.rateLimitRpm.toLocaleString('es-AR')} solicitudes / min`,
    `${plan.monthlyTxQuota.toLocaleString('es-AR')} transacciones / mes`,
  ]
}

/** Siguiente upgrade sugerido según el plan actual. */
function suggestedUpgrade(planId: string | undefined): 'pro' | 'pro_double' | null {
  if (planId === 'free') return 'pro'
  if (planId === 'pro') return 'pro_double'
  return null
}

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
  const upgradeId = suggestedUpgrade(account?.plan)
  const upgradePlan = upgradeId ? plans.find((p) => p.id === upgradeId) : undefined

  return (
    <div>
      <PageHeader
        title="Plan"
        description={
          account ? (
            <>
              Tu plan actual:{' '}
              <Badge tone="accent" className="align-middle">
                {current?.label ?? account.plan}
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
              items={
                account?.plan === 'business'
                  ? [
                      `${account.maxProducts} productos (acordado)`,
                      `${account.rateLimitRpm.toLocaleString('es-AR')} solicitudes / min`,
                      `${account.monthlyTxQuota.toLocaleString('es-AR')} transacciones / mes`,
                    ]
                  : planFeatures(current)
              }
            />
          </div>
          {upgradePlan && upgradeId ? (
            <div className="rounded-2xl border border-[var(--kuatia-accent)]/40 bg-[var(--kuatia-accent)]/10 p-5 lg:max-w-xs">
              <p className="font-medium">Mejorá tu experiencia</p>
              <p className="mt-1 text-sm text-[var(--kuatia-muted)]">
                Pasá a {upgradePlan.label ?? upgradeId}: más productos, más solicitudes/min y más
                cuota mensual.
              </p>
              <Button
                className="mt-4 w-full"
                size="lg"
                disabled={pending === upgradeId}
                onClick={() => void checkout(upgradeId)}
              >
                {pending === upgradeId ? '…' : `Mejorar a ${upgradePlan.label ?? upgradeId}`}
              </Button>
            </div>
          ) : null}
        </Panel>
      ) : null}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {plans.map((plan) => {
          const isCurrent = account?.plan === plan.id
          return (
            <Panel key={plan.id} className={isCurrent ? 'border-[var(--kuatia-accent)]/50' : undefined}>
              <div className="flex items-center justify-between gap-2">
                <h3 className="font-display text-2xl">{plan.label ?? plan.id}</h3>
                {isCurrent ? <Badge tone="accent">Actual</Badge> : null}
              </div>
              <ul className="mt-4 space-y-2 text-base text-[var(--kuatia-muted)]">
                {planFeatures(plan).map((line) => (
                  <li key={line}>{line}</li>
                ))}
              </ul>
              {!isCurrent && plan.id === 'business' ? (
                <a href={mailtoSales('Kuatia dedicado / on-prem')} className="mt-5 block">
                  <Button className="w-full" variant="secondary">
                    Contactar ventas
                  </Button>
                </a>
              ) : null}
              {!isCurrent && plan.id !== 'free' && plan.id !== 'business' ? (
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
