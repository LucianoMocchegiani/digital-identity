import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:meta/meta.dart';

/// Carga [TrustConfig] con las CAs raíz que usa la EUDI Wallet de referencia.
///
/// Los PEM viven en `assets/trust/eudi/` (mismo set que
/// `eudi-app-android-wallet-ui/resources-logic/src/main/res/raw/`).
abstract final class EudiTrustConfigLoader {
  static const _assetPaths = [
    'assets/trust/eudi/pidissuerca02_eu.pem',
    'assets/trust/eudi/pidissuerca02_ut.pem',
    'assets/trust/eudi/pidissuerca02_cz.pem',
    'assets/trust/eudi/pidissuerca02_ee.pem',
    'assets/trust/eudi/pidissuerca02_lu.pem',
    'assets/trust/eudi/pidissuerca02_nl.pem',
    'assets/trust/eudi/pidissuerca02_pt.pem',
    'assets/trust/eudi/dc4eu.pem',
    'assets/trust/eudi/r45_staging.pem',
  ];

  static TrustConfig? _cached;

  /// Retorna un [TrustConfig] con todas las CAs EUDI bundleadas.
  ///
  /// El resultado se cachea en memoria tras la primera carga.
  static Future<TrustConfig> load() async {
    if (_cached != null) return _cached!;

    final roots = <String>[];
    for (final path in _assetPaths) {
      try {
        final pem = await rootBundle.loadString(path);
        roots.add(_pemBodyToDerBase64(pem));
      } on FlutterError {
        // Asset ausente: omitir sin abortar el resto.
      }
    }

    _cached = TrustConfig(trustedRootCertificates: roots);
    return _cached!;
  }

  /// Extrae el cuerpo base64 DER de un PEM (sin headers ni saltos de línea).
  static String _pemBodyToDerBase64(String pem) {
    final buffer = StringBuffer();
    for (final line in pem.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('-----')) continue;
      buffer.write(trimmed);
    }
    return buffer.toString();
  }

  @visibleForTesting
  static String pemBodyToDerBase64ForTest(String pem) => _pemBodyToDerBase64(pem);
}
