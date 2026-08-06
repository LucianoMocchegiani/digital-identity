import 'sd_jwt_parser.dart';
import 'sd_jwt_selector.dart';

/// Claims reservados del issuer JWT que no se materializan en [prettyClaims].
const reservedSdJwtPayloadClaims = {
  'iss',
  'sub',
  'iat',
  'exp',
  'nbf',
  'vct',
  '_sd',
  '_sd_alg',
  'cnf',
};

/// Claims técnicos (revocación, etc.) excluidos de la vista de detalle.
const uiHiddenSdJwtClaims = {'status'};

/// Reconstruye claims legibles para UI a partir de un SD-JWT compacto.
///
/// Aplica todas las disclosures con [SdJwtSelector.reconstructClaims] y filtra
/// metadata de protocolo.
Future<Map<String, dynamic>> buildPrettyClaimsFromCompactSdJwt(
  String compactSdJwt,
) async {
  final token = await SdJwtParser.parse(compactSdJwt);
  final reconstructed = SdJwtSelector.reconstructClaims(token);

  return Map<String, dynamic>.fromEntries(
    reconstructed.entries.where(
      (entry) =>
          !reservedSdJwtPayloadClaims.contains(entry.key) &&
          !uiHiddenSdJwtClaims.contains(entry.key),
    ),
  );
}
