import { siteConfig } from '@/shared/config/site'
import type { Metadata } from 'next'

/** Reexport de config para SEO / metadata. */
export const SITE_URL = siteConfig.url
export const SITE_NAME = siteConfig.name
export const DEFAULT_DESCRIPTION = siteConfig.description
export const SOCIAL_DESCRIPTION = siteConfig.socialDescription

/** URL absoluta a partir de un path (`/` o `/docs/...`). */
export function absoluteUrl(path = '/'): string {
  if (!path || path === '/') return SITE_URL
  return `${SITE_URL}${path.startsWith('/') ? path : `/${path}`}`
}

type PageMetaInput = {
  title: string
  description: string
  path: string
  /** Título completo para OG/Twitter (si difiere del `title` corto). */
  ogTitle?: string
  /** Description corta para redes (si no, usa `description`). */
  ogDescription?: string
  noIndex?: boolean
}

/** Metadata de página con canónica, Open Graph y Twitter. */
export function buildPageMetadata({
  title,
  description,
  path,
  ogTitle,
  ogDescription,
  noIndex,
}: PageMetaInput): Metadata {
  const url = absoluteUrl(path)
  const socialTitle = ogTitle ?? title
  const socialDesc = ogDescription ?? description

  return {
    title,
    description,
    alternates: { canonical: url },
    openGraph: {
      title: socialTitle,
      description: socialDesc,
      url,
      siteName: SITE_NAME,
      locale: siteConfig.locale,
      type: 'website',
    },
    twitter: {
      card: 'summary_large_image',
      title: socialTitle,
      description: socialDesc,
    },
    robots: noIndex ? { index: false, follow: false } : { index: true, follow: true },
  }
}
