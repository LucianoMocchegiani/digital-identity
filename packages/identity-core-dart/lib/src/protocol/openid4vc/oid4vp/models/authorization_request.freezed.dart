// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authorization_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthorizationRequest _$AuthorizationRequestFromJson(Map<String, dynamic> json) {
  return _AuthorizationRequest.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationRequest {
  /// Tipo de respuesta esperado. Normalmente `'vp_token'`.
  @JsonKey(name: 'response_type')
  String get responseType => throw _privateConstructorUsedError;

  /// Identificador del cliente (verifier).
  @JsonKey(name: 'client_id')
  String get clientId => throw _privateConstructorUsedError;

  /// Modo de respuesta. Normalmente `'direct_post'`.
  @JsonKey(name: 'response_mode')
  String? get responseMode => throw _privateConstructorUsedError;

  /// URI a la que el wallet envía la respuesta via POST.
  @JsonKey(name: 'response_uri')
  String? get responseUri => throw _privateConstructorUsedError;

  /// Nonce para prevenir replay attacks. Incluido en el kb-JWT y VP JWT.
  String? get nonce => throw _privateConstructorUsedError;

  /// Estado opaco del verifier, devuelto en la respuesta.
  String? get state => throw _privateConstructorUsedError;

  /// Presentation Definition (PEX) en formato crudo.
  @JsonKey(name: 'presentation_definition')
  Map<String, dynamic>? get presentationDefinition =>
      throw _privateConstructorUsedError;

  /// Referencia URI a una Presentation Definition externa.
  @JsonKey(name: 'presentation_definition_uri')
  String? get presentationDefinitionUri => throw _privateConstructorUsedError;

  /// DCQL query para selección de credenciales.
  @JsonKey(name: 'dcql_query')
  Map<String, dynamic>? get dcqlQuery => throw _privateConstructorUsedError;

  /// Metadatos del cliente verifier (nombre, logo, políticas).
  @JsonKey(name: 'client_metadata')
  Map<String, dynamic>? get clientMetadata =>
      throw _privateConstructorUsedError;

  /// Scope adicional.
  String? get scope => throw _privateConstructorUsedError;

  /// Algoritmo JWE (`direct_post.jwt`). Normalmente `ECDH-ES`.
  @JsonKey(name: 'authorization_encrypted_response_alg')
  String? get authorizationEncryptedResponseAlg =>
      throw _privateConstructorUsedError;

  /// Cifrado de contenido JWE. Normalmente `A128GCM`.
  @JsonKey(name: 'authorization_encrypted_response_enc')
  String? get authorizationEncryptedResponseEnc =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthorizationRequestCopyWith<AuthorizationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationRequestCopyWith<$Res> {
  factory $AuthorizationRequestCopyWith(AuthorizationRequest value,
          $Res Function(AuthorizationRequest) then) =
      _$AuthorizationRequestCopyWithImpl<$Res, AuthorizationRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'response_type') String responseType,
      @JsonKey(name: 'client_id') String clientId,
      @JsonKey(name: 'response_mode') String? responseMode,
      @JsonKey(name: 'response_uri') String? responseUri,
      String? nonce,
      String? state,
      @JsonKey(name: 'presentation_definition')
      Map<String, dynamic>? presentationDefinition,
      @JsonKey(name: 'presentation_definition_uri')
      String? presentationDefinitionUri,
      @JsonKey(name: 'dcql_query') Map<String, dynamic>? dcqlQuery,
      @JsonKey(name: 'client_metadata') Map<String, dynamic>? clientMetadata,
      String? scope,
      @JsonKey(name: 'authorization_encrypted_response_alg')
      String? authorizationEncryptedResponseAlg,
      @JsonKey(name: 'authorization_encrypted_response_enc')
      String? authorizationEncryptedResponseEnc});
}

/// @nodoc
class _$AuthorizationRequestCopyWithImpl<$Res,
        $Val extends AuthorizationRequest>
    implements $AuthorizationRequestCopyWith<$Res> {
  _$AuthorizationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responseType = null,
    Object? clientId = null,
    Object? responseMode = freezed,
    Object? responseUri = freezed,
    Object? nonce = freezed,
    Object? state = freezed,
    Object? presentationDefinition = freezed,
    Object? presentationDefinitionUri = freezed,
    Object? dcqlQuery = freezed,
    Object? clientMetadata = freezed,
    Object? scope = freezed,
    Object? authorizationEncryptedResponseAlg = freezed,
    Object? authorizationEncryptedResponseEnc = freezed,
  }) {
    return _then(_value.copyWith(
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      responseMode: freezed == responseMode
          ? _value.responseMode
          : responseMode // ignore: cast_nullable_to_non_nullable
              as String?,
      responseUri: freezed == responseUri
          ? _value.responseUri
          : responseUri // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationDefinition: freezed == presentationDefinition
          ? _value.presentationDefinition
          : presentationDefinition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      presentationDefinitionUri: freezed == presentationDefinitionUri
          ? _value.presentationDefinitionUri
          : presentationDefinitionUri // ignore: cast_nullable_to_non_nullable
              as String?,
      dcqlQuery: freezed == dcqlQuery
          ? _value.dcqlQuery
          : dcqlQuery // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientMetadata: freezed == clientMetadata
          ? _value.clientMetadata
          : clientMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      scope: freezed == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationEncryptedResponseAlg: freezed ==
              authorizationEncryptedResponseAlg
          ? _value.authorizationEncryptedResponseAlg
          : authorizationEncryptedResponseAlg // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationEncryptedResponseEnc: freezed ==
              authorizationEncryptedResponseEnc
          ? _value.authorizationEncryptedResponseEnc
          : authorizationEncryptedResponseEnc // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthorizationRequestImplCopyWith<$Res>
    implements $AuthorizationRequestCopyWith<$Res> {
  factory _$$AuthorizationRequestImplCopyWith(_$AuthorizationRequestImpl value,
          $Res Function(_$AuthorizationRequestImpl) then) =
      __$$AuthorizationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'response_type') String responseType,
      @JsonKey(name: 'client_id') String clientId,
      @JsonKey(name: 'response_mode') String? responseMode,
      @JsonKey(name: 'response_uri') String? responseUri,
      String? nonce,
      String? state,
      @JsonKey(name: 'presentation_definition')
      Map<String, dynamic>? presentationDefinition,
      @JsonKey(name: 'presentation_definition_uri')
      String? presentationDefinitionUri,
      @JsonKey(name: 'dcql_query') Map<String, dynamic>? dcqlQuery,
      @JsonKey(name: 'client_metadata') Map<String, dynamic>? clientMetadata,
      String? scope,
      @JsonKey(name: 'authorization_encrypted_response_alg')
      String? authorizationEncryptedResponseAlg,
      @JsonKey(name: 'authorization_encrypted_response_enc')
      String? authorizationEncryptedResponseEnc});
}

/// @nodoc
class __$$AuthorizationRequestImplCopyWithImpl<$Res>
    extends _$AuthorizationRequestCopyWithImpl<$Res, _$AuthorizationRequestImpl>
    implements _$$AuthorizationRequestImplCopyWith<$Res> {
  __$$AuthorizationRequestImplCopyWithImpl(_$AuthorizationRequestImpl _value,
      $Res Function(_$AuthorizationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responseType = null,
    Object? clientId = null,
    Object? responseMode = freezed,
    Object? responseUri = freezed,
    Object? nonce = freezed,
    Object? state = freezed,
    Object? presentationDefinition = freezed,
    Object? presentationDefinitionUri = freezed,
    Object? dcqlQuery = freezed,
    Object? clientMetadata = freezed,
    Object? scope = freezed,
    Object? authorizationEncryptedResponseAlg = freezed,
    Object? authorizationEncryptedResponseEnc = freezed,
  }) {
    return _then(_$AuthorizationRequestImpl(
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      responseMode: freezed == responseMode
          ? _value.responseMode
          : responseMode // ignore: cast_nullable_to_non_nullable
              as String?,
      responseUri: freezed == responseUri
          ? _value.responseUri
          : responseUri // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationDefinition: freezed == presentationDefinition
          ? _value._presentationDefinition
          : presentationDefinition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      presentationDefinitionUri: freezed == presentationDefinitionUri
          ? _value.presentationDefinitionUri
          : presentationDefinitionUri // ignore: cast_nullable_to_non_nullable
              as String?,
      dcqlQuery: freezed == dcqlQuery
          ? _value._dcqlQuery
          : dcqlQuery // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientMetadata: freezed == clientMetadata
          ? _value._clientMetadata
          : clientMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      scope: freezed == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationEncryptedResponseAlg: freezed ==
              authorizationEncryptedResponseAlg
          ? _value.authorizationEncryptedResponseAlg
          : authorizationEncryptedResponseAlg // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationEncryptedResponseEnc: freezed ==
              authorizationEncryptedResponseEnc
          ? _value.authorizationEncryptedResponseEnc
          : authorizationEncryptedResponseEnc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizationRequestImpl implements _AuthorizationRequest {
  const _$AuthorizationRequestImpl(
      {@JsonKey(name: 'response_type') required this.responseType,
      @JsonKey(name: 'client_id') required this.clientId,
      @JsonKey(name: 'response_mode') this.responseMode,
      @JsonKey(name: 'response_uri') this.responseUri,
      this.nonce,
      this.state,
      @JsonKey(name: 'presentation_definition')
      final Map<String, dynamic>? presentationDefinition,
      @JsonKey(name: 'presentation_definition_uri')
      this.presentationDefinitionUri,
      @JsonKey(name: 'dcql_query') final Map<String, dynamic>? dcqlQuery,
      @JsonKey(name: 'client_metadata')
      final Map<String, dynamic>? clientMetadata,
      this.scope,
      @JsonKey(name: 'authorization_encrypted_response_alg')
      this.authorizationEncryptedResponseAlg,
      @JsonKey(name: 'authorization_encrypted_response_enc')
      this.authorizationEncryptedResponseEnc})
      : _presentationDefinition = presentationDefinition,
        _dcqlQuery = dcqlQuery,
        _clientMetadata = clientMetadata;

  factory _$AuthorizationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationRequestImplFromJson(json);

  /// Tipo de respuesta esperado. Normalmente `'vp_token'`.
  @override
  @JsonKey(name: 'response_type')
  final String responseType;

  /// Identificador del cliente (verifier).
  @override
  @JsonKey(name: 'client_id')
  final String clientId;

  /// Modo de respuesta. Normalmente `'direct_post'`.
  @override
  @JsonKey(name: 'response_mode')
  final String? responseMode;

  /// URI a la que el wallet envía la respuesta via POST.
  @override
  @JsonKey(name: 'response_uri')
  final String? responseUri;

  /// Nonce para prevenir replay attacks. Incluido en el kb-JWT y VP JWT.
  @override
  final String? nonce;

  /// Estado opaco del verifier, devuelto en la respuesta.
  @override
  final String? state;

  /// Presentation Definition (PEX) en formato crudo.
  final Map<String, dynamic>? _presentationDefinition;

  /// Presentation Definition (PEX) en formato crudo.
  @override
  @JsonKey(name: 'presentation_definition')
  Map<String, dynamic>? get presentationDefinition {
    final value = _presentationDefinition;
    if (value == null) return null;
    if (_presentationDefinition is EqualUnmodifiableMapView)
      return _presentationDefinition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Referencia URI a una Presentation Definition externa.
  @override
  @JsonKey(name: 'presentation_definition_uri')
  final String? presentationDefinitionUri;

  /// DCQL query para selección de credenciales.
  final Map<String, dynamic>? _dcqlQuery;

  /// DCQL query para selección de credenciales.
  @override
  @JsonKey(name: 'dcql_query')
  Map<String, dynamic>? get dcqlQuery {
    final value = _dcqlQuery;
    if (value == null) return null;
    if (_dcqlQuery is EqualUnmodifiableMapView) return _dcqlQuery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Metadatos del cliente verifier (nombre, logo, políticas).
  final Map<String, dynamic>? _clientMetadata;

  /// Metadatos del cliente verifier (nombre, logo, políticas).
  @override
  @JsonKey(name: 'client_metadata')
  Map<String, dynamic>? get clientMetadata {
    final value = _clientMetadata;
    if (value == null) return null;
    if (_clientMetadata is EqualUnmodifiableMapView) return _clientMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Scope adicional.
  @override
  final String? scope;

  /// Algoritmo JWE (`direct_post.jwt`). Normalmente `ECDH-ES`.
  @override
  @JsonKey(name: 'authorization_encrypted_response_alg')
  final String? authorizationEncryptedResponseAlg;

  /// Cifrado de contenido JWE. Normalmente `A128GCM`.
  @override
  @JsonKey(name: 'authorization_encrypted_response_enc')
  final String? authorizationEncryptedResponseEnc;

  @override
  String toString() {
    return 'AuthorizationRequest(responseType: $responseType, clientId: $clientId, responseMode: $responseMode, responseUri: $responseUri, nonce: $nonce, state: $state, presentationDefinition: $presentationDefinition, presentationDefinitionUri: $presentationDefinitionUri, dcqlQuery: $dcqlQuery, clientMetadata: $clientMetadata, scope: $scope, authorizationEncryptedResponseAlg: $authorizationEncryptedResponseAlg, authorizationEncryptedResponseEnc: $authorizationEncryptedResponseEnc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationRequestImpl &&
            (identical(other.responseType, responseType) ||
                other.responseType == responseType) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.responseMode, responseMode) ||
                other.responseMode == responseMode) &&
            (identical(other.responseUri, responseUri) ||
                other.responseUri == responseUri) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality().equals(
                other._presentationDefinition, _presentationDefinition) &&
            (identical(other.presentationDefinitionUri,
                    presentationDefinitionUri) ||
                other.presentationDefinitionUri == presentationDefinitionUri) &&
            const DeepCollectionEquality()
                .equals(other._dcqlQuery, _dcqlQuery) &&
            const DeepCollectionEquality()
                .equals(other._clientMetadata, _clientMetadata) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.authorizationEncryptedResponseAlg,
                    authorizationEncryptedResponseAlg) ||
                other.authorizationEncryptedResponseAlg ==
                    authorizationEncryptedResponseAlg) &&
            (identical(other.authorizationEncryptedResponseEnc,
                    authorizationEncryptedResponseEnc) ||
                other.authorizationEncryptedResponseEnc ==
                    authorizationEncryptedResponseEnc));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      responseType,
      clientId,
      responseMode,
      responseUri,
      nonce,
      state,
      const DeepCollectionEquality().hash(_presentationDefinition),
      presentationDefinitionUri,
      const DeepCollectionEquality().hash(_dcqlQuery),
      const DeepCollectionEquality().hash(_clientMetadata),
      scope,
      authorizationEncryptedResponseAlg,
      authorizationEncryptedResponseEnc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationRequestImplCopyWith<_$AuthorizationRequestImpl>
      get copyWith =>
          __$$AuthorizationRequestImplCopyWithImpl<_$AuthorizationRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationRequestImplToJson(
      this,
    );
  }
}

abstract class _AuthorizationRequest implements AuthorizationRequest {
  const factory _AuthorizationRequest(
          {@JsonKey(name: 'response_type') required final String responseType,
          @JsonKey(name: 'client_id') required final String clientId,
          @JsonKey(name: 'response_mode') final String? responseMode,
          @JsonKey(name: 'response_uri') final String? responseUri,
          final String? nonce,
          final String? state,
          @JsonKey(name: 'presentation_definition')
          final Map<String, dynamic>? presentationDefinition,
          @JsonKey(name: 'presentation_definition_uri')
          final String? presentationDefinitionUri,
          @JsonKey(name: 'dcql_query') final Map<String, dynamic>? dcqlQuery,
          @JsonKey(name: 'client_metadata')
          final Map<String, dynamic>? clientMetadata,
          final String? scope,
          @JsonKey(name: 'authorization_encrypted_response_alg')
          final String? authorizationEncryptedResponseAlg,
          @JsonKey(name: 'authorization_encrypted_response_enc')
          final String? authorizationEncryptedResponseEnc}) =
      _$AuthorizationRequestImpl;

  factory _AuthorizationRequest.fromJson(Map<String, dynamic> json) =
      _$AuthorizationRequestImpl.fromJson;

  @override

  /// Tipo de respuesta esperado. Normalmente `'vp_token'`.
  @JsonKey(name: 'response_type')
  String get responseType;
  @override

  /// Identificador del cliente (verifier).
  @JsonKey(name: 'client_id')
  String get clientId;
  @override

  /// Modo de respuesta. Normalmente `'direct_post'`.
  @JsonKey(name: 'response_mode')
  String? get responseMode;
  @override

  /// URI a la que el wallet envía la respuesta via POST.
  @JsonKey(name: 'response_uri')
  String? get responseUri;
  @override

  /// Nonce para prevenir replay attacks. Incluido en el kb-JWT y VP JWT.
  String? get nonce;
  @override

  /// Estado opaco del verifier, devuelto en la respuesta.
  String? get state;
  @override

  /// Presentation Definition (PEX) en formato crudo.
  @JsonKey(name: 'presentation_definition')
  Map<String, dynamic>? get presentationDefinition;
  @override

  /// Referencia URI a una Presentation Definition externa.
  @JsonKey(name: 'presentation_definition_uri')
  String? get presentationDefinitionUri;
  @override

  /// DCQL query para selección de credenciales.
  @JsonKey(name: 'dcql_query')
  Map<String, dynamic>? get dcqlQuery;
  @override

  /// Metadatos del cliente verifier (nombre, logo, políticas).
  @JsonKey(name: 'client_metadata')
  Map<String, dynamic>? get clientMetadata;
  @override

  /// Scope adicional.
  String? get scope;
  @override

  /// Algoritmo JWE (`direct_post.jwt`). Normalmente `ECDH-ES`.
  @JsonKey(name: 'authorization_encrypted_response_alg')
  String? get authorizationEncryptedResponseAlg;
  @override

  /// Cifrado de contenido JWE. Normalmente `A128GCM`.
  @JsonKey(name: 'authorization_encrypted_response_enc')
  String? get authorizationEncryptedResponseEnc;
  @override
  @JsonKey(ignore: true)
  _$$AuthorizationRequestImplCopyWith<_$AuthorizationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
