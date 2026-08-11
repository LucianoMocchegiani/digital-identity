/**
 * Landing pública de Kuatia: hero, casos, estándares, precios y CTA.
 */
import { Atmosphere } from '@/design-system'
import { siteConfig } from '@/shared/config/site'
import { JsonLd } from '@/shared/seo/JsonLd'
import { FeatureStrip } from './FeatureStrip'
import { FinalCta } from './FinalCta'
import { Hero } from './Hero'
import { MarketingHeader } from './MarketingHeader'
import { Pricing } from './Pricing'
import { SiteFooter } from './SiteFooter'
import { Standards } from './Standards'
import { UseCases } from './UseCases'

/** Schema.org: Organization + WebSite (sin “offers” de checkout). */
const landingJsonLd = [
  {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: siteConfig.name,
    url: siteConfig.url,
    email: siteConfig.contactEmail,
    description: siteConfig.description,
  },
  {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: siteConfig.name,
    url: siteConfig.url,
    inLanguage: siteConfig.locale,
    description: siteConfig.description,
  },
]

/** Composición completa de la home de marketing. */
export function LandingPage() {
  return (
    <div className="relative min-h-screen overflow-hidden bg-[var(--kuatia-bg)] text-[var(--kuatia-text)]">
      <JsonLd data={landingJsonLd} />
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
