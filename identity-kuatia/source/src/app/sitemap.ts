import { DOCS_FLAT } from '@/modules/docs/nav'
import { absoluteUrl } from '@/shared/seo/site'
import type { MetadataRoute } from 'next'

/** sitemap.xml — home + páginas de documentación (sin /app ni auth). */
export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date()

  return [
    {
      url: absoluteUrl('/'),
      lastModified,
      changeFrequency: 'weekly',
      priority: 1,
    },
    ...DOCS_FLAT.map((item) => ({
      url: absoluteUrl(item.href),
      lastModified,
      changeFrequency: 'monthly' as const,
      priority: item.href === '/docs/introduccion' ? 0.9 : 0.7,
    })),
  ]
}
