import { describe, expect, it, vi } from 'vitest'
import { webcrypto } from 'node:crypto'

vi.mock('./credential-verification', () => ({ verifySdJwtSignature: vi.fn(async () => undefined) }))
import { findPresentationOptions } from './oid4vp-presentation'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true })

function encode(value: unknown): string {
  return Buffer.from(JSON.stringify(value)).toString('base64url')
}

async function digest(value: string): Promise<string> {
  return Buffer.from(await webcrypto.subtle.digest('SHA-256', new TextEncoder().encode(value))).toString('base64url')
}

const request = {
  payload: {
    dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['name'] }, { path: ['email'] }] }] },
  },
} as VerifiedOid4vpRequest

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
    const stored = await credential({ vct: 'MembershipCredential', _sd: [await digest(name), await digest(email)] }, [name, email])
    await expect(findPresentationOptions(request, [stored])).resolves.toEqual([{
      queryId: 'membership', credentialId: 'credential-1', label: 'Membership',
      claims: { name: 'Ada', email: 'ada@example.test' },
    }])
  })

  it('does not offer credentials missing requested claims or unsupported nested paths', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const stored = await credential({ vct: 'MembershipCredential', _sd: [await digest(name)] }, [name])
    const missing = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['role'] }] }] } } } as VerifiedOid4vpRequest
    await expect(findPresentationOptions(missing, [stored])).resolves.toEqual([])
    const nested = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['address', 'city'] }] }] } } } as VerifiedOid4vpRequest
    await expect(findPresentationOptions(nested, [stored])).resolves.toEqual([])
  })

  it('never mislabels nested disclosures as top-level claims', async () => {
    const name = encode(['salt', 'name', 'Ada'])
    const stored = await credential({ vct: 'MembershipCredential', address: { _sd: [await digest(name)] } }, [name])
    await expect(findPresentationOptions(request, [stored])).resolves.toEqual([])
  })
})
