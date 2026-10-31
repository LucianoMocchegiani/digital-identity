import type { ResolvedResource } from './protocol-resource'
import { verifyOid4vpRequest } from './oid4vp-verification'

export async function verifyPresentationResource(
  resource: Extract<ResolvedResource, { kind: 'present' }>,
  clientId: string,
) {
  return verifyOid4vpRequest(resource.compactRequest, clientId)
}
