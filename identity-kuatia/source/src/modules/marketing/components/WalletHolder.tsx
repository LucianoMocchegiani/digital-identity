import { Button, IconArrowRight, IconCredentials, SectionEyebrow } from '@/design-system'
import { mailto, siteConfig, walletDownloadHref } from '@/shared/config/site'
import { MarketingShell } from './MarketingShell'

/**
 * Wallet Kuatia: descarga / solicitud de acceso.
 */
export function WalletHolder() {
  const hasAndroid = Boolean(siteConfig.walletAndroidUrl)
  const hasIos = Boolean(siteConfig.walletIosUrl)
  const hasStore = hasAndroid || hasIos

  return (
    <MarketingShell as="section" id="wallet" className="py-20">
      <SectionEyebrow>Wallet</SectionEyebrow>
      <h2 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl xl:text-6xl">
        Wallet Kuatia
      </h2>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-lg lg:text-xl">
        App para que los titulares acepten, guarden y presenten credenciales.
      </p>

      <div className="mt-10">
        <div className="mb-3 grid h-10 w-10 place-items-center rounded-lg border border-[var(--kuatia-accent)]/40 text-[var(--kuatia-accent)]">
          <IconCredentials size={20} />
        </div>
        <h3 className="font-display text-2xl font-semibold lg:text-3xl">Descargar</h3>
        <p className="mt-2 max-w-xl text-base leading-relaxed text-[var(--kuatia-muted)] lg:text-lg">
          Aplicación lista para ofertas, guardado y presentación de credenciales.
        </p>
        <div className="mt-6 flex flex-wrap gap-3">
          {hasAndroid ? (
            <a href={siteConfig.walletAndroidUrl} target="_blank" rel="noopener noreferrer">
              <Button size="lg">
                Android
                <IconArrowRight size={18} />
              </Button>
            </a>
          ) : null}
          {hasIos ? (
            <a href={siteConfig.walletIosUrl} target="_blank" rel="noopener noreferrer">
              <Button size="lg" variant={hasAndroid ? 'secondary' : 'primary'}>
                iOS
                <IconArrowRight size={18} />
              </Button>
            </a>
          ) : null}
          {!hasStore ? (
            <a href={walletDownloadHref('any')}>
              <Button size="lg">
                Solicitar acceso
                <IconArrowRight size={18} />
              </Button>
            </a>
          ) : null}
          {hasStore && (!hasAndroid || !hasIos) ? (
            <a href={mailto('Wallet Kuatia — acceso')}>
              <Button size="lg" variant="secondary">
                Otra plataforma
              </Button>
            </a>
          ) : null}
        </div>
      </div>
    </MarketingShell>
  )
}
