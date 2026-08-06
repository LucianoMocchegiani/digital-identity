/**
 * Constantes del camino BBS+ (JSON-LD) en identity-core.
 * Alineado a Extrimian / BbsBlsSignature2020; independiente del default Ed25519 de Credo 0.7.
 */

/** proofType de emisión W3C JSON-LD con BBS+. */
export const BBS_PROOF_TYPE = 'BbsBlsSignature2020'

/** proofType de presentación con selective disclosure (deriveProof). */
export const BBS_PROOF_TYPE_DERIVED = 'BbsBlsSignatureProof2020'

/** Tipo de verification method BLS G2 en el DID Document. */
export const BLS12381_G2_VERIFICATION_METHOD_TYPE = 'Bls12381G2Key2020'

/** Contexto W3C Security BBS requerido para canonicalizar proofs BBS. */
export const BBS_SECURITY_CONTEXT = 'https://w3id.org/security/bbs/v1'

/** Descriptor de createKey para KMS internal/external. */
export const BLS12381_G2_KEY_TYPE = { keyType: 'Bls12381G2' as const }

/** true si el proof es emisión BBS o derived proof de selective disclosure. */
export function isBbsProofType(proofType: string | undefined): boolean {
  return proofType === BBS_PROOF_TYPE || proofType === BBS_PROOF_TYPE_DERIVED
}
