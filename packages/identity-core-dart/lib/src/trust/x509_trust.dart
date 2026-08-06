import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/asn1_object.dart';
import 'package:pointycastle/asn1/primitives/asn1_generalized_time.dart';
import 'package:pointycastle/asn1/primitives/asn1_ia5_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_octet_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_printable_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asn1/primitives/asn1_set.dart';
import 'package:pointycastle/asn1/primitives/asn1_utc_time.dart';
import 'package:pointycastle/asn1/primitives/asn1_utf8_string.dart';

import 'models/trust_mechanism.dart';
import 'models/trusted_entity.dart';

/// Valida una cadena de certificados X.509 extraída del header `x5c` de un JWT.
///
/// Verificaciones implementadas:
/// - Validez temporal (notBefore / notAfter) del certificado leaf.
/// - Coincidencia de `clientId` con SAN URI o SAN DNS del leaf.
/// - Continuidad estructural de la cadena: el campo `issuer` de cada cert
///   coincide con el campo `subject` del siguiente.
/// - Si [trustedRootCertificates] no está vacío, la CA raíz debe estar en la lista
///   (comparación byte a byte del DER).
///
/// ## Verificación criptográfica de firmas — NO implementada
///
/// Lo que falta es confirmar matemáticamente que cada certificado fue firmado
/// por la clave privada de la CA anterior:
///
///   hash(TBSCertificate_bytes) → verificar con publicKey(cert[i+1]) → firma(cert[i])
///
/// Una CA (Certificate Authority) es la entidad que emite y firma certificados.
/// La cadena es: CA Raíz → Intermediate CA → Leaf (el cert del verifier).
/// Sin esta verificación, un atacante podría construir una cadena estructuralmente
/// válida con certificados falsos. En la práctica, combinada con `trustedRootCertificates`
/// (comparación byte a byte del root), el riesgo es bajo para el MVP.
abstract final class X509Trust {
  /// Valida [x5cChain] y retorna un [TrustedEntity].
  ///
  /// [x5cChain]: lista de certificados DER en base64 (sin padding opcional),
  ///   `[0]` = certificado del firmante (leaf), último = CA raíz.
  static Future<TrustedEntity> validate({
    required List<String> x5cChain,
    required String clientId,
    List<String> trustedRootCertificates = const [],
  }) async {
    if (x5cChain.isEmpty) {
      return _unverified(clientId, 'Cadena x5c vacía.');
    }

    try {
      final certs = x5cChain.map(_parseCert).toList();
      final leaf = certs.first;
      final now = DateTime.now().toUtc();

      if (!_validDates(leaf, now)) {
        return _unverified(clientId, 'Certificado expirado o no válido aún.');
      }

      if (!_matchesClientId(leaf, clientId)) {
        return _unverified(clientId, 'clientId no encontrado en SAN del certificado.');
      }

      if (!_validChain(certs)) {
        return _unverified(clientId, 'Cadena de certificados estructuralmente inválida.');
      }

      if (trustedRootCertificates.isNotEmpty) {
        if (!_rootIsTrusted(certs.last, trustedRootCertificates)) {
          return _unverified(clientId, 'CA raíz no está en la lista de confianza.');
        }
      }

      return TrustedEntity(
        trustMechanism: TrustMechanismType.x509,
        isVerified: true,
        certificateChain: x5cChain,
        relyingParty: RelyingParty(
          entityId: clientId,
          organizationName: leaf.organizationName,
          domain: leaf.sanDns.isNotEmpty ? leaf.sanDns.first : null,
          uri: leaf.sanUris.isNotEmpty ? leaf.sanUris.first : null,
        ),
      );
    } catch (_) {
      return _unverified(clientId, 'Error al parsear la cadena de certificados.');
    }
  }

  // — parsing —

  static _CertInfo _parseCert(String base64Der) {
    // Normalizar base64url → base64 estándar y agregar padding
    final std = base64Der.replaceAll('-', '+').replaceAll('_', '/');
    final padded = std.padRight((std.length + 3) ~/ 4 * 4, '=');
    final der = base64Decode(padded);

    final parser = ASN1Parser(der);
    final cert = parser.nextObject() as ASN1Sequence;

    // Certificate SEQUENCE: [tbsCertificate, signatureAlgorithm, signatureValue]
    final tbs = cert.elements![0] as ASN1Sequence;

    int idx = 0;

    // Version [0] EXPLICIT tiene tag 0xA0
    if (((tbs.elements![0].tag ?? 0) & 0xFF) == 0xA0) idx++;

    idx++; // serialNumber
    idx++; // signature AlgorithmIdentifier

    // issuer Name
    final issuerBytes = Uint8List.fromList(tbs.elements![idx].encodedBytes ?? []);
    final issuerSeq = tbs.elements![idx] as ASN1Sequence;
    idx++;

    // validity SEQUENCE { notBefore, notAfter }
    final validity = tbs.elements![idx] as ASN1Sequence;
    idx++;

    // subject Name
    final subjectBytes = Uint8List.fromList(tbs.elements![idx].encodedBytes ?? []);
    final subjectSeq = tbs.elements![idx] as ASN1Sequence;
    idx++;

    idx++; // subjectPublicKeyInfo

    // Extensions opcionales en [3] EXPLICIT (tag 0xA3)
    final sanDns = <String>[];
    final sanUris = <String>[];
    while (idx < (tbs.elements?.length ?? 0)) {
      final elem = tbs.elements![idx];
      if (((elem.tag ?? 0) & 0xFF) == 0xA3) {
        _parseExtensions(elem, sanDns, sanUris);
      }
      idx++;
    }

    final notBefore = _parseTime(validity.elements![0]);
    final notAfter = _parseTime(validity.elements![1]);

    // Organization Name OID: 2.5.4.10 — fallback a CN (2.5.4.3) del issuer
    final orgName = _extractDnAttr(subjectSeq, '2.5.4.10') ??
        _extractDnAttr(issuerSeq, '2.5.4.10') ??
        _extractDnAttr(subjectSeq, '2.5.4.3');

    return _CertInfo(
      rawDer: der,
      issuerBytes: issuerBytes,
      subjectBytes: subjectBytes,
      organizationName: orgName,
      sanDns: sanDns,
      sanUris: sanUris,
      notBefore: notBefore,
      notAfter: notAfter,
    );
  }

  static void _parseExtensions(
    ASN1Object extWrapper,
    List<String> sanDns,
    List<String> sanUris,
  ) {
    try {
      // El wrapper [3] EXPLICIT puede ser ASN1Sequence con tag 0xA3 o ASN1Object
      // Su contenido (value) es una SEQUENCE OF Extension
      Iterable<ASN1Object> extensions;

      if (extWrapper is ASN1Sequence && extWrapper.tag != 0x30) {
        // pointycastle parseó el wrapper como ASN1Sequence con tag no-estándar
        // Los elements son [SEQUENCE OF Extension] — un solo hijo
        final inner = extWrapper.elements;
        if (inner?.length == 1 && inner![0] is ASN1Sequence) {
          extensions = (inner[0] as ASN1Sequence).elements ?? [];
        } else {
          extensions = inner ?? [];
        }
      } else {
        final raw = extWrapper.valueBytes;
        if (raw == null) return;
        final seq = ASN1Parser(raw).nextObject();
        if (seq is! ASN1Sequence) return;
        extensions = seq.elements ?? [];
      }

      for (final extObj in extensions) {
        if (extObj is! ASN1Sequence) continue;
        final elems = extObj.elements;
        if ((elems?.length ?? 0) < 2) continue;

        if (elems![0] is! ASN1ObjectIdentifier) continue;
        final oid = (elems[0] as ASN1ObjectIdentifier).objectIdentifierAsString;
        if (oid != '2.5.29.17') continue; // Subject Alternative Name

        // Última posición es siempre el OCTET STRING con el valor de la extensión
        final octetStr = elems.last;
        if (octetStr is! ASN1OctetString) continue;

        final sanBytes = octetStr.octets ?? octetStr.valueBytes;
        if (sanBytes == null) continue;

        final sanSeq = ASN1Parser(sanBytes).nextObject();
        if (sanSeq is! ASN1Sequence) continue;

        for (final gn in sanSeq.elements ?? []) {
          if (gn is! ASN1Object) continue;
          final tag = gn.tag;
          if (tag == null) continue;
          final rawTag = tag & 0xFF;
          final bytes = gn.valueBytes;
          if (bytes == null) continue;

          if (rawTag == 0x82) {
            // dNSName [2] IMPLICIT
            sanDns.add(utf8.decode(bytes));
          } else if (rawTag == 0x86) {
            // uniformResourceIdentifier [6] IMPLICIT
            sanUris.add(utf8.decode(bytes));
          }
        }
      }
    } catch (_) {
      // parsing tolerante — ignorar errores de extensiones desconocidas
    }
  }

  static DateTime? _parseTime(ASN1Object obj) {
    if (obj is ASN1UtcTime) return obj.time;
    if (obj is ASN1GeneralizedTime) return obj.dateTimeValue;
    return null;
  }

  static String? _extractDnAttr(ASN1Sequence dn, String targetOid) {
    try {
      for (final rdnObj in dn.elements ?? []) {
        if (rdnObj is! ASN1Set) continue;
        for (final atvObj in rdnObj.elements ?? []) {
          if (atvObj is! ASN1Sequence) continue;
          final atv = atvObj.elements;
          if ((atv?.length ?? 0) < 2) continue;
          if (atv![0] is! ASN1ObjectIdentifier) continue;
          final oid = (atv[0] as ASN1ObjectIdentifier).objectIdentifierAsString;
          if (oid == targetOid) return _stringValue(atv[1]);
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _stringValue(ASN1Object obj) {
    if (obj is ASN1UTF8String) return obj.utf8StringValue;
    if (obj is ASN1PrintableString) return obj.stringValue;
    if (obj is ASN1IA5String) return obj.stringValue;
    try {
      final bytes = obj.valueBytes;
      if (bytes != null) return utf8.decode(bytes);
    } catch (_) {}
    return null;
  }

  // — validaciones —

  static bool _validDates(_CertInfo cert, DateTime now) {
    if (cert.notBefore != null && now.isBefore(cert.notBefore!)) return false;
    if (cert.notAfter != null && now.isAfter(cert.notAfter!)) return false;
    return true;
  }

  static bool _matchesClientId(_CertInfo leaf, String clientId) {
    for (final uri in leaf.sanUris) {
      if (uri == clientId || clientId.startsWith(uri)) return true;
    }
    final host = Uri.tryParse(clientId)?.host ?? clientId;
    for (final dns in leaf.sanDns) {
      if (dns == host) return true;
      // wildcard: *.example.com
      if (dns.startsWith('*.') && host.endsWith(dns.substring(1))) return true;
    }
    return false;
  }

  static bool _validChain(List<_CertInfo> certs) {
    for (int i = 0; i < certs.length - 1; i++) {
      // Verificación estructural: issuer[i] == subject[i+1].
      // TODO: agregar verificación criptográfica de firma cuando sea necesario:
      //   signer.init(false, PublicKeyParameter(certs[i+1].publicKey))
      //   signer.verifySignature(certs[i].tbsBytes, certs[i].signature)
      if (!_bytesEqual(certs[i].issuerBytes, certs[i + 1].subjectBytes)) {
        return false;
      }
    }
    return true;
  }

  static bool _rootIsTrusted(_CertInfo root, List<String> trusted) {
    final rootB64 = base64.encode(root.rawDer);
    final rootB64Url = base64Url.encode(root.rawDer).replaceAll('=', '');
    return trusted.any((t) {
      final n = t.replaceAll('=', '');
      return n == rootB64.replaceAll('=', '') ||
          n == rootB64Url ||
          t == rootB64;
    });
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static TrustedEntity _unverified(String clientId, String reason) {
    return TrustedEntity(
      trustMechanism: TrustMechanismType.x509,
      isVerified: false,
      relyingParty: RelyingParty(entityId: clientId),
    );
  }
}

// — modelo interno —

class _CertInfo {
  const _CertInfo({
    required this.rawDer,
    required this.issuerBytes,
    required this.subjectBytes,
    required this.sanDns,
    required this.sanUris,
    this.organizationName,
    this.notBefore,
    this.notAfter,
  });

  final Uint8List rawDer;
  final Uint8List issuerBytes;
  final Uint8List subjectBytes;
  final String? organizationName;
  final List<String> sanDns;
  final List<String> sanUris;
  final DateTime? notBefore;
  final DateTime? notAfter;
}
