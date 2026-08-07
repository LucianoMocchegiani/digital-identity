import { IconCredentials, IconShield, SectionEyebrow } from '@/design-system'
import { MarketingShell } from './MarketingShell'

const items = [
  {
    title: 'OpenID4VC',
    body: 'Marco abierto para emisión y presentación de credenciales verificables.',
    Icon: IconShield,
  },
  {
    title: 'SD-JWT VC',
    body: 'Credenciales con privacidad por diseño y presentación selectiva.',
    Icon: IconCredentials,
  },
  {
    title: 'Trust management',
    body: 'Gestión de confianza y revocación alineada a tu issuer y verifier.',
    Icon: IconShield,
  },
]

/** Bloque de estándares abiertos. */
export function Standards() {
  return (
    <MarketingShell as="section" id="estandares" className="py-16">
      <SectionEyebrow>Interoperable por diseño</SectionEyebrow>
      <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
        Estándares abiertos
      </h2>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-lg lg:text-xl">
        Basado en estándares abiertos para máxima interoperabilidad y control del usuario.
      </p>
      <div className="mt-10 grid gap-8 md:grid-cols-3 lg:gap-12">
        {items.map(({ title, body, Icon }) => (
          <div key={title}>
            <div className="mb-4 text-[var(--kuatia-accent)]">
              <Icon size={36} />
            </div>
            <h3 className="text-lg font-semibold text-[var(--kuatia-accent)] lg:text-xl">{title}</h3>
            <p className="mt-2 text-base leading-relaxed text-[var(--kuatia-muted)] lg:text-lg">{body}</p>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
