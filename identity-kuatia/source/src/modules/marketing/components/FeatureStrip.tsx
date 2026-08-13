import { IconShield, IconTicket, IconUsers } from '@/design-system'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const items: { title: string; body: string; Icon: IconComp }[] = [
  {
    title: 'Privacidad del titular',
    body: 'La credencial vive en su wallet. Vos verificás la prueba — no acumulás una copia central de su identidad.',
    Icon: IconShield,
  },
  {
    title: 'Acceso y eventos',
    body: 'Membresías, pases y entradas firmadas. Validación en puerta con QR o deep link.',
    Icon: IconTicket,
  },
  {
    title: 'Organizaciones',
    body: 'Acreditaciones, roles y acceso a instalaciones para empresas, clubes e instituciones.',
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
