import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'credential_record.dart';

part 'mdoc_record.freezed.dart';

/// Credencial en formato mDoc según ISO 18013-5 (CBOR).
///
/// Almacena el documento CBOR firmado por el issuer ([issuerSignedBytes]) y los
/// namespaces decodificados para visualización en UI. El parsing CBOR completo
/// se realiza en [MdocParser] (Fase 4).
@freezed
class MdocRecord with _$MdocRecord implements CredentialRecord {
  const MdocRecord._();

  const factory MdocRecord({
    /// Identificador único. Formato: `'mdoc-{uuid}'`.
    required String id,

    /// Fecha de almacenamiento en el wallet.
    required DateTime createdAt,

    /// Tipo de documento mDoc (ej. `'eu.europa.ec.eudi.pid_mdoc'`).
    required String docType,

    /// Atributos agrupados por namespace.
    ///
    /// Estructura: `{ namespace: { claimName: claimValue } }`
    /// Ejemplo: `{ 'eu.europa.ec.eudi.pid.1': { 'family_name': 'García' } }`
    required Map<String, Map<String, dynamic>> namespaces,

    /// Bytes CBOR del `IssuerSigned` firmado, necesarios para la presentación offline.
    required Uint8List issuerSignedBytes,

    /// Metadata de visualización extraída del credential endpoint.
    Map<String, dynamic>? displayMetadata,
  }) = _MdocRecord;

  @override
  ClaimFormat get claimFormat => ClaimFormat.mdoc;
}
