/**
 * Ruta `/login` — ingreso a la consola con email/contraseña (billing).
 */
import { LoginForm } from '@/modules/auth/components/LoginForm'
import { buildPageMetadata } from '@/shared/seo/site'

export const metadata = buildPageMetadata({
  title: 'Ingresar',
  description: 'Ingresá a la consola Kuatia para gestionar productos, API keys y uso.',
  path: '/login',
  noIndex: true,
})

export default function LoginPage() {
  return <LoginForm />
}
