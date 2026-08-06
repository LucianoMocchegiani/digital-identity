// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresentationDefinition _$PresentationDefinitionFromJson(
    Map<String, dynamic> json) {
  return _PresentationDefinition.fromJson(json);
}

/// @nodoc
mixin _$PresentationDefinition {
  /// Identificador único de la definition.
  String get id => throw _privateConstructorUsedError;

  /// Lista de descriptores de input (uno por credencial requerida).
  @JsonKey(name: 'input_descriptors')
  List<InputDescriptor> get inputDescriptors =>
      throw _privateConstructorUsedError;

  /// Requisitos de combinación entre input descriptors (PEX avanzado).
  @JsonKey(name: 'submission_requirements')
  List<Map<String, dynamic>>? get submissionRequirements =>
      throw _privateConstructorUsedError;

  /// Nombre descriptivo de la solicitud.
  String? get name => throw _privateConstructorUsedError;

  /// Propósito de la solicitud (para mostrar al usuario).
  String? get purpose => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PresentationDefinitionCopyWith<PresentationDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresentationDefinitionCopyWith<$Res> {
  factory $PresentationDefinitionCopyWith(PresentationDefinition value,
          $Res Function(PresentationDefinition) then) =
      _$PresentationDefinitionCopyWithImpl<$Res, PresentationDefinition>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'input_descriptors')
      List<InputDescriptor> inputDescriptors,
      @JsonKey(name: 'submission_requirements')
      List<Map<String, dynamic>>? submissionRequirements,
      String? name,
      String? purpose});
}

/// @nodoc
class _$PresentationDefinitionCopyWithImpl<$Res,
        $Val extends PresentationDefinition>
    implements $PresentationDefinitionCopyWith<$Res> {
  _$PresentationDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inputDescriptors = null,
    Object? submissionRequirements = freezed,
    Object? name = freezed,
    Object? purpose = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      inputDescriptors: null == inputDescriptors
          ? _value.inputDescriptors
          : inputDescriptors // ignore: cast_nullable_to_non_nullable
              as List<InputDescriptor>,
      submissionRequirements: freezed == submissionRequirements
          ? _value.submissionRequirements
          : submissionRequirements // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresentationDefinitionImplCopyWith<$Res>
    implements $PresentationDefinitionCopyWith<$Res> {
  factory _$$PresentationDefinitionImplCopyWith(
          _$PresentationDefinitionImpl value,
          $Res Function(_$PresentationDefinitionImpl) then) =
      __$$PresentationDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'input_descriptors')
      List<InputDescriptor> inputDescriptors,
      @JsonKey(name: 'submission_requirements')
      List<Map<String, dynamic>>? submissionRequirements,
      String? name,
      String? purpose});
}

/// @nodoc
class __$$PresentationDefinitionImplCopyWithImpl<$Res>
    extends _$PresentationDefinitionCopyWithImpl<$Res,
        _$PresentationDefinitionImpl>
    implements _$$PresentationDefinitionImplCopyWith<$Res> {
  __$$PresentationDefinitionImplCopyWithImpl(
      _$PresentationDefinitionImpl _value,
      $Res Function(_$PresentationDefinitionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inputDescriptors = null,
    Object? submissionRequirements = freezed,
    Object? name = freezed,
    Object? purpose = freezed,
  }) {
    return _then(_$PresentationDefinitionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      inputDescriptors: null == inputDescriptors
          ? _value._inputDescriptors
          : inputDescriptors // ignore: cast_nullable_to_non_nullable
              as List<InputDescriptor>,
      submissionRequirements: freezed == submissionRequirements
          ? _value._submissionRequirements
          : submissionRequirements // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresentationDefinitionImpl implements _PresentationDefinition {
  const _$PresentationDefinitionImpl(
      {required this.id,
      @JsonKey(name: 'input_descriptors')
      required final List<InputDescriptor> inputDescriptors,
      @JsonKey(name: 'submission_requirements')
      final List<Map<String, dynamic>>? submissionRequirements,
      this.name,
      this.purpose})
      : _inputDescriptors = inputDescriptors,
        _submissionRequirements = submissionRequirements;

  factory _$PresentationDefinitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresentationDefinitionImplFromJson(json);

  /// Identificador único de la definition.
  @override
  final String id;

  /// Lista de descriptores de input (uno por credencial requerida).
  final List<InputDescriptor> _inputDescriptors;

  /// Lista de descriptores de input (uno por credencial requerida).
  @override
  @JsonKey(name: 'input_descriptors')
  List<InputDescriptor> get inputDescriptors {
    if (_inputDescriptors is EqualUnmodifiableListView)
      return _inputDescriptors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputDescriptors);
  }

  /// Requisitos de combinación entre input descriptors (PEX avanzado).
  final List<Map<String, dynamic>>? _submissionRequirements;

  /// Requisitos de combinación entre input descriptors (PEX avanzado).
  @override
  @JsonKey(name: 'submission_requirements')
  List<Map<String, dynamic>>? get submissionRequirements {
    final value = _submissionRequirements;
    if (value == null) return null;
    if (_submissionRequirements is EqualUnmodifiableListView)
      return _submissionRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Nombre descriptivo de la solicitud.
  @override
  final String? name;

  /// Propósito de la solicitud (para mostrar al usuario).
  @override
  final String? purpose;

  @override
  String toString() {
    return 'PresentationDefinition(id: $id, inputDescriptors: $inputDescriptors, submissionRequirements: $submissionRequirements, name: $name, purpose: $purpose)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresentationDefinitionImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._inputDescriptors, _inputDescriptors) &&
            const DeepCollectionEquality().equals(
                other._submissionRequirements, _submissionRequirements) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.purpose, purpose) || other.purpose == purpose));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_inputDescriptors),
      const DeepCollectionEquality().hash(_submissionRequirements),
      name,
      purpose);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PresentationDefinitionImplCopyWith<_$PresentationDefinitionImpl>
      get copyWith => __$$PresentationDefinitionImplCopyWithImpl<
          _$PresentationDefinitionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresentationDefinitionImplToJson(
      this,
    );
  }
}

abstract class _PresentationDefinition implements PresentationDefinition {
  const factory _PresentationDefinition(
      {required final String id,
      @JsonKey(name: 'input_descriptors')
      required final List<InputDescriptor> inputDescriptors,
      @JsonKey(name: 'submission_requirements')
      final List<Map<String, dynamic>>? submissionRequirements,
      final String? name,
      final String? purpose}) = _$PresentationDefinitionImpl;

  factory _PresentationDefinition.fromJson(Map<String, dynamic> json) =
      _$PresentationDefinitionImpl.fromJson;

  @override

  /// Identificador único de la definition.
  String get id;
  @override

  /// Lista de descriptores de input (uno por credencial requerida).
  @JsonKey(name: 'input_descriptors')
  List<InputDescriptor> get inputDescriptors;
  @override

  /// Requisitos de combinación entre input descriptors (PEX avanzado).
  @JsonKey(name: 'submission_requirements')
  List<Map<String, dynamic>>? get submissionRequirements;
  @override

  /// Nombre descriptivo de la solicitud.
  String? get name;
  @override

  /// Propósito de la solicitud (para mostrar al usuario).
  String? get purpose;
  @override
  @JsonKey(ignore: true)
  _$$PresentationDefinitionImplCopyWith<_$PresentationDefinitionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

InputDescriptor _$InputDescriptorFromJson(Map<String, dynamic> json) {
  return _InputDescriptor.fromJson(json);
}

/// @nodoc
mixin _$InputDescriptor {
  /// Identificador único del descriptor.
  String get id => throw _privateConstructorUsedError;

  /// Nombre descriptivo del tipo de credencial requerida.
  String? get name => throw _privateConstructorUsedError;

  /// Propósito del uso de esta credencial.
  String? get purpose => throw _privateConstructorUsedError;

  /// Restricciones sobre los claims de la credencial.
  ///
  /// Contiene `fields: List<{path, filter?, optional?}>` como mínimo.
  Map<String, dynamic> get constraints => throw _privateConstructorUsedError;

  /// Formatos de credencial aceptados para este descriptor.
  Map<String, dynamic>? get format => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InputDescriptorCopyWith<InputDescriptor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InputDescriptorCopyWith<$Res> {
  factory $InputDescriptorCopyWith(
          InputDescriptor value, $Res Function(InputDescriptor) then) =
      _$InputDescriptorCopyWithImpl<$Res, InputDescriptor>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? purpose,
      Map<String, dynamic> constraints,
      Map<String, dynamic>? format});
}

/// @nodoc
class _$InputDescriptorCopyWithImpl<$Res, $Val extends InputDescriptor>
    implements $InputDescriptorCopyWith<$Res> {
  _$InputDescriptorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? purpose = freezed,
    Object? constraints = null,
    Object? format = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: null == constraints
          ? _value.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      format: freezed == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InputDescriptorImplCopyWith<$Res>
    implements $InputDescriptorCopyWith<$Res> {
  factory _$$InputDescriptorImplCopyWith(_$InputDescriptorImpl value,
          $Res Function(_$InputDescriptorImpl) then) =
      __$$InputDescriptorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String? purpose,
      Map<String, dynamic> constraints,
      Map<String, dynamic>? format});
}

/// @nodoc
class __$$InputDescriptorImplCopyWithImpl<$Res>
    extends _$InputDescriptorCopyWithImpl<$Res, _$InputDescriptorImpl>
    implements _$$InputDescriptorImplCopyWith<$Res> {
  __$$InputDescriptorImplCopyWithImpl(
      _$InputDescriptorImpl _value, $Res Function(_$InputDescriptorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? purpose = freezed,
    Object? constraints = null,
    Object? format = freezed,
  }) {
    return _then(_$InputDescriptorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: null == constraints
          ? _value._constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      format: freezed == format
          ? _value._format
          : format // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InputDescriptorImpl implements _InputDescriptor {
  const _$InputDescriptorImpl(
      {required this.id,
      this.name,
      this.purpose,
      required final Map<String, dynamic> constraints,
      final Map<String, dynamic>? format})
      : _constraints = constraints,
        _format = format;

  factory _$InputDescriptorImpl.fromJson(Map<String, dynamic> json) =>
      _$$InputDescriptorImplFromJson(json);

  /// Identificador único del descriptor.
  @override
  final String id;

  /// Nombre descriptivo del tipo de credencial requerida.
  @override
  final String? name;

  /// Propósito del uso de esta credencial.
  @override
  final String? purpose;

  /// Restricciones sobre los claims de la credencial.
  ///
  /// Contiene `fields: List<{path, filter?, optional?}>` como mínimo.
  final Map<String, dynamic> _constraints;

  /// Restricciones sobre los claims de la credencial.
  ///
  /// Contiene `fields: List<{path, filter?, optional?}>` como mínimo.
  @override
  Map<String, dynamic> get constraints {
    if (_constraints is EqualUnmodifiableMapView) return _constraints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_constraints);
  }

  /// Formatos de credencial aceptados para este descriptor.
  final Map<String, dynamic>? _format;

  /// Formatos de credencial aceptados para este descriptor.
  @override
  Map<String, dynamic>? get format {
    final value = _format;
    if (value == null) return null;
    if (_format is EqualUnmodifiableMapView) return _format;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'InputDescriptor(id: $id, name: $name, purpose: $purpose, constraints: $constraints, format: $format)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InputDescriptorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            const DeepCollectionEquality()
                .equals(other._constraints, _constraints) &&
            const DeepCollectionEquality().equals(other._format, _format));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      purpose,
      const DeepCollectionEquality().hash(_constraints),
      const DeepCollectionEquality().hash(_format));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InputDescriptorImplCopyWith<_$InputDescriptorImpl> get copyWith =>
      __$$InputDescriptorImplCopyWithImpl<_$InputDescriptorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InputDescriptorImplToJson(
      this,
    );
  }
}

abstract class _InputDescriptor implements InputDescriptor {
  const factory _InputDescriptor(
      {required final String id,
      final String? name,
      final String? purpose,
      required final Map<String, dynamic> constraints,
      final Map<String, dynamic>? format}) = _$InputDescriptorImpl;

  factory _InputDescriptor.fromJson(Map<String, dynamic> json) =
      _$InputDescriptorImpl.fromJson;

  @override

  /// Identificador único del descriptor.
  String get id;
  @override

  /// Nombre descriptivo del tipo de credencial requerida.
  String? get name;
  @override

  /// Propósito del uso de esta credencial.
  String? get purpose;
  @override

  /// Restricciones sobre los claims de la credencial.
  ///
  /// Contiene `fields: List<{path, filter?, optional?}>` como mínimo.
  Map<String, dynamic> get constraints;
  @override

  /// Formatos de credencial aceptados para este descriptor.
  Map<String, dynamic>? get format;
  @override
  @JsonKey(ignore: true)
  _$$InputDescriptorImplCopyWith<_$InputDescriptorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
