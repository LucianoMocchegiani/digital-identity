// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrustedEntity {
  TrustMechanismType get trustMechanism => throw _privateConstructorUsedError;
  RelyingParty get relyingParty => throw _privateConstructorUsedError;

  /// `true` si la cadena de confianza fue verificada correctamente.
  bool get isVerified => throw _privateConstructorUsedError;

  /// Cadena de certificados X.509 en base64 DER (solo para [TrustMechanismType.x509]).
  List<String>? get certificateChain => throw _privateConstructorUsedError;

  /// DID del verifier (solo para [TrustMechanismType.did]).
  String? get did => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TrustedEntityCopyWith<TrustedEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustedEntityCopyWith<$Res> {
  factory $TrustedEntityCopyWith(
          TrustedEntity value, $Res Function(TrustedEntity) then) =
      _$TrustedEntityCopyWithImpl<$Res, TrustedEntity>;
  @useResult
  $Res call(
      {TrustMechanismType trustMechanism,
      RelyingParty relyingParty,
      bool isVerified,
      List<String>? certificateChain,
      String? did});

  $RelyingPartyCopyWith<$Res> get relyingParty;
}

/// @nodoc
class _$TrustedEntityCopyWithImpl<$Res, $Val extends TrustedEntity>
    implements $TrustedEntityCopyWith<$Res> {
  _$TrustedEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trustMechanism = null,
    Object? relyingParty = null,
    Object? isVerified = null,
    Object? certificateChain = freezed,
    Object? did = freezed,
  }) {
    return _then(_value.copyWith(
      trustMechanism: null == trustMechanism
          ? _value.trustMechanism
          : trustMechanism // ignore: cast_nullable_to_non_nullable
              as TrustMechanismType,
      relyingParty: null == relyingParty
          ? _value.relyingParty
          : relyingParty // ignore: cast_nullable_to_non_nullable
              as RelyingParty,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateChain: freezed == certificateChain
          ? _value.certificateChain
          : certificateChain // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RelyingPartyCopyWith<$Res> get relyingParty {
    return $RelyingPartyCopyWith<$Res>(_value.relyingParty, (value) {
      return _then(_value.copyWith(relyingParty: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrustedEntityImplCopyWith<$Res>
    implements $TrustedEntityCopyWith<$Res> {
  factory _$$TrustedEntityImplCopyWith(
          _$TrustedEntityImpl value, $Res Function(_$TrustedEntityImpl) then) =
      __$$TrustedEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TrustMechanismType trustMechanism,
      RelyingParty relyingParty,
      bool isVerified,
      List<String>? certificateChain,
      String? did});

  @override
  $RelyingPartyCopyWith<$Res> get relyingParty;
}

/// @nodoc
class __$$TrustedEntityImplCopyWithImpl<$Res>
    extends _$TrustedEntityCopyWithImpl<$Res, _$TrustedEntityImpl>
    implements _$$TrustedEntityImplCopyWith<$Res> {
  __$$TrustedEntityImplCopyWithImpl(
      _$TrustedEntityImpl _value, $Res Function(_$TrustedEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trustMechanism = null,
    Object? relyingParty = null,
    Object? isVerified = null,
    Object? certificateChain = freezed,
    Object? did = freezed,
  }) {
    return _then(_$TrustedEntityImpl(
      trustMechanism: null == trustMechanism
          ? _value.trustMechanism
          : trustMechanism // ignore: cast_nullable_to_non_nullable
              as TrustMechanismType,
      relyingParty: null == relyingParty
          ? _value.relyingParty
          : relyingParty // ignore: cast_nullable_to_non_nullable
              as RelyingParty,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateChain: freezed == certificateChain
          ? _value._certificateChain
          : certificateChain // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TrustedEntityImpl implements _TrustedEntity {
  const _$TrustedEntityImpl(
      {required this.trustMechanism,
      required this.relyingParty,
      required this.isVerified,
      final List<String>? certificateChain,
      this.did})
      : _certificateChain = certificateChain;

  @override
  final TrustMechanismType trustMechanism;
  @override
  final RelyingParty relyingParty;

  /// `true` si la cadena de confianza fue verificada correctamente.
  @override
  final bool isVerified;

  /// Cadena de certificados X.509 en base64 DER (solo para [TrustMechanismType.x509]).
  final List<String>? _certificateChain;

  /// Cadena de certificados X.509 en base64 DER (solo para [TrustMechanismType.x509]).
  @override
  List<String>? get certificateChain {
    final value = _certificateChain;
    if (value == null) return null;
    if (_certificateChain is EqualUnmodifiableListView)
      return _certificateChain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// DID del verifier (solo para [TrustMechanismType.did]).
  @override
  final String? did;

  @override
  String toString() {
    return 'TrustedEntity(trustMechanism: $trustMechanism, relyingParty: $relyingParty, isVerified: $isVerified, certificateChain: $certificateChain, did: $did)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustedEntityImpl &&
            (identical(other.trustMechanism, trustMechanism) ||
                other.trustMechanism == trustMechanism) &&
            (identical(other.relyingParty, relyingParty) ||
                other.relyingParty == relyingParty) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            const DeepCollectionEquality()
                .equals(other._certificateChain, _certificateChain) &&
            (identical(other.did, did) || other.did == did));
  }

  @override
  int get hashCode => Object.hash(runtimeType, trustMechanism, relyingParty,
      isVerified, const DeepCollectionEquality().hash(_certificateChain), did);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustedEntityImplCopyWith<_$TrustedEntityImpl> get copyWith =>
      __$$TrustedEntityImplCopyWithImpl<_$TrustedEntityImpl>(this, _$identity);
}

abstract class _TrustedEntity implements TrustedEntity {
  const factory _TrustedEntity(
      {required final TrustMechanismType trustMechanism,
      required final RelyingParty relyingParty,
      required final bool isVerified,
      final List<String>? certificateChain,
      final String? did}) = _$TrustedEntityImpl;

  @override
  TrustMechanismType get trustMechanism;
  @override
  RelyingParty get relyingParty;
  @override

  /// `true` si la cadena de confianza fue verificada correctamente.
  bool get isVerified;
  @override

  /// Cadena de certificados X.509 en base64 DER (solo para [TrustMechanismType.x509]).
  List<String>? get certificateChain;
  @override

  /// DID del verifier (solo para [TrustMechanismType.did]).
  String? get did;
  @override
  @JsonKey(ignore: true)
  _$$TrustedEntityImplCopyWith<_$TrustedEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RelyingParty {
  /// Identificador de la entidad — `client_id` del authorization request.
  String get entityId => throw _privateConstructorUsedError;

  /// Nombre de la organización, extraído del Subject DN (X.509) o `client_metadata`.
  String? get organizationName => throw _privateConstructorUsedError;

  /// URI del logo del verifier.
  String? get logoUri => throw _privateConstructorUsedError;

  /// URI de la entidad (extraído de SAN URI o `client_metadata`).
  String? get uri => throw _privateConstructorUsedError;

  /// Dominio del verifier (extraído de SAN DNS del certificado leaf).
  String? get domain => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RelyingPartyCopyWith<RelyingParty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelyingPartyCopyWith<$Res> {
  factory $RelyingPartyCopyWith(
          RelyingParty value, $Res Function(RelyingParty) then) =
      _$RelyingPartyCopyWithImpl<$Res, RelyingParty>;
  @useResult
  $Res call(
      {String entityId,
      String? organizationName,
      String? logoUri,
      String? uri,
      String? domain});
}

/// @nodoc
class _$RelyingPartyCopyWithImpl<$Res, $Val extends RelyingParty>
    implements $RelyingPartyCopyWith<$Res> {
  _$RelyingPartyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? organizationName = freezed,
    Object? logoUri = freezed,
    Object? uri = freezed,
    Object? domain = freezed,
  }) {
    return _then(_value.copyWith(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      organizationName: freezed == organizationName
          ? _value.organizationName
          : organizationName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUri: freezed == logoUri
          ? _value.logoUri
          : logoUri // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelyingPartyImplCopyWith<$Res>
    implements $RelyingPartyCopyWith<$Res> {
  factory _$$RelyingPartyImplCopyWith(
          _$RelyingPartyImpl value, $Res Function(_$RelyingPartyImpl) then) =
      __$$RelyingPartyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String entityId,
      String? organizationName,
      String? logoUri,
      String? uri,
      String? domain});
}

/// @nodoc
class __$$RelyingPartyImplCopyWithImpl<$Res>
    extends _$RelyingPartyCopyWithImpl<$Res, _$RelyingPartyImpl>
    implements _$$RelyingPartyImplCopyWith<$Res> {
  __$$RelyingPartyImplCopyWithImpl(
      _$RelyingPartyImpl _value, $Res Function(_$RelyingPartyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? organizationName = freezed,
    Object? logoUri = freezed,
    Object? uri = freezed,
    Object? domain = freezed,
  }) {
    return _then(_$RelyingPartyImpl(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      organizationName: freezed == organizationName
          ? _value.organizationName
          : organizationName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUri: freezed == logoUri
          ? _value.logoUri
          : logoUri // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RelyingPartyImpl implements _RelyingParty {
  const _$RelyingPartyImpl(
      {required this.entityId,
      this.organizationName,
      this.logoUri,
      this.uri,
      this.domain});

  /// Identificador de la entidad — `client_id` del authorization request.
  @override
  final String entityId;

  /// Nombre de la organización, extraído del Subject DN (X.509) o `client_metadata`.
  @override
  final String? organizationName;

  /// URI del logo del verifier.
  @override
  final String? logoUri;

  /// URI de la entidad (extraído de SAN URI o `client_metadata`).
  @override
  final String? uri;

  /// Dominio del verifier (extraído de SAN DNS del certificado leaf).
  @override
  final String? domain;

  @override
  String toString() {
    return 'RelyingParty(entityId: $entityId, organizationName: $organizationName, logoUri: $logoUri, uri: $uri, domain: $domain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelyingPartyImpl &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.logoUri, logoUri) || other.logoUri == logoUri) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.domain, domain) || other.domain == domain));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, entityId, organizationName, logoUri, uri, domain);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RelyingPartyImplCopyWith<_$RelyingPartyImpl> get copyWith =>
      __$$RelyingPartyImplCopyWithImpl<_$RelyingPartyImpl>(this, _$identity);
}

abstract class _RelyingParty implements RelyingParty {
  const factory _RelyingParty(
      {required final String entityId,
      final String? organizationName,
      final String? logoUri,
      final String? uri,
      final String? domain}) = _$RelyingPartyImpl;

  @override

  /// Identificador de la entidad — `client_id` del authorization request.
  String get entityId;
  @override

  /// Nombre de la organización, extraído del Subject DN (X.509) o `client_metadata`.
  String? get organizationName;
  @override

  /// URI del logo del verifier.
  String? get logoUri;
  @override

  /// URI de la entidad (extraído de SAN URI o `client_metadata`).
  String? get uri;
  @override

  /// Dominio del verifier (extraído de SAN DNS del certificado leaf).
  String? get domain;
  @override
  @JsonKey(ignore: true)
  _$$RelyingPartyImplCopyWith<_$RelyingPartyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
