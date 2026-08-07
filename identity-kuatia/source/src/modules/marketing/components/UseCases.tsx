import {
  CheckList,
  CredentialCard,
  IconDoc,
  IconTicket,
  IconUsers,
  PhoneFrame,
  SectionEyebrow,
} from '@/design-system'
import type { ComponentType, SVGProps } from 'react'
import { MarketingShell } from './MarketingShell'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

const cases: {
  title: string
  subtitle: string
  Icon: IconComp
  bullets: string[]
  card: { variant: 'document' | 'ticket' | 'membership'; eyebrow: string; title: string; meta: string }
}[] = [
  {
    title: 'Documentos',
    subtitle: 'DNI / certificados',
    Icon: IconDoc,
    bullets: [
      'Atributos oficiales verificables',
      'Presentación selectiva',
      'Validez y revocación en tiempo real',
    ],
    card: {
      variant: 'document',
      eyebrow: 'Documento',
      title: 'María Pérez',
      meta: 'Argentina · Válido',
    },
  },
  {
    title: 'Eventos',
    subtitle: 'Entradas con QR',
    Icon: IconTicket,
    bullets: [
      'Entrada segura verificable',
      'QR dinámico antifraude',
      'Control de acceso online/offline',
    ],
    card: {
      variant: 'ticket',
      eyebrow: 'Entrada',
      title: 'Rock en el Parque',
      meta: 'Campo · Transferible',
    },
  },
  {
    title: 'Organizaciones',
    subtitle: 'Empresas, instituciones y centros',
    Icon: IconUsers,
    bullets: [
      'Identidad de miembro verificable',
      'Beneficios y accesos asociados',
      'Estado y renovación en tiempo real',
    ],
    card: {
      variant: 'membership',
      eyebrow: 'Membresía',
      title: 'Club Atlético Norte',
      meta: 'Socio · Activo',
    },
  },
]

/** Casos de uso con bullets + phones (mockup mid). */
export function UseCases() {
  return (
    <MarketingShell as="section" id="producto" className="py-20">
      <SectionEyebrow>Un solo modelo</SectionEyebrow>
      <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
        Un solo modelo de credencial
      </h2>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-lg lg:text-xl">
        El mismo stack OpenID4VC se adapta a documentos, entradas y membresías. Vos emitís; la wallet
        guarda; el verifier valida en la puerta.
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
            <div className="mt-6">
              <PhoneFrame label={c.title} className="max-w-[240px]">
                <CredentialCard {...c.card} />
              </PhoneFrame>
            </div>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
