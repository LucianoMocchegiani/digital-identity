// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials_for_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CredentialsForRequest {
  /// Query type detectado: PEX o DCQL.
  QueryType get queryType => throw _privateConstructorUsedError;

  /// Submission formateada para UI.
  FormattedSubmission get submission => throw _privateConstructorUsedError;

  /// `client_id` del verifier (para el kb-JWT audience).
  String get verifierClientId => throw _privateConstructorUsedError;

  /// Nonce del authorization request (para kb-JWT y VP JWT).
  String? get nonce => throw _privateConstructorUsedError;

  /// URI a la que enviar la respuesta.
  String? get responseUri => throw _privateConstructorUsedError;

  /// Estado opaco del verifier.
  String? get state => throw _privateConstructorUsedError;

  /// ID de la Presentation Definition (solo PEX).
  String? get presentationDefinitionId => throw _privateConstructorUsedError;

  /// Información de confianza del verifier. Null si no se pudo determinar.
  TrustedEntity? get trustedEntity => throw _privateConstructorUsedError;

  /// `response_mode` del authorization request.
  String? get responseMode => throw _privateConstructorUsedError;

  /// Metadatos del verifier (`jwks` para JARM).
  Map<String, dynamic>? get clientMetadata =>
      throw _privateConstructorUsedError;

  /// Algoritmo JWE de respuesta cifrada.
  String? get authorizationEncryptedResponseEnc =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CredentialsForRequestCopyWith<CredentialsForRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialsForRequestCopyWith<$Res> {
  factory $CredentialsForRequestCopyWith(CredentialsForRequest value,
          $Res Function(CredentialsForRequest) then) =
      _$CredentialsForRequestCopyWithImpl<$Res, CredentialsForRequest>;
  @useResult
  $Res call(
      {QueryType queryType,
      FormattedSubmission submission,
      String verifierClientId,
      String? nonce,
      String? responseUri,
      String? state,
      String? presentationDefinitionId,
      TrustedEntity? trustedEntity,
      String? responseMode,
      Map<String, dynamic>? clientMetadata,
      String? authorizationEncryptedResponseEnc});

  $FormattedSubmissionCopyWith<$Res> get submission;
  $TrustedEntityCopyWith<$Res>? get trustedEntity;
}

/// @nodoc
class _$CredentialsForRequestCopyWithImpl<$Res,
        $Val extends CredentialsForRequest>
    implements $CredentialsForRequestCopyWith<$Res> {
  _$CredentialsForRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queryType = null,
    Object? submission = null,
    Object? verifierClientId = null,
    Object? nonce = freezed,
    Object? responseUri = freezed,
    Object? state = freezed,
    Object? presentationDefinitionId = freezed,
    Object? trustedEntity = freezed,
    Object? responseMode = freezed,
    Object? clientMetadata = freezed,
    Object? authorizationEncryptedResponseEnc = freezed,
  }) {
    return _then(_value.copyWith(
      queryType: null == queryType
          ? _value.queryType
          : queryType // ignore: cast_nullable_to_non_nullable
              as QueryType,
      submission: null == submission
          ? _value.submission
          : submission // ignore: cast_nullable_to_non_nullable
              as FormattedSubmission,
      verifierClientId: null == verifierClientId
          ? _value.verifierClientId
          : verifierClientId // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      responseUri: freezed == responseUri
          ? _value.responseUri
          : responseUri // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationDefinitionId: freezed == presentationDefinitionId
          ? _value.presentationDefinitionId
          : presentationDefinitionId // ignore: cast_nullable_to_non_nullable
              as String?,
      trustedEntity: freezed == trustedEntity
          ? _value.trustedEntity
          : trustedEntity // ignore: cast_nullable_to_non_nullable
              as TrustedEntity?,
      responseMode: freezed == responseMode
          ? _value.responseMode
          : responseMode // ignore: cast_nullable_to_non_nullable
              as String?,
      clientMetadata: freezed == clientMetadata
          ? _value.clientMetadata
          : clientMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      authorizationEncryptedResponseEnc: freezed ==
              authorizationEncryptedResponseEnc
          ? _value.authorizationEncryptedResponseEnc
          : authorizationEncryptedResponseEnc // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FormattedSubmissionCopyWith<$Res> get submission {
    return $FormattedSubmissionCopyWith<$Res>(_value.submission, (value) {
      return _then(_value.copyWith(submission: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TrustedEntityCopyWith<$Res>? get trustedEntity {
    if (_value.trustedEntity == null) {
      return null;
    }

    return $TrustedEntityCopyWith<$Res>(_value.trustedEntity!, (value) {
      return _then(_value.copyWith(trustedEntity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialsForRequestImplCopyWith<$Res>
    implements $CredentialsForRequestCopyWith<$Res> {
  factory _$$CredentialsForRequestImplCopyWith(
          _$CredentialsForRequestImpl value,
          $Res Function(_$CredentialsForRequestImpl) then) =
      __$$CredentialsForRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {QueryType queryType,
      FormattedSubmission submission,
      String verifierClientId,
      String? nonce,
      String? responseUri,
      String? state,
      String? presentationDefinitionId,
      TrustedEntity? trustedEntity,
      String? responseMode,
      Map<String, dynamic>? clientMetadata,
      String? authorizationEncryptedResponseEnc});

  @override
  $FormattedSubmissionCopyWith<$Res> get submission;
  @override
  $TrustedEntityCopyWith<$Res>? get trustedEntity;
}

/// @nodoc
class __$$CredentialsForRequestImplCopyWithImpl<$Res>
    extends _$CredentialsForRequestCopyWithImpl<$Res,
        _$CredentialsForRequestImpl>
    implements _$$CredentialsForRequestImplCopyWith<$Res> {
  __$$CredentialsForRequestImplCopyWithImpl(_$CredentialsForRequestImpl _value,
      $Res Function(_$CredentialsForRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queryType = null,
    Object? submission = null,
    Object? verifierClientId = null,
    Object? nonce = freezed,
    Object? responseUri = freezed,
    Object? state = freezed,
    Object? presentationDefinitionId = freezed,
    Object? trustedEntity = freezed,
    Object? responseMode = freezed,
    Object? clientMetadata = freezed,
    Object? authorizationEncryptedResponseEnc = freezed,
  }) {
    return _then(_$CredentialsForRequestImpl(
      queryType: null == queryType
          ? _value.queryType
          : queryType // ignore: cast_nullable_to_non_nullable
              as QueryType,
      submission: null == submission
          ? _value.submission
          : submission // ignore: cast_nullable_to_non_nullable
              as FormattedSubmission,
      verifierClientId: null == verifierClientId
          ? _value.verifierClientId
          : verifierClientId // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      responseUri: freezed == responseUri
          ? _value.responseUri
          : responseUri // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationDefinitionId: freezed == presentationDefinitionId
          ? _value.presentationDefinitionId
          : presentationDefinitionId // ignore: cast_nullable_to_non_nullable
              as String?,
      trustedEntity: freezed == trustedEntity
          ? _value.trustedEntity
          : trustedEntity // ignore: cast_nullable_to_non_nullable
              as TrustedEntity?,
      responseMode: freezed == responseMode
          ? _value.responseMode
          : responseMode // ignore: cast_nullable_to_non_nullable
              as String?,
      clientMetadata: freezed == clientMetadata
          ? _value._clientMetadata
          : clientMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      authorizationEncryptedResponseEnc: freezed ==
              authorizationEncryptedResponseEnc
          ? _value.authorizationEncryptedResponseEnc
          : authorizationEncryptedResponseEnc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CredentialsForRequestImpl implements _CredentialsForRequest {
  const _$CredentialsForRequestImpl(
      {required this.queryType,
      required this.submission,
      required this.verifierClientId,
      this.nonce,
      this.responseUri,
      this.state,
      this.presentationDefinitionId,
      this.trustedEntity,
      this.responseMode,
      final Map<String, dynamic>? clientMetadata,
      this.authorizationEncryptedResponseEnc})
      : _clientMetadata = clientMetadata;

  /// Query type detectado: PEX o DCQL.
  @override
  final QueryType queryType;

  /// Submission formateada para UI.
  @override
  final FormattedSubmission submission;

  /// `client_id` del verifier (para el kb-JWT audience).
  @override
  final String verifierClientId;

  /// Nonce del authorization request (para kb-JWT y VP JWT).
  @override
  final String? nonce;

  /// URI a la que enviar la respuesta.
  @override
  final String? responseUri;

  /// Estado opaco del verifier.
  @override
  final String? state;

  /// ID de la Presentation Definition (solo PEX).
  @override
  final String? presentationDefinitionId;

  /// Información de confianza del verifier. Null si no se pudo determinar.
  @override
  final TrustedEntity? trustedEntity;

  /// `response_mode` del authorization request.
  @override
  final String? responseMode;

  /// Metadatos del verifier (`jwks` para JARM).
  final Map<String, dynamic>? _clientMetadata;

  /// Metadatos del verifier (`jwks` para JARM).
  @override
  Map<String, dynamic>? get clientMetadata {
    final value = _clientMetadata;
    if (value == null) return null;
    if (_clientMetadata is EqualUnmodifiableMapView) return _clientMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Algoritmo JWE de respuesta cifrada.
  @override
  final String? authorizationEncryptedResponseEnc;

  @override
  String toString() {
    return 'CredentialsForRequest(queryType: $queryType, submission: $submission, verifierClientId: $verifierClientId, nonce: $nonce, responseUri: $responseUri, state: $state, presentationDefinitionId: $presentationDefinitionId, trustedEntity: $trustedEntity, responseMode: $responseMode, clientMetadata: $clientMetadata, authorizationEncryptedResponseEnc: $authorizationEncryptedResponseEnc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialsForRequestImpl &&
            (identical(other.queryType, queryType) ||
                other.queryType == queryType) &&
            (identical(other.submission, submission) ||
                other.submission == submission) &&
            (identical(other.verifierClientId, verifierClientId) ||
                other.verifierClientId == verifierClientId) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.responseUri, responseUri) ||
                other.responseUri == responseUri) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(
                    other.presentationDefinitionId, presentationDefinitionId) ||
                other.presentationDefinitionId == presentationDefinitionId) &&
            (identical(other.trustedEntity, trustedEntity) ||
                other.trustedEntity == trustedEntity) &&
            (identical(other.responseMode, responseMode) ||
                other.responseMode == responseMode) &&
            const DeepCollectionEquality()
                .equals(other._clientMetadata, _clientMetadata) &&
            (identical(other.authorizationEncryptedResponseEnc,
                    authorizationEncryptedResponseEnc) ||
                other.authorizationEncryptedResponseEnc ==
                    authorizationEncryptedResponseEnc));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      queryType,
      submission,
      verifierClientId,
      nonce,
      responseUri,
      state,
      presentationDefinitionId,
      trustedEntity,
      responseMode,
      const DeepCollectionEquality().hash(_clientMetadata),
      authorizationEncryptedResponseEnc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsForRequestImplCopyWith<_$CredentialsForRequestImpl>
      get copyWith => __$$CredentialsForRequestImplCopyWithImpl<
          _$CredentialsForRequestImpl>(this, _$identity);
}

abstract class _CredentialsForRequest implements CredentialsForRequest {
  const factory _CredentialsForRequest(
          {required final QueryType queryType,
          required final FormattedSubmission submission,
          required final String verifierClientId,
          final String? nonce,
          final String? responseUri,
          final String? state,
          final String? presentationDefinitionId,
          final TrustedEntity? trustedEntity,
          final String? responseMode,
          final Map<String, dynamic>? clientMetadata,
          final String? authorizationEncryptedResponseEnc}) =
      _$CredentialsForRequestImpl;

  @override

  /// Query type detectado: PEX o DCQL.
  QueryType get queryType;
  @override

  /// Submission formateada para UI.
  FormattedSubmission get submission;
  @override

  /// `client_id` del verifier (para el kb-JWT audience).
  String get verifierClientId;
  @override

  /// Nonce del authorization request (para kb-JWT y VP JWT).
  String? get nonce;
  @override

  /// URI a la que enviar la respuesta.
  String? get responseUri;
  @override

  /// Estado opaco del verifier.
  String? get state;
  @override

  /// ID de la Presentation Definition (solo PEX).
  String? get presentationDefinitionId;
  @override

  /// Información de confianza del verifier. Null si no se pudo determinar.
  TrustedEntity? get trustedEntity;
  @override

  /// `response_mode` del authorization request.
  String? get responseMode;
  @override

  /// Metadatos del verifier (`jwks` para JARM).
  Map<String, dynamic>? get clientMetadata;
  @override

  /// Algoritmo JWE de respuesta cifrada.
  String? get authorizationEncryptedResponseEnc;
  @override
  @JsonKey(ignore: true)
  _$$CredentialsForRequestImplCopyWith<_$CredentialsForRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FormattedSubmission {
  /// Nombre de la solicitud (del PEX `name` o metadata del verifier).
  String? get name => throw _privateConstructorUsedError;

  /// Propósito declarado de la solicitud.
  String? get purpose => throw _privateConstructorUsedError;

  /// Verdadero si todas las entradas tienen credenciales disponibles.
  bool get areAllSatisfied => throw _privateConstructorUsedError;

  /// Entradas individuales: una por input descriptor o credential query.
  List<FormattedSubmissionEntry> get entries =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FormattedSubmissionCopyWith<FormattedSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormattedSubmissionCopyWith<$Res> {
  factory $FormattedSubmissionCopyWith(
          FormattedSubmission value, $Res Function(FormattedSubmission) then) =
      _$FormattedSubmissionCopyWithImpl<$Res, FormattedSubmission>;
  @useResult
  $Res call(
      {String? name,
      String? purpose,
      bool areAllSatisfied,
      List<FormattedSubmissionEntry> entries});
}

/// @nodoc
class _$FormattedSubmissionCopyWithImpl<$Res, $Val extends FormattedSubmission>
    implements $FormattedSubmissionCopyWith<$Res> {
  _$FormattedSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? purpose = freezed,
    Object? areAllSatisfied = null,
    Object? entries = null,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      areAllSatisfied: null == areAllSatisfied
          ? _value.areAllSatisfied
          : areAllSatisfied // ignore: cast_nullable_to_non_nullable
              as bool,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<FormattedSubmissionEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormattedSubmissionImplCopyWith<$Res>
    implements $FormattedSubmissionCopyWith<$Res> {
  factory _$$FormattedSubmissionImplCopyWith(_$FormattedSubmissionImpl value,
          $Res Function(_$FormattedSubmissionImpl) then) =
      __$$FormattedSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? purpose,
      bool areAllSatisfied,
      List<FormattedSubmissionEntry> entries});
}

/// @nodoc
class __$$FormattedSubmissionImplCopyWithImpl<$Res>
    extends _$FormattedSubmissionCopyWithImpl<$Res, _$FormattedSubmissionImpl>
    implements _$$FormattedSubmissionImplCopyWith<$Res> {
  __$$FormattedSubmissionImplCopyWithImpl(_$FormattedSubmissionImpl _value,
      $Res Function(_$FormattedSubmissionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? purpose = freezed,
    Object? areAllSatisfied = null,
    Object? entries = null,
  }) {
    return _then(_$FormattedSubmissionImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      areAllSatisfied: null == areAllSatisfied
          ? _value.areAllSatisfied
          : areAllSatisfied // ignore: cast_nullable_to_non_nullable
              as bool,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<FormattedSubmissionEntry>,
    ));
  }
}

/// @nodoc

class _$FormattedSubmissionImpl implements _FormattedSubmission {
  const _$FormattedSubmissionImpl(
      {this.name,
      this.purpose,
      required this.areAllSatisfied,
      required final List<FormattedSubmissionEntry> entries})
      : _entries = entries;

  /// Nombre de la solicitud (del PEX `name` o metadata del verifier).
  @override
  final String? name;

  /// Propósito declarado de la solicitud.
  @override
  final String? purpose;

  /// Verdadero si todas las entradas tienen credenciales disponibles.
  @override
  final bool areAllSatisfied;

  /// Entradas individuales: una por input descriptor o credential query.
  final List<FormattedSubmissionEntry> _entries;

  /// Entradas individuales: una por input descriptor o credential query.
  @override
  List<FormattedSubmissionEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  String toString() {
    return 'FormattedSubmission(name: $name, purpose: $purpose, areAllSatisfied: $areAllSatisfied, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormattedSubmissionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.areAllSatisfied, areAllSatisfied) ||
                other.areAllSatisfied == areAllSatisfied) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, purpose, areAllSatisfied,
      const DeepCollectionEquality().hash(_entries));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormattedSubmissionImplCopyWith<_$FormattedSubmissionImpl> get copyWith =>
      __$$FormattedSubmissionImplCopyWithImpl<_$FormattedSubmissionImpl>(
          this, _$identity);
}

abstract class _FormattedSubmission implements FormattedSubmission {
  const factory _FormattedSubmission(
          {final String? name,
          final String? purpose,
          required final bool areAllSatisfied,
          required final List<FormattedSubmissionEntry> entries}) =
      _$FormattedSubmissionImpl;

  @override

  /// Nombre de la solicitud (del PEX `name` o metadata del verifier).
  String? get name;
  @override

  /// Propósito declarado de la solicitud.
  String? get purpose;
  @override

  /// Verdadero si todas las entradas tienen credenciales disponibles.
  bool get areAllSatisfied;
  @override

  /// Entradas individuales: una por input descriptor o credential query.
  List<FormattedSubmissionEntry> get entries;
  @override
  @JsonKey(ignore: true)
  _$$FormattedSubmissionImplCopyWith<_$FormattedSubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FormattedSubmissionEntry {
  /// ID del input descriptor (PEX) o credential query (DCQL).
  String get inputDescriptorId => throw _privateConstructorUsedError;

  /// Verdadero si hay al menos una credencial disponible para este descriptor.
  bool get isSatisfied => throw _privateConstructorUsedError;

  /// Nombre descriptivo del tipo de credencial requerida.
  String? get name => throw _privateConstructorUsedError;

  /// Propósito específico de este descriptor.
  String? get purpose => throw _privateConstructorUsedError;

  /// Credenciales disponibles que satisfacen este descriptor.
  List<CredentialRecord>? get matchingCredentials =>
      throw _privateConstructorUsedError;

  /// Paths de claims solicitados (para mostrar al usuario qué se compartirá).
  List<String>? get requestedClaimPaths => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FormattedSubmissionEntryCopyWith<FormattedSubmissionEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormattedSubmissionEntryCopyWith<$Res> {
  factory $FormattedSubmissionEntryCopyWith(FormattedSubmissionEntry value,
          $Res Function(FormattedSubmissionEntry) then) =
      _$FormattedSubmissionEntryCopyWithImpl<$Res, FormattedSubmissionEntry>;
  @useResult
  $Res call(
      {String inputDescriptorId,
      bool isSatisfied,
      String? name,
      String? purpose,
      List<CredentialRecord>? matchingCredentials,
      List<String>? requestedClaimPaths});
}

/// @nodoc
class _$FormattedSubmissionEntryCopyWithImpl<$Res,
        $Val extends FormattedSubmissionEntry>
    implements $FormattedSubmissionEntryCopyWith<$Res> {
  _$FormattedSubmissionEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputDescriptorId = null,
    Object? isSatisfied = null,
    Object? name = freezed,
    Object? purpose = freezed,
    Object? matchingCredentials = freezed,
    Object? requestedClaimPaths = freezed,
  }) {
    return _then(_value.copyWith(
      inputDescriptorId: null == inputDescriptorId
          ? _value.inputDescriptorId
          : inputDescriptorId // ignore: cast_nullable_to_non_nullable
              as String,
      isSatisfied: null == isSatisfied
          ? _value.isSatisfied
          : isSatisfied // ignore: cast_nullable_to_non_nullable
              as bool,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      matchingCredentials: freezed == matchingCredentials
          ? _value.matchingCredentials
          : matchingCredentials // ignore: cast_nullable_to_non_nullable
              as List<CredentialRecord>?,
      requestedClaimPaths: freezed == requestedClaimPaths
          ? _value.requestedClaimPaths
          : requestedClaimPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormattedSubmissionEntryImplCopyWith<$Res>
    implements $FormattedSubmissionEntryCopyWith<$Res> {
  factory _$$FormattedSubmissionEntryImplCopyWith(
          _$FormattedSubmissionEntryImpl value,
          $Res Function(_$FormattedSubmissionEntryImpl) then) =
      __$$FormattedSubmissionEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inputDescriptorId,
      bool isSatisfied,
      String? name,
      String? purpose,
      List<CredentialRecord>? matchingCredentials,
      List<String>? requestedClaimPaths});
}

/// @nodoc
class __$$FormattedSubmissionEntryImplCopyWithImpl<$Res>
    extends _$FormattedSubmissionEntryCopyWithImpl<$Res,
        _$FormattedSubmissionEntryImpl>
    implements _$$FormattedSubmissionEntryImplCopyWith<$Res> {
  __$$FormattedSubmissionEntryImplCopyWithImpl(
      _$FormattedSubmissionEntryImpl _value,
      $Res Function(_$FormattedSubmissionEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputDescriptorId = null,
    Object? isSatisfied = null,
    Object? name = freezed,
    Object? purpose = freezed,
    Object? matchingCredentials = freezed,
    Object? requestedClaimPaths = freezed,
  }) {
    return _then(_$FormattedSubmissionEntryImpl(
      inputDescriptorId: null == inputDescriptorId
          ? _value.inputDescriptorId
          : inputDescriptorId // ignore: cast_nullable_to_non_nullable
              as String,
      isSatisfied: null == isSatisfied
          ? _value.isSatisfied
          : isSatisfied // ignore: cast_nullable_to_non_nullable
              as bool,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String?,
      matchingCredentials: freezed == matchingCredentials
          ? _value._matchingCredentials
          : matchingCredentials // ignore: cast_nullable_to_non_nullable
              as List<CredentialRecord>?,
      requestedClaimPaths: freezed == requestedClaimPaths
          ? _value._requestedClaimPaths
          : requestedClaimPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$FormattedSubmissionEntryImpl implements _FormattedSubmissionEntry {
  const _$FormattedSubmissionEntryImpl(
      {required this.inputDescriptorId,
      required this.isSatisfied,
      this.name,
      this.purpose,
      final List<CredentialRecord>? matchingCredentials,
      final List<String>? requestedClaimPaths})
      : _matchingCredentials = matchingCredentials,
        _requestedClaimPaths = requestedClaimPaths;

  /// ID del input descriptor (PEX) o credential query (DCQL).
  @override
  final String inputDescriptorId;

  /// Verdadero si hay al menos una credencial disponible para este descriptor.
  @override
  final bool isSatisfied;

  /// Nombre descriptivo del tipo de credencial requerida.
  @override
  final String? name;

  /// Propósito específico de este descriptor.
  @override
  final String? purpose;

  /// Credenciales disponibles que satisfacen este descriptor.
  final List<CredentialRecord>? _matchingCredentials;

  /// Credenciales disponibles que satisfacen este descriptor.
  @override
  List<CredentialRecord>? get matchingCredentials {
    final value = _matchingCredentials;
    if (value == null) return null;
    if (_matchingCredentials is EqualUnmodifiableListView)
      return _matchingCredentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Paths de claims solicitados (para mostrar al usuario qué se compartirá).
  final List<String>? _requestedClaimPaths;

  /// Paths de claims solicitados (para mostrar al usuario qué se compartirá).
  @override
  List<String>? get requestedClaimPaths {
    final value = _requestedClaimPaths;
    if (value == null) return null;
    if (_requestedClaimPaths is EqualUnmodifiableListView)
      return _requestedClaimPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FormattedSubmissionEntry(inputDescriptorId: $inputDescriptorId, isSatisfied: $isSatisfied, name: $name, purpose: $purpose, matchingCredentials: $matchingCredentials, requestedClaimPaths: $requestedClaimPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormattedSubmissionEntryImpl &&
            (identical(other.inputDescriptorId, inputDescriptorId) ||
                other.inputDescriptorId == inputDescriptorId) &&
            (identical(other.isSatisfied, isSatisfied) ||
                other.isSatisfied == isSatisfied) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            const DeepCollectionEquality()
                .equals(other._matchingCredentials, _matchingCredentials) &&
            const DeepCollectionEquality()
                .equals(other._requestedClaimPaths, _requestedClaimPaths));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      inputDescriptorId,
      isSatisfied,
      name,
      purpose,
      const DeepCollectionEquality().hash(_matchingCredentials),
      const DeepCollectionEquality().hash(_requestedClaimPaths));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormattedSubmissionEntryImplCopyWith<_$FormattedSubmissionEntryImpl>
      get copyWith => __$$FormattedSubmissionEntryImplCopyWithImpl<
          _$FormattedSubmissionEntryImpl>(this, _$identity);
}

abstract class _FormattedSubmissionEntry implements FormattedSubmissionEntry {
  const factory _FormattedSubmissionEntry(
          {required final String inputDescriptorId,
          required final bool isSatisfied,
          final String? name,
          final String? purpose,
          final List<CredentialRecord>? matchingCredentials,
          final List<String>? requestedClaimPaths}) =
      _$FormattedSubmissionEntryImpl;

  @override

  /// ID del input descriptor (PEX) o credential query (DCQL).
  String get inputDescriptorId;
  @override

  /// Verdadero si hay al menos una credencial disponible para este descriptor.
  bool get isSatisfied;
  @override

  /// Nombre descriptivo del tipo de credencial requerida.
  String? get name;
  @override

  /// Propósito específico de este descriptor.
  String? get purpose;
  @override

  /// Credenciales disponibles que satisfacen este descriptor.
  List<CredentialRecord>? get matchingCredentials;
  @override

  /// Paths de claims solicitados (para mostrar al usuario qué se compartirá).
  List<String>? get requestedClaimPaths;
  @override
  @JsonKey(ignore: true)
  _$$FormattedSubmissionEntryImplCopyWith<_$FormattedSubmissionEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
