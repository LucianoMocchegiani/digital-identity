/**
 * Reveal frames y helpers de selective disclosure BBS+.
 */

/**
 * Extrae paths JSONPath de los `constraints.fields` de una Presentation Definition DIF PEX.
 */
export function extractRevealPathsFromPresentationDefinition(
  presentationDefinition: Record<string, unknown>
): string[] {
  const descriptors = presentationDefinition.input_descriptors as
    | { constraints?: { fields?: { path?: string | string[] }[] } }[]
    | undefined
  if (!Array.isArray(descriptors)) return []

  const paths: string[] = []
  for (const desc of descriptors) {
    for (const field of desc.constraints?.fields ?? []) {
      const p = field.path
      if (typeof p === 'string') paths.push(p)
      else if (Array.isArray(p)) paths.push(...p.filter((x): x is string => typeof x === 'string'))
    }
  }
  return [...new Set(paths)]
}

function isValidJsonLdType(value: unknown): value is string | string[] {
  if (typeof value === 'string' && value.length > 0) return true
  if (Array.isArray(value) && value.every((t) => typeof t === 'string')) return true
  return false
}

/**
 * Construye un JSON-LD frame (MATTR / BbsBlsSignatureProof2020) a partir de paths PEX
 * (p. ej. `$.credentialSubject.name`).
 *
 * MVP: solo paths bajo `credentialSubject` con un nivel de propiedad.
 * No incluir `type`/`id` inválidos: jsonld exige `@type` string | string[] | {}.
 *
 * @see https://github.com/mattrglobal/jsonld-signatures-bbs#derive-a-proof
 */
export function buildRevealFrame(
  credential: Record<string, unknown>,
  requestedPaths: string[]
): Record<string, unknown> {
  const subject = (credential.credentialSubject ?? {}) as Record<string, unknown>
  const revealedSubject: Record<string, unknown> = {
    '@explicit': true,
  }

  // Holder binding: Credo firma la VP con credentialSubject.id; hay que revelarlo.
  if (typeof subject.id === 'string' && subject.id.length > 0) {
    revealedSubject.id = {}
  }

  if (isValidJsonLdType(subject.type)) {
    revealedSubject.type = subject.type
  }

  for (const path of requestedPaths) {
    const match = path.match(/^\$\.credentialSubject\.([A-Za-z0-9_]+)$/)
    if (!match) continue
    const key = match[1]
    if (key === 'id' || key === 'type') continue
    if (key in subject) {
      revealedSubject[key] = {}
    }
  }

  const frame: Record<string, unknown> = {
    '@context': credential['@context'],
    type: credential.type,
    credentialSubject: revealedSubject,
  }

  if (!isValidJsonLdType(frame.type)) {
    frame.type = ['VerifiableCredential']
  }

  return frame
}
