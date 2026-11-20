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
        App y wallet web para que los titulares acepten, guarden y presenten credenciales emitidas y
        verificadas con Kuatia.
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

      <DocsH2>Wallet web</DocsH2>
      <DocsP>
        También podés usar la{' '}
        <a
          href="https://wallet.kuatia.xyz"
          className="text-[var(--kuatia-accent)] hover:underline"
          target="_blank"
          rel="noopener noreferrer"
        >
          wallet web de Kuatia
        </a>
        , sin instalar una aplicación. En la consola, dentro de{' '}
        <code className="text-sm">Credenciales</code>, el emisor crea una oferta y el verifier crea
        una solicitud. Kuatia muestra para cada operación un QR original para wallets compatibles
        y otro QR que abre la wallet web con la operación cargada.
      </DocsP>
      <DocsP>
        Escaneá el QR para wallet web con la cámara del teléfono: las ofertas abren{' '}
        <code className="text-sm">/issue</code> y las solicitudes{' '}
        <code className="text-sm">/present</code>, listas para revisar. El titular siempre debe
        aceptar la emisión o elegir la credencial y confirmar qué comparte; escanear el QR no acepta
        ni envía datos automáticamente.
      </DocsP>
      <DocsP>
        Si integrás tu propio sistema, convertí la <code className="text-sm">offerUri</code> a{' '}
        <code className="text-sm">https://wallet.kuatia.xyz/issue</code> y la{' '}
        <code className="text-sm">requestUri</code> a{' '}
        <code className="text-sm">https://wallet.kuatia.xyz/present</code>, conservando los
        parámetros de consulta, y generá el QR con el enlace HTTPS completo. La consola de Kuatia ya
        hace esta conversión. Encontrás los pasos en las guías de{' '}
        <Link href="/docs/emitir" className="text-[var(--kuatia-accent)] hover:underline">
          emisión
        </Link>{' '}
        y{' '}
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          verificación
        </Link>
        .
      </DocsP>
      <DocsP>
        La clave del titular y las credenciales se guardan cifradas en el almacenamiento del
        navegador de ese dispositivo. Si se borran los datos del sitio o se pierde acceso al
        dispositivo, no hay recuperación ni copia de seguridad. Es una versión experimental: no
        uses credenciales reales.
      </DocsP>

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
Wallet Kuatia   → app y web para titulares (opcional)
Tu producto     → negocio, UX y, si aplica, wallet propia
Tu backend      → claims, cuándo emitir, qué exigir al verificar`}</DocsCode>
    </>
  )
}
