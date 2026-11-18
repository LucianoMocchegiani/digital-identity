import { afterEach, describe, expect, it, vi } from 'vitest'
import { resolveProtocolResource } from './protocol-resource'

const offerRequest = { kind: 'issue', endpoint: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer/offers/offer-1' } as const
const presentationRequest = { kind: 'present', endpoint: 'https://verifier.kuatia.xyz/openid4vc-flow/verifier/authorize/request-1', clientId: 'decentralized_identifier:did:web:verifier.kuatia.xyz:verifier' } as const
const encode = (value: unknown) => btoa(JSON.stringify(value)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

afterEach(() => vi.unstubAllGlobals())

describe('protocol resource resolution', () => {
  it('resolves a pre-authorized offer and issuer metadata without browser credentials', async () => {
    const offer = {
      credential_issuer: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer',
      credential_configuration_ids: ['membership_card'],
      grants: { 'urn:ietf:params:oauth:grant-type:pre-authorized_code': { 'pre-authorized_code': 'one-time-code' } },
    }
    const metadata = {
      credential_issuer: offer.credential_issuer,
      credential_endpoint: `${offer.credential_issuer}/credential`,
      token_endpoint: `${offer.credential_issuer}/token`,
      credential_configurations_supported: { membership_card: { format: 'dc+sd-jwt', vct: 'MembershipCredential' } },
    }
    const fetch = vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify(offer)))
      .mockResolvedValueOnce(new Response(JSON.stringify(metadata)))
    vi.stubGlobal('fetch', fetch)

    await expect(resolveProtocolResource(offerRequest)).resolves.toMatchObject({
      kind: 'issue', credentialIssuer: offer.credential_issuer, credentialConfigurationIds: ['membership_card'],
      credentialEndpoint: metadata.credential_endpoint, tokenEndpoint: metadata.token_endpoint,
      supportedConfigurations: metadata.credential_configurations_supported, hasPreAuthorizedCode: true,
    })
    expect(fetch.mock.calls.map(call => call[0].toString())).toEqual([
      offerRequest.endpoint,
      'https://issuer.kuatia.xyz/openid4vc-flow/issuer/.well-known/openid-credential-issuer',
    ])
    expect(fetch.mock.calls[0][1]).toMatchObject({ credentials: 'omit', redirect: 'error', cache: 'no-store' })
  })

  it('decodes the verifier JWT only to preview its request payload', async () => {
    const jwt = `${encode({ alg: 'ES256' })}.${encode({ response_mode: 'direct_post', dcql_query: { credentials: [] } })}.signature`
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(jwt)))
    await expect(resolveProtocolResource(presentationRequest)).resolves.toMatchObject({
      kind: 'present', header: { alg: 'ES256' }, payload: { response_mode: 'direct_post' },
    })
  })

  it('rejects malformed offers, unsupported configurations and untrusted endpoints', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({ credential_issuer: 'https://issuer.kuatia.xyz' }))))
    await expect(resolveProtocolResource(offerRequest)).rejects.toThrow()

    const unsupported = {
      credential_issuer: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer',
      credential_configuration_ids: ['missing'], grants: {},
    }
    vi.stubGlobal('fetch', vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify(unsupported)))
      .mockResolvedValueOnce(new Response(JSON.stringify({
        credential_issuer: unsupported.credential_issuer,
        credential_endpoint: `${unsupported.credential_issuer}/credential`,
        credential_configurations_supported: {},
      }))))
    await expect(resolveProtocolResource(offerRequest)).rejects.toThrow('no anuncia la configuración')

    const malicious = { ...unsupported, grants: {} }
    vi.stubGlobal('fetch', vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify(malicious)))
      .mockResolvedValueOnce(new Response(JSON.stringify({
        credential_issuer: malicious.credential_issuer,
        credential_endpoint: 'https://attacker.example/credential',
        credential_configurations_supported: { missing: { format: 'dc+sd-jwt' } },
      }))))
    await expect(resolveProtocolResource(offerRequest)).rejects.toThrow('no pertenece al issuer')
  })

  it('rejects non-JWT verifier responses', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('not-a-jwt')))
    await expect(resolveProtocolResource(presentationRequest)).rejects.toThrow()
  })
})
