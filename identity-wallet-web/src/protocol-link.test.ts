import { describe, expect, it } from 'vitest'
import { parseIncomingLink, parseCurrentPage } from './protocol-link'

const offer = 'https://issuer.kuatia.xyz/openid4vc-flow/issuer-a/offers/offer-1'
const request = 'https://verifier.kuatia.xyz/openid4vc-flow/verifier-a/authorize/request-1'
const clientId = 'decentralized_identifier:did:web:verifier.kuatia.xyz:verifier-a'

 describe('Kuatia protocol links', () => {
  it('accepts a credential offer custom scheme and extracts its HTTPS URI', () => {
    const result = parseIncomingLink(`openid-credential-offer://?credential_offer_uri=${encodeURIComponent(offer)}`)
    expect(result).toEqual({ kind: 'issue', endpoint: offer })
  })

  it('accepts a direct_post request while preserving its client id', () => {
    const result = parseIncomingLink(`openid4vp://?client_id=${encodeURIComponent(clientId)}&request_uri=${encodeURIComponent(request)}`)
    expect(result).toEqual({ kind: 'present', endpoint: request, clientId })
  })

  it('rejects arbitrary origins and unrelated endpoint paths', () => {
    expect(() => parseIncomingLink('openid-credential-offer://?credential_offer_uri=https%3A%2F%2Fevil.example%2Foffer')).toThrow()
    expect(() => parseIncomingLink(`openid4vp://?client_id=${encodeURIComponent(clientId)}&request_uri=${encodeURIComponent('https://verifier.kuatia.xyz/other')}`)).toThrow()
  })

  it('parses the HTTPS wallet deep-link path', () => {
    expect(parseCurrentPage('/issue', `?credential_offer_uri=${encodeURIComponent(offer)}`)).toEqual({ kind: 'issue', endpoint: offer })
    expect(parseCurrentPage('/', '')).toBeNull()
  })
})
