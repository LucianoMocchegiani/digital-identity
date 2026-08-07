/**
 * Layout raíz de la app: fuentes, metadata SEO y `AuthProvider` global.
 */
import { AuthProvider } from '@/shared/auth/AuthProvider'
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

/** HTML raíz con providers de sesión. */
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="es">
      <body className={`${body.variable} ${display.variable} antialiased`}>
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  )
}
