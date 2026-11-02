import { afterEach, describe, expect, it, vi } from 'vitest'
import { webcrypto } from 'node:crypto'

vi.mock('./credential-verification', () => ({ verifySdJwtSignature: vi.fn(async () => undefined) }))
import { findPresentationOptions, inspectStoredCredentials, sendOid4vpPresentation, type PresentationOption } from './oid4vp-presentation'
import { verifySdJwtSignature } from './credential-verification'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true })
afterEach(() => vi.unstubAllGlobals())

function encode(value: unknown): string {
  return Buffer.from(JSON.stringify(value)).toString('base64url')
}

async function digest(value: string): Promise<string> {
  return Buffer.from(await webcrypto.subtle.digest('SHA-256', new TextEncoder().encode(value))).toString('base64url')
}

const holderPublicJwk: JsonWebKey = {
  kty: 'EC', crv: 'P-256',
  x: 'holder-key-x', y: 'holder-key-y',
}

const request: VerifiedOid4vpRequest = {
  header: {},
  payload: {
    client_id: 'decentralized_identifier:did:web:verifier.kuatia.xyz:test',
    dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['name'] }, { path: ['email'] }] }] },
  },
  verifierDid: 'did:web:verifier.kuatia.xyz:test',
  responseUri: 'https://verifier.kuatia.xyz/openid4vc-flow/test/authorize',
  nonce: 'test-nonce',
}

async function credential(payload: Record<string, unknown>, disclosures: string[]) {
  return {
    id: 'credential-1', label: 'Membership',
    compactSdJwt: `${encode({ alg: 'ES256' })}.${encode(payload)}.signature~${disclosures.join('~')}~`,
  }
}

describe('OID4VP local presentation preview', () => {
  it('offers only a verified matching credential and previews only requested claims', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const email = encode(['salt-2', 'email', 'ada@example.test'])
    const stored = await credential({ vct: 'MembershipCredential', cnf: { jwk: holderPublicJwk }, _sd: [await digest(name), await digest(email)] }, [name, email])
    await expect(findPresentationOptions(request, [stored], holderPublicJwk)).resolves.toEqual([{
      queryId: 'membership', credentialId: 'credential-1', label: 'Membership',
      claims: { name: 'Ada', email: 'ada@example.test' },
    }])
  })

  it('does not offer credentials bound to a different holder key', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const email = encode(['salt-2', 'email', 'ada@example.test'])
    const stored = await credential({
      vct: 'MembershipCredential',
      cnf: { jwk: { ...holderPublicJwk, x: 'another-key' } },
      _sd: [await digest(name), await digest(email)],
    }, [name, email])
    await expect(findPresentationOptions(request, [stored], holderPublicJwk)).resolves.toEqual([])
  })

  it('does not offer credentials without a holder binding', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const email = encode(['salt-2', 'email', 'ada@example.test'])
    const stored = await credential({ vct: 'MembershipCredential', _sd: [await digest(name), await digest(email)] }, [name, email])
    await expect(findPresentationOptions(request, [stored], holderPublicJwk)).resolves.toEqual([])
  })

  it('does not offer credentials missing requested claims or unsupported nested paths', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const stored = await credential({ vct: 'MembershipCredential', _sd: [await digest(name)] }, [name])
    const missing: VerifiedOid4vpRequest = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['role'] }] }] } } }
    await expect(findPresentationOptions(missing, [stored], holderPublicJwk)).resolves.toEqual([])
    const nested: VerifiedOid4vpRequest = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['address', 'city'] }] }] } } }
    await expect(findPresentationOptions(nested, [stored], holderPublicJwk)).resolves.toEqual([])
  })

  it('never mislabels nested disclosures as top-level claims', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const stored = await credential({ vct: 'MembershipCredential', address: { _sd: [await digest(name)] } }, [name])
    await expect(findPresentationOptions(request, [stored], holderPublicJwk)).resolves.toEqual([])
  })

  it('shows only metadata and claim names in the local credential inventory', async () => {
    const name = encode(['salt', 'name', 'Ada Lovelace'])
    const stored = await credential({ iss: 'issuer', vct: 'MembershipCredential', role: 'member', _sd: [await digest(name)] }, [name])
    await expect(inspectStoredCredentials([stored])).resolves.toEqual([{
      id: 'credential-1', label: 'Membership', format: 'dc+sd-jwt', vct: 'MembershipCredential',
      claims: ['name', 'role'], verified: true,
    }])
    expect(vi.mocked(verifySdJwtSignature)).toHaveBeenCalledWith(stored.compactSdJwt)
  })

  it('does not expose claim values and marks unverifiable credentials', async () => {
    const stored = await credential({ vct: 'MembershipCredential', name: 'Private Name' }, [])
    vi.mocked(verifySdJwtSignature).mockRejectedValueOnce(new Error('signature invalid'))
    const [summary] = await inspectStoredCredentials([stored])
    expect(summary).toMatchObject({ vct: 'MembershipCredential', claims: ['name'], verified: false })
    expect(JSON.stringify(summary)).not.toContain('Private Name')
  })

  it('signs a nonce-bound presentation and posts only requested disclosures', async () => {
    const pair = await webcrypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])
    const publicJwk = await webcrypto.subtle.exportKey('jwk', pair.publicKey)
    const name = encode(['salt', 'name', 'Ada'])
    const email = encode(['salt-2', 'email', 'private@example.test'])
    const stored = await credential({
      vct: 'MembershipCredential', cnf: { jwk: publicJwk }, _sd: [await digest(name), await digest(email)],
    }, [name, email])
    const selected: PresentationOption = {
      queryId: 'membership', credentialId: stored.id, label: stored.label, claims: { name: 'Ada' },
    }
    const selectedRequest: VerifiedOid4vpRequest = {
      ...request,
      payload: { ...request.payload, dcql_query: { credentials: [{
        id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['name'] }],
      }] } },
      state: 'state-123',
    }
    const fetchMock = vi.fn().mockResolvedValue(new Response(null, { status: 204 }))
    vi.stubGlobal('fetch', fetchMock)

    await sendOid4vpPresentation(selectedRequest, selected, stored, { privateKey: pair.privateKey, publicJwk })

    const [, init] = fetchMock.mock.calls[0] as [string, RequestInit]
    expect(fetchMock.mock.calls[0][0]).toBe(selectedRequest.responseUri)
    const params = new URLSearchParams(init.body as string)
    expect(params.get('state')).toBe('state-123')
    const vpToken = JSON.parse(params.get('vp_token') ?? '{}') as Record<string, string[]>
    const presentation = vpToken.membership[0]
    expect(presentation).not.toContain(email)
    const sdJwt = presentation.slice(0, presentation.lastIndexOf('~'))
    const jwt = presentation.slice(presentation.lastIndexOf('~') + 1)
    const [header, body, signature] = jwt.split('.')
    const decodedBody = JSON.parse(Buffer.from(body, 'base64url').toString())
    expect(decodedBody).toMatchObject({ aud: selectedRequest.payload.client_id, nonce: 'test-nonce', sd_hash: await digest(sdJwt) })
    const verifyKey = await webcrypto.subtle.importKey('jwk', publicJwk, { name: 'ECDSA', namedCurve: 'P-256' }, false, ['verify'])
    expect(await webcrypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, verifyKey, Buffer.from(signature, 'base64url'), new TextEncoder().encode(`${header}.${body}`))).toBe(true)
    expect(init.method).toBe('POST')
    expect(init.redirect).toBe('error')
  })
})
