// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mdoc_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MdocRecord {
  /// Identificador único. Formato: `'mdoc-{uuid}'`.
  String get id => throw _privateConstructorUsedError;

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Tipo de documento mDoc (ej. `'eu.europa.ec.eudi.pid_mdoc'`).
  String get docType => throw _privateConstructorUsedError;

  /// Atributos agrupados por namespace.
  ///
  /// Estructura: `{ namespace: { claimName: claimValue } }`
  /// Ejemplo: `{ 'eu.europa.ec.eudi.pid.1': { 'family_name': 'García' } }`
  Map<String, Map<String, dynamic>> get namespaces =>
      throw _privateConstructorUsedError;

  /// Bytes CBOR del `IssuerSigned` firmado, necesarios para la presentación offline.
  Uint8List get issuerSignedBytes => throw _privateConstructorUsedError;

  /// Metadata de visualización extraída del credential endpoint.
  Map<String, dynamic>? get displayMetadata =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MdocRecordCopyWith<MdocRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MdocRecordCopyWith<$Res> {
  factory $MdocRecordCopyWith(
          MdocRecord value, $Res Function(MdocRecord) then) =
      _$MdocRecordCopyWithImpl<$Res, MdocRecord>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String docType,
      Map<String, Map<String, dynamic>> namespaces,
      Uint8List issuerSignedBytes,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class _$MdocRecordCopyWithImpl<$Res, $Val extends MdocRecord>
    implements $MdocRecordCopyWith<$Res> {
  _$MdocRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? docType = null,
    Object? namespaces = null,
    Object? issuerSignedBytes = null,
    Object? displayMetadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      docType: null == docType
          ? _value.docType
          : docType // ignore: cast_nullable_to_non_nullable
              as String,
      namespaces: null == namespaces
          ? _value.namespaces
          : namespaces // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, dynamic>>,
      issuerSignedBytes: null == issuerSignedBytes
          ? _value.issuerSignedBytes
          : issuerSignedBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      displayMetadata: freezed == displayMetadata
          ? _value.displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MdocRecordImplCopyWith<$Res>
    implements $MdocRecordCopyWith<$Res> {
  factory _$$MdocRecordImplCopyWith(
          _$MdocRecordImpl value, $Res Function(_$MdocRecordImpl) then) =
      __$$MdocRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String docType,
      Map<String, Map<String, dynamic>> namespaces,
      Uint8List issuerSignedBytes,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class __$$MdocRecordImplCopyWithImpl<$Res>
    extends _$MdocRecordCopyWithImpl<$Res, _$MdocRecordImpl>
    implements _$$MdocRecordImplCopyWith<$Res> {
  __$$MdocRecordImplCopyWithImpl(
      _$MdocRecordImpl _value, $Res Function(_$MdocRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? docType = null,
    Object? namespaces = null,
    Object? issuerSignedBytes = null,
    Object? displayMetadata = freezed,
  }) {
    return _then(_$MdocRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      docType: null == docType
          ? _value.docType
          : docType // ignore: cast_nullable_to_non_nullable
              as String,
      namespaces: null == namespaces
          ? _value._namespaces
          : namespaces // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, dynamic>>,
      issuerSignedBytes: null == issuerSignedBytes
          ? _value.issuerSignedBytes
          : issuerSignedBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      displayMetadata: freezed == displayMetadata
          ? _value._displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$MdocRecordImpl extends _MdocRecord {
  const _$MdocRecordImpl(
      {required this.id,
      required this.createdAt,
      required this.docType,
      required final Map<String, Map<String, dynamic>> namespaces,
      required this.issuerSignedBytes,
      final Map<String, dynamic>? displayMetadata})
      : _namespaces = namespaces,
        _displayMetadata = displayMetadata,
        super._();

  /// Identificador único. Formato: `'mdoc-{uuid}'`.
  @override
  final String id;

  /// Fecha de almacenamiento en el wallet.
  @override
  final DateTime createdAt;

  /// Tipo de documento mDoc (ej. `'eu.europa.ec.eudi.pid_mdoc'`).
  @override
  final String docType;

  /// Atributos agrupados por namespace.
  ///
  /// Estructura: `{ namespace: { claimName: claimValue } }`
  /// Ejemplo: `{ 'eu.europa.ec.eudi.pid.1': { 'family_name': 'García' } }`
  final Map<String, Map<String, dynamic>> _namespaces;

  /// Atributos agrupados por namespace.
  ///
  /// Estructura: `{ namespace: { claimName: claimValue } }`
  /// Ejemplo: `{ 'eu.europa.ec.eudi.pid.1': { 'family_name': 'García' } }`
  @override
  Map<String, Map<String, dynamic>> get namespaces {
    if (_namespaces is EqualUnmodifiableMapView) return _namespaces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_namespaces);
  }

  /// Bytes CBOR del `IssuerSigned` firmado, necesarios para la presentación offline.
  @override
  final Uint8List issuerSignedBytes;

  /// Metadata de visualización extraída del credential endpoint.
  final Map<String, dynamic>? _displayMetadata;

  /// Metadata de visualización extraída del credential endpoint.
  @override
  Map<String, dynamic>? get displayMetadata {
    final value = _displayMetadata;
    if (value == null) return null;
    if (_displayMetadata is EqualUnmodifiableMapView) return _displayMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MdocRecord(id: $id, createdAt: $createdAt, docType: $docType, namespaces: $namespaces, issuerSignedBytes: $issuerSignedBytes, displayMetadata: $displayMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MdocRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            const DeepCollectionEquality()
                .equals(other._namespaces, _namespaces) &&
            const DeepCollectionEquality()
                .equals(other.issuerSignedBytes, issuerSignedBytes) &&
            const DeepCollectionEquality()
                .equals(other._displayMetadata, _displayMetadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      docType,
      const DeepCollectionEquality().hash(_namespaces),
      const DeepCollectionEquality().hash(issuerSignedBytes),
      const DeepCollectionEquality().hash(_displayMetadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MdocRecordImplCopyWith<_$MdocRecordImpl> get copyWith =>
      __$$MdocRecordImplCopyWithImpl<_$MdocRecordImpl>(this, _$identity);
}

abstract class _MdocRecord extends MdocRecord {
  const factory _MdocRecord(
      {required final String id,
      required final DateTime createdAt,
      required final String docType,
      required final Map<String, Map<String, dynamic>> namespaces,
      required final Uint8List issuerSignedBytes,
      final Map<String, dynamic>? displayMetadata}) = _$MdocRecordImpl;
  const _MdocRecord._() : super._();

  @override

  /// Identificador único. Formato: `'mdoc-{uuid}'`.
  String get id;
  @override

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt;
  @override

  /// Tipo de documento mDoc (ej. `'eu.europa.ec.eudi.pid_mdoc'`).
  String get docType;
  @override

  /// Atributos agrupados por namespace.
  ///
  /// Estructura: `{ namespace: { claimName: claimValue } }`
  /// Ejemplo: `{ 'eu.europa.ec.eudi.pid.1': { 'family_name': 'García' } }`
  Map<String, Map<String, dynamic>> get namespaces;
  @override

  /// Bytes CBOR del `IssuerSigned` firmado, necesarios para la presentación offline.
  Uint8List get issuerSignedBytes;
  @override

  /// Metadata de visualización extraída del credential endpoint.
  Map<String, dynamic>? get displayMetadata;
  @override
  @JsonKey(ignore: true)
  _$$MdocRecordImplCopyWith<_$MdocRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
