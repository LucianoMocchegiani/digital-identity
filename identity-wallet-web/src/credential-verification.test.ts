import { describe, expect, it, vi } from 'vitest'
import { webcrypto } from 'node:crypto'
import { verifySdJwtSignature } from './credential-verification'

const issuer = 'https://issuer.kuatia.xyz/openid4vc-flow/faciliter-issuer-2v-4ygb'
const did = 'did:web:issuer.kuatia.xyz:faciliter-issuer-2v-4ygb'
const kid = `${did}#key-p256`
const pair = await webcrypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])
const jwk = await webcrypto.subtle.exportKey('jwk', pair.publicKey)

function base64url(value: Uint8Array): string {
  return Buffer.from(value).toString('base64url')
}

async function disclosure(value: unknown): Promise<string> {
  return base64url(new TextEncoder().encode(JSON.stringify(value)))
}

async function disclosureDigest(encoded: string): Promise<string> {
  return base64url(new Uint8Array(await webcrypto.subtle.digest('SHA-256', new TextEncoder().encode(encoded))))
}

async function signedCredential(payload: Record<string, unknown>, disclosures: string[] = []): Promise<string> {
  const header = base64url(new TextEncoder().encode(JSON.stringify({ alg: 'ES256', kid })))
  const body = base64url(new TextEncoder().encode(JSON.stringify(payload)))
  const input = `${header}.${body}`
  const signature = new Uint8Array(await webcrypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, pair.privateKey, new TextEncoder().encode(input)))
  return `${input}.${base64url(signature)}~${disclosures.join('~')}~`
}

function mockDidDocument() {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({
    id: did,
    verificationMethod: [{ id: kid, type: 'JsonWebKey2020', controller: did, publicKeyJwk: jwk }],
    assertionMethod: [kid],
  }))))
}

describe('SD-JWT ES256 issuer signature and disclosures', () => {
  it('verifies the issuer signature, expected issuer/VCT, and disclosure digest', async () => {
    const encodedDisclosure = await disclosure(['salt', 'name', 'Ada'])
    mockDidDocument()
    await expect(verifySdJwtSignature(await signedCredential({
      iss: issuer,
      vct: 'MembershipCredential',
      _sd_alg: 'sha-256',
      _sd: [await disclosureDigest(encodedDisclosure)],
    }, [encodedDisclosure]), issuer, 'MembershipCredential')).resolves.toBeUndefined()
  })

  it('rejects a disclosure not committed by the signed payload and an unsupported digest algorithm', async () => {
    mockDidDocument()
    await expect(verifySdJwtSignature(await signedCredential(
      { iss: issuer, vct: 'MembershipCredential', _sd_alg: 'sha-256', _sd: ['A'.repeat(43)] },
      [await disclosure(['salt', 'name', 'Ada'])],
    ), issuer, 'MembershipCredential')).rejects.toThrow('no coincide')
    await expect(verifySdJwtSignature(await signedCredential(
      { iss: issuer, vct: 'MembershipCredential', _sd_alg: 'sha-512' },
    ), issuer, 'MembershipCredential')).rejects.toThrow('algoritmo')
  })

  it('rejects a credential signed by another key or for another VCT', async () => {
    mockDidDocument()
    await expect(verifySdJwtSignature(await signedCredential({ iss: issuer, vct: 'OtherCredential' }), issuer, 'MembershipCredential')).rejects.toThrow('VCT')
    const credential = await signedCredential({ iss: issuer, vct: 'MembershipCredential' })
    await expect(verifySdJwtSignature(`${credential.slice(0, -2)}A~`, issuer, 'MembershipCredential')).rejects.toThrow()
  })

  it('rejects an issuer outside the expected Kuatia tenant', async () => {
    mockDidDocument()
    await expect(verifySdJwtSignature(await signedCredential({ iss: 'https://evil.example', vct: 'MembershipCredential' }))).rejects.toThrow('issuer')
  })
})
