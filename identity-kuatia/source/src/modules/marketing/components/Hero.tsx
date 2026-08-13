import { Button, IconArrowRight, IconCalendar, PhoneFrame } from '@/design-system'
import { mailto } from '@/shared/config/site'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'
import { WalletHomeMock } from './WalletHomeMock'

/** Primer viewport: necesidad (privacidad / identidad) + phone. */
export function Hero() {
  return (
    <MarketingShell
      as="section"
      className="grid items-center gap-12 pb-16 pt-10 md:grid-cols-2 md:gap-16 md:pb-24 md:pt-16 xl:gap-20"
    >
      <div className="relative z-10">
        <p className="font-display text-2xl font-semibold tracking-tight text-[var(--kuatia-accent)] sm:text-3xl md:text-4xl">
          Kuatia
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold leading-[1.08] tracking-tight text-[var(--kuatia-text)] sm:text-5xl md:text-6xl lg:text-7xl xl:text-[5.25rem]">
          Privacidad para tus usuarios. Identidad sin fraude.
        </h1>
        <p className="mt-5 max-w-xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:mt-6 sm:text-lg md:text-xl lg:text-2xl">
          Una forma segura de saber quién es quién — sin pedir datos de más, sin presentar 20
          documentos, sin links engañosos, sin reenviar archivos que cualquiera puede copiar. Emití
          afirmaciones firmadas; el titular las guarda en su wallet.
        </p>
        <div className="mt-10 flex flex-wrap gap-4">
          <Link href="/register">
            <Button size="lg">
              Empezar gratis
              <IconArrowRight size={18} />
            </Button>
          </Link>
          <a href={mailto('Demo Kuatia')}>
            <Button size="lg" variant="secondary">
              <IconCalendar size={18} />
              Reservar demo
            </Button>
          </a>
        </div>
      </div>

      <PhoneFrame className="xl:max-w-[320px]" padded={false}>
        <WalletHomeMock />
      </PhoneFrame>
    </MarketingShell>
  )
}
