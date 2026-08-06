import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../utils/base64_utils.dart';

/// Token SD-JWT parseado, con el issuer JWT, disclosures decodificados y kb-JWT opcional.
class SdJwtToken {
  const SdJwtToken({
    required this.issuerJwt,
    required this.header,
    required this.payload,
    required this.disclosures,
    this.keyBindingJwt,
  });

  /// JWT del issuer completo: `header.payload.signature` (sin disclosures).
  final String issuerJwt;

  /// Claims del header del issuer JWT (alg, typ, etc.).
  final Map<String, dynamic> header;

  /// Claims del payload del issuer JWT (con arrays `_sd` sin resolver).
  final Map<String, dynamic> payload;

  /// Disclosures decodificados del SD-JWT.
  final List<Disclosure> disclosures;

  /// Key Binding JWT (kb+jwt), presente si el SD-JWT requiere holder binding.
  final String? keyBindingJwt;
}

/// Disclosure individual de un SD-JWT.
class Disclosure {
  const Disclosure({
    required this.encoded,
    required this.claimName,
    required this.claimValue,
    required this.hash,
    this.isArrayElement = false,
  });

  /// Valor base64url original del disclosure (como viene en el SD-JWT).
  final String encoded;

  /// Nombre del claim revelado (segundo elemento de `[salt, name, value]`).
  ///
  /// Vacío para disclosures de elemento de array (`[salt, value]`).
  final String claimName;

  /// Valor del claim revelado.
  final dynamic claimValue;

  /// `true` si el disclosure es de 2 elementos (elemento de array SD-JWT).
  final bool isArrayElement;

  /// Hash SHA-256 del [encoded] en base64url sin padding.
  ///
  /// Es el valor que aparece en los arrays `_sd` del payload del issuer JWT.
  final String hash;
}

/// Parsea un SD-JWT compacto en sus componentes.
///
/// Formato de entrada: `{issuer-jwt}~{disclosure1}~{disclosure2}~...~{kb-jwt?}`
class SdJwtParser {
  static final _sha256 = Sha256();

  /// Parsea el [compactSdJwt] y retorna un [SdJwtToken].
  ///
  /// Lanza [FormatException] si el formato es inválido.
  static Future<SdJwtToken> parse(String compactSdJwt) async {
    final parts = compactSdJwt.split('~');
    if (parts.isEmpty) throw const FormatException('SD-JWT vacío.');

    final issuerJwt = parts.first;
    if (!issuerJwt.contains('.')) {
      throw const FormatException('SD-JWT: el primer elemento no es un JWT válido.');
    }

    // Determinar si el último elemento es un kb-JWT (empieza con 'ey' y tiene dos puntos)
    String? kbJwt;
    final last = parts.last;
    if (last.isNotEmpty && last.startsWith('ey') && last.split('.').length == 3) {
      kbJwt = last;
    }

    // Los disclosures son los elementos intermedios (excluir issuerJwt y kb-jwt/vacío)
    final endIndex = (kbJwt != null || last.isEmpty) ? parts.length - 1 : parts.length;
    final disclosureStrings = parts.sublist(1, endIndex).where((s) => s.isNotEmpty);

    final disclosures = await Future.wait(
      disclosureStrings.map(_parseDisclosure),
    );

    // Parsear header y payload del issuer JWT
    final jwtParts = issuerJwt.split('.');
    final header = _decodeJwtPart(jwtParts[0]);
    final payload = _decodeJwtPart(jwtParts[1]);

    return SdJwtToken(
      issuerJwt: issuerJwt,
      header: header,
      payload: payload,
      disclosures: disclosures.toList(),
      keyBindingJwt: kbJwt,
    );
  }

  static Future<Disclosure> _parseDisclosure(String encoded) async {
    final decodedBytes = base64UrlDecode(encoded);
    final decoded = jsonDecode(utf8.decode(decodedBytes)) as List<dynamic>;

    if (decoded.length < 2) {
      throw FormatException(
        'Disclosure inválido: se esperan al menos 2 elementos, se obtuvieron ${decoded.length}.',
      );
    }

    final hash = await _computeHash(encoded);

    // Elemento de array: [salt, value] — usado con {"...": hash} en el payload.
    if (decoded.length == 2) {
      return Disclosure(
        encoded: encoded,
        claimName: '',
        claimValue: decoded[1],
        hash: hash,
        isArrayElement: true,
      );
    }

    return Disclosure(
      encoded: encoded,
      claimName: decoded[1] as String,
      claimValue: decoded[2],
      hash: hash,
    );
  }

  /// Calcula el hash SHA-256 del [encoded] y lo devuelve en base64url sin padding.
  static Future<String> _computeHash(String encoded) async {
    final inputBytes = Uint8List.fromList(utf8.encode(encoded));
    final hash = await _sha256.hash(inputBytes);
    return base64UrlEncode(Uint8List.fromList(hash.bytes));
  }

  static Map<String, dynamic> _decodeJwtPart(String part) {
    final decoded = base64UrlDecode(part);
    return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
  }
}
