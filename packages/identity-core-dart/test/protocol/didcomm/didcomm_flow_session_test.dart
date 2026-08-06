import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_core_dart/src/protocol/didcomm/flow/didcomm_message_router.dart';

void main() {
  group('DidCommMessageRouter', () {
    test('clasifica offer-credential', () {
      final kind = DidCommMessageRouter.classify({
        '@type': 'https://didcomm.org/issue-credential/2.0/offer-credential',
      });
      expect(kind, DidCommProtocolMessageKind.credentialOffer);
    });

    test('clasifica request-presentation', () {
      final kind = DidCommMessageRouter.classify({
        '@type': 'https://didcomm.org/present-proof/2.0/request-presentation',
      });
      expect(kind, DidCommProtocolMessageKind.presentationRequest);
    });

    test('tipo desconocido', () {
      final kind = DidCommMessageRouter.classify({
        '@type': 'https://didcomm.org/didexchange/1.1/complete',
      });
      expect(kind, DidCommProtocolMessageKind.unknown);
    });
  });

  group('WsTransport', () {
    test('httpEndpointToWs convierte https a wss', () {
      final uri = WsTransport.httpEndpointToWs(
        'https://issuer.example.com/v1/issuers/w1/didcomm',
      );
      expect(uri.scheme, 'wss');
      expect(uri.host, 'issuer.example.com');
    });

    test('normalizeMessage decodifica bytes UTF-8', () {
      final text = WsTransport.normalizeMessage([72, 101, 108, 108, 111]);
      expect(text, 'Hello');
    });
  });
}
