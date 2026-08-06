/**
 * Credo a menudo devuelve verification methods de did:peer con `id` relativo (`#key-1`).
 * El documentLoader JSON-LD solo acepta http(s) o did:; un fragmento suelto falla con InvalidUrl.
 */

export interface VerificationMethodLike {
  id: string
  controller?: string
}

/**
 * Expande `id` (y `controller` si aplica) a DID URL absolutas respecto al subject DID.
 */
export function absolutizeVerificationMethodForDid<T extends VerificationMethodLike>(
  verificationMethod: T,
  subjectDid: string
): T {
  if (!subjectDid.startsWith('did:')) return verificationMethod

  const id =
    verificationMethod.id.startsWith('did:') || verificationMethod.id.startsWith('http')
      ? verificationMethod.id
      : `${subjectDid}${verificationMethod.id.startsWith('#') ? verificationMethod.id : `#${verificationMethod.id}`}`

  const controller = verificationMethod.controller
  const absoluteController =
    controller == null ||
    controller.startsWith('did:') ||
    controller.startsWith('http')
      ? controller
      : subjectDid

  if (id === verificationMethod.id && absoluteController === controller) {
    return verificationMethod
  }

  return Object.assign(Object.create(Object.getPrototypeOf(verificationMethod)), verificationMethod, {
    id,
    ...(absoluteController !== undefined ? { controller: absoluteController } : {}),
  }) as T
}
