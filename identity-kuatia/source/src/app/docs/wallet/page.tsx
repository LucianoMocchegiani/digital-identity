import { DocsCode, DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import { mailtoSales, siteConfig, walletDownloadHref } from '@/shared/config/site'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('wallet')

/**
 * Wallet Kuatia + wallet en la app del cliente.
 */
export default function DocsWalletPage() {
  const hasAndroid = Boolean(siteConfig.walletAndroidUrl)
  const hasIos = Boolean(siteConfig.walletIosUrl)

  return (
    <>
      <DocsTitle>Wallet</DocsTitle>
      <DocsLead>
        App para que los titulares acepten, guarden y presenten credenciales emitidas y verificadas
        con Kuatia.
      </DocsLead>

      <DocsH2>Wallet Kuatia</DocsH2>
      <DocsP>
        Aplicación lista para ofertas (OID4VCI), guardado y presentación (OID4VP) frente a issuer y
        verifier Kuatia.
      </DocsP>

      <DocsH2>Descargar</DocsH2>
      {hasAndroid || hasIos ? (
        <DocsUl>
          {hasAndroid ? (
            <li>
              <a
                href={siteConfig.walletAndroidUrl}
                className="text-[var(--kuatia-accent)] hover:underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                Android
              </a>
            </li>
          ) : null}
          {hasIos ? (
            <li>
              <a
                href={siteConfig.walletIosUrl}
                className="text-[var(--kuatia-accent)] hover:underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                iOS
              </a>
            </li>
          ) : null}
        </DocsUl>
      ) : (
        <DocsP>
          Los enlaces de tienda se publicarán cuando estén disponibles. Mientras tanto, solicitá
          acceso:{' '}
          <a href={walletDownloadHref('any')} className="text-[var(--kuatia-accent)] hover:underline">
            {siteConfig.contactEmail}
          </a>
          .
        </DocsP>
      )}

      <DocsH2>Wallet en tu app</DocsH2>
      <DocsP>
        Si preferís no usar la app Kuatia, podés llevar la wallet dentro de tu producto: tu app
        mantiene login, UI y negocio; en el dispositivo se aceptan ofertas y se presentan
        credenciales contra Kuatia (OpenID4VC).
      </DocsP>
      <DocsUl>
        <li>Entrada por QR o deep link (offer URI / request URI)</li>
        <li>Claves del titular en el dispositivo</li>
        <li>Misma metadata y VCT que publica tu issuer</li>
      </DocsUl>
      <DocsP>
        Podés integrarla con librerías del ecosistema SSI / OpenID4VC, o pedir que el equipo de
        Kuatia la implemente:{' '}
        <a
          href={mailtoSales('Integración wallet en app')}
          className="text-[var(--kuatia-accent)] hover:underline"
        >
          {siteConfig.salesEmail}
        </a>
        .
      </DocsP>

      <DocsH2>Emisión y verificación</DocsH2>
      <DocsP>
        Desde tu backend:{' '}
        <Link href="/docs/emitir" className="text-[var(--kuatia-accent)] hover:underline">
          Emitir
        </Link>
        ,{' '}
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          Verificar
        </Link>
        . Prueba en consola:{' '}
        <Link href="/docs/empezar" className="text-[var(--kuatia-accent)] hover:underline">
          Primera credencial
        </Link>
        .
      </DocsP>

      <DocsH2>Responsabilidades</DocsH2>
      <DocsCode>{`Kuatia (cloud)  → issuer / verifier / API keys / cupos
Wallet Kuatia   → app para titulares (opcional)
Tu producto     → negocio, UX y, si aplica, wallet propia
Tu backend      → claims, cuándo emitir, qué exigir al verificar`}</DocsCode>
    </>
  )
}
