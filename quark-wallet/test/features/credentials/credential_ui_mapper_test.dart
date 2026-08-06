import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/features/credentials/mappers/credential_ui_mapper.dart';

void main() {
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
