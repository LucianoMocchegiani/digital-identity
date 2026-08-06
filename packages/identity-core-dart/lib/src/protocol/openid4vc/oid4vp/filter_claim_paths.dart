import '../../../credential/models/credential_record.dart';
import '../../../credential/models/sd_jwt_vc_record.dart';
import '../../../credential/models/w3c_credential_record.dart';
import '../../../sd_jwt/sd_jwt_parser.dart';
import '../../../sd_jwt/sd_jwt_selector.dart';

/// Filtra rutas solicitadas por el verifier a las que [credential] puede satisfacer.
Future<List<String>> filterClaimPathsForCredential(
  CredentialRecord credential,
  List<String> requestedPaths,
) async {
  if (requestedPaths.isEmpty) return const [];

  if (credential is SdJwtVcRecord) {
    final token = await SdJwtParser.parse(credential.compactSdJwt);
    return SdJwtSelector.filterPresentableClaimPaths(
      token: token,
      requestedPaths: requestedPaths,
    );
  }

  if (credential is W3cCredentialRecord) {
    final subject =
        credential.credential['credentialSubject'] as Map<String, dynamic>? ??
            const {};
    return requestedPaths
        .where((path) => _hasPresentableValue(subject, path))
        .toList();
  }

  return const [];
}

bool _hasPresentableValue(Map<String, dynamic> claims, String path) {
  dynamic current = claims;
  for (final segment in path.split('.')) {
    if (current is! Map) return false;
    current = current[segment];
  }
  return _isPresentableValue(current);
}

bool _isPresentableValue(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.isNotEmpty;
  if (value is List) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}
