/**
 * Ruta `/` — landing pública de marketing Kuatia.
 */
import { LandingPage } from '@/modules/marketing/components/LandingPage'
import {
  buildPageMetadata,
  DEFAULT_DESCRIPTION,
  SOCIAL_DESCRIPTION,
} from '@/shared/seo/site'

export const metadata = {
  ...buildPageMetadata({
    title: 'Credenciales digitales',
    description: DEFAULT_DESCRIPTION,
    path: '/',
    ogTitle: 'Kuatia — Credenciales digitales',
    ogDescription: SOCIAL_DESCRIPTION,
  }),
  title: {
    absolute: 'Kuatia — Credenciales digitales',
  },
}

export default function HomePage() {
  return <LandingPage />
}
