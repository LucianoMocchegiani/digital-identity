import { afterEach, describe, expect, it, vi } from 'vitest'
import { resolveProtocolResource } from './protocol-resource'

const offerRequest = { kind: 'issue', endpoint: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer/offers/offer-1' } as const
const presentationRequest = { kind: 'present', endpoint: 'https://verifier.kuatia.xyz/openid4vc-flow/verifier/authorize/request-1', clientId: 'decentralized_identifier:did:web:verifier.kuatia.xyz:verifier' } as const
const encode = (value: unknown) => btoa(JSON.stringify(value)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

afterEach(() => vi.unstubAllGlobals())

describe('protocol resource resolution', () => {
  it('fetches and parses a credential offer without sending browser credentials', async () => {
    const fetch = vi.fn().mockResolvedValue(new Response(JSON.stringify({ credential_issuer: 'https://issuer.kuatia.xyz' })))
    vi.stubGlobal('fetch', fetch)
    await expect(resolveProtocolResource(offerRequest)).resolves.toEqual({
      kind: 'issue', credentialOffer: { credential_issuer: 'https://issuer.kuatia.xyz' },
    })
    expect(fetch.mock.calls[0][1]).toMatchObject({ credentials: 'omit', redirect: 'error', cache: 'no-store' })
  })

  it('decodes the verifier JWT only to preview its request payload', async () => {
    const jwt = `${encode({ alg: 'ES256' })}.${encode({ response_mode: 'direct_post', dcql_query: { credentials: [] } })}.signature`
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(jwt)))
    await expect(resolveProtocolResource(presentationRequest)).resolves.toMatchObject({
      kind: 'present', header: { alg: 'ES256' }, payload: { response_mode: 'direct_post' },
    })
  })

  it('rejects non-JSON offers and non-JWT verifier responses', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('not-json')))
    await expect(resolveProtocolResource(offerRequest)).rejects.toThrow()
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('not-a-jwt')))
    await expect(resolveProtocolResource(presentationRequest)).rejects.toThrow()
  })
})
