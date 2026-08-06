// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sd_jwt_vc_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SdJwtVcRecord {
  /// Identificador único de la credencial. Formato: `'sd-jwt-vc-{uuid}'`.
  String get id => throw _privateConstructorUsedError;

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Token SD-JWT compacto completo, incluyendo todas las disclosures del issuer.
  ///
  /// Formato: `{issuer-jwt}~{disclosure1}~{disclosure2}~...~`
  String get compactSdJwt => throw _privateConstructorUsedError;

  /// Tipo de credencial declarado por el issuer en el claim `vct`.
  ///
  /// Ejemplo: `'eu.europa.ec.eudi.pid_vc_sd_jwt'`
  String get vct => throw _privateConstructorUsedError;

  /// Claims decodificados con todas las disclosures aplicadas.
  ///
  /// Listo para mostrar en UI sin re-parsear el SD-JWT.
  Map<String, dynamic> get prettyClaims => throw _privateConstructorUsedError;

  /// Metadata del issuer obtenida del endpoint `/.well-known/openid-credential-issuer`.
  Map<String, dynamic>? get issuerMetadata =>
      throw _privateConstructorUsedError;

  /// Metadata de visualización (nombre, colores, logo) extraída de [issuerMetadata].
  Map<String, dynamic>? get displayMetadata =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SdJwtVcRecordCopyWith<SdJwtVcRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SdJwtVcRecordCopyWith<$Res> {
  factory $SdJwtVcRecordCopyWith(
          SdJwtVcRecord value, $Res Function(SdJwtVcRecord) then) =
      _$SdJwtVcRecordCopyWithImpl<$Res, SdJwtVcRecord>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String compactSdJwt,
      String vct,
      Map<String, dynamic> prettyClaims,
      Map<String, dynamic>? issuerMetadata,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class _$SdJwtVcRecordCopyWithImpl<$Res, $Val extends SdJwtVcRecord>
    implements $SdJwtVcRecordCopyWith<$Res> {
  _$SdJwtVcRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? compactSdJwt = null,
    Object? vct = null,
    Object? prettyClaims = null,
    Object? issuerMetadata = freezed,
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
      compactSdJwt: null == compactSdJwt
          ? _value.compactSdJwt
          : compactSdJwt // ignore: cast_nullable_to_non_nullable
              as String,
      vct: null == vct
          ? _value.vct
          : vct // ignore: cast_nullable_to_non_nullable
              as String,
      prettyClaims: null == prettyClaims
          ? _value.prettyClaims
          : prettyClaims // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      issuerMetadata: freezed == issuerMetadata
          ? _value.issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      displayMetadata: freezed == displayMetadata
          ? _value.displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SdJwtVcRecordImplCopyWith<$Res>
    implements $SdJwtVcRecordCopyWith<$Res> {
  factory _$$SdJwtVcRecordImplCopyWith(
          _$SdJwtVcRecordImpl value, $Res Function(_$SdJwtVcRecordImpl) then) =
      __$$SdJwtVcRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String compactSdJwt,
      String vct,
      Map<String, dynamic> prettyClaims,
      Map<String, dynamic>? issuerMetadata,
      Map<String, dynamic>? displayMetadata});
}

/// @nodoc
class __$$SdJwtVcRecordImplCopyWithImpl<$Res>
    extends _$SdJwtVcRecordCopyWithImpl<$Res, _$SdJwtVcRecordImpl>
    implements _$$SdJwtVcRecordImplCopyWith<$Res> {
  __$$SdJwtVcRecordImplCopyWithImpl(
      _$SdJwtVcRecordImpl _value, $Res Function(_$SdJwtVcRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? compactSdJwt = null,
    Object? vct = null,
    Object? prettyClaims = null,
    Object? issuerMetadata = freezed,
    Object? displayMetadata = freezed,
  }) {
    return _then(_$SdJwtVcRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      compactSdJwt: null == compactSdJwt
          ? _value.compactSdJwt
          : compactSdJwt // ignore: cast_nullable_to_non_nullable
              as String,
      vct: null == vct
          ? _value.vct
          : vct // ignore: cast_nullable_to_non_nullable
              as String,
      prettyClaims: null == prettyClaims
          ? _value._prettyClaims
          : prettyClaims // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      issuerMetadata: freezed == issuerMetadata
          ? _value._issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      displayMetadata: freezed == displayMetadata
          ? _value._displayMetadata
          : displayMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$SdJwtVcRecordImpl extends _SdJwtVcRecord {
  const _$SdJwtVcRecordImpl(
      {required this.id,
      required this.createdAt,
      required this.compactSdJwt,
      required this.vct,
      required final Map<String, dynamic> prettyClaims,
      final Map<String, dynamic>? issuerMetadata,
      final Map<String, dynamic>? displayMetadata})
      : _prettyClaims = prettyClaims,
        _issuerMetadata = issuerMetadata,
        _displayMetadata = displayMetadata,
        super._();

  /// Identificador único de la credencial. Formato: `'sd-jwt-vc-{uuid}'`.
  @override
  final String id;

  /// Fecha de almacenamiento en el wallet.
  @override
  final DateTime createdAt;

  /// Token SD-JWT compacto completo, incluyendo todas las disclosures del issuer.
  ///
  /// Formato: `{issuer-jwt}~{disclosure1}~{disclosure2}~...~`
  @override
  final String compactSdJwt;

  /// Tipo de credencial declarado por el issuer en el claim `vct`.
  ///
  /// Ejemplo: `'eu.europa.ec.eudi.pid_vc_sd_jwt'`
  @override
  final String vct;

  /// Claims decodificados con todas las disclosures aplicadas.
  ///
  /// Listo para mostrar en UI sin re-parsear el SD-JWT.
  final Map<String, dynamic> _prettyClaims;

  /// Claims decodificados con todas las disclosures aplicadas.
  ///
  /// Listo para mostrar en UI sin re-parsear el SD-JWT.
  @override
  Map<String, dynamic> get prettyClaims {
    if (_prettyClaims is EqualUnmodifiableMapView) return _prettyClaims;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prettyClaims);
  }

  /// Metadata del issuer obtenida del endpoint `/.well-known/openid-credential-issuer`.
  final Map<String, dynamic>? _issuerMetadata;

  /// Metadata del issuer obtenida del endpoint `/.well-known/openid-credential-issuer`.
  @override
  Map<String, dynamic>? get issuerMetadata {
    final value = _issuerMetadata;
    if (value == null) return null;
    if (_issuerMetadata is EqualUnmodifiableMapView) return _issuerMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Metadata de visualización (nombre, colores, logo) extraída de [issuerMetadata].
  final Map<String, dynamic>? _displayMetadata;

  /// Metadata de visualización (nombre, colores, logo) extraída de [issuerMetadata].
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
    return 'SdJwtVcRecord(id: $id, createdAt: $createdAt, compactSdJwt: $compactSdJwt, vct: $vct, prettyClaims: $prettyClaims, issuerMetadata: $issuerMetadata, displayMetadata: $displayMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SdJwtVcRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.compactSdJwt, compactSdJwt) ||
                other.compactSdJwt == compactSdJwt) &&
            (identical(other.vct, vct) || other.vct == vct) &&
            const DeepCollectionEquality()
                .equals(other._prettyClaims, _prettyClaims) &&
            const DeepCollectionEquality()
                .equals(other._issuerMetadata, _issuerMetadata) &&
            const DeepCollectionEquality()
                .equals(other._displayMetadata, _displayMetadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      compactSdJwt,
      vct,
      const DeepCollectionEquality().hash(_prettyClaims),
      const DeepCollectionEquality().hash(_issuerMetadata),
      const DeepCollectionEquality().hash(_displayMetadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SdJwtVcRecordImplCopyWith<_$SdJwtVcRecordImpl> get copyWith =>
      __$$SdJwtVcRecordImplCopyWithImpl<_$SdJwtVcRecordImpl>(this, _$identity);
}

abstract class _SdJwtVcRecord extends SdJwtVcRecord {
  const factory _SdJwtVcRecord(
      {required final String id,
      required final DateTime createdAt,
      required final String compactSdJwt,
      required final String vct,
      required final Map<String, dynamic> prettyClaims,
      final Map<String, dynamic>? issuerMetadata,
      final Map<String, dynamic>? displayMetadata}) = _$SdJwtVcRecordImpl;
  const _SdJwtVcRecord._() : super._();

  @override

  /// Identificador único de la credencial. Formato: `'sd-jwt-vc-{uuid}'`.
  String get id;
  @override

  /// Fecha de almacenamiento en el wallet.
  DateTime get createdAt;
  @override

  /// Token SD-JWT compacto completo, incluyendo todas las disclosures del issuer.
  ///
  /// Formato: `{issuer-jwt}~{disclosure1}~{disclosure2}~...~`
  String get compactSdJwt;
  @override

  /// Tipo de credencial declarado por el issuer en el claim `vct`.
  ///
  /// Ejemplo: `'eu.europa.ec.eudi.pid_vc_sd_jwt'`
  String get vct;
  @override

  /// Claims decodificados con todas las disclosures aplicadas.
  ///
  /// Listo para mostrar en UI sin re-parsear el SD-JWT.
  Map<String, dynamic> get prettyClaims;
  @override

  /// Metadata del issuer obtenida del endpoint `/.well-known/openid-credential-issuer`.
  Map<String, dynamic>? get issuerMetadata;
  @override

  /// Metadata de visualización (nombre, colores, logo) extraída de [issuerMetadata].
  Map<String, dynamic>? get displayMetadata;
  @override
  @JsonKey(ignore: true)
  _$$SdJwtVcRecordImplCopyWith<_$SdJwtVcRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
