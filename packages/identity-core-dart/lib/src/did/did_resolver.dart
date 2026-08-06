import 'package:dio/dio.dart';

import 'did_jwk.dart';
import 'did_key.dart';

/// Interfaz para resolvedores de DIDs.
abstract class DidResolver {
  /// Resuelve [did] a su DID Document.
  ///
  /// Devuelve `null` si el método no es soportado o el DID no existe.
  Future<Map<String, dynamic>?> resolve(String did);
}

/// Resolvedor universal que rutea por método DID.
///
/// - `did:key`  → resolución local sin red via [DidKey.resolve]
/// - `did:jwk`  → resolución local sin red via [DidJwk.resolve]
/// - `did:web`  → GET HTTP al endpoint `.well-known/did.json` con [Dio]
///
/// Métodos no soportados devuelven `null`.
class UniversalDidResolver implements DidResolver {
  UniversalDidResolver({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<Map<String, dynamic>?> resolve(String did) async {
    final method = _extractMethod(did);

    return switch (method) {
      'key' => _resolveKey(did),
      'jwk' => _resolveJwk(did),
      'web' => await _resolveWeb(did),
      _ => null,
    };
  }

  String _extractMethod(String did) {
    final parts = did.split(':');
    return parts.length >= 2 ? parts[1] : '';
  }

  Map<String, dynamic>? _resolveKey(String did) {
    try {
      return DidKey.resolve(did);
    } on FormatException {
      return null;
    } on UnsupportedError {
      return null;
    }
  }

  Map<String, dynamic>? _resolveJwk(String did) {
    try {
      return DidJwk.resolve(did);
    } on FormatException {
      return null;
    }
  }

  /// Resuelve `did:web` haciendo GET al endpoint canónico del DID Document.
  ///
  /// `did:web:example.com` → `https://example.com/.well-known/did.json`
  /// `did:web:example.com:path:to` → `https://example.com/path/to/did.json`
  Future<Map<String, dynamic>?> _resolveWeb(String did) async {
    final url = _didWebToUrl(did);
    if (url == null) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      return response.data;
    } on DioException {
      return null;
    }
  }

  static String? _didWebToUrl(String did) {
    // did:web:<host>[:<path-segments>...]
    final withoutPrefix = did.replaceFirst('did:web:', '');
    if (withoutPrefix.isEmpty) return null;

    final segments = withoutPrefix.split(':');
    final host = Uri.decodeComponent(segments[0]);

    if (segments.length == 1) {
      return 'https://$host/.well-known/did.json';
    }

    final path = segments.sublist(1).map(Uri.decodeComponent).join('/');
    return 'https://$host/$path/did.json';
  }
}
