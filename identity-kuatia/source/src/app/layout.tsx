/**
 * Layout raíz de la app: fuentes, metadata SEO, tema y `AuthProvider`.
 */
import { AuthProvider } from '@/shared/auth/AuthProvider'
import {
  DEFAULT_DESCRIPTION,
  SITE_NAME,
  SITE_URL,
  SOCIAL_DESCRIPTION,
} from '@/shared/seo/site'
import { ThemeProvider } from '@/shared/theme/ThemeProvider'
import type { Metadata, Viewport } from 'next'
import { DM_Sans, Syne } from 'next/font/google'
import './globals.css'

const body = DM_Sans({
  subsets: ['latin'],
  variable: '--font-body',
  display: 'swap',
})

const display = Syne({
  subsets: ['latin'],
  variable: '--font-display',
  display: 'swap',
})

/** Metadata por defecto del sitio Kuatia. */
export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: `${SITE_NAME} — Credenciales digitales`,
    template: `%s — ${SITE_NAME}`,
  },
  description: DEFAULT_DESCRIPTION,
  applicationName: SITE_NAME,
  keywords: [
    'Kuatia',
    'credenciales digitales',
    'OpenID4VC',
    'verifiable credentials',
    'issuer',
    'verifier',
    'SD-JWT',
  ],
  authors: [{ name: SITE_NAME, url: SITE_URL }],
  creator: SITE_NAME,
  openGraph: {
    type: 'website',
    locale: 'es',
    url: SITE_URL,
    siteName: SITE_NAME,
    title: `${SITE_NAME} — Credenciales digitales`,
    description: SOCIAL_DESCRIPTION,
  },
  twitter: {
    card: 'summary_large_image',
    title: `${SITE_NAME} — Credenciales digitales`,
    description: SOCIAL_DESCRIPTION,
  },
  robots: {
    index: true,
    follow: true,
  },
  alternates: {
    canonical: SITE_URL,
  },
}

/** Viewport + theme-color (CWV / PWA-lite). */
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: [
    { media: '(prefers-color-scheme: dark)', color: '#050a10' },
    { media: '(prefers-color-scheme: light)', color: '#eef3f5' },
  ],
}

/** Evita flash de tema incorrecto antes de hidratar. */
const themeBootScript = `(function(){try{var t=localStorage.getItem('kuatia-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia('(prefers-color-scheme: light)').matches?'light':'dark';}document.documentElement.setAttribute('data-theme',t);}catch(e){document.documentElement.setAttribute('data-theme','dark');}})();`

/** HTML raíz con providers de sesión y tema. */
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="es" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeBootScript }} />
      </head>
      <body className={`${body.variable} ${display.variable} antialiased`}>
        <ThemeProvider>
          <AuthProvider>{children}</AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  )
}
