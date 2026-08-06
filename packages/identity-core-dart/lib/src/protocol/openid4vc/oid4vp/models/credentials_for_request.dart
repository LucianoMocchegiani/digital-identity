import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../credential/models/credential_record.dart';
import '../../../../trust/models/trusted_entity.dart';

part 'credentials_for_request.freezed.dart';

/// Tipo de query usado en el authorization request.
enum QueryType {
  /// Presentation Exchange (PEX v2).
  pex,

  /// Digital Credentials Query Language (DCQL).
  dcql,
}

/// Resultado del matching de credenciales locales contra el request del verifier.
///
/// Contiene la información para mostrar en UI y para ejecutar la presentación.
@freezed
class CredentialsForRequest with _$CredentialsForRequest {
  const factory CredentialsForRequest({
    /// Query type detectado: PEX o DCQL.
    required QueryType queryType,

    /// Submission formateada para UI.
    required FormattedSubmission submission,

    /// `client_id` del verifier (para el kb-JWT audience).
    required String verifierClientId,

    /// Nonce del authorization request (para kb-JWT y VP JWT).
    String? nonce,

    /// URI a la que enviar la respuesta.
    String? responseUri,

    /// Estado opaco del verifier.
    String? state,

    /// ID de la Presentation Definition (solo PEX).
    String? presentationDefinitionId,

    /// Información de confianza del verifier. Null si no se pudo determinar.
    TrustedEntity? trustedEntity,

    /// `response_mode` del authorization request.
    String? responseMode,

    /// Metadatos del verifier (`jwks` para JARM).
    Map<String, dynamic>? clientMetadata,

    /// Algoritmo JWE de respuesta cifrada.
    String? authorizationEncryptedResponseEnc,
  }) = _CredentialsForRequest;
}

/// Presentación formateada para mostrar en UI.
///
/// Agrupa las credenciales que satisfacen (o no) el request del verifier.
@freezed
class FormattedSubmission with _$FormattedSubmission {
  const factory FormattedSubmission({
    /// Nombre de la solicitud (del PEX `name` o metadata del verifier).
    String? name,

    /// Propósito declarado de la solicitud.
    String? purpose,

    /// Verdadero si todas las entradas tienen credenciales disponibles.
    required bool areAllSatisfied,

    /// Entradas individuales: una por input descriptor o credential query.
    required List<FormattedSubmissionEntry> entries,
  }) = _FormattedSubmission;
}

/// Entrada individual en una [FormattedSubmission].
@freezed
class FormattedSubmissionEntry with _$FormattedSubmissionEntry {
  const factory FormattedSubmissionEntry({
    /// ID del input descriptor (PEX) o credential query (DCQL).
    required String inputDescriptorId,

    /// Verdadero si hay al menos una credencial disponible para este descriptor.
    required bool isSatisfied,

    /// Nombre descriptivo del tipo de credencial requerida.
    String? name,

    /// Propósito específico de este descriptor.
    String? purpose,

    /// Credenciales disponibles que satisfacen este descriptor.
    List<CredentialRecord>? matchingCredentials,

    /// Paths de claims solicitados (para mostrar al usuario qué se compartirá).
    List<String>? requestedClaimPaths,
  }) = _FormattedSubmissionEntry;
}
