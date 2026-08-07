/**
 * Landing pública de Kuatia: hero, casos, estándares, precios y CTA.
 */
import { Atmosphere } from '@/design-system'
import { FeatureStrip } from './FeatureStrip'
import { FinalCta } from './FinalCta'
import { Hero } from './Hero'
import { MarketingHeader } from './MarketingHeader'
import { Pricing } from './Pricing'
import { SiteFooter } from './SiteFooter'
import { Standards } from './Standards'
import { UseCases } from './UseCases'

/** Composición completa de la home de marketing. */
export function LandingPage() {
  return (
    <div className="relative min-h-screen overflow-hidden bg-[var(--kuatia-bg)] text-[var(--kuatia-text)]">
      <Atmosphere />
      <div className="relative">
        <MarketingHeader />
        <Hero />
        <FeatureStrip />
        <UseCases />
        <Standards />
        <Pricing />
        <FinalCta />
        <SiteFooter />
      </div>
    </div>
  )
}
