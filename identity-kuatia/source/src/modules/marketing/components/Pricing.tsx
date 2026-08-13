import {
  Badge,
  Button,
  CheckList,
  IconBolt,
  IconBuilding,
  IconProducts,
  IconRocket,
} from '@/design-system'
import { mailtoSales, siteConfig } from '@/shared/config/site'
import Link from 'next/link'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const plans: {
  id: string
  name: string
  price: string
  blurb: string
  features: string[]
  cta: string
  href: string
  highlight?: boolean
  Icon: IconComp
  variant: 'primary' | 'secondary'
  external?: boolean
}[] = [
  {
    id: 'free',
    name: 'Free',
    price: '$0 / mes',
    blurb: 'Para probar el flujo y un primer caso de uso (issuer + verifier).',
    features: [
      '2 productos (issuer y/o verifier)',
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
    blurb: 'Para operar en producción con más volumen, con el mismo cupo de productos.',
    features: [
      '2 productos (issuer y/o verifier)',
      '600 solicitudes / min',
      '100.000 transacciones / mes',
      'API REST',
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
    name: 'Proveedores',
    price: 'Plan pago',
    blurb:
      'Para quien emite o verifica para varias marcas, clientes o líneas de negocio.',
    features: [
      'Hasta 10 productos (issuers y/o verifiers)',
      '1.200 solicitudes / min',
      '200.000 transacciones / mes',
      'API REST',
      'Soporte prioritario',
    ],
    cta: 'Elegir Proveedores',
    href: '/register',
    Icon: IconBolt,
    variant: 'secondary',
  },
  {
    id: 'dedicated',
    name: 'Dedicado',
    price: 'A medida',
    blurb:
      'Ideal para gobiernos y organizaciones que necesitan el servicio en su propia infraestructura.',
    features: [
      'Instalación en tu servidor o red',
      'Despliegue asistido como hacen las grandes empresas',
      'Cupos, SLA y soporte acordados',
      'Pensado para requisitos de soberanía y compliance',
    ],
    cta: 'Contactar ventas',
    href: mailtoSales('Kuatia dedicado / on-prem'),
    Icon: IconBuilding,
    variant: 'secondary',
    external: true,
  },
]

/** Planes Free / Pro / Proveedores + card dedicado (on-prem). */
export function Pricing() {
  return (
    <MarketingShell as="section" id="precios" className="py-20">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
            Planes
          </h2>
          <p className="mt-3 max-w-2xl text-base text-[var(--kuatia-muted)] sm:text-lg">
            Elegí según tu volumen y cuántos{' '}
            <Link href="/docs/issuer" className="text-[var(--kuatia-accent)] hover:underline">
              issuers
            </Link>{' '}
            y{' '}
            <Link href="/docs/verifier" className="text-[var(--kuatia-accent)] hover:underline">
              verifiers
            </Link>{' '}
            necesitás. Los planes cloud se miden en productos, solicitudes por minuto y
            transacciones de API. Si preferís operar en tu propia infraestructura, mirá Dedicado.
          </p>
        </div>
        <Badge tone="accent">Cloud sin permanencia</Badge>
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
            <p className="mt-3 text-sm leading-relaxed text-[var(--kuatia-muted)] lg:text-base">
              {plan.blurb}
            </p>
            <CheckList items={plan.features} />
            {plan.id === 'dedicated' ? (
              <div className="mt-6 space-y-3">
                <a href={plan.href} className="block">
                  <Button className="w-full" size="lg" variant={plan.variant}>
                    {plan.cta}
                  </Button>
                </a>
                <p className="text-center text-sm text-[var(--kuatia-muted)]">
                  <a
                    href={mailtoSales('Kuatia dedicado / on-prem')}
                    className="text-[var(--kuatia-accent)] hover:underline"
                  >
                    {siteConfig.salesEmail}
                  </a>
                </p>
              </div>
            ) : (
              <Link href={plan.href} className="mt-6 block">
                <Button className="w-full" size="lg" variant={plan.variant}>
                  {plan.cta}
                </Button>
              </Link>
            )}
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
