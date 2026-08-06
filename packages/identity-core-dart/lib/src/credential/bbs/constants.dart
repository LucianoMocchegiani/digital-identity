/// Constantes BBS+ (JSON-LD) alineadas a identity-core QUARK-990 / MATTR.
library;

/// proofType de emisión W3C JSON-LD con BBS+.
const String kBbsProofType = 'BbsBlsSignature2020';

/// proofType de presentación con selective disclosure (deriveProof).
const String kBbsProofTypeDerived = 'BbsBlsSignatureProof2020';

/// Tipo de verification method BLS G2 en el DID Document.
const String kBls12381G2VerificationMethodType = 'Bls12381G2Key2020';

/// Contexto W3C Security BBS requerido para canonicalizar proofs BBS.
const String kBbsSecurityContext = 'https://w3id.org/security/bbs/v1';

/// Suites con las que el holder firma la VP (no la VC BBS).
const List<String> kHolderVpProofTypes = [
  'Ed25519Signature2018',
  'Ed25519Signature2020',
];

/// true si el proof es emisión BBS o derived proof de selective disclosure.
bool isBbsProofType(String? proofType) =>
    proofType == kBbsProofType || proofType == kBbsProofTypeDerived;
