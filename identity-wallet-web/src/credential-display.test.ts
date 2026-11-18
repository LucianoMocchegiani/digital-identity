import { describe, expect, it } from 'vitest'
import { credentialDisplayFromConfiguration } from './credential-display'

describe('issuer credential display metadata', () => {
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
})
