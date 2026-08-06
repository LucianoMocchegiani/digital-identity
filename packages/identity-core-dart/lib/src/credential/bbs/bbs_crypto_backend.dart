/// Contrato del backend cripto BBS+ (Node oracle / Dart LD+FFI).
library;

abstract class BbsCryptoBackend {
  Future<Map<String, dynamic>> deriveProof({
    required Map<String, dynamic> credential,
    required Map<String, dynamic> revealDocument,
    String? nonce,
    Map<String, dynamic>? issuerDidDocument,
  });

  Future<({bool verified, String? error})> verifyCredential({
    required Map<String, dynamic> credential,
    Map<String, dynamic>? issuerDidDocument,
  });
}
