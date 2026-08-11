import { Button, IconArrowRight, IconBolt, IconCode } from '@/design-system'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'

/** CTA final antes del footer. */
export function FinalCta() {
  return (
    <MarketingShell as="section" className="py-16">
      <div className="relative overflow-hidden rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/70 px-6 py-8 md:flex-row md:items-center md:px-10 lg:px-14 lg:py-12">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 opacity-30"
          style={{
            backgroundImage:
              'radial-gradient(ellipse 50% 80% at 0% 50%, rgba(0,168,157,0.25), transparent), linear-gradient(90deg, transparent, rgba(0,168,157,0.06))',
          }}
        />
        <div className="relative flex flex-col items-start justify-between gap-6 md:flex-row md:items-center">
          <div className="flex items-start gap-4">
            <span className="grid h-14 w-14 shrink-0 place-items-center rounded-full border border-[var(--kuatia-accent)]/40 bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)]">
              <IconBolt size={26} />
            </span>
            <div>
              <h2 className="font-display text-2xl font-semibold sm:text-3xl md:text-4xl xl:text-5xl">
                Empezá a emitir hoy
              </h2>
              <p className="mt-3 max-w-xl text-base text-[var(--kuatia-muted)] sm:text-lg">
                Creá una cuenta Free, provisioná un issuer o verifier y obtené tu API key.
              </p>
            </div>
          </div>
          <div className="flex flex-wrap gap-3">
            <Link href="/register">
              <Button size="lg">
                Empezar gratis
                <IconArrowRight size={18} />
              </Button>
            </Link>
            <Link href="/docs">
              <Button size="lg" variant="secondary">
                <IconCode size={18} />
                Ver docs
              </Button>
            </Link>
          </div>
        </div>
      </div>
    </MarketingShell>
  )
}
