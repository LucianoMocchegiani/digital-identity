import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_core_dart/src/utils/base64_utils.dart';

String _b64Json(Object value) =>
    base64UrlEncode(Uint8List.fromList(utf8.encode(jsonEncode(value))));

Future<String> _disclosureHash(String encoded) async {
  final hash = await Sha256().hash(Uint8List.fromList(utf8.encode(encoded)));
  return base64UrlEncode(Uint8List.fromList(hash.bytes));
}

String _issuerJwt(Map<String, dynamic> payload) {
  final header = _b64Json({'alg': 'none', 'typ': 'vc+sd-jwt'});
  final body = _b64Json(payload);
  return '$header.$body.';
}

Future<String> _compactSdJwt({
  required Map<String, dynamic> payload,
  required List<String> disclosureEncoded,
}) async {
  final issuer = _issuerJwt(payload);
  if (disclosureEncoded.isEmpty) return '$issuer~';
  return '$issuer~${disclosureEncoded.join('~')}~';
}

void main() {
  group('SdJwtParser', () {
    test('acepta disclosures de 2 elementos (elemento de array)', () async {
      final elemDisc = _b64Json(['salt-elem', 'nationality-ES']);
      final hash = await _disclosureHash(elemDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:test:pid',
          'iss': 'https://issuer.example',
          'nationalities': [
            {'...': hash},
          ],
        },
        disclosureEncoded: [elemDisc],
      );

      final token = await SdJwtParser.parse(compact);
      expect(token.disclosures, hasLength(1));
      expect(token.disclosures.first.isArrayElement, isTrue);
      expect(token.disclosures.first.claimValue, 'nationality-ES');
    });

    test('acepta disclosures de 3 elementos (claim con nombre)', () async {
      final givenNameDisc = _b64Json(['salt', 'given_name', 'Alice']);
      final hash = await _disclosureHash(givenNameDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:test:pid',
          '_sd': [hash],
        },
        disclosureEncoded: [givenNameDisc],
      );

      final token = await SdJwtParser.parse(compact);
      expect(token.disclosures.first.isArrayElement, isFalse);
      expect(token.disclosures.first.claimName, 'given_name');
    });
  });

  group('SdJwtSelector.reconstructClaims', () {
    test('fusiona claims de disclosures de 3 elementos', () async {
      final givenNameDisc = _b64Json(['6qX8Q', 'given_name', 'Alice']);
      final familyNameDisc = _b64Json(['8H8Q', 'family_name', 'Smith']);
      final h1 = await _disclosureHash(givenNameDisc);
      final h2 = await _disclosureHash(familyNameDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:eudi:pid:1',
          'iss': 'https://issuer.example',
          'status': {'status_list': {'idx': 1, 'uri': 'https://sl.example'}},
          '_sd': [h1, h2],
        },
        disclosureEncoded: [givenNameDisc, familyNameDisc],
      );

      final token = await SdJwtParser.parse(compact);
      final claims = SdJwtSelector.reconstructClaims(token);

      expect(claims['given_name'], 'Alice');
      expect(claims['family_name'], 'Smith');
      expect(claims['status'], isNotNull);
    });

    test('fusiona elementos de array con disclosures de 2 elementos', () async {
      final elemDisc = _b64Json(['salt-a', 'ES']);
      final hash = await _disclosureHash(elemDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:test',
          'nationalities': [
            {'...': hash},
          ],
        },
        disclosureEncoded: [elemDisc],
      );

      final token = await SdJwtParser.parse(compact);
      final claims = SdJwtSelector.reconstructClaims(token);

      expect(claims['nationalities'], ['ES']);
    });

    test('expande objeto anidado con _sd interno', () async {
      final streetDisc = _b64Json(['s1', 'street_address', 'Main St']);
      final hStreet = await _disclosureHash(streetDisc);
      final addressDisc = _b64Json([
        's2',
        'address',
        {'_sd': [hStreet]},
      ]);
      final hAddress = await _disclosureHash(addressDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:test',
          '_sd': [hAddress],
        },
        disclosureEncoded: [addressDisc, streetDisc],
      );

      final token = await SdJwtParser.parse(compact);
      final claims = SdJwtSelector.reconstructClaims(token);

      expect(claims['address'], {'street_address': 'Main St'});
    });
  });

  group('buildPrettyClaimsFromCompactSdJwt', () {
    test('excluye metadata de protocolo y status de revocación', () async {
      final givenNameDisc = _b64Json(['salt', 'given_name', 'Alice']);
      final hash = await _disclosureHash(givenNameDisc);
      final compact = await _compactSdJwt(
        payload: {
          'vct': 'urn:eudi:pid:1',
          'iss': 'https://issuer.example',
          'status': {'status_list': {'idx': 1253, 'uri': 'https://sl.example'}},
          '_sd': [hash],
        },
        disclosureEncoded: [givenNameDisc],
      );

      final pretty = await buildPrettyClaimsFromCompactSdJwt(compact);

      expect(pretty['given_name'], 'Alice');
      expect(pretty.containsKey('vct'), isFalse);
      expect(pretty.containsKey('iss'), isFalse);
      expect(pretty.containsKey('_sd'), isFalse);
      expect(pretty.containsKey('status'), isFalse);
    });
  });
}
