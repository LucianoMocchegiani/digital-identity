import { SITE_URL } from '@/shared/seo/site'
import type { MetadataRoute } from 'next'

/** robots.txt — indexar marketing/docs; bloquear consola y proxy de billing. */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/app/', '/api/'],
      },
    ],
    sitemap: `${SITE_URL}/sitemap.xml`,
    host: SITE_URL,
  }
}
