// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'w3c_credential_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$W3cCredentialRecord {
  /// Identificador único. Formato: `'w3c-credential-{uuid}'`.
  String get id => throw _privateConstructorUsedError;

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Formato exacto de la credencial (JWT o JSON-LD).
  ClaimFormat get claimFormat => throw _privateConstructorUsedError;

  /// Objeto JSON completo de la W3C Verifiable Credential.
  Map<String, dynamic> get credential => throw _privateConstructorUsedError;

  /// Tipos declarados en el campo `type` de la credencial.
  ///
  /// Ejemplo: `['VerifiableCredential', 'UniversityDegreeCredential']`
  List<String> get types => throw _privateConstructorUsedError;

  /// DID del issuer.
  String? get issuerDid => throw _privateConstructorUsedError;

  /// DID del holder (claim `credentialSubject.id`).
  String? get holderDid => throw _privateConstructorUsedError;

  /// Inicio de validez (`validFrom` o `issuanceDate`).
  DateTime? get validFrom => throw _privateConstructorUsedError;

  /// Fin de validez (`validUntil` o `expirationDate`).
  DateTime? get validUntil => throw _privateConstructorUsedError;

  /// Metadata de visualización extraída de la credencial.
  Map<String, dynamic>? get displayMetadata =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $W3cCredentialRecordCopyWith<W3cCredentialRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $W3cCredentialRecordCopyWith<$Res> {
  factory $W3cCredentialRecordCopyWith(
          W3cCredentialRecord value, $Res Function(W3cCredentialRecord) then) =
      _$W3cCredentialRecordCopyWithImpl<$Res, W3cCredentialRecord>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      ClaimFormat claimFormat,
      Map<String, dynamic> credential,
      List<String> types,
      String? issuerDid,
      String? holderDid,
      DateTime? validFrom,
      DateTime? validUntil,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class _$W3cCredentialRecordCopyWithImpl<$Res, $Val extends W3cCredentialRecord>
    implements $W3cCredentialRecordCopyWith<$Res> {
  _$W3cCredentialRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? claimFormat = null,
    Object? credential = null,
    Object? types = null,
    Object? issuerDid = freezed,
    Object? holderDid = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
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
      claimFormat: null == claimFormat
          ? _value.claimFormat
          : claimFormat // ignore: cast_nullable_to_non_nullable
              as ClaimFormat,
      credential: null == credential
          ? _value.credential
          : credential // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issuerDid: freezed == issuerDid
          ? _value.issuerDid
          : issuerDid // ignore: cast_nullable_to_non_nullable
              as String?,
      holderDid: freezed == holderDid
          ? _value.holderDid
          : holderDid // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      displayMetadata: freezed == displayMetadata
          ? _value.displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$W3cCredentialRecordImplCopyWith<$Res>
    implements $W3cCredentialRecordCopyWith<$Res> {
  factory _$$W3cCredentialRecordImplCopyWith(_$W3cCredentialRecordImpl value,
          $Res Function(_$W3cCredentialRecordImpl) then) =
      __$$W3cCredentialRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      ClaimFormat claimFormat,
      Map<String, dynamic> credential,
      List<String> types,
      String? issuerDid,
      String? holderDid,
      DateTime? validFrom,
      DateTime? validUntil,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class __$$W3cCredentialRecordImplCopyWithImpl<$Res>
    extends _$W3cCredentialRecordCopyWithImpl<$Res, _$W3cCredentialRecordImpl>
    implements _$$W3cCredentialRecordImplCopyWith<$Res> {
  __$$W3cCredentialRecordImplCopyWithImpl(_$W3cCredentialRecordImpl _value,
      $Res Function(_$W3cCredentialRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? claimFormat = null,
    Object? credential = null,
    Object? types = null,
    Object? issuerDid = freezed,
    Object? holderDid = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? displayMetadata = freezed,
  }) {
    return _then(_$W3cCredentialRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimFormat: null == claimFormat
          ? _value.claimFormat
          : claimFormat // ignore: cast_nullable_to_non_nullable
              as ClaimFormat,
      credential: null == credential
          ? _value._credential
          : credential // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      types: null == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issuerDid: freezed == issuerDid
          ? _value.issuerDid
          : issuerDid // ignore: cast_nullable_to_non_nullable
              as String?,
      holderDid: freezed == holderDid
          ? _value.holderDid
          : holderDid // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      displayMetadata: freezed == displayMetadata
          ? _value._displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$W3cCredentialRecordImpl extends _W3cCredentialRecord {
  const _$W3cCredentialRecordImpl(
      {required this.id,
      required this.createdAt,
      required this.claimFormat,
      required final Map<String, dynamic> credential,
      required final List<String> types,
      this.issuerDid,
      this.holderDid,
      this.validFrom,
      this.validUntil,
      final Map<String, dynamic>? displayMetadata})
      : _credential = credential,
        _types = types,
        _displayMetadata = displayMetadata,
        super._();

  /// Identificador único. Formato: `'w3c-credential-{uuid}'`.
  @override
  final String id;

  /// Fecha de almacenamiento en el wallet.
  @override
  final DateTime createdAt;

  /// Formato exacto de la credencial (JWT o JSON-LD).
  @override
  final ClaimFormat claimFormat;

  /// Objeto JSON completo de la W3C Verifiable Credential.
  final Map<String, dynamic> _credential;

  /// Objeto JSON completo de la W3C Verifiable Credential.
  @override
  Map<String, dynamic> get credential {
    if (_credential is EqualUnmodifiableMapView) return _credential;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_credential);
  }

  /// Tipos declarados en el campo `type` de la credencial.
  ///
  /// Ejemplo: `['VerifiableCredential', 'UniversityDegreeCredential']`
  final List<String> _types;

  /// Tipos declarados en el campo `type` de la credencial.
  ///
  /// Ejemplo: `['VerifiableCredential', 'UniversityDegreeCredential']`
  @override
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  /// DID del issuer.
  @override
  final String? issuerDid;

  /// DID del holder (claim `credentialSubject.id`).
  @override
  final String? holderDid;

  /// Inicio de validez (`validFrom` o `issuanceDate`).
  @override
  final DateTime? validFrom;

  /// Fin de validez (`validUntil` o `expirationDate`).
  @override
  final DateTime? validUntil;

  /// Metadata de visualización extraída de la credencial.
  final Map<String, dynamic>? _displayMetadata;

  /// Metadata de visualización extraída de la credencial.
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
    return 'W3cCredentialRecord(id: $id, createdAt: $createdAt, claimFormat: $claimFormat, credential: $credential, types: $types, issuerDid: $issuerDid, holderDid: $holderDid, validFrom: $validFrom, validUntil: $validUntil, displayMetadata: $displayMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$W3cCredentialRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.claimFormat, claimFormat) ||
                other.claimFormat == claimFormat) &&
            const DeepCollectionEquality()
                .equals(other._credential, _credential) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.issuerDid, issuerDid) ||
                other.issuerDid == issuerDid) &&
            (identical(other.holderDid, holderDid) ||
                other.holderDid == holderDid) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            const DeepCollectionEquality()
                .equals(other._displayMetadata, _displayMetadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      claimFormat,
      const DeepCollectionEquality().hash(_credential),
      const DeepCollectionEquality().hash(_types),
      issuerDid,
      holderDid,
      validFrom,
      validUntil,
      const DeepCollectionEquality().hash(_displayMetadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$W3cCredentialRecordImplCopyWith<_$W3cCredentialRecordImpl> get copyWith =>
      __$$W3cCredentialRecordImplCopyWithImpl<_$W3cCredentialRecordImpl>(
          this, _$identity);
}

abstract class _W3cCredentialRecord extends W3cCredentialRecord {
  const factory _W3cCredentialRecord(
      {required final String id,
      required final DateTime createdAt,
      required final ClaimFormat claimFormat,
      required final Map<String, dynamic> credential,
      required final List<String> types,
      final String? issuerDid,
      final String? holderDid,
      final DateTime? validFrom,
      final DateTime? validUntil,
      final Map<String, dynamic>? displayMetadata}) = _$W3cCredentialRecordImpl;
  const _W3cCredentialRecord._() : super._();

  @override

  /// Identificador único. Formato: `'w3c-credential-{uuid}'`.
  String get id;
  @override

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt;
  @override

  /// Formato exacto de la credencial (JWT o JSON-LD).
  ClaimFormat get claimFormat;
  @override

  /// Objeto JSON completo de la W3C Verifiable Credential.
  Map<String, dynamic> get credential;
  @override

  /// Tipos declarados en el campo `type` de la credencial.
  ///
  /// Ejemplo: `['VerifiableCredential', 'UniversityDegreeCredential']`
  List<String> get types;
  @override

  /// DID del issuer.
  String? get issuerDid;
  @override

  /// DID del holder (claim `credentialSubject.id`).
  String? get holderDid;
  @override

  /// Inicio de validez (`validFrom` o `issuanceDate`).
  DateTime? get validFrom;
  @override

  /// Fin de validez (`validUntil` o `expirationDate`).
  DateTime? get validUntil;
  @override

  /// Metadata de visualización extraída de la credencial.
  Map<String, dynamic>? get displayMetadata;
  @override
  @JsonKey(ignore: true)
  _$$W3cCredentialRecordImplCopyWith<_$W3cCredentialRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
