/**
 * Ruta `/register` — alta de cuenta Free y acceso a la consola.
 */
import { RegisterForm } from '@/modules/auth/components/RegisterForm'
import { buildPageMetadata } from '@/shared/seo/site'

export const metadata = buildPageMetadata({
  title: 'Crear cuenta',
  description: 'Creá una cuenta Free en Kuatia y provisioná tu primer issuer o verifier.',
  path: '/register',
  noIndex: true,
})

export default function RegisterPage() {
  return <RegisterForm />
}
