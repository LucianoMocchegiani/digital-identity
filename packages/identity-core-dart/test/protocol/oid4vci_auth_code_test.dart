import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vci/pkce.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vci/prepare_auth_code_flow.dart';

void main() {
  group('PKCE', () {
    test('code_challenge es determinista para un verifier fijo', () {
      const verifier = 'test-verifier-abcdefghijklmnopqrstuvwxyz123456';
      final challenge = computeOid4VciCodeChallenge(verifier);
      expect(challenge, isNotEmpty);
      expect(challenge.contains('='), isFalse);
      expect(computeOid4VciCodeChallenge(verifier), challenge);
    });
  });

  group('parseOid4VciAuthRedirect', () {
    test('extrae code y state del callback', () {
      final parsed = parseOid4VciAuthRedirect(
        'com.quarkid.wallet://oid4vci/callback?code=abc&state=xyz',
      );
      expect(parsed.code, 'abc');
      expect(parsed.state, 'xyz');
      expect(parsed.error, isNull);
    });

    test('extrae error OAuth del callback', () {
      final parsed = parseOid4VciAuthRedirect(
        'com.quarkid.wallet://oid4vci/callback?error=access_denied',
      );
      expect(parsed.code, isNull);
      expect(parsed.error, 'access_denied');
    });
  });

  group('isOid4VciAuthRedirect', () {
    test('coincide scheme host y path', () {
      expect(
        isOid4VciAuthRedirect(
          callbackUri: 'com.quarkid.wallet://oid4vci/callback?code=1',
          redirectUri: 'com.quarkid.wallet://oid4vci/callback',
        ),
        isTrue,
      );
      expect(
        isOid4VciAuthRedirect(
          callbackUri: 'https://issuer.eudiw.dev/callback?code=1',
          redirectUri: 'com.quarkid.wallet://oid4vci/callback',
        ),
        isFalse,
      );
    });
  });
}
