import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

SdJwtVcRecord _sdJwtRecord({
  required Map<String, dynamic> prettyClaims,
  Map<String, dynamic>? issuerMetadata,
}) {
  return SdJwtVcRecord(
    id: 'sd-jwt-vc-test',
    createdAt: DateTime.utc(2026, 1, 1),
    compactSdJwt: 'eyJ.test.~',
    vct: 'urn:eudi:pid:1',
    prettyClaims: prettyClaims,
    issuerMetadata: issuerMetadata,
  );
}

void main() {
  group('ClaimDisplayResolver', () {
    test('usa credential_metadata.claims con display EUDI', () {
      final record = _sdJwtRecord(
        prettyClaims: {
          'given_name': 'Alice',
          'family_name': 'Smith',
          'birthdate': '1990-01-01',
        },
        issuerMetadata: {
          'credential_metadata': {
            'claims': [
              {
                'path': ['family_name'],
                'display': [
                  {'locale': 'en', 'name': 'Family Name(s)'},
                ],
              },
              {
                'path': ['given_name'],
                'display': [
                  {'locale': 'en', 'name': 'Given Name(s)'},
                ],
              },
              {
                'path': ['birthdate'],
                'display': [
                  {'locale': 'en', 'name': 'Birth Date'},
                ],
              },
            ],
          },
        },
      );

      final labeled = ClaimDisplayResolver.resolve(record, locale: 'en');

      expect(labeled, hasLength(3));
      expect(labeled[0].label, 'Family Name(s)');
      expect(labeled[0].value, 'Smith');
      expect(labeled[1].label, 'Given Name(s)');
      expect(labeled[1].value, 'Alice');
      expect(labeled[2].label, 'Birth Date');
    });

    test('elige display por locale con fallback al primero', () {
      final record = _sdJwtRecord(
        prettyClaims: {'given_name': 'Ana'},
        issuerMetadata: {
          'credential_metadata': {
            'claims': [
              {
                'path': ['given_name'],
                'display': [
                  {'locale': 'en', 'name': 'Given Name(s)'},
                  {'locale': 'es', 'name': 'Nombre(s) de pila'},
                ],
              },
            ],
          },
        },
      );

      expect(
        ClaimDisplayResolver.resolve(record, locale: 'es').first.label,
        'Nombre(s) de pila',
      );
      expect(
        ClaimDisplayResolver.resolve(record, locale: 'de').first.label,
        'Given Name(s)',
      );
    });

    test('soporta claims legacy como objeto', () {
      final record = _sdJwtRecord(
        prettyClaims: {'email': 'a@example.com'},
        issuerMetadata: {
          'claims': {
            'email': {
              'display': [
                {'locale': 'es', 'name': 'Correo electrónico'},
              ],
            },
          },
        },
      );

      final labeled = ClaimDisplayResolver.resolve(record, locale: 'es');
      expect(labeled.single.label, 'Correo electrónico');
      expect(labeled.single.value, 'a@example.com');
    });

    test('agrega claims sin metadata al final con etiqueta humanizada', () {
      final record = _sdJwtRecord(
        prettyClaims: {
          'given_name': 'Alice',
          'custom_field': 'x',
        },
        issuerMetadata: {
          'credential_metadata': {
            'claims': [
              {
                'path': ['given_name'],
                'display': [
                  {'locale': 'en', 'name': 'Given Name(s)'},
                ],
              },
            ],
          },
        },
      );

      final labeled = ClaimDisplayResolver.resolve(record, locale: 'en');
      expect(labeled, hasLength(2));
      expect(labeled.last.key, 'custom_field');
      expect(labeled.last.label, 'Custom Field');
    });

    test('sin metadata humaniza todas las claves', () {
      final record = _sdJwtRecord(
        prettyClaims: {'given_name': 'Alice', 'family_name': 'Smith'},
      );

      final labeled = ClaimDisplayResolver.resolve(record);
      expect(labeled[0].label, 'Given Name');
      expect(labeled[1].label, 'Family Name');
    });

    test('omite claims del metadata sin valor en la credencial', () {
      final record = _sdJwtRecord(
        prettyClaims: {'given_name': 'Alice'},
        issuerMetadata: {
          'credential_metadata': {
            'claims': [
              {
                'path': ['given_name'],
                'display': [
                  {'locale': 'en', 'name': 'Given Name(s)'},
                ],
              },
              {
                'path': ['portrait'],
                'display': [
                  {'locale': 'en', 'name': 'Portrait'},
                ],
              },
            ],
          },
        },
      );

      expect(ClaimDisplayResolver.resolve(record), hasLength(1));
    });
  });

  group('ClaimDisplayResolver.humanizeClaimKey', () {
    test('formatea snake_case', () {
      expect(ClaimDisplayResolver.humanizeClaimKey('given_name'), 'Given Name');
      expect(
        ClaimDisplayResolver.humanizeClaimKey('place_of_birth'),
        'Place Of Birth',
      );
    });
  });

  group('ClaimDisplayResolver.subjectClaimsForDisplay', () {
    test('omite id del titular', () {
      final claims = ClaimDisplayResolver.subjectClaimsForDisplay({
        'id': 'did:peer:holder',
        'name': 'Juan Perez',
        'documentNumber': '12345678',
      });

      expect(claims.containsKey('id'), isFalse);
      expect(claims['name'], 'Juan Perez');
      expect(claims['documentNumber'], '12345678');
    });
  });

  group('ClaimDisplayResolver.orderedDisplayClaims', () {
    test('sin values deja value vacío pero conserva key técnica', () {
      final claims = ClaimDisplayResolver.orderedDisplayClaims(
        {
          'claims': {
            'role': {
              'display': [
                {'locale': 'es', 'name': 'Rol'},
              ],
            },
          },
        },
        locale: 'es',
      );

      expect(claims.single.label, 'Rol');
      expect(claims.single.key, 'role');
      expect(claims.single.value, '');
    });
  });
}
