export interface CredentialDisplay {
  name?: string
  backgroundColor?: string
  textColor?: string
  backgroundImageUrl?: string
  logoUrl?: string
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function displayImage(value: unknown): string | undefined {
  const candidate = typeof value === 'string'
    ? value
    : isRecord(value) ? value.uri ?? value.url : undefined
  if (typeof candidate !== 'string' || candidate.length > 2048) return undefined
  try {
    const url = new URL(candidate)
    return url.protocol === 'https:' && !url.username && !url.password && /\.(png|jpe?g|webp)$/i.test(url.pathname)
      ? url.href
      : undefined
  } catch {
    return undefined
  }
}

function displayColor(value: unknown): string | undefined {
  if (typeof value !== 'string' || !/^#[\da-f]{6}(?:[\da-f]{2})?$/i.test(value)) return undefined
  const hex = value.slice(1)
  return `#${hex.length === 8 ? `${hex.slice(2)}${hex.slice(0, 2)}` : hex}`
}

export function credentialDisplayFromConfiguration(value: unknown): CredentialDisplay | undefined {
  const entries = Array.isArray(value) ? value : [value]
  const displays = entries.filter(isRecord)
  const display = displays.find(item => typeof item.locale === 'string' && item.locale.toLowerCase().startsWith('es')) ?? displays[0]
  if (!display) return undefined
  const name = typeof display.name === 'string' && display.name.trim() ? display.name.trim() : undefined
  const backgroundColor = displayColor(display.background_color ?? display.backgroundColor)
  const textColor = displayColor(display.text_color ?? display.textColor)
  const backgroundImageUrl = displayImage(display.background_image ?? display.backgroundImageUrl)
  const logoUrl = displayImage(display.logo ?? display.logoUrl)
  return name || backgroundColor || textColor || backgroundImageUrl || logoUrl
    ? { name, backgroundColor, textColor, backgroundImageUrl, logoUrl }
    : undefined
}
