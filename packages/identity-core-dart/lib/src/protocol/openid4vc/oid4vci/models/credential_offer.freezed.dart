// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CredentialOffer _$CredentialOfferFromJson(Map<String, dynamic> json) {
  return _CredentialOffer.fromJson(json);
}

/// @nodoc
mixin _$CredentialOffer {
  /// URL del credential issuer.
  @JsonKey(name: 'credential_issuer')
  String get credentialIssuer => throw _privateConstructorUsedError;

  /// IDs de las configuraciones de credencial ofrecidas.
  @JsonKey(name: 'credential_configuration_ids')
  List<String> get credentialConfigurationIds =>
      throw _privateConstructorUsedError;

  /// Grants disponibles (pre-authorized, authorization code).
  GrantsContainer? get grants => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CredentialOfferCopyWith<CredentialOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialOfferCopyWith<$Res> {
  factory $CredentialOfferCopyWith(
          CredentialOffer value, $Res Function(CredentialOffer) then) =
      _$CredentialOfferCopyWithImpl<$Res, CredentialOffer>;
  @useResult
  $Res call(
      {@JsonKey(name: 'credential_issuer') String credentialIssuer,
      @JsonKey(name: 'credential_configuration_ids')
      List<String> credentialConfigurationIds,
      GrantsContainer? grants});

  $GrantsContainerCopyWith<$Res>? get grants;
}

/// @nodoc
class _$CredentialOfferCopyWithImpl<$Res, $Val extends CredentialOffer>
    implements $CredentialOfferCopyWith<$Res> {
  _$CredentialOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentialIssuer = null,
    Object? credentialConfigurationIds = null,
    Object? grants = freezed,
  }) {
    return _then(_value.copyWith(
      credentialIssuer: null == credentialIssuer
          ? _value.credentialIssuer
          : credentialIssuer // ignore: cast_nullable_to_non_nullable
              as String,
      credentialConfigurationIds: null == credentialConfigurationIds
          ? _value.credentialConfigurationIds
          : credentialConfigurationIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grants: freezed == grants
          ? _value.grants
          : grants // ignore: cast_nullable_to_non_nullable
              as GrantsContainer?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GrantsContainerCopyWith<$Res>? get grants {
    if (_value.grants == null) {
      return null;
    }

    return $GrantsContainerCopyWith<$Res>(_value.grants!, (value) {
      return _then(_value.copyWith(grants: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialOfferImplCopyWith<$Res>
    implements $CredentialOfferCopyWith<$Res> {
  factory _$$CredentialOfferImplCopyWith(_$CredentialOfferImpl value,
          $Res Function(_$CredentialOfferImpl) then) =
      __$$CredentialOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'credential_issuer') String credentialIssuer,
      @JsonKey(name: 'credential_configuration_ids')
      List<String> credentialConfigurationIds,
      GrantsContainer? grants});

  @override
  $GrantsContainerCopyWith<$Res>? get grants;
}

/// @nodoc
class __$$CredentialOfferImplCopyWithImpl<$Res>
    extends _$CredentialOfferCopyWithImpl<$Res, _$CredentialOfferImpl>
    implements _$$CredentialOfferImplCopyWith<$Res> {
  __$$CredentialOfferImplCopyWithImpl(
      _$CredentialOfferImpl _value, $Res Function(_$CredentialOfferImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentialIssuer = null,
    Object? credentialConfigurationIds = null,
    Object? grants = freezed,
  }) {
    return _then(_$CredentialOfferImpl(
      credentialIssuer: null == credentialIssuer
          ? _value.credentialIssuer
          : credentialIssuer // ignore: cast_nullable_to_non_nullable
              as String,
      credentialConfigurationIds: null == credentialConfigurationIds
          ? _value._credentialConfigurationIds
          : credentialConfigurationIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grants: freezed == grants
          ? _value.grants
          : grants // ignore: cast_nullable_to_non_nullable
              as GrantsContainer?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialOfferImpl implements _CredentialOffer {
  const _$CredentialOfferImpl(
      {@JsonKey(name: 'credential_issuer') required this.credentialIssuer,
      @JsonKey(name: 'credential_configuration_ids')
      required final List<String> credentialConfigurationIds,
      this.grants})
      : _credentialConfigurationIds = credentialConfigurationIds;

  factory _$CredentialOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialOfferImplFromJson(json);

  /// URL del credential issuer.
  @override
  @JsonKey(name: 'credential_issuer')
  final String credentialIssuer;

  /// IDs de las configuraciones de credencial ofrecidas.
  final List<String> _credentialConfigurationIds;

  /// IDs de las configuraciones de credencial ofrecidas.
  @override
  @JsonKey(name: 'credential_configuration_ids')
  List<String> get credentialConfigurationIds {
    if (_credentialConfigurationIds is EqualUnmodifiableListView)
      return _credentialConfigurationIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_credentialConfigurationIds);
  }

  /// Grants disponibles (pre-authorized, authorization code).
  @override
  final GrantsContainer? grants;

  @override
  String toString() {
    return 'CredentialOffer(credentialIssuer: $credentialIssuer, credentialConfigurationIds: $credentialConfigurationIds, grants: $grants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialOfferImpl &&
            (identical(other.credentialIssuer, credentialIssuer) ||
                other.credentialIssuer == credentialIssuer) &&
            const DeepCollectionEquality().equals(
                other._credentialConfigurationIds,
                _credentialConfigurationIds) &&
            (identical(other.grants, grants) || other.grants == grants));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, credentialIssuer,
      const DeepCollectionEquality().hash(_credentialConfigurationIds), grants);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialOfferImplCopyWith<_$CredentialOfferImpl> get copyWith =>
      __$$CredentialOfferImplCopyWithImpl<_$CredentialOfferImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialOfferImplToJson(
      this,
    );
  }
}

abstract class _CredentialOffer implements CredentialOffer {
  const factory _CredentialOffer(
      {@JsonKey(name: 'credential_issuer')
      required final String credentialIssuer,
      @JsonKey(name: 'credential_configuration_ids')
      required final List<String> credentialConfigurationIds,
      final GrantsContainer? grants}) = _$CredentialOfferImpl;

  factory _CredentialOffer.fromJson(Map<String, dynamic> json) =
      _$CredentialOfferImpl.fromJson;

  @override

  /// URL del credential issuer.
  @JsonKey(name: 'credential_issuer')
  String get credentialIssuer;
  @override

  /// IDs de las configuraciones de credencial ofrecidas.
  @JsonKey(name: 'credential_configuration_ids')
  List<String> get credentialConfigurationIds;
  @override

  /// Grants disponibles (pre-authorized, authorization code).
  GrantsContainer? get grants;
  @override
  @JsonKey(ignore: true)
  _$$CredentialOfferImplCopyWith<_$CredentialOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrantsContainer _$GrantsContainerFromJson(Map<String, dynamic> json) {
  return _GrantsContainer.fromJson(json);
}

/// @nodoc
mixin _$GrantsContainer {
  /// Grant pre-authorized_code.
  @JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
  PreAuthorizedGrant? get preAuthorized => throw _privateConstructorUsedError;

  /// Grant authorization_code.
  @JsonKey(name: 'authorization_code')
  AuthorizationCodeGrant? get authCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GrantsContainerCopyWith<GrantsContainer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrantsContainerCopyWith<$Res> {
  factory $GrantsContainerCopyWith(
          GrantsContainer value, $Res Function(GrantsContainer) then) =
      _$GrantsContainerCopyWithImpl<$Res, GrantsContainer>;
  @useResult
  $Res call(
      {@JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
      PreAuthorizedGrant? preAuthorized,
      @JsonKey(name: 'authorization_code') AuthorizationCodeGrant? authCode});

  $PreAuthorizedGrantCopyWith<$Res>? get preAuthorized;
  $AuthorizationCodeGrantCopyWith<$Res>? get authCode;
}

/// @nodoc
class _$GrantsContainerCopyWithImpl<$Res, $Val extends GrantsContainer>
    implements $GrantsContainerCopyWith<$Res> {
  _$GrantsContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preAuthorized = freezed,
    Object? authCode = freezed,
  }) {
    return _then(_value.copyWith(
      preAuthorized: freezed == preAuthorized
          ? _value.preAuthorized
          : preAuthorized // ignore: cast_nullable_to_non_nullable
              as PreAuthorizedGrant?,
      authCode: freezed == authCode
          ? _value.authCode
          : authCode // ignore: cast_nullable_to_non_nullable
              as AuthorizationCodeGrant?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PreAuthorizedGrantCopyWith<$Res>? get preAuthorized {
    if (_value.preAuthorized == null) {
      return null;
    }

    return $PreAuthorizedGrantCopyWith<$Res>(_value.preAuthorized!, (value) {
      return _then(_value.copyWith(preAuthorized: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthorizationCodeGrantCopyWith<$Res>? get authCode {
    if (_value.authCode == null) {
      return null;
    }

    return $AuthorizationCodeGrantCopyWith<$Res>(_value.authCode!, (value) {
      return _then(_value.copyWith(authCode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GrantsContainerImplCopyWith<$Res>
    implements $GrantsContainerCopyWith<$Res> {
  factory _$$GrantsContainerImplCopyWith(_$GrantsContainerImpl value,
          $Res Function(_$GrantsContainerImpl) then) =
      __$$GrantsContainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
      PreAuthorizedGrant? preAuthorized,
      @JsonKey(name: 'authorization_code') AuthorizationCodeGrant? authCode});

  @override
  $PreAuthorizedGrantCopyWith<$Res>? get preAuthorized;
  @override
  $AuthorizationCodeGrantCopyWith<$Res>? get authCode;
}

/// @nodoc
class __$$GrantsContainerImplCopyWithImpl<$Res>
    extends _$GrantsContainerCopyWithImpl<$Res, _$GrantsContainerImpl>
    implements _$$GrantsContainerImplCopyWith<$Res> {
  __$$GrantsContainerImplCopyWithImpl(
      _$GrantsContainerImpl _value, $Res Function(_$GrantsContainerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preAuthorized = freezed,
    Object? authCode = freezed,
  }) {
    return _then(_$GrantsContainerImpl(
      preAuthorized: freezed == preAuthorized
          ? _value.preAuthorized
          : preAuthorized // ignore: cast_nullable_to_non_nullable
              as PreAuthorizedGrant?,
      authCode: freezed == authCode
          ? _value.authCode
          : authCode // ignore: cast_nullable_to_non_nullable
              as AuthorizationCodeGrant?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrantsContainerImpl implements _GrantsContainer {
  const _$GrantsContainerImpl(
      {@JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
      this.preAuthorized,
      @JsonKey(name: 'authorization_code') this.authCode});

  factory _$GrantsContainerImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrantsContainerImplFromJson(json);

  /// Grant pre-authorized_code.
  @override
  @JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
  final PreAuthorizedGrant? preAuthorized;

  /// Grant authorization_code.
  @override
  @JsonKey(name: 'authorization_code')
  final AuthorizationCodeGrant? authCode;

  @override
  String toString() {
    return 'GrantsContainer(preAuthorized: $preAuthorized, authCode: $authCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrantsContainerImpl &&
            (identical(other.preAuthorized, preAuthorized) ||
                other.preAuthorized == preAuthorized) &&
            (identical(other.authCode, authCode) ||
                other.authCode == authCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, preAuthorized, authCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GrantsContainerImplCopyWith<_$GrantsContainerImpl> get copyWith =>
      __$$GrantsContainerImplCopyWithImpl<_$GrantsContainerImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrantsContainerImplToJson(
      this,
    );
  }
}

abstract class _GrantsContainer implements GrantsContainer {
  const factory _GrantsContainer(
      {@JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
      final PreAuthorizedGrant? preAuthorized,
      @JsonKey(name: 'authorization_code')
      final AuthorizationCodeGrant? authCode}) = _$GrantsContainerImpl;

  factory _GrantsContainer.fromJson(Map<String, dynamic> json) =
      _$GrantsContainerImpl.fromJson;

  @override

  /// Grant pre-authorized_code.
  @JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
  PreAuthorizedGrant? get preAuthorized;
  @override

  /// Grant authorization_code.
  @JsonKey(name: 'authorization_code')
  AuthorizationCodeGrant? get authCode;
  @override
  @JsonKey(ignore: true)
  _$$GrantsContainerImplCopyWith<_$GrantsContainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreAuthorizedGrant _$PreAuthorizedGrantFromJson(Map<String, dynamic> json) {
  return _PreAuthorizedGrant.fromJson(json);
}

/// @nodoc
mixin _$PreAuthorizedGrant {
  /// Código pre-autorizado de un solo uso.
  @JsonKey(name: 'pre-authorized_code')
  String get preAuthorizedCode => throw _privateConstructorUsedError;

  /// Información sobre el código de transacción requerido (e.g. PIN de 4 dígitos).
  @JsonKey(name: 'tx_code')
  TxCodeInfo? get txCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreAuthorizedGrantCopyWith<PreAuthorizedGrant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreAuthorizedGrantCopyWith<$Res> {
  factory $PreAuthorizedGrantCopyWith(
          PreAuthorizedGrant value, $Res Function(PreAuthorizedGrant) then) =
      _$PreAuthorizedGrantCopyWithImpl<$Res, PreAuthorizedGrant>;
  @useResult
  $Res call(
      {@JsonKey(name: 'pre-authorized_code') String preAuthorizedCode,
      @JsonKey(name: 'tx_code') TxCodeInfo? txCode});

  $TxCodeInfoCopyWith<$Res>? get txCode;
}

/// @nodoc
class _$PreAuthorizedGrantCopyWithImpl<$Res, $Val extends PreAuthorizedGrant>
    implements $PreAuthorizedGrantCopyWith<$Res> {
  _$PreAuthorizedGrantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preAuthorizedCode = null,
    Object? txCode = freezed,
  }) {
    return _then(_value.copyWith(
      preAuthorizedCode: null == preAuthorizedCode
          ? _value.preAuthorizedCode
          : preAuthorizedCode // ignore: cast_nullable_to_non_nullable
              as String,
      txCode: freezed == txCode
          ? _value.txCode
          : txCode // ignore: cast_nullable_to_non_nullable
              as TxCodeInfo?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TxCodeInfoCopyWith<$Res>? get txCode {
    if (_value.txCode == null) {
      return null;
    }

    return $TxCodeInfoCopyWith<$Res>(_value.txCode!, (value) {
      return _then(_value.copyWith(txCode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PreAuthorizedGrantImplCopyWith<$Res>
    implements $PreAuthorizedGrantCopyWith<$Res> {
  factory _$$PreAuthorizedGrantImplCopyWith(_$PreAuthorizedGrantImpl value,
          $Res Function(_$PreAuthorizedGrantImpl) then) =
      __$$PreAuthorizedGrantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'pre-authorized_code') String preAuthorizedCode,
      @JsonKey(name: 'tx_code') TxCodeInfo? txCode});

  @override
  $TxCodeInfoCopyWith<$Res>? get txCode;
}

/// @nodoc
class __$$PreAuthorizedGrantImplCopyWithImpl<$Res>
    extends _$PreAuthorizedGrantCopyWithImpl<$Res, _$PreAuthorizedGrantImpl>
    implements _$$PreAuthorizedGrantImplCopyWith<$Res> {
  __$$PreAuthorizedGrantImplCopyWithImpl(_$PreAuthorizedGrantImpl _value,
      $Res Function(_$PreAuthorizedGrantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preAuthorizedCode = null,
    Object? txCode = freezed,
  }) {
    return _then(_$PreAuthorizedGrantImpl(
      preAuthorizedCode: null == preAuthorizedCode
          ? _value.preAuthorizedCode
          : preAuthorizedCode // ignore: cast_nullable_to_non_nullable
              as String,
      txCode: freezed == txCode
          ? _value.txCode
          : txCode // ignore: cast_nullable_to_non_nullable
              as TxCodeInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreAuthorizedGrantImpl implements _PreAuthorizedGrant {
  const _$PreAuthorizedGrantImpl(
      {@JsonKey(name: 'pre-authorized_code') required this.preAuthorizedCode,
      @JsonKey(name: 'tx_code') this.txCode});

  factory _$PreAuthorizedGrantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreAuthorizedGrantImplFromJson(json);

  /// Código pre-autorizado de un solo uso.
  @override
  @JsonKey(name: 'pre-authorized_code')
  final String preAuthorizedCode;

  /// Información sobre el código de transacción requerido (e.g. PIN de 4 dígitos).
  @override
  @JsonKey(name: 'tx_code')
  final TxCodeInfo? txCode;

  @override
  String toString() {
    return 'PreAuthorizedGrant(preAuthorizedCode: $preAuthorizedCode, txCode: $txCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreAuthorizedGrantImpl &&
            (identical(other.preAuthorizedCode, preAuthorizedCode) ||
                other.preAuthorizedCode == preAuthorizedCode) &&
            (identical(other.txCode, txCode) || other.txCode == txCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, preAuthorizedCode, txCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreAuthorizedGrantImplCopyWith<_$PreAuthorizedGrantImpl> get copyWith =>
      __$$PreAuthorizedGrantImplCopyWithImpl<_$PreAuthorizedGrantImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreAuthorizedGrantImplToJson(
      this,
    );
  }
}

abstract class _PreAuthorizedGrant implements PreAuthorizedGrant {
  const factory _PreAuthorizedGrant(
          {@JsonKey(name: 'pre-authorized_code')
          required final String preAuthorizedCode,
          @JsonKey(name: 'tx_code') final TxCodeInfo? txCode}) =
      _$PreAuthorizedGrantImpl;

  factory _PreAuthorizedGrant.fromJson(Map<String, dynamic> json) =
      _$PreAuthorizedGrantImpl.fromJson;

  @override

  /// Código pre-autorizado de un solo uso.
  @JsonKey(name: 'pre-authorized_code')
  String get preAuthorizedCode;
  @override

  /// Información sobre el código de transacción requerido (e.g. PIN de 4 dígitos).
  @JsonKey(name: 'tx_code')
  TxCodeInfo? get txCode;
  @override
  @JsonKey(ignore: true)
  _$$PreAuthorizedGrantImplCopyWith<_$PreAuthorizedGrantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TxCodeInfo _$TxCodeInfoFromJson(Map<String, dynamic> json) {
  return _TxCodeInfo.fromJson(json);
}

/// @nodoc
mixin _$TxCodeInfo {
  /// Longitud esperada del código.
  int? get length => throw _privateConstructorUsedError;

  /// Modo de entrada: `'numeric'` o `'text'`.
  @JsonKey(name: 'input_mode')
  String? get inputMode => throw _privateConstructorUsedError;

  /// Descripción para mostrar al usuario.
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TxCodeInfoCopyWith<TxCodeInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TxCodeInfoCopyWith<$Res> {
  factory $TxCodeInfoCopyWith(
          TxCodeInfo value, $Res Function(TxCodeInfo) then) =
      _$TxCodeInfoCopyWithImpl<$Res, TxCodeInfo>;
  @useResult
  $Res call(
      {int? length,
      @JsonKey(name: 'input_mode') String? inputMode,
      String? description});
}

/// @nodoc
class _$TxCodeInfoCopyWithImpl<$Res, $Val extends TxCodeInfo>
    implements $TxCodeInfoCopyWith<$Res> {
  _$TxCodeInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? length = freezed,
    Object? inputMode = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int?,
      inputMode: freezed == inputMode
          ? _value.inputMode
          : inputMode // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TxCodeInfoImplCopyWith<$Res>
    implements $TxCodeInfoCopyWith<$Res> {
  factory _$$TxCodeInfoImplCopyWith(
          _$TxCodeInfoImpl value, $Res Function(_$TxCodeInfoImpl) then) =
      __$$TxCodeInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? length,
      @JsonKey(name: 'input_mode') String? inputMode,
      String? description});
}

/// @nodoc
class __$$TxCodeInfoImplCopyWithImpl<$Res>
    extends _$TxCodeInfoCopyWithImpl<$Res, _$TxCodeInfoImpl>
    implements _$$TxCodeInfoImplCopyWith<$Res> {
  __$$TxCodeInfoImplCopyWithImpl(
      _$TxCodeInfoImpl _value, $Res Function(_$TxCodeInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? length = freezed,
    Object? inputMode = freezed,
    Object? description = freezed,
  }) {
    return _then(_$TxCodeInfoImpl(
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int?,
      inputMode: freezed == inputMode
          ? _value.inputMode
          : inputMode // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TxCodeInfoImpl implements _TxCodeInfo {
  const _$TxCodeInfoImpl(
      {this.length,
      @JsonKey(name: 'input_mode') this.inputMode,
      this.description});

  factory _$TxCodeInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TxCodeInfoImplFromJson(json);

  /// Longitud esperada del código.
  @override
  final int? length;

  /// Modo de entrada: `'numeric'` o `'text'`.
  @override
  @JsonKey(name: 'input_mode')
  final String? inputMode;

  /// Descripción para mostrar al usuario.
  @override
  final String? description;

  @override
  String toString() {
    return 'TxCodeInfo(length: $length, inputMode: $inputMode, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TxCodeInfoImpl &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.inputMode, inputMode) ||
                other.inputMode == inputMode) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, length, inputMode, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TxCodeInfoImplCopyWith<_$TxCodeInfoImpl> get copyWith =>
      __$$TxCodeInfoImplCopyWithImpl<_$TxCodeInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TxCodeInfoImplToJson(
      this,
    );
  }
}

abstract class _TxCodeInfo implements TxCodeInfo {
  const factory _TxCodeInfo(
      {final int? length,
      @JsonKey(name: 'input_mode') final String? inputMode,
      final String? description}) = _$TxCodeInfoImpl;

  factory _TxCodeInfo.fromJson(Map<String, dynamic> json) =
      _$TxCodeInfoImpl.fromJson;

  @override

  /// Longitud esperada del código.
  int? get length;
  @override

  /// Modo de entrada: `'numeric'` o `'text'`.
  @JsonKey(name: 'input_mode')
  String? get inputMode;
  @override

  /// Descripción para mostrar al usuario.
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$TxCodeInfoImplCopyWith<_$TxCodeInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthorizationCodeGrant _$AuthorizationCodeGrantFromJson(
    Map<String, dynamic> json) {
  return _AuthorizationCodeGrant.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationCodeGrant {
  /// URL del issuer state para iniciar el flujo.
  @JsonKey(name: 'issuer_state')
  String? get issuerState => throw _privateConstructorUsedError;

  /// Servidor de autorización que emitirá el token.
  @JsonKey(name: 'authorization_server')
  String? get authorizationServer => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthorizationCodeGrantCopyWith<AuthorizationCodeGrant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationCodeGrantCopyWith<$Res> {
  factory $AuthorizationCodeGrantCopyWith(AuthorizationCodeGrant value,
          $Res Function(AuthorizationCodeGrant) then) =
      _$AuthorizationCodeGrantCopyWithImpl<$Res, AuthorizationCodeGrant>;
  @useResult
  $Res call(
      {@JsonKey(name: 'issuer_state') String? issuerState,
      @JsonKey(name: 'authorization_server') String? authorizationServer});
}

/// @nodoc
class _$AuthorizationCodeGrantCopyWithImpl<$Res,
        $Val extends AuthorizationCodeGrant>
    implements $AuthorizationCodeGrantCopyWith<$Res> {
  _$AuthorizationCodeGrantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issuerState = freezed,
    Object? authorizationServer = freezed,
  }) {
    return _then(_value.copyWith(
      issuerState: freezed == issuerState
          ? _value.issuerState
          : issuerState // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationServer: freezed == authorizationServer
          ? _value.authorizationServer
          : authorizationServer // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthorizationCodeGrantImplCopyWith<$Res>
    implements $AuthorizationCodeGrantCopyWith<$Res> {
  factory _$$AuthorizationCodeGrantImplCopyWith(
          _$AuthorizationCodeGrantImpl value,
          $Res Function(_$AuthorizationCodeGrantImpl) then) =
      __$$AuthorizationCodeGrantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'issuer_state') String? issuerState,
      @JsonKey(name: 'authorization_server') String? authorizationServer});
}

/// @nodoc
class __$$AuthorizationCodeGrantImplCopyWithImpl<$Res>
    extends _$AuthorizationCodeGrantCopyWithImpl<$Res,
        _$AuthorizationCodeGrantImpl>
    implements _$$AuthorizationCodeGrantImplCopyWith<$Res> {
  __$$AuthorizationCodeGrantImplCopyWithImpl(
      _$AuthorizationCodeGrantImpl _value,
      $Res Function(_$AuthorizationCodeGrantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issuerState = freezed,
    Object? authorizationServer = freezed,
  }) {
    return _then(_$AuthorizationCodeGrantImpl(
      issuerState: freezed == issuerState
          ? _value.issuerState
          : issuerState // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationServer: freezed == authorizationServer
          ? _value.authorizationServer
          : authorizationServer // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizationCodeGrantImpl implements _AuthorizationCodeGrant {
  const _$AuthorizationCodeGrantImpl(
      {@JsonKey(name: 'issuer_state') this.issuerState,
      @JsonKey(name: 'authorization_server') this.authorizationServer});

  factory _$AuthorizationCodeGrantImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationCodeGrantImplFromJson(json);

  /// URL del issuer state para iniciar el flujo.
  @override
  @JsonKey(name: 'issuer_state')
  final String? issuerState;

  /// Servidor de autorización que emitirá el token.
  @override
  @JsonKey(name: 'authorization_server')
  final String? authorizationServer;

  @override
  String toString() {
    return 'AuthorizationCodeGrant(issuerState: $issuerState, authorizationServer: $authorizationServer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationCodeGrantImpl &&
            (identical(other.issuerState, issuerState) ||
                other.issuerState == issuerState) &&
            (identical(other.authorizationServer, authorizationServer) ||
                other.authorizationServer == authorizationServer));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, issuerState, authorizationServer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationCodeGrantImplCopyWith<_$AuthorizationCodeGrantImpl>
      get copyWith => __$$AuthorizationCodeGrantImplCopyWithImpl<
          _$AuthorizationCodeGrantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationCodeGrantImplToJson(
      this,
    );
  }
}

abstract class _AuthorizationCodeGrant implements AuthorizationCodeGrant {
  const factory _AuthorizationCodeGrant(
      {@JsonKey(name: 'issuer_state') final String? issuerState,
      @JsonKey(name: 'authorization_server')
      final String? authorizationServer}) = _$AuthorizationCodeGrantImpl;

  factory _AuthorizationCodeGrant.fromJson(Map<String, dynamic> json) =
      _$AuthorizationCodeGrantImpl.fromJson;

  @override

  /// URL del issuer state para iniciar el flujo.
  @JsonKey(name: 'issuer_state')
  String? get issuerState;
  @override

  /// Servidor de autorización que emitirá el token.
  @JsonKey(name: 'authorization_server')
  String? get authorizationServer;
  @override
  @JsonKey(ignore: true)
  _$$AuthorizationCodeGrantImplCopyWith<_$AuthorizationCodeGrantImpl>
      get copyWith => throw _privateConstructorUsedError;
}
