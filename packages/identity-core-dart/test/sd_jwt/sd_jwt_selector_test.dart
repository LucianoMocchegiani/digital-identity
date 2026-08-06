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
  test('selectDisclosuresForPaths incluye elementos de array nationalities', () async {
    final givenNameDisc = _b64Json(['salt', 'given_name', 'Juan']);
    final natDisc = _b64Json(['salt-nat', 'ARG']);
    final givenHash = await _disclosureHash(givenNameDisc);
    final natHash = await _disclosureHash(natDisc);

    final compact = await _compactSdJwt(
      payload: {
        'vct': 'urn:eudi:pid:1',
        '_sd': [givenHash],
        'nationalities': [
          {'...': natHash},
        ],
      },
      disclosureEncoded: [givenNameDisc, natDisc],
    );

    final token = await SdJwtParser.parse(compact);
    final selected = SdJwtSelector.selectDisclosuresForPaths(token, [
      'given_name',
      'nationalities',
    ]);

    expect(selected.map((d) => d.encoded).toSet(), {givenNameDisc, natDisc});
  });

  test('filterPresentableClaimPaths ignora claims ausentes en la credencial', () async {
    final givenNameDisc = _b64Json(['salt', 'given_name', 'Juan']);
    final givenHash = await _disclosureHash(givenNameDisc);

    final compact = await _compactSdJwt(
      payload: {
        'vct': 'urn:eudi:pid:1',
        '_sd': [givenHash],
      },
      disclosureEncoded: [givenNameDisc],
    );

    final token = await SdJwtParser.parse(compact);
    final filtered = SdJwtSelector.filterPresentableClaimPaths(
      token: token,
      requestedPaths: ['given_name', 'picture', 'age_over_18'],
    );

    expect(filtered, ['given_name']);
  });

  test('selectDisclosures usa disclosure padre para rutas anidadas', () async {
    final addressDisc = _b64Json([
      'salt',
      'address',
      {
        '_sd': ['hash-locality'],
        'locality': 'Madrid',
      },
    ]);
    final localityDisc = _b64Json(['salt-loc', 'locality', 'Madrid']);
    final addressHash = await _disclosureHash(addressDisc);
    final localityHash = await _disclosureHash(localityDisc);

    final payload = {
      'vct': 'urn:eudi:pid:1',
      '_sd': [addressHash],
      'address': {
        '_sd': [localityHash],
      },
    };

    final compact = await _compactSdJwt(
      payload: payload,
      disclosureEncoded: [addressDisc, localityDisc],
    );

    final token = await SdJwtParser.parse(compact);
    final selected = SdJwtSelector.selectDisclosures(token, ['address.locality']);

    expect(selected, isNotEmpty);
  });
}
