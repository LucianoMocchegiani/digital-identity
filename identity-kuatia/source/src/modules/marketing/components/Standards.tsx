import { IconCredentials, IconShield, SectionEyebrow } from '@/design-system'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'

const items = [
  {
    title: 'OpenID4VC',
    href: '/docs/glosario',
    body: 'Estándar abierto para emitir y presentar credenciales. Issuer, wallet y verifier hablan el mismo protocolo.',
    Icon: IconShield,
  },
  {
    title: 'SD-JWT VC',
    href: '/docs/glosario',
    body: 'Formato de credencial con divulgación selectiva: el titular puede revelar solo los campos necesarios.',
    Icon: IconCredentials,
  },
  {
    title: 'Revocación',
    href: '/docs/como-funciona',
    body: 'Invalidá credenciales cuando el caso lo requiere (membresía dada de baja, entrada cancelada).',
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
        Basado en protocolos abiertos para interoperar con wallets compatibles y evitar un formato
        propietario.{' '}
        <Link href="/docs" className="text-[var(--kuatia-accent)] hover:underline">
          Ver documentación →
        </Link>
      </p>
      <div className="mt-10 grid gap-8 md:grid-cols-3 lg:gap-12">
        {items.map(({ title, body, Icon, href }) => (
          <div key={title}>
            <div className="mb-4 text-[var(--kuatia-accent)]">
              <Icon size={36} />
            </div>
            <h3 className="text-lg font-semibold text-[var(--kuatia-accent)] lg:text-xl">
              <Link href={href} className="hover:underline">
                {title}
              </Link>
            </h3>
            <p className="mt-2 text-base leading-relaxed text-[var(--kuatia-muted)] lg:text-lg">{body}</p>
          </div>
        ))}
      </div>
    </MarketingShell>
  )
}
