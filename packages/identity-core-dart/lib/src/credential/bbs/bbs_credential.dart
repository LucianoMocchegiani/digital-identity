import 'bbs_crypto.dart';
import 'constants.dart';
import 'reveal_frame.dart';

export 'bbs_crypto.dart';
export 'constants.dart';
export 'reveal_frame.dart';

/// Opciones para [deriveBbsProof].
class DeriveBbsProofOptions {
  const DeriveBbsProofOptions({
    required this.credential,
    required this.revealDocument,
    this.nonce,
    this.issuerDidDocument,
    this.crypto,
  });

  final Map<String, dynamic> credential;
  final Map<String, dynamic> revealDocument;
  final String? nonce;
  final Map<String, dynamic>? issuerDidDocument;
  final BbsCryptoBackend? crypto;
}

/// Deriva `BbsBlsSignatureProof2020` (selective disclosure) desde una VC BBS.
Future<Map<String, dynamic>> deriveBbsProof(DeriveBbsProofOptions options) {
  final proof = options.credential['proof'];
  final proofType = proof is Map ? proof['type'] as String? : null;
  if (proofType != kBbsProofType) {
    throw ArgumentError(
      'deriveBbsProof espera proof.type=$kBbsProofType, recibido=$proofType',
    );
  }
  return (options.crypto ?? bbsCrypto).deriveProof(
    credential: options.credential,
    revealDocument: options.revealDocument,
    nonce: options.nonce,
    issuerDidDocument: options.issuerDidDocument,
  );
}

/// Verifica VC con proof BBS (Signature2020 o Proof2020).
Future<({bool verified, String? error})> verifyBbsCredential(
  Map<String, dynamic> credential, {
  Map<String, dynamic>? issuerDidDocument,
  BbsCryptoBackend? crypto,
}) {
  final proof = credential['proof'];
  final proofType = proof is Map ? proof['type'] as String? : null;
  if (!isBbsProofType(proofType)) {
    return Future.value((
      verified: false,
      error: 'proof.type no es BBS ($proofType)',
    ));
  }
  return (crypto ?? bbsCrypto).verifyCredential(
    credential: credential,
    issuerDidDocument: issuerDidDocument,
  );
}

/// Si la VC es `BbsBlsSignature2020`, deriva según paths del PD; si no, la deja igual.
Future<Map<String, dynamic>> maybeDeriveBbsCredentialForPex({
  required Map<String, dynamic> credential,
  required Map<String, dynamic> presentationDefinition,
  String? nonce,
  Map<String, dynamic>? issuerDidDocument,
  BbsCryptoBackend? crypto,
}) async {
  final proof = credential['proof'];
  final proofType = proof is Map ? proof['type'] as String? : null;
  if (proofType != kBbsProofType) {
    return Map<String, dynamic>.from(credential);
  }

  final paths =
      extractRevealPathsFromPresentationDefinition(presentationDefinition);
  if (paths.isEmpty) {
    return Map<String, dynamic>.from(credential);
  }

  final frame = buildRevealFrame(credential, paths);
  final derived = await deriveBbsProof(
    DeriveBbsProofOptions(
      credential: credential,
      revealDocument: frame,
      nonce: nonce,
      issuerDidDocument: issuerDidDocument,
      crypto: crypto,
    ),
  );

  // Holder binding: restaurar credentialSubject.id si el frame no lo preservó.
  final originalSubject = credential['credentialSubject'];
  final originalId =
      originalSubject is Map ? originalSubject['id'] as String? : null;
  final derivedSubject = derived['credentialSubject'];
  if (originalId != null &&
      derivedSubject is Map &&
      derivedSubject['id'] is! String) {
    derived['credentialSubject'] = {
      ...Map<String, dynamic>.from(derivedSubject),
      'id': originalId,
    };
  }

  return derived;
}
