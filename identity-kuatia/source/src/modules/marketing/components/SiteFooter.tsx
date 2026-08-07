import { BrandMark } from '@/design-system'
import { MarketingShell } from './MarketingShell'

const CONTACT_EMAIL = 'hola@kuatia.xyz'
const CONTACT_PHONE = '+595 21 000 000'

/** Pie de sitio: productos, developer y contacto. */
export function SiteFooter() {
  return (
    <footer className="mt-8 border-t border-white/10">
      <MarketingShell className="grid gap-10 py-12 md:grid-cols-2 lg:grid-cols-4">
        <div className="lg:col-span-1">
          <BrandMark size="sm" />
          <p className="mt-3 max-w-xs text-base text-[var(--kuatia-muted)]">
            Credenciales digitales para documentos, eventos y organizaciones.
          </p>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Productos
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>Issuer</li>
            <li>Verifier</li>
          </ul>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Developer
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>
              <a href="#estandares" className="hover:text-[var(--kuatia-accent)]">
                Docs
              </a>
            </li>
            <li>
              <a href="#estandares" className="hover:text-[var(--kuatia-accent)]">
                API
              </a>
            </li>
          </ul>
        </div>
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-[var(--kuatia-muted)]">
            Contacto
          </p>
          <ul className="mt-3 space-y-2 text-base text-[var(--kuatia-text)]/80">
            <li>
              <a href={`mailto:${CONTACT_EMAIL}`} className="hover:text-[var(--kuatia-accent)]">
                {CONTACT_EMAIL}
              </a>
            </li>
            <li>
              <a href={`tel:${CONTACT_PHONE.replace(/\s/g, '')}`} className="hover:text-[var(--kuatia-accent)]">
                {CONTACT_PHONE}
              </a>
            </li>
          </ul>
        </div>
      </MarketingShell>
      <div className="border-t border-white/5 py-4 text-center text-sm text-[var(--kuatia-muted)]">
        © {new Date().getFullYear()} Kuatia
      </div>
    </footer>
  )
}
