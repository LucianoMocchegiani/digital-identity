import {
  CheckList,
  CredentialCard,
  IconDoc,
  IconTicket,
  IconUsers,
  SectionEyebrow,
  type CredentialCardPreset,
} from '@/design-system'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const cases: {
  title: string
  subtitle: string
  Icon: IconComp
  bullets: string[]
  preset: CredentialCardPreset
}[] = [
  {
    title: 'Acreditaciones',
    subtitle: 'Certificados y habilitaciones',
    Icon: IconDoc,
    bullets: [
      'Afirmaciones firmadas por tu organización',
      'El titular revela solo lo necesario',
      'Revocación cuando el caso lo pide',
    ],
    preset: 'operator',
  },
  {
    title: 'Eventos',
    subtitle: 'Entradas con QR',
    Icon: IconTicket,
    bullets: [
      'Entrada firmada, no una captura',
      'QR o deep link para la wallet',
      'Control de acceso en puerta',
    ],
    preset: 'ticket',
  },
  {
    title: 'Organizaciones',
    subtitle: 'Empresas, clubes e instituciones',
    Icon: IconUsers,
    bullets: [
      'Membresía o carnet verificable',
      'Beneficios y accesos asociados',
      'Estado vigente al momento del control',
    ],
    preset: 'membership',
  },
]

/** Casos de uso: copy + credencial suelta (sin marco de teléfono). */
export function UseCases() {
  return (
    <MarketingShell as="section" id="producto" className="py-20">
      <SectionEyebrow>Un solo modelo</SectionEyebrow>
      <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
        Un solo modelo de credencial
      </h2>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-lg lg:text-xl">
        El mismo flujo OpenID4VC sirve para certificados, entradas, membresías y accesos. Tu backend
        emite o pide una prueba; la wallet del usuario completa el protocolo; el verifier valida el
        resultado.
      </p>
      <div className="mt-12 grid gap-10 md:grid-cols-3 lg:gap-12">
        {cases.map((c) => (
          <div key={c.title}>
            <div className="mb-3 grid h-10 w-10 place-items-center rounded-lg border border-[var(--kuatia-accent)]/40 text-[var(--kuatia-accent)]">
              <c.Icon size={20} />
            </div>
            <h3 className="font-display text-2xl font-semibold lg:text-3xl">{c.title}</h3>
            <p className="mt-1 text-base text-[var(--kuatia-accent)]">{c.subtitle}</p>
            <CheckList items={c.bullets} />
            <div className="mt-6 max-w-[280px]">
              <CredentialCard preset={c.preset} />
            </div>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
