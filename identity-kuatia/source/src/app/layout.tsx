/**
 * Layout raíz de la app: fuentes, metadata SEO, tema y `AuthProvider`.
 */
import { AuthProvider } from '@/shared/auth/AuthProvider'
import { ThemeProvider } from '@/shared/theme/ThemeProvider'
import type { Metadata } from 'next'
import { DM_Sans, Syne } from 'next/font/google'
import './globals.css'

const body = DM_Sans({
  subsets: ['latin'],
  variable: '--font-body',
})

const display = Syne({
  subsets: ['latin'],
  variable: '--font-display',
})

/** Metadata por defecto del sitio Kuatia. */
export const metadata: Metadata = {
  title: 'Kuatia — Credenciales digitales',
  description:
    'Emití y verificá documentos, entradas a eventos y membresías con OpenID4VC.',
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
