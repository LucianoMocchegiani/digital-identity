import { afterEach, describe, expect, it, vi } from 'vitest'
import { webcrypto } from 'node:crypto'
import { verifyOid4vpRequest } from './oid4vp-verification'

const did = 'did:web:verifier.kuatia.xyz:verifier-a'
const clientId = `decentralized_identifier:${did}`
const kid = `${did}#key-p256`
const pair = await webcrypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])
const jwk = await webcrypto.subtle.exportKey('jwk', pair.publicKey)
Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true })

afterEach(() => vi.unstubAllGlobals())

function encode(value: unknown): string {
  return Buffer.from(JSON.stringify(value)).toString('base64url')
}

async function request(overrides: Record<string, unknown> = {}): Promise<string> {
  const header = encode({ alg: 'ES256', kid })
  const payload = encode({
    client_id: clientId,
    aud: 'https://self-issued.me/v2',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 120,
    nonce: 'one-time-nonce',
    response_type: 'vp_token',
    response_mode: 'direct_post',
    response_uri: 'https://verifier.kuatia.xyz/openid4vc-flow/verifier-a/authorize',
    dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] } }] },
    ...overrides,
  })
  const input = `${header}.${payload}`
  const signature = new Uint8Array(await webcrypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, pair.privateKey, new TextEncoder().encode(input)))
  return `${input}.${Buffer.from(signature).toString('base64url')}`
}

function mockDid() {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({
    id: did,
    verificationMethod: [{ id: kid, type: 'JsonWebKey2020', controller: did, publicKeyJwk: jwk }],
    assertionMethod: [kid],
  }))))
}

describe('OID4VP signed request verification', () => {
  it('verifies ES256 against the expected verifier DID and accepts the verifier request fields', async () => {
    mockDid()
    await expect(verifyOid4vpRequest(await request(), clientId)).resolves.toMatchObject({
      verifierDid: did,
      responseUri: 'https://verifier.kuatia.xyz/openid4vc-flow/verifier-a/authorize',
      nonce: 'one-time-nonce',
      payload: { response_mode: 'direct_post', response_type: 'vp_token', client_id: clientId },
    })
  })

  it('fails closed for a mismatched issuer, invalid signature, response endpoint, audience, or missing nonce', async () => {
    mockDid()
    await expect(verifyOid4vpRequest(await request({ iss: 'wrong-client' }), clientId)).rejects.toThrow('issuer')
    const jwt = await request()
    const [header, payload, signature] = jwt.split('.')
    const altered = `${header}.${payload}.${signature[0] === 'A' ? 'B' : 'A'}${signature.slice(1)}`
    await expect(verifyOid4vpRequest(altered, clientId)).rejects.toThrow('firma')
    await expect(verifyOid4vpRequest(await request({ response_uri: 'https://attacker.example/collect' }), clientId)).rejects.toThrow('response_uri')
    await expect(verifyOid4vpRequest(await request({ aud: 'https://attacker.example' }), clientId)).rejects.toThrow('audiencia')
    await expect(verifyOid4vpRequest(await request({ nonce: '' }), clientId)).rejects.toThrow('compatible')
  })

  it('rejects a request from a different tenant before resolving its DID', async () => {
    mockDid()
    await expect(verifyOid4vpRequest(await request(), 'decentralized_identifier:did:web:verifier.kuatia.xyz:other')).rejects.toThrow('client_id')
    expect(fetch).not.toHaveBeenCalled()
  })
})
