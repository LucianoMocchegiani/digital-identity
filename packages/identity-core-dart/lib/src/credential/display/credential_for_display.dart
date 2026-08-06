import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/credential_record.dart';
import 'attribute_formatter.dart';

part 'credential_for_display.freezed.dart';

/// Credencial normalizada para su presentación en UI, independiente del formato subyacente.
///
/// Generada por [CredentialDisplayMapper] a partir de un [CredentialRecord].
/// Contiene tanto los atributos formateados para el usuario como la referencia
/// al record original para operaciones de firma y presentación OID4VP (Fase 4).
@freezed
class CredentialForDisplay with _$CredentialForDisplay {
  const factory CredentialForDisplay({
    /// Identificador único, coincide con [CredentialRecord.id].
    required String id,

    /// Fecha de almacenamiento.
    required DateTime createdAt,

    /// Formato subyacente de la credencial.
    required ClaimFormat claimFormat,

    /// Información de visualización (nombre, colores, logo).
    required CredentialDisplay display,

    /// Atributos formateados y listos para renderizar en UI.
    required List<FormattedAttribute> attributes,

    /// Claims crudos (sin formatear) para operaciones programáticas.
    required Map<String, dynamic> rawAttributes,

    /// Record original necesario para firmar y presentar la credencial.
    required CredentialRecord record,
  }) = _CredentialForDisplay;
}

/// Información de presentación visual de una credencial.
@freezed
class CredentialDisplay with _$CredentialDisplay {
  const factory CredentialDisplay({
    /// Nombre descriptivo de la credencial (ej. `'Documento de identidad'`).
    String? name,

    /// Descripción breve del propósito de la credencial.
    String? description,

    /// Color del texto en formato hex (ej. `'#FFFFFF'`).
    String? textColor,

    /// Color de fondo en formato hex (ej. `'#003399'`).
    String? backgroundColor,

    /// URL de la imagen de fondo de la tarjeta.
    String? backgroundImageUrl,

    /// Información de visualización del issuer.
    required IssuerDisplay issuer,
  }) = _CredentialDisplay;
}

/// Información de visualización del emisor de una credencial.
@freezed
class IssuerDisplay with _$IssuerDisplay {
  const factory IssuerDisplay({
    /// Nombre del issuer (ej. `'Ministerio del Interior'`).
    String? name,

    /// Dominio del issuer (ej. `'interior.gob.es'`).
    String? domain,

    /// URL del logo del issuer.
    String? logoUrl,
  }) = _IssuerDisplay;
}
