import { Atmosphere } from '@/design-system'
import { MarketingHeader } from '@/modules/marketing/components/MarketingHeader'
import type { ReactNode } from 'react'

/**
 * Marco de auth: atmósfera + mismo navbar marketing en login y register.
 */
export function AuthShell({
  title,
  subtitle,
  children,
  footer,
}: {
  title: string
  subtitle?: ReactNode
  children: ReactNode
  footer?: ReactNode
}) {
  return (
    <div className="relative min-h-screen overflow-hidden bg-[var(--kuatia-bg)]">
      <Atmosphere />
      <div className="relative z-10">
        <MarketingHeader homeAnchors />
        <div className="grid place-items-center px-4 pb-12 pt-4 sm:pt-8">
          <div className="w-full max-w-md md:max-w-lg">
            <div className="rounded-2xl border border-[var(--kuatia-accent)]/30 bg-[var(--kuatia-panel)]/90 p-5 shadow-2xl shadow-[var(--kuatia-accent)]/10 backdrop-blur sm:p-7 md:p-9">
              <h1 className="text-center font-display text-3xl font-semibold text-[var(--kuatia-text)] sm:text-4xl">
                {title}
              </h1>
              {subtitle ? (
                <div className="mt-2 text-center text-base text-[var(--kuatia-muted)] sm:text-lg">
                  {subtitle}
                </div>
              ) : null}
              <div className="mt-6 sm:mt-7">{children}</div>
              {footer ? (
                <div className="mt-6 border-t border-[var(--kuatia-border)] pt-5 text-center text-base text-[var(--kuatia-muted)]">
                  {footer}
                </div>
              ) : null}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
