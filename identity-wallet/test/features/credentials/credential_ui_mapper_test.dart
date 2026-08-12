import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/features/credentials/mappers/credential_ui_mapper.dart';

SdJwtVcRecord _sdJwt({
  required String vct,
  Map<String, dynamic>? displayMetadata,
  Map<String, dynamic>? issuerMetadata,
}) {
  return SdJwtVcRecord(
    id: 'cred-1',
    createdAt: DateTime.utc(2026, 1, 1),
    compactSdJwt: 'header.payload.sig~',
    vct: vct,
    prettyClaims: const {},
    displayMetadata: displayMetadata,
    issuerMetadata: issuerMetadata,
  );
}

void main() {
  group('CredentialUiMapper.credentialTitle / credentialIssuer', () {
    test('usa display.name y issuer_brand_display.name', () {
      final record = _sdJwt(
        vct: 'urn:eu.europa.ec.eudi:diploma:1:1',
        displayMetadata: {
          'name': 'Membresía',
          'locale': 'es',
          'logo': {'uri': 'https://cdn.example/cred.png'},
        },
        issuerMetadata: {
          'issuer': 'did:web:issuer.example',
          CredentialUiMapper.issuerBrandDisplayKey: {
            'name': 'Club Norte',
            'locale': 'es',
            'logo': {'uri': 'https://cdn.example/logo.png'},
          },
        },
      );

      expect(CredentialUiMapper.credentialTitle(record), 'Membresía');
      expect(CredentialUiMapper.credentialIssuer(record), 'Club Norte');
      final card = CredentialUiMapper.toWalletCredential(record);
      expect(card.title, 'Membresía');
      expect(card.issuer, 'Club Norte');
      expect(card.logoUrl, 'https://cdn.example/cred.png');
    });

    test('sin display no muestra VCT ni DID', () {
      final record = _sdJwt(
        vct: 'urn:eu.europa.ec.eudi:diploma:1:1',
        issuerMetadata: {'issuer': 'did:web:issuer.example'},
      );

      expect(CredentialUiMapper.credentialTitle(record), 'Credencial');
      expect(CredentialUiMapper.credentialIssuer(record), isNull);
      expect(
        CredentialUiMapper.toWalletCredential(record).issuer,
        'Emisor desconocido',
      );
    });

    test('issuer https cae al host legible', () {
      final record = _sdJwt(
        vct: 'membership',
        displayMetadata: {'name': 'Socio'},
        issuerMetadata: {'issuer': 'https://www.clubnorte.example/oid4vci'},
      );

      expect(CredentialUiMapper.credentialIssuer(record), 'clubnorte.example');
    });
  });

  group('CredentialUiMapper.claimsForDisclosurePaths', () {
    const claims = [
      LabeledClaim(label: 'Nombre', key: 'nombre', value: 'Juan'),
      LabeledClaim(label: 'Apellido', key: 'apellido', value: 'Pérez'),
      LabeledClaim(label: 'Carrera', key: 'carrera', value: 'Ingeniería'),
    ];

    test('filtra por el último segmento de cada ruta, en orden', () {
      final result = CredentialUiMapper.claimsForDisclosurePaths(
        claims,
        ['credentialSubject.apellido', 'nombre'],
      );
      expect(result.map((c) => c.label).toList(), ['Apellido', 'Nombre']);
      expect(result.map((c) => c.value).toList(), ['Pérez', 'Juan']);
    });

    test('ruta sin claim resuelto usa etiqueta humanizada sin valor', () {
      final result = CredentialUiMapper.claimsForDisclosurePaths(
        claims,
        ['fecha_nacimiento'],
      );
      expect(result.single.label, 'Fecha Nacimiento');
      expect(result.single.value, '');
    });

    test('lista de rutas vacía devuelve lista vacía', () {
      expect(CredentialUiMapper.claimsForDisclosurePaths(claims, []), isEmpty);
    });
  });
}
