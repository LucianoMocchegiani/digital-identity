import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { webcrypto } from 'node:crypto'
import type { ResolvedResource } from './protocol-resource'

const pair = await webcrypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign', 'verify'])
const publicJwk = await webcrypto.subtle.exportKey('jwk', pair.publicKey)
vi.mock('./wallet-storage', () => ({
  getHolderSigningKey: vi.fn(async () => ({ privateKey: (globalThis as typeof globalThis & { __holderKey?: CryptoKey }).__holderKey!, publicJwk: (globalThis as typeof globalThis & { __holderJwk?: JsonWebKey }).__holderJwk! })),
  saveCredential: vi.fn(async () => 'saved-id'),
}))
vi.mock('./credential-verification', () => ({ verifySdJwtSignature: vi.fn(async () => undefined) }))
import { issuePreAuthorizedCredential } from './oid4vci'
import { getHolderSigningKey, saveCredential } from './wallet-storage'
import { verifySdJwtSignature } from './credential-verification'

Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true })
Object.assign(globalThis, { __holderKey: pair.privateKey, __holderJwk: publicJwk })
beforeEach(() => vi.clearAllMocks())
afterEach(() => vi.unstubAllGlobals())

const resource: Extract<ResolvedResource, { kind: 'issue' }> = {
  kind: 'issue', credentialIssuer: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer',
  credentialEndpoint: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer/credential',
  tokenEndpoint: 'https://issuer.kuatia.xyz/openid4vc-flow/issuer/token',
  credentialConfigurationIds: ['membership_card'],
  supportedConfigurations: { membership_card: {
    format: 'dc+sd-jwt', vct: 'MembershipCredential', proof_types_supported: { jwt: { proof_signing_alg_values_supported: ['ES256'] } },
    cryptographic_binding_methods_supported: ['jwk'],
  } },
  hasPreAuthorizedCode: true, preAuthorizedCode: 'secret-one-time-code',
}
const issuedJwt = 'eyJhbGciOiJFUzI1NiJ9.eyJ2Y3QiOiJNZW1iZXJzaGlwQ3JlZGVudGlhbCJ9.signature~'

function decodeBase64url(value: string): Uint8Array {
  const binary = atob(value.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(value.length / 4) * 4, '='))
  return Uint8Array.from(binary, char => char.charCodeAt(0))
}

describe('OID4VCI pre-authorized issuance', () => {
  it('exchanges the code, signs a holder proof, requests and stores SD-JWT encrypted', async () => {
    const fetch = vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify({ access_token: 'access', token_type: 'Bearer', c_nonce: 'nonce' })))
      .mockResolvedValueOnce(new Response(JSON.stringify({ credential: issuedJwt })))
    vi.stubGlobal('fetch', fetch)
    await expect(issuePreAuthorizedCredential(resource)).resolves.toEqual({ count: 1, verifiedCount: 1 })
    expect(fetch).toHaveBeenCalledTimes(2)
    expect(fetch.mock.calls[0][1]).toMatchObject({ credentials: 'omit', redirect: 'error' })
    expect(String(fetch.mock.calls[0][1].body)).toContain('pre-authorized_code=secret-one-time-code')
    const requestBody = JSON.parse(String(fetch.mock.calls[1][1].body))
    expect(requestBody).toMatchObject({ credential_configuration_id: 'membership_card', format: 'dc+sd-jwt', proof: { proof_type: 'jwt' } })
    const proofParts = requestBody.proof.jwt.split('.')
    const signingInput = new TextEncoder().encode(`${proofParts[0]}.${proofParts[1]}`)
    expect(await webcrypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, pair.publicKey, decodeBase64url(proofParts[2]), signingInput)).toBe(true)
    const proofPayload = JSON.parse(new TextDecoder().decode(decodeBase64url(proofParts[1])))
    expect(proofPayload).toMatchObject({ aud: resource.credentialIssuer, nonce: 'nonce' })
    expect(verifySdJwtSignature).toHaveBeenCalledWith(issuedJwt, resource.credentialIssuer, 'MembershipCredential')
    expect(saveCredential).toHaveBeenCalledWith(issuedJwt, expect.stringContaining('firma ES256 verificada'))
  })

  it('does not contact the issuer if the configuration does not support the proof', async () => {
    const fetch = vi.fn()
    vi.stubGlobal('fetch', fetch)
    await expect(issuePreAuthorizedCredential({ ...resource, supportedConfigurations: { membership_card: { format: 'dc+sd-jwt' } } })).rejects.toThrow('no admite proofs ES256')
    expect(fetch).not.toHaveBeenCalled()
  })

  it('requires a supplied transaction code when the offer requests it', async () => {
    const fetch = vi.fn()
    vi.stubGlobal('fetch', fetch)
    await expect(issuePreAuthorizedCredential({ ...resource, txCode: { inputMode: 'numeric', length: 4 } })).rejects.toThrow('Ingresá el código')
    expect(fetch).not.toHaveBeenCalled()
    expect(getHolderSigningKey).not.toHaveBeenCalled()
  })
})
