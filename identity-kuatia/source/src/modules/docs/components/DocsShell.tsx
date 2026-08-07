import { Atmosphere } from '@/design-system'
import { DocsPager } from '@/modules/docs/components/DocsPager'
import { DocsSidebar } from '@/modules/docs/components/DocsSidebar'
import { MarketingHeader } from '@/modules/marketing/components/MarketingHeader'
import { MarketingShell } from '@/modules/marketing/components/MarketingShell'
import { SiteFooter } from '@/modules/marketing/components/SiteFooter'
import type { ReactNode } from 'react'

/**
 * Shell de documentación: header + sidebar + artículo + pager.
 */
export function DocsShell({ children }: { children: ReactNode }) {
  return (
    <div className="relative min-h-screen overflow-hidden bg-[var(--kuatia-bg)] text-[var(--kuatia-text)]">
      <Atmosphere />
      <div className="relative z-10 flex min-h-screen flex-col">
        <MarketingHeader homeAnchors />
        <MarketingShell className="flex-1 pb-16 pt-4 sm:pt-6">
          <div className="lg:flex lg:items-start lg:gap-10 xl:gap-14">
            <DocsSidebar />
            <article className="min-w-0 flex-1 pb-8">
              {children}
              <DocsPager />
            </article>
          </div>
        </MarketingShell>
        <SiteFooter />
      </div>
    </div>
  )
}
