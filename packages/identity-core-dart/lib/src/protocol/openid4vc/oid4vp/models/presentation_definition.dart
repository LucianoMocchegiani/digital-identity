import 'package:freezed_annotation/freezed_annotation.dart';

part 'presentation_definition.freezed.dart';
part 'presentation_definition.g.dart';

/// Presentation Definition (PEX v2) del verifier.
///
/// Define los requisitos de presentación: qué credenciales se necesitan
/// y qué claims deben ser revelados.
@freezed
class PresentationDefinition with _$PresentationDefinition {
  const factory PresentationDefinition({
    /// Identificador único de la definition.
    required String id,

    /// Lista de descriptores de input (uno por credencial requerida).
    @JsonKey(name: 'input_descriptors')
    required List<InputDescriptor> inputDescriptors,

    /// Requisitos de combinación entre input descriptors (PEX avanzado).
    @JsonKey(name: 'submission_requirements')
    List<Map<String, dynamic>>? submissionRequirements,

    /// Nombre descriptivo de la solicitud.
    String? name,

    /// Propósito de la solicitud (para mostrar al usuario).
    String? purpose,
  }) = _PresentationDefinition;

  factory PresentationDefinition.fromJson(Map<String, dynamic> json) =>
      _$PresentationDefinitionFromJson(json);
}

/// Input Descriptor de un PEX: define los requisitos para una credencial concreta.
@freezed
class InputDescriptor with _$InputDescriptor {
  const factory InputDescriptor({
    /// Identificador único del descriptor.
    required String id,

    /// Nombre descriptivo del tipo de credencial requerida.
    String? name,

    /// Propósito del uso de esta credencial.
    String? purpose,

    /// Restricciones sobre los claims de la credencial.
    ///
    /// Contiene `fields: List<{path, filter?, optional?}>` como mínimo.
    required Map<String, dynamic> constraints,

    /// Formatos de credencial aceptados para este descriptor.
    Map<String, dynamic>? format,
  }) = _InputDescriptor;

  factory InputDescriptor.fromJson(Map<String, dynamic> json) =>
      _$InputDescriptorFromJson(json);
}
