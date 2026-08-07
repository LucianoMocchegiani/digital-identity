import {
  Badge,
  Button,
  CheckList,
  IconBuilding,
  IconProducts,
  IconRocket,
} from '@/design-system'
import Link from 'next/link'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const plans: {
  id: string
  price: string
  features: string[]
  cta: string
  href: string
  highlight?: boolean
  Icon: IconComp
  variant: 'primary' | 'secondary'
}[] = [
  {
    id: 'free',
    price: '$0 /mes',
    features: ['2 productos', '30 rpm', '5.000 tx/mes', 'API REST', 'Soporte por email'],
    cta: 'Empezar gratis',
    href: '/register',
    Icon: IconProducts,
    variant: 'secondary',
  },
  {
    id: 'pro',
    price: 'Pro',
    features: [
      '5 productos',
      '600 rpm',
      '100.000 tx/mes',
      'API REST',
      'Provision issuer/verifier',
      'Soporte prioritario',
    ],
    cta: 'Elegir Pro',
    href: '/register',
    highlight: true,
    Icon: IconRocket,
    variant: 'primary',
  },
  {
    id: 'business',
    price: 'A medida',
    features: ['20 productos', '3.000 rpm', '1.000.000 tx/mes', 'Cupos custom', 'Onboarding asistido'],
    cta: 'Contactar ventas',
    href: 'mailto:hola@kuatia.xyz?subject=Plan%20Business',
    Icon: IconBuilding,
    variant: 'secondary',
  },
]

/** Planes Free / Pro / Business alineados al mockup. */
export function Pricing() {
  return (
    <MarketingShell as="section" id="precios" className="py-20">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
            Planes
          </h2>
          <p className="mt-3 text-base text-[var(--kuatia-muted)] sm:text-lg">
            El plan que mejor se adapta a tu negocio. Todos incluyen API REST.
          </p>
        </div>
        <Badge tone="accent">Sin permanencia · Cancelá cuando quieras</Badge>
      </div>
      <div className="mt-10 grid gap-5 md:grid-cols-3 lg:gap-8">
        {plans.map((plan) => (
          <div
            key={plan.id}
            className={
              plan.highlight
                ? 'relative rounded-2xl border border-[var(--kuatia-accent)]/60 bg-[var(--kuatia-panel)] p-6 lg:p-8'
                : 'rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/50 p-6 lg:p-8'
            }
          >
            {plan.highlight ? (
              <p className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full border border-[var(--kuatia-accent)]/50 bg-[var(--kuatia-bg)] px-3 py-0.5 text-sm font-medium uppercase tracking-wide text-[var(--kuatia-accent)]">
                Más elegido
              </p>
            ) : null}
            <div className="text-[var(--kuatia-accent)]">
              <plan.Icon size={28} />
            </div>
            <h3 className="mt-3 font-display text-3xl capitalize">{plan.id}</h3>
            <p className="mt-1 text-xl font-semibold text-[var(--kuatia-accent)]">{plan.price}</p>
            <CheckList items={plan.features} />
            <Link href={plan.href} className="mt-6 block">
              <Button className="w-full" size="lg" variant={plan.variant}>
                {plan.cta}
              </Button>
            </Link>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
