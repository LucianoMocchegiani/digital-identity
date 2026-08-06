import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../utils/base64_utils.dart';
import '../utils/multibase.dart';

/// Soporte para el método DID `did:peer` (numAlgo 2 y 4).
///
/// El identificador se auto-certifica a partir de las claves y servicios incluidos.
/// No requiere registro en ningún ledger ni acceso a red para creación o resolución.
///
/// Formato:
///   `did:peer:2.Ez<base58btc(0xEC01||x25519_pub)>.Vz<base58btc(0xED01||ed25519_pub)>`
///   `.S<base64url(service_json)>` (si hay servicios).
///
/// Prefijos multicodec:
///   - `E` = keyAgreement (X25519), multicodec 0xEC 0x01
///   - `V` = verificationMethod (Ed25519), multicodec 0xED 0x01
///   - `S` = service (base64url del JSON de servicio)
class DidPeer {
  static const _x25519Prefix = [0xEC, 0x01];
  static const _ed25519Prefix = [0xED, 0x01];
  static const _jsonMulticodecVarint = 512;

  /// Genera un `did:peer:4` long-form compatible con Credo (numAlgo 4).
  ///
  /// Credo espera claves `Ed25519VerificationKey2018` / `X25519KeyAgreementKey2019`
  /// con `publicKeyBase58` y, opcionalmente, un servicio DIDComm.
  static String createNumAlgo4({
    required Map<String, dynamic> ed25519PublicJwk,
    required Map<String, dynamic> x25519PublicJwk,
    String? serviceEndpoint,
  }) {
    final ed25519Bytes = base64UrlDecode(ed25519PublicJwk['x'] as String);
    final x25519Bytes = base64UrlDecode(x25519PublicJwk['x'] as String);

    final document = <String, dynamic>{
      '@context': ['https://www.w3.org/ns/did/v1'],
      'authentication': [
        {
          'id': '#key-1',
          'type': 'Ed25519VerificationKey2018',
          'publicKeyBase58': encodeBase58Btc(ed25519Bytes),
        },
      ],
      'keyAgreement': [
        {
          'id': '#key-2',
          'type': 'X25519KeyAgreementKey2019',
          'publicKeyBase58': encodeBase58Btc(x25519Bytes),
        },
      ],
    };

    if (serviceEndpoint != null && serviceEndpoint.isNotEmpty) {
      document['service'] = [
        {
          'id': '#inline-0',
          'type': 'did-communication',
          'serviceEndpoint': serviceEndpoint,
          'priority': 0,
          'recipientKeys': ['#key-1'],
          'routingKeys': <String>[],
        },
      ];
    }

    final encodedDocument = _encodeNumAlgo4Document(document);
    final hash = _hashEncodedDocument(encodedDocument);
    return 'did:peer:4$hash:$encodedDocument';
  }

  /// Genera un `did:peer:2` a partir de claves públicas JWK.
  ///
  /// [ed25519PublicJwk]: clave de firma (OKP Ed25519, sin `d`).
  /// [x25519PublicJwk]: clave de key agreement (OKP X25519, sin `d`).
  /// [services]: lista opcional de objetos de servicio a incluir en el DID.
  static String create({
    required Map<String, dynamic> ed25519PublicJwk,
    required Map<String, dynamic> x25519PublicJwk,
    List<Map<String, dynamic>>? services,
  }) {
    final ed25519Bytes = base64UrlDecode(ed25519PublicJwk['x'] as String);
    final x25519Bytes = base64UrlDecode(x25519PublicJwk['x'] as String);

    final eKey =
        'Ez${encodeBase58Btc(Uint8List.fromList([..._x25519Prefix, ...x25519Bytes]))}';
    final vKey =
        'Vz${encodeBase58Btc(Uint8List.fromList([..._ed25519Prefix, ...ed25519Bytes]))}';

    final buf = StringBuffer('did:peer:2.$eKey.$vKey');

    if (services != null) {
      for (final service in services) {
        final compact = jsonEncode(service);
        buf.write(
          '.S${base64UrlEncode(Uint8List.fromList(utf8.encode(compact)))}',
        );
      }
    }

    return buf.toString();
  }

  /// Resuelve un `did:peer:2` o `did:peer:4` a su DID Document sin red.
  static Map<String, dynamic> resolve(String did) {
    if (did.startsWith('did:peer:4')) {
      return _resolveNumAlgo4(did);
    }
    if (!did.startsWith('did:peer:2.')) {
      throw FormatException('did:peer no soportado: $did');
    }

    final elements = did.substring('did:peer:2.'.length).split('.');

    final vms = <Map<String, dynamic>>[];
    final keyAgreements = <String>[];
    final authentications = <String>[];
    final services = <Map<String, dynamic>>[];
    var keyCounter = 0;

    for (final element in elements) {
      if (element.isEmpty) continue;
      final prefix = element[0];
      final encoded = element.substring(1);

      if (prefix == 'E' && encoded.startsWith('z')) {
        keyCounter++;
        final decoded = decodeBase58Btc(encoded.substring(1));
        if (decoded.length < 3) continue;
        final rawKey = decoded.sublist(2);
        final vmId = '$did#key-$keyCounter';
        vms.add({
          'id': vmId,
          'type': 'JsonWebKey2020',
          'controller': did,
          'publicKeyJwk': {
            'kty': 'OKP',
            'crv': 'X25519',
            'x': base64UrlEncode(Uint8List.fromList(rawKey)),
          },
        });
        keyAgreements.add(vmId);
      } else if (prefix == 'V' && encoded.startsWith('z')) {
        keyCounter++;
        final decoded = decodeBase58Btc(encoded.substring(1));
        if (decoded.length < 3) continue;
        final rawKey = decoded.sublist(2);
        final vmId = '$did#key-$keyCounter';
        vms.add({
          'id': vmId,
          'type': 'JsonWebKey2020',
          'controller': did,
          'publicKeyJwk': {
            'kty': 'OKP',
            'crv': 'Ed25519',
            'x': base64UrlEncode(Uint8List.fromList(rawKey)),
          },
        });
        authentications.add(vmId);
      } else if (prefix == 'S') {
        try {
          final json = utf8.decode(base64UrlDecode(encoded));
          final service = jsonDecode(json) as Map<String, dynamic>;
          services.add(service);
        } catch (_) {}
      }
    }

    return {
      '@context': [
        'https://www.w3.org/ns/did/v1',
        'https://w3id.org/security/suites/jws-2020/v1',
      ],
      'id': did,
      'verificationMethod': vms,
      'authentication': authentications,
      'assertionMethod': authentications,
      'keyAgreement': keyAgreements,
      if (services.isNotEmpty) 'service': services,
    };
  }

  static String _encodeNumAlgo4Document(Map<String, dynamic> document) {
    final jsonBytes = utf8.encode(jsonEncode(document));
    final payload = Uint8List.fromList([
      ..._encodeVarint(_jsonMulticodecVarint),
      ...jsonBytes,
    ]);
    return 'z${encodeBase58Btc(payload)}';
  }

  static String _hashEncodedDocument(String encodedDocument) {
    final digest = sha256.convert(utf8.encode(encodedDocument));
    final multihash = Uint8List.fromList([0x12, 0x20, ...digest.bytes]);
    return 'z${encodeBase58Btc(multihash)}';
  }

  static List<int> _encodeVarint(int value) {
    final out = <int>[];
    var n = value;
    while (n > 0x7f) {
      out.add((n & 0x7f) | 0x80);
      n >>= 7;
    }
    out.add(n);
    return out;
  }

  static Map<String, dynamic> _resolveNumAlgo4(String did) {
    final match = RegExp(
      r'^did:peer:4(z[1-9a-km-zA-HJ-NP-Z]{46}):(z[1-9a-km-zA-HJ-NP-Z]{6,})$',
    ).firstMatch(did);
    if (match == null) {
      throw FormatException('did:peer:4 long-form inválido: $did');
    }
    final hash = match.group(1)!;
    final encodedDocument = match.group(2)!;
    if (hash != _hashEncodedDocument(encodedDocument)) {
      throw FormatException('Hash inválido para did:peer:4: $did');
    }

    final decoded = decodeBase58Btc(encodedDocument.substring(1));
    var offset = 0;
    final (codec, varintLen) = _decodeVarint(decoded, offset);
    offset += varintLen;
    if (codec != _jsonMulticodecVarint) {
      throw FormatException('Multicodec JSON esperado en did:peer:4');
    }

    final document = jsonDecode(
      utf8.decode(decoded.sublist(offset)),
    ) as Map<String, dynamic>;
    document['id'] = did;
    return document;
  }

  static (int, int) _decodeVarint(Uint8List bytes, int offset) {
    var result = 0;
    var shift = 0;
    var index = offset;
    while (index < bytes.length) {
      final byte = bytes[index];
      result |= (byte & 0x7f) << shift;
      index++;
      if ((byte & 0x80) == 0) {
        return (result, index - offset);
      }
      shift += 7;
    }
    throw FormatException('Varint truncado');
  }
}
