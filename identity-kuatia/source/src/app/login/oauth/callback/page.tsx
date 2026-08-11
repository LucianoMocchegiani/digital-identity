/**
 * Callback post-OAuth: billing redirige acá con `?accessToken=…`.
 */
import { OAuthCallbackClient } from '@/modules/auth/components/OAuthCallbackClient'
import { buildPageMetadata } from '@/shared/seo/site'

export const metadata = buildPageMetadata({
  title: 'Ingresando',
  description: 'Completando ingreso OAuth.',
  path: '/login/oauth/callback',
  noIndex: true,
})

export default function OAuthCallbackPage() {
  return <OAuthCallbackClient />
}
