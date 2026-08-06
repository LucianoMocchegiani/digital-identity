import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'bbs_crypto_backend.dart';
import 'bbs_ld_suite.dart';

export 'bbs_crypto_backend.dart';

/// Backend cripto BBS+.
///
/// Desktop/CI: bridge Node (`tool/bbs_mattr_bridge.mjs`) — oracle MATTR.
/// Mobile: [DartBbsLdSuite] + `libbbs` FFI.
BbsCryptoBackend? _override;

/// Permite inyectar un backend en tests.
void debugSetBbsCryptoBackend(BbsCryptoBackend? backend) {
  _override = backend;
}

/// Backend activo: override de test, o auto-detección Node / Dart+FFI.
BbsCryptoBackend get bbsCrypto {
  final override = _override;
  if (override != null) return override;
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return const NodeBbsMattrBridge();
  }
  return DartBbsLdSuite();
}

/// Invoca `tool/bbs_mattr_bridge.mjs` (Node + MATTR).
class NodeBbsMattrBridge implements BbsCryptoBackend {
  const NodeBbsMattrBridge({this.bridgePath, this.nodeExecutable = 'node'});

  /// Ruta absoluta al bridge; si es null se resuelve relativo al package.
  final String? bridgePath;
  final String nodeExecutable;

  String _resolveBridge() {
    if (bridgePath != null) return bridgePath!;
    // test/… → package root; también funciona desde tool/.
    final candidates = <String>[
      p.join(Directory.current.path, 'tool', 'bbs_mattr_bridge.mjs'),
      p.join(Directory.current.path, 'packages', 'identity-core-dart', 'tool',
          'bbs_mattr_bridge.mjs'),
      p.normalize(p.join(Directory.current.path, '..', 'identity-core-dart',
          'tool', 'bbs_mattr_bridge.mjs')),
    ];
    for (final c in candidates) {
      if (File(c).existsSync()) return c;
    }
    throw StateError(
      'No se encontró tool/bbs_mattr_bridge.mjs (cwd=${Directory.current.path}).',
    );
  }

  Future<Map<String, dynamic>> _run(Map<String, dynamic> payload) async {
    final bridge = _resolveBridge();
    final proc = await Process.start(
      nodeExecutable,
      [bridge],
      workingDirectory: p.dirname(p.dirname(bridge)),
      runInShell: Platform.isWindows,
    );
    proc.stdin.add(utf8.encode(jsonEncode(payload)));
    await proc.stdin.close();
    final stdout = await proc.stdout.transform(utf8.decoder).join();
    final stderr = await proc.stderr.transform(utf8.decoder).join();
    final code = await proc.exitCode;
    if (stdout.trim().isEmpty) {
      throw StateError(
        'bbs_mattr_bridge sin stdout (exit=$code stderr=$stderr)',
      );
    }
    final decoded = jsonDecode(stdout) as Map<String, dynamic>;
    if (decoded['ok'] != true) {
      throw StateError(
        'bbs_mattr_bridge: ${decoded['error'] ?? 'error desconocido'}'
        '${stderr.isNotEmpty ? ' | $stderr' : ''}',
      );
    }
    return decoded;
  }

  @override
  Future<Map<String, dynamic>> deriveProof({
    required Map<String, dynamic> credential,
    required Map<String, dynamic> revealDocument,
    String? nonce,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    final out = await _run({
      'op': 'derive',
      'credential': credential,
      'revealDocument': revealDocument,
      if (nonce != null) 'nonce': nonce,
      if (issuerDidDocument != null) 'issuerDidDocument': issuerDidDocument,
    });
    final cred = out['credential'];
    if (cred is! Map) {
      throw StateError('bbs_mattr_bridge derive sin credential');
    }
    return Map<String, dynamic>.from(cred);
  }

  @override
  Future<({bool verified, String? error})> verifyCredential({
    required Map<String, dynamic> credential,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    final out = await _run({
      'op': 'verify',
      'credential': credential,
      if (issuerDidDocument != null) 'issuerDidDocument': issuerDidDocument,
    });
    return (
      verified: out['verified'] == true,
      error: out['error'] as String?,
    );
  }
}
