/**
 * Config pública del sitio: envs → un solo objeto.
 * Valores `NEXT_PUBLIC_*` quedan en el bundle del cliente.
 */

function trimSlash(url: string): string {
  return url.replace(/\/$/, '')
}

function hostFromUrl(url: string): string {
  try {
    return new URL(url).host
  } catch {
    return url.replace(/^https?:\/\//, '')
  }
}

export const siteConfig = {
  name: 'Kuatia',
  url: trimSlash(process.env.NEXT_PUBLIC_SITE_URL ?? 'https://kuatia.xyz'),
  contactEmail: process.env.NEXT_PUBLIC_CONTACT_EMAIL ?? 'hola@kuatia.xyz',
  /** Meta description (SEO / Google). */
  description:
    process.env.NEXT_PUBLIC_SITE_DESCRIPTION ??
    'Plataforma para emitir y verificar credenciales digitales con OpenID4VC.',
  /**
   * Texto corto para OG / WhatsApp (~70 chars; si es más largo se corta feo).
   */
  socialDescription:
    process.env.NEXT_PUBLIC_SITE_SOCIAL_DESCRIPTION ??
    'Emití y verificá credenciales: documentos, entradas y membresías.',
  locale: 'es',
} as const

/** Host visible (kuatia.xyz) derivado de `url`. */
export const siteHost = hostFromUrl(siteConfig.url)

/** `mailto:` con subject opcional. */
export function mailto(subject?: string): string {
  if (!subject) return `mailto:${siteConfig.contactEmail}`
  return `mailto:${siteConfig.contactEmail}?subject=${encodeURIComponent(subject)}`
}
