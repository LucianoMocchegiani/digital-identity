import 'package:identity_core_dart/identity_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvitationParser EUDI', () {
    test('auth code offer con host credential_offer', () {
      const u =
          'openid-credential-offer://credential_offer?credential_offer=%7B%22credential_issuer%22:%20%22https://issuer.eudiw.dev%22%7D';
      expect(InvitationParser.detectType(u), InvitationType.openid4vciOffer);
    });

    test('haip-vci con credential_offer_uri', () {
      const u =
          'haip-vci://?credential_offer_uri=https%3A%2F%2Fissuer.eudiw.dev%2Foffer';
      expect(InvitationParser.detectType(u), InvitationType.openid4vciOffer);
    });

    test('openid-credential-offer con una sola barra', () {
      const u = 'openid-credential-offer:?credential_offer=test';
      expect(InvitationParser.detectType(u), InvitationType.openid4vciOffer);
    });

    test('https issuer credential_offer path', () {
      const u = 'https://issuer.eudiw.dev/credential_offer';
      expect(InvitationParser.detectType(u), InvitationType.openid4vciOffer);
    });

    test('JSON inline en el QR', () {
      const u =
          '{"credential_issuer":"https://issuer.eudiw.dev","credential_configuration_ids":["eu.europa.ec.eudi.pid_jwt_vc_json"],"grants":{"authorization_code":{}}}';
      expect(InvitationParser.detectType(u), InvitationType.openid4vciOffer);
    });

    test('normaliza trailing > de ejemplos EUDI', () {
      const u =
          'openid-credential-offer://?credential_offer=test>';
      expect(
        InvitationParser.detectType(u),
        InvitationType.openid4vciOffer,
      );
    });

    test('DIDComm short URL /oob/:id (RFC 0434)', () {
      const u =
          'https://verifier.example.com/oob/5f0e3ffb-3f92-4648-9868-0d6f8889e6f3';
      expect(InvitationParser.detectType(u), InvitationType.didcommInvitation);
    });

    test('DIDComm _oobid query param', () {
      const u = 'https://verifier.example.com/ssi?_oobid=abc123';
      expect(InvitationParser.detectType(u), InvitationType.didcommInvitation);
    });
  });
}
