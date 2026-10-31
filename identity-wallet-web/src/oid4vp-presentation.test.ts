import { describe, expect, it, vi } from 'vitest'

vi.mock('./credential-verification', () => ({ verifySdJwtSignature: vi.fn(async () => undefined) }))
import { findPresentationOptions } from './oid4vp-presentation'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

function encode(value: unknown): string {
  return Buffer.from(JSON.stringify(value)).toString('base64url')
}

const request = {
  payload: {
    dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['name'] }, { path: ['email'] }] }] },
  },
} as VerifiedOid4vpRequest

const credential = {
  id: 'credential-1', label: 'Membership', compactSdJwt: `${encode({ alg: 'ES256' })}.${encode({ vct: 'MembershipCredential' })}.signature~${encode(['salt', 'name', 'Ada'])}~${encode(['salt-2', 'email', 'ada@example.test'])}~`,
}

describe('OID4VP local presentation preview', () => {
  it('offers only a verified matching credential and previews only requested claims', async () => {
    await expect(findPresentationOptions(request, [credential])).resolves.toEqual([{
      queryId: 'membership', credentialId: 'credential-1', label: 'Membership',
      claims: { name: 'Ada', email: 'ada@example.test' },
    }])
  })

  it('does not offer credentials missing requested claims or unsupported nested paths', async () => {
    const missing = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['role'] }] }] } } } as VerifiedOid4vpRequest
    await expect(findPresentationOptions(missing, [credential])).resolves.toEqual([])
    const nested = { ...request, payload: { dcql_query: { credentials: [{ id: 'membership', format: 'dc+sd-jwt', meta: { vct_values: ['MembershipCredential'] }, claims: [{ path: ['address', 'city'] }] }] } } } as VerifiedOid4vpRequest
    await expect(findPresentationOptions(nested, [credential])).resolves.toEqual([])
  })
})
