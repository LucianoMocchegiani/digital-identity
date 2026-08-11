import {
  Badge,
  Button,
  CheckList,
  IconBolt,
  IconBuilding,
  IconProducts,
  IconRocket,
} from '@/design-system'
import { mailto } from '@/shared/config/site'
import Link from 'next/link'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const plans: {
  id: string
  name: string
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
    name: 'Free',
    price: '$0 / mes',
    features: [
      '2 productos (issuer o verifier)',
      '30 solicitudes / min',
      '5.000 transacciones / mes',
      'API REST',
      'Soporte por email',
    ],
    cta: 'Empezar gratis',
    href: '/register',
    Icon: IconProducts,
    variant: 'secondary',
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 'Plan pago',
    features: [
      '5 productos',
      '600 solicitudes / min',
      '100.000 transacciones / mes',
      'API REST',
      'Provision issuer / verifier',
      'Soporte prioritario',
    ],
    cta: 'Elegir Pro',
    href: '/register',
    highlight: true,
    Icon: IconRocket,
    variant: 'primary',
  },
  {
    id: 'pro_double',
    name: 'Pro Double',
    price: 'Plan pago',
    features: [
      '10 productos',
      '1.200 solicitudes / min',
      '200.000 transacciones / mes',
      'API REST',
      'Provision issuer / verifier',
      'Soporte prioritario',
    ],
    cta: 'Elegir Pro Double',
    href: '/register',
    Icon: IconBolt,
    variant: 'secondary',
  },
  {
    id: 'business',
    name: 'Business',
    price: 'A medida',
    features: [
      'Cupos de productos, RPM y TX a medida',
      'Overrides según tu operación',
      'Onboarding asistido',
      'Soporte dedicado',
      'API REST',
    ],
    cta: 'Contactar ventas',
    href: mailto('Plan Business'),
    Icon: IconBuilding,
    variant: 'secondary',
  },
]

/** Planes Free / Pro / Pro Double / Business. */
export function Pricing() {
  return (
    <MarketingShell as="section" id="precios" className="py-20">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
            Planes
          </h2>
          <p className="mt-3 max-w-xl text-base text-[var(--kuatia-muted)] sm:text-lg">
            Un producto es un issuer o un verifier. Todos los planes incluyen API REST.
          </p>
        </div>
        <Badge tone="accent">Sin permanencia · Cancelá cuando quieras</Badge>
      </div>
      <div className="mt-10 grid gap-5 sm:grid-cols-2 xl:grid-cols-4 lg:gap-6">
        {plans.map((plan) => (
          <div
            key={plan.id}
            className={
              plan.highlight
                ? 'relative rounded-2xl border border-[var(--kuatia-accent)]/60 bg-[var(--kuatia-panel)] p-6 lg:p-7'
                : 'rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/50 p-6 lg:p-7'
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
            <h3 className="mt-3 font-display text-2xl xl:text-3xl">{plan.name}</h3>
            <p className="mt-1 text-lg font-semibold text-[var(--kuatia-accent)] xl:text-xl">
              {plan.price}
            </p>
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
