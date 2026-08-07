import {
  Button,
  CredentialCard,
  IconArrowRight,
  IconCalendar,
  PhoneFrame,
} from '@/design-system'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'

/** Primer viewport: copy + phone wallet (fiel al mockup long-1). */
export function Hero() {
  return (
    <MarketingShell
      as="section"
      className="grid items-center gap-12 pb-16 pt-10 md:grid-cols-2 md:gap-16 md:pb-24 md:pt-16 xl:gap-20"
    >
      <div className="relative z-10">
        <h1 className="font-display text-4xl font-semibold leading-[1.08] tracking-tight text-[var(--kuatia-text)] sm:text-5xl md:text-6xl lg:text-7xl xl:text-[5.25rem]">
          Emití y verificá credenciales digitales
        </h1>
        <p className="mt-5 max-w-xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:mt-6 sm:text-lg md:text-xl lg:text-2xl">
          Documentos, entradas a eventos y membresías para empresas, instituciones y centros
          deportivos — con <span className="text-[var(--kuatia-accent)]">OpenID4VC</span>.
        </p>
        <div className="mt-10 flex flex-wrap gap-4">
          <Link href="/register">
            <Button size="lg">
              Empezar gratis
              <IconArrowRight size={18} />
            </Button>
          </Link>
          <a href="mailto:hola@kuatia.xyz?subject=Demo%20Kuatia">
            <Button size="lg" variant="secondary">
              <IconCalendar size={18} />
              Reservar demo
            </Button>
          </a>
        </div>
      </div>

      <PhoneFrame className="xl:max-w-[320px]">
        <div className="space-y-3">
          <CredentialCard
            variant="membership"
            eyebrow="Membresía"
            title="Atlántico FC"
            meta="Socio Platino · 2026"
          />
          <CredentialCard
            variant="ticket"
            eyebrow="Entrada"
            title="Live Night"
            meta="Campo VIP · Transferible"
          />
        </div>
      </PhoneFrame>
    </MarketingShell>
  )
}
