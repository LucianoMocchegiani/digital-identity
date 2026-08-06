import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

/// Contrato de cifrado que aplican los record stores sensibles (PR2).
///
/// No abre Isar: valida el round-trip vía [WalletCryptoContext], que es lo
/// que invocan `KeyRecordStore`, `CredentialRecordStore` y
/// `DeferredCredentialRecordStore` al persistir.
void main() {
  final encryptionKey = Uint8List.fromList(List.generate(32, (i) => i));
  late WalletCryptoContext crypto;

  setUp(() {
    crypto = WalletCryptoContext(encryptionKey: encryptionKey);
  });

  group('KeyRecordStore fields', () {
    test('privateJwkJson cifrado con enc:v1:', () async {
      const privateJwk = {
        'kty': 'OKP',
        'crv': 'Ed25519',
        'd': 'super-secret',
        'x': 'public',
      };
      final plain = jsonEncode(privateJwk);

      final stored = await crypto.protectFieldRequired(plain);
      expect(stored, startsWith(FieldCipher.prefix));
      expect(stored, isNot(contains('super-secret')));

      final revealed = await crypto.revealField(stored);
      expect(jsonDecode(revealed!) as Map<String, dynamic>, privateJwk);
    });

    test('privateJwk null no se cifra', () async {
      expect(await crypto.protectField(null), isNull);
    });
  });

  group('CredentialRecordStore fields', () {
    test('SD-JWT compactSdJwt y prettyClaimsJson', () async {
      const jwt = 'eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJzZWNyZXQifQ.sig~';
      final claimsJson = jsonEncode({'given_name': 'Ana'});

      final storedJwt = await crypto.protectFieldRequired(jwt);
      final storedClaims = await crypto.protectFieldRequired(claimsJson);

      expect(storedJwt, startsWith(FieldCipher.prefix));
      expect(storedClaims, startsWith(FieldCipher.prefix));

      expect(await crypto.revealField(storedJwt), jwt);
      expect(await crypto.revealField(storedClaims), claimsJson);
    });

    test('W3C credentialJson', () async {
      final credentialJson = jsonEncode({
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'credentialSubject': {'id': 'did:example:holder'},
      });

      final stored = await crypto.protectFieldRequired(credentialJson);
      expect(stored, startsWith(FieldCipher.prefix));
      expect(await crypto.revealField(stored), credentialJson);
    });

    test('mDoc issuerSigned y namespaces', () async {
      const issuerSigned = 'aW1wb3J0YW50ZS1ieXRlcw';
      final namespacesJson = jsonEncode({'org.iso.18013.5.1': {'given_name': 'Ana'}});

      final storedSigned = await crypto.protectFieldRequired(issuerSigned);
      final storedNs = await crypto.protectFieldRequired(namespacesJson);

      expect(storedSigned, startsWith(FieldCipher.prefix));
      expect(await crypto.revealField(storedSigned), issuerSigned);
      expect(await crypto.revealField(storedNs), namespacesJson);
    });
  });

  group('DeferredCredentialRecordStore fields', () {
    test('accessTokenJson y responseJson cifrados; issuerMetadata en claro', () async {
      final accessTokenJson = jsonEncode({'access_token': 'token-secret'});
      final responseJson = jsonEncode({'transaction_id': 'tx-1'});
      final issuerMetadataJson = jsonEncode({'credential_endpoint': 'https://issuer'});

      final storedToken = await crypto.protectFieldRequired(accessTokenJson);
      final storedResponse = await crypto.protectFieldRequired(responseJson);

      expect(storedToken, startsWith(FieldCipher.prefix));
      expect(storedResponse, startsWith(FieldCipher.prefix));
      expect(issuerMetadataJson, isNot(startsWith(FieldCipher.prefix)));

      expect(await crypto.revealField(storedToken), accessTokenJson);
      expect(await crypto.revealField(storedResponse), responseJson);
    });
  });
}
