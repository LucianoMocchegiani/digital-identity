// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issuer_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IssuerMetadata _$IssuerMetadataFromJson(Map<String, dynamic> json) {
  return _IssuerMetadata.fromJson(json);
}

/// @nodoc
mixin _$IssuerMetadata {
  /// URL base del issuer.
  @JsonKey(name: 'credential_issuer')
  String get credentialIssuer => throw _privateConstructorUsedError;

  /// Endpoint para solicitar credenciales.
  @JsonKey(name: 'credential_endpoint')
  String get credentialEndpoint => throw _privateConstructorUsedError;

  /// Endpoint para obtener el access token.
  ///
  /// Puede estar en el authorization server metadata; se permite nulo
  /// si se obtiene por separado.
  @JsonKey(name: 'token_endpoint')
  String? get tokenEndpoint => throw _privateConstructorUsedError;

  /// Map de configuraciones de credencial soportadas, indexadas por ID.
  @JsonKey(name: 'credential_configurations_supported')
  Map<String, dynamic> get credentialConfigurationsSupported =>
      throw _privateConstructorUsedError;

  /// Metadatos de display del issuer (nombre, logo, etc.).
  List<Map<String, dynamic>>? get display => throw _privateConstructorUsedError;

  /// Servidor de autorización asociado (puede diferir del issuer).
  @JsonKey(name: 'authorization_servers')
  List<String>? get authorizationServers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IssuerMetadataCopyWith<IssuerMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssuerMetadataCopyWith<$Res> {
  factory $IssuerMetadataCopyWith(
          IssuerMetadata value, $Res Function(IssuerMetadata) then) =
      _$IssuerMetadataCopyWithImpl<$Res, IssuerMetadata>;
  @useResult
  $Res call(
      {@JsonKey(name: 'credential_issuer') String credentialIssuer,
      @JsonKey(name: 'credential_endpoint') String credentialEndpoint,
      @JsonKey(name: 'token_endpoint') String? tokenEndpoint,
      @JsonKey(name: 'credential_configurations_supported')
      Map<String, dynamic> credentialConfigurationsSupported,
      List<Map<String, dynamic>>? display,
      @JsonKey(name: 'authorization_servers')
      List<String>? authorizationServers});
}

/// @nodoc
class _$IssuerMetadataCopyWithImpl<$Res, $Val extends IssuerMetadata>
    implements $IssuerMetadataCopyWith<$Res> {
  _$IssuerMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentialIssuer = null,
    Object? credentialEndpoint = null,
    Object? tokenEndpoint = freezed,
    Object? credentialConfigurationsSupported = null,
    Object? display = freezed,
    Object? authorizationServers = freezed,
  }) {
    return _then(_value.copyWith(
      credentialIssuer: null == credentialIssuer
          ? _value.credentialIssuer
          : credentialIssuer // ignore: cast_nullable_to_non_nullable
              as String,
      credentialEndpoint: null == credentialEndpoint
          ? _value.credentialEndpoint
          : credentialEndpoint // ignore: cast_nullable_to_non_nullable
              as String,
      tokenEndpoint: freezed == tokenEndpoint
          ? _value.tokenEndpoint
          : tokenEndpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      credentialConfigurationsSupported: null ==
              credentialConfigurationsSupported
          ? _value.credentialConfigurationsSupported
          : credentialConfigurationsSupported // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      display: freezed == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      authorizationServers: freezed == authorizationServers
          ? _value.authorizationServers
          : authorizationServers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssuerMetadataImplCopyWith<$Res>
    implements $IssuerMetadataCopyWith<$Res> {
  factory _$$IssuerMetadataImplCopyWith(_$IssuerMetadataImpl value,
          $Res Function(_$IssuerMetadataImpl) then) =
      __$$IssuerMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'credential_issuer') String credentialIssuer,
      @JsonKey(name: 'credential_endpoint') String credentialEndpoint,
      @JsonKey(name: 'token_endpoint') String? tokenEndpoint,
      @JsonKey(name: 'credential_configurations_supported')
      Map<String, dynamic> credentialConfigurationsSupported,
      List<Map<String, dynamic>>? display,
      @JsonKey(name: 'authorization_servers')
      List<String>? authorizationServers});
}

/// @nodoc
class __$$IssuerMetadataImplCopyWithImpl<$Res>
    extends _$IssuerMetadataCopyWithImpl<$Res, _$IssuerMetadataImpl>
    implements _$$IssuerMetadataImplCopyWith<$Res> {
  __$$IssuerMetadataImplCopyWithImpl(
      _$IssuerMetadataImpl _value, $Res Function(_$IssuerMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentialIssuer = null,
    Object? credentialEndpoint = null,
    Object? tokenEndpoint = freezed,
    Object? credentialConfigurationsSupported = null,
    Object? display = freezed,
    Object? authorizationServers = freezed,
  }) {
    return _then(_$IssuerMetadataImpl(
      credentialIssuer: null == credentialIssuer
          ? _value.credentialIssuer
          : credentialIssuer // ignore: cast_nullable_to_non_nullable
              as String,
      credentialEndpoint: null == credentialEndpoint
          ? _value.credentialEndpoint
          : credentialEndpoint // ignore: cast_nullable_to_non_nullable
              as String,
      tokenEndpoint: freezed == tokenEndpoint
          ? _value.tokenEndpoint
          : tokenEndpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      credentialConfigurationsSupported: null ==
              credentialConfigurationsSupported
          ? _value._credentialConfigurationsSupported
          : credentialConfigurationsSupported // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      display: freezed == display
          ? _value._display
          : display // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      authorizationServers: freezed == authorizationServers
          ? _value._authorizationServers
          : authorizationServers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IssuerMetadataImpl implements _IssuerMetadata {
  const _$IssuerMetadataImpl(
      {@JsonKey(name: 'credential_issuer') required this.credentialIssuer,
      @JsonKey(name: 'credential_endpoint') required this.credentialEndpoint,
      @JsonKey(name: 'token_endpoint') this.tokenEndpoint,
      @JsonKey(name: 'credential_configurations_supported')
      required final Map<String, dynamic> credentialConfigurationsSupported,
      final List<Map<String, dynamic>>? display,
      @JsonKey(name: 'authorization_servers')
      final List<String>? authorizationServers})
      : _credentialConfigurationsSupported = credentialConfigurationsSupported,
        _display = display,
        _authorizationServers = authorizationServers;

  factory _$IssuerMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$IssuerMetadataImplFromJson(json);

  /// URL base del issuer.
  @override
  @JsonKey(name: 'credential_issuer')
  final String credentialIssuer;

  /// Endpoint para solicitar credenciales.
  @override
  @JsonKey(name: 'credential_endpoint')
  final String credentialEndpoint;

  /// Endpoint para obtener el access token.
  ///
  /// Puede estar en el authorization server metadata; se permite nulo
  /// si se obtiene por separado.
  @override
  @JsonKey(name: 'token_endpoint')
  final String? tokenEndpoint;

  /// Map de configuraciones de credencial soportadas, indexadas por ID.
  final Map<String, dynamic> _credentialConfigurationsSupported;

  /// Map de configuraciones de credencial soportadas, indexadas por ID.
  @override
  @JsonKey(name: 'credential_configurations_supported')
  Map<String, dynamic> get credentialConfigurationsSupported {
    if (_credentialConfigurationsSupported is EqualUnmodifiableMapView)
      return _credentialConfigurationsSupported;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_credentialConfigurationsSupported);
  }

  /// Metadatos de display del issuer (nombre, logo, etc.).
  final List<Map<String, dynamic>>? _display;

  /// Metadatos de display del issuer (nombre, logo, etc.).
  @override
  List<Map<String, dynamic>>? get display {
    final value = _display;
    if (value == null) return null;
    if (_display is EqualUnmodifiableListView) return _display;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Servidor de autorización asociado (puede diferir del issuer).
  final List<String>? _authorizationServers;

  /// Servidor de autorización asociado (puede diferir del issuer).
  @override
  @JsonKey(name: 'authorization_servers')
  List<String>? get authorizationServers {
    final value = _authorizationServers;
    if (value == null) return null;
    if (_authorizationServers is EqualUnmodifiableListView)
      return _authorizationServers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'IssuerMetadata(credentialIssuer: $credentialIssuer, credentialEndpoint: $credentialEndpoint, tokenEndpoint: $tokenEndpoint, credentialConfigurationsSupported: $credentialConfigurationsSupported, display: $display, authorizationServers: $authorizationServers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssuerMetadataImpl &&
            (identical(other.credentialIssuer, credentialIssuer) ||
                other.credentialIssuer == credentialIssuer) &&
            (identical(other.credentialEndpoint, credentialEndpoint) ||
                other.credentialEndpoint == credentialEndpoint) &&
            (identical(other.tokenEndpoint, tokenEndpoint) ||
                other.tokenEndpoint == tokenEndpoint) &&
            const DeepCollectionEquality().equals(
                other._credentialConfigurationsSupported,
                _credentialConfigurationsSupported) &&
            const DeepCollectionEquality().equals(other._display, _display) &&
            const DeepCollectionEquality()
                .equals(other._authorizationServers, _authorizationServers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      credentialIssuer,
      credentialEndpoint,
      tokenEndpoint,
      const DeepCollectionEquality().hash(_credentialConfigurationsSupported),
      const DeepCollectionEquality().hash(_display),
      const DeepCollectionEquality().hash(_authorizationServers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IssuerMetadataImplCopyWith<_$IssuerMetadataImpl> get copyWith =>
      __$$IssuerMetadataImplCopyWithImpl<_$IssuerMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IssuerMetadataImplToJson(
      this,
    );
  }
}

abstract class _IssuerMetadata implements IssuerMetadata {
  const factory _IssuerMetadata(
      {@JsonKey(name: 'credential_issuer')
      required final String credentialIssuer,
      @JsonKey(name: 'credential_endpoint')
      required final String credentialEndpoint,
      @JsonKey(name: 'token_endpoint') final String? tokenEndpoint,
      @JsonKey(name: 'credential_configurations_supported')
      required final Map<String, dynamic> credentialConfigurationsSupported,
      final List<Map<String, dynamic>>? display,
      @JsonKey(name: 'authorization_servers')
      final List<String>? authorizationServers}) = _$IssuerMetadataImpl;

  factory _IssuerMetadata.fromJson(Map<String, dynamic> json) =
      _$IssuerMetadataImpl.fromJson;

  @override

  /// URL base del issuer.
  @JsonKey(name: 'credential_issuer')
  String get credentialIssuer;
  @override

  /// Endpoint para solicitar credenciales.
  @JsonKey(name: 'credential_endpoint')
  String get credentialEndpoint;
  @override

  /// Endpoint para obtener el access token.
  ///
  /// Puede estar en el authorization server metadata; se permite nulo
  /// si se obtiene por separado.
  @JsonKey(name: 'token_endpoint')
  String? get tokenEndpoint;
  @override

  /// Map de configuraciones de credencial soportadas, indexadas por ID.
  @JsonKey(name: 'credential_configurations_supported')
  Map<String, dynamic> get credentialConfigurationsSupported;
  @override

  /// Metadatos de display del issuer (nombre, logo, etc.).
  List<Map<String, dynamic>>? get display;
  @override

  /// Servidor de autorización asociado (puede diferir del issuer).
  @JsonKey(name: 'authorization_servers')
  List<String>? get authorizationServers;
  @override
  @JsonKey(ignore: true)
  _$$IssuerMetadataImplCopyWith<_$IssuerMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
