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
  /** Consultas comerciales / integración / Business. */
  salesEmail: process.env.NEXT_PUBLIC_SALES_EMAIL ?? 'ventas@kuatia.xyz',
  /** Meta description (SEO / Google). */
  description:
    process.env.NEXT_PUBLIC_SITE_DESCRIPTION ??
    'Privacidad para tus usuarios e identidad sin fraude: emití y verificá credenciales firmadas con OpenID4VC.',
  /**
   * Texto corto para OG / WhatsApp (~70 chars; si es más largo se corta feo).
   */
  socialDescription:
    process.env.NEXT_PUBLIC_SITE_SOCIAL_DESCRIPTION ??
    'Privacidad para tus usuarios. Identidad sin fraude.',
  locale: 'es',
  /**
   * Links de descarga de la wallet Kuatia (vacío = pedir acceso beta por mail).
   * Play / App Store cuando estén publicados.
   */
  walletAndroidUrl: process.env.NEXT_PUBLIC_WALLET_ANDROID_URL?.trim() || '',
  walletIosUrl: process.env.NEXT_PUBLIC_WALLET_IOS_URL?.trim() || '',
} as const

/** Host visible (kuatia.xyz) derivado de `url`. */
export const siteHost = hostFromUrl(siteConfig.url)

/** `mailto:` con subject opcional (contacto general). */
export function mailto(subject?: string): string {
  if (!subject) return `mailto:${siteConfig.contactEmail}`
  return `mailto:${siteConfig.contactEmail}?subject=${encodeURIComponent(subject)}`
}

/** `mailto:` comercial (ventas / integración / Business). */
export function mailtoSales(subject?: string): string {
  if (!subject) return `mailto:${siteConfig.salesEmail}`
  return `mailto:${siteConfig.salesEmail}?subject=${encodeURIComponent(subject)}`
}

/** CTA descarga wallet: store URL o mail de beta. */
export function walletDownloadHref(platform: 'android' | 'ios' | 'any' = 'any'): string {
  if (platform === 'android' && siteConfig.walletAndroidUrl) return siteConfig.walletAndroidUrl
  if (platform === 'ios' && siteConfig.walletIosUrl) return siteConfig.walletIosUrl
  if (platform === 'any') {
    return siteConfig.walletAndroidUrl || siteConfig.walletIosUrl || mailto('Wallet Kuatia — acceso')
  }
  return mailto(`Wallet Kuatia — acceso (${platform})`)
}
