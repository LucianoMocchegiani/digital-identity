import { BrandMark } from '@/design-system'
import { mailto, siteConfig } from '@/shared/config/site'
import Link from 'next/link'
import { MarketingShell } from './MarketingShell'

/** Pie de sitio: productos, developer y contacto. */
export function SiteFooter() {
  return (
    <footer className="mt-8 border-t border-[var(--kuatia-border)]">
      <MarketingShell className="grid gap-10 py-12 md:grid-cols-2 lg:grid-cols-4">
        <div className="lg:col-span-1">
          <BrandMark size="sm" />
          <p className="mt-3 max-w-xs text-base text-[var(--kuatia-muted)]">
            Emisión y verificación de credenciales digitales para documentos, eventos y
            organizaciones.
          </p>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Productos
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>Issuer (emisor)</li>
            <li>Verifier (verificador)</li>
          </ul>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Developer
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>
              <Link href="/docs" className="hover:text-[var(--kuatia-accent)]">
                Documentación
              </Link>
            </li>
            <li>
              <Link href="/docs/empezar" className="hover:text-[var(--kuatia-accent)]">
                Primeros pasos
              </Link>
            </li>
            <li>
              <Link href="/docs/glosario" className="hover:text-[var(--kuatia-accent)]">
                Glosario
              </Link>
            </li>
            <li>
              <Link href="/docs/seguridad" className="hover:text-[var(--kuatia-accent)]">
                Seguridad
              </Link>
            </li>
            <li>
              <Link href="/docs/changelog" className="hover:text-[var(--kuatia-accent)]">
                Changelog
              </Link>
            </li>
          </ul>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Contacto
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>
              <a href={mailto()} className="hover:text-[var(--kuatia-accent)]">
                {siteConfig.contactEmail}
              </a>
            </li>
          </ul>
        </div>
      </MarketingShell>
      <div className="border-t border-[var(--kuatia-border-subtle)] py-4 text-center text-sm text-[var(--kuatia-muted)]">
        © {new Date().getFullYear()} Kuatia
      </div>
    </footer>
  )
}
