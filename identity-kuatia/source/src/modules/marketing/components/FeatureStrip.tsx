import { IconShield, IconTicket, IconUsers } from '@/design-system'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const items: { title: string; body: string; Icon: IconComp }[] = [
  {
    title: 'OpenID4VC',
    body: 'Estándar abierto para credenciales verificables y portables.',
    Icon: IconShield,
  },
  {
    title: 'Eventos',
    body: 'Entradas seguras, transferibles y antifraude para shows, ferias y accesos.',
    Icon: IconTicket,
  },
  {
    title: 'Organizaciones',
    body: 'Empresas, instituciones, clubes y centros deportivos: membresías y acceso.',
    Icon: IconUsers,
  },
]

/** Franja de tres pilares bajo el hero. */
export function FeatureStrip() {
  return (
    <MarketingShell as="section" className="pb-20">
      <div className="grid gap-6 rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/60 p-6 md:grid-cols-3 md:gap-0 md:divide-x md:divide-[var(--kuatia-border)] md:p-8 lg:p-10">
        {items.map(({ title, body, Icon }) => (
          <div key={title} className="md:px-8 first:md:pl-4 last:md:pr-4">
            <div className="mb-3 grid h-10 w-10 place-items-center rounded-lg bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)]">
              <Icon size={20} />
            </div>
            <h2 className="font-display text-xl font-semibold lg:text-2xl">{title}</h2>
            <p className="mt-2 max-w-md text-base leading-relaxed text-[var(--kuatia-muted)] lg:text-lg">
              {body}
            </p>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
