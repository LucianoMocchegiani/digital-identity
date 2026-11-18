import { describe, expect, it } from 'vitest'
import { cleanCredentialLabel, credentialDisplayFromConfiguration } from './credential-display'

describe('issuer credential display metadata', () => {
  it('cleans obsolete signature labels without changing credential names', () => {
    expect(cleanCredentialLabel('membership_card · firma ES256 verificada')).toBe('membership_card')
    expect(cleanCredentialLabel('Membresía · firma no verificada')).toBe('Membresía')
    expect(cleanCredentialLabel('Membresía')).toBe('Membresía')
  })

  it('prefers Spanish display and converts mobile ARGB colors to CSS', () => {
    expect(credentialDisplayFromConfiguration([
      { locale: 'en', name: 'Membership' },
      { locale: 'es-AR', name: 'Membresía', background_color: '#8044AAFF', text_color: '#102030' },
    ])).toMatchObject({ name: 'Membresía', backgroundColor: '#44AAFF80', textColor: '#102030' })
  })

  it('ignores unsafe or unsupported image URLs and malformed colors', () => {
    expect(credentialDisplayFromConfiguration({
      background_color: 'red',
      logo: { uri: 'http://issuer.example/logo.png' },
      background_image: 'https://issuer.example/image.svg',
    })).toBeUndefined()
  })

  it('revalidates styles loaded from encrypted storage', () => {
    expect(credentialDisplayFromConfiguration({ name: 'Tarjeta', logoUrl: 'javascript:alert(1)' }))
      .toEqual({ name: 'Tarjeta', backgroundColor: undefined, textColor: undefined, backgroundImageUrl: undefined, logoUrl: undefined })
  })
})
