import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/features/protocol_flows/oid4vp/verifier_display.dart';

void main() {
  group('verifierDisplay', () {
    test('did:web con path: deriva el dominio y usa genérico como nombre', () {
      final d = verifierDisplay(
        'decentralized_identifier:did:web:verifier.pruebasaproduccunon.uno:uade-verifier',
        null,
      );
      expect(d.name, 'verifier.pruebasaproduccunon.uno');
      expect(d.domain, isNull);
    });

    test('organizationName presente: nombre = org, dominio como secundario', () {
      final d = verifierDisplay(
        'decentralized_identifier:did:web:verifier.pruebasaproduccunon.uno:uade-verifier',
        const RelyingParty(entityId: 'x', organizationName: 'UADE'),
      );
      expect(d.name, 'UADE');
      expect(d.domain, 'verifier.pruebasaproduccunon.uno');
    });

    test('did:web con puerto (%3A) decodifica el puerto', () {
      final d = verifierDisplay('did:web:localhost%3A8080:ejemplo', null);
      expect(d.name, 'localhost:8080');
    });

    test('https usa el host', () {
      final d = verifierDisplay(
        'redirect_uri:https://verifier.example.com/cb',
        null,
      );
      expect(d.name, 'verifier.example.com');
    });

    test('x509_hash opaco: sin dominio → etiqueta genérica', () {
      final d = verifierDisplay(
        'x509_hash:LTHlBmrN6Wc9oE3TxFZp47fET6iFBQliwMJiu3BLcqw',
        null,
      );
      expect(d.name, 'Verificador no identificado');
      expect(d.domain, isNull);
    });

    test('x509 sin nombre pero con domain del certificado (SAN DNS)', () {
      final d = verifierDisplay(
        'x509_hash:LTHlBmrN6Wc9oE3TxFZp47fET6iFBQliwMJiu3BLcqw',
        const RelyingParty(entityId: 'x', domain: 'verifier.uade.edu.ar'),
      );
      expect(d.name, 'verifier.uade.edu.ar');
      expect(d.domain, isNull);
    });

    test('sin clientId útil ni metadata → genérico', () {
      final d = verifierDisplay('did:key:z6Mk...', null);
      expect(d.name, 'Verificador no identificado');
      expect(d.domain, isNull);
    });
  });
}
