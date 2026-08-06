// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deferred_credential_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeferredCredentialRecord {
  /// Identificador único del registro (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Fecha de creación del registro.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Última vez que se consultó el deferred credential endpoint.
  DateTime get lastCheckedAt => throw _privateConstructorUsedError;

  /// Última vez que ocurrió un error al consultar el endpoint.
  DateTime? get lastErroredAt => throw _privateConstructorUsedError;

  /// Respuesta original del credential endpoint con el `transaction_id`.
  Map<String, dynamic> get response => throw _privateConstructorUsedError;

  /// Metadata del issuer necesaria para construir la URL de deferred credential.
  Map<String, dynamic> get issuerMetadata => throw _privateConstructorUsedError;

  /// Access token para autenticar la request de deferred credential.
  Map<String, dynamic> get accessToken => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeferredCredentialRecordCopyWith<DeferredCredentialRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeferredCredentialRecordCopyWith<$Res> {
  factory $DeferredCredentialRecordCopyWith(DeferredCredentialRecord value,
          $Res Function(DeferredCredentialRecord) then) =
      _$DeferredCredentialRecordCopyWithImpl<$Res, DeferredCredentialRecord>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime lastCheckedAt,
      DateTime? lastErroredAt,
      Map<String, dynamic> response,
      Map<String, dynamic> issuerMetadata,
      Map<String, dynamic> accessToken});
}

/// @nodoc
class _$DeferredCredentialRecordCopyWithImpl<$Res,
        $Val extends DeferredCredentialRecord>
    implements $DeferredCredentialRecordCopyWith<$Res> {
  _$DeferredCredentialRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? lastCheckedAt = null,
    Object? lastErroredAt = freezed,
    Object? response = null,
    Object? issuerMetadata = null,
    Object? accessToken = null,
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
      lastCheckedAt: null == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastErroredAt: freezed == lastErroredAt
          ? _value.lastErroredAt
          : lastErroredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      issuerMetadata: null == issuerMetadata
          ? _value.issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeferredCredentialRecordImplCopyWith<$Res>
    implements $DeferredCredentialRecordCopyWith<$Res> {
  factory _$$DeferredCredentialRecordImplCopyWith(
          _$DeferredCredentialRecordImpl value,
          $Res Function(_$DeferredCredentialRecordImpl) then) =
      __$$DeferredCredentialRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime lastCheckedAt,
      DateTime? lastErroredAt,
      Map<String, dynamic> response,
      Map<String, dynamic> issuerMetadata,
      Map<String, dynamic> accessToken});
}

/// @nodoc
class __$$DeferredCredentialRecordImplCopyWithImpl<$Res>
    extends _$DeferredCredentialRecordCopyWithImpl<$Res,
        _$DeferredCredentialRecordImpl>
    implements _$$DeferredCredentialRecordImplCopyWith<$Res> {
  __$$DeferredCredentialRecordImplCopyWithImpl(
      _$DeferredCredentialRecordImpl _value,
      $Res Function(_$DeferredCredentialRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? lastCheckedAt = null,
    Object? lastErroredAt = freezed,
    Object? response = null,
    Object? issuerMetadata = null,
    Object? accessToken = null,
  }) {
    return _then(_$DeferredCredentialRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastCheckedAt: null == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastErroredAt: freezed == lastErroredAt
          ? _value.lastErroredAt
          : lastErroredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      response: null == response
          ? _value._response
          : response // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      issuerMetadata: null == issuerMetadata
          ? _value._issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accessToken: null == accessToken
          ? _value._accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$DeferredCredentialRecordImpl implements _DeferredCredentialRecord {
  const _$DeferredCredentialRecordImpl(
      {required this.id,
      required this.createdAt,
      required this.lastCheckedAt,
      this.lastErroredAt,
      required final Map<String, dynamic> response,
      required final Map<String, dynamic> issuerMetadata,
      required final Map<String, dynamic> accessToken})
      : _response = response,
        _issuerMetadata = issuerMetadata,
        _accessToken = accessToken;

  /// Identificador único del registro (UUID v4).
  @override
  final String id;

  /// Fecha de creación del registro.
  @override
  final DateTime createdAt;

  /// Última vez que se consultó el deferred credential endpoint.
  @override
  final DateTime lastCheckedAt;

  /// Última vez que ocurrió un error al consultar el endpoint.
  @override
  final DateTime? lastErroredAt;

  /// Respuesta original del credential endpoint con el `transaction_id`.
  final Map<String, dynamic> _response;

  /// Respuesta original del credential endpoint con el `transaction_id`.
  @override
  Map<String, dynamic> get response {
    if (_response is EqualUnmodifiableMapView) return _response;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_response);
  }

  /// Metadata del issuer necesaria para construir la URL de deferred credential.
  final Map<String, dynamic> _issuerMetadata;

  /// Metadata del issuer necesaria para construir la URL de deferred credential.
  @override
  Map<String, dynamic> get issuerMetadata {
    if (_issuerMetadata is EqualUnmodifiableMapView) return _issuerMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_issuerMetadata);
  }

  /// Access token para autenticar la request de deferred credential.
  final Map<String, dynamic> _accessToken;

  /// Access token para autenticar la request de deferred credential.
  @override
  Map<String, dynamic> get accessToken {
    if (_accessToken is EqualUnmodifiableMapView) return _accessToken;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_accessToken);
  }

  @override
  String toString() {
    return 'DeferredCredentialRecord(id: $id, createdAt: $createdAt, lastCheckedAt: $lastCheckedAt, lastErroredAt: $lastErroredAt, response: $response, issuerMetadata: $issuerMetadata, accessToken: $accessToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeferredCredentialRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastCheckedAt, lastCheckedAt) ||
                other.lastCheckedAt == lastCheckedAt) &&
            (identical(other.lastErroredAt, lastErroredAt) ||
                other.lastErroredAt == lastErroredAt) &&
            const DeepCollectionEquality().equals(other._response, _response) &&
            const DeepCollectionEquality()
                .equals(other._issuerMetadata, _issuerMetadata) &&
            const DeepCollectionEquality()
                .equals(other._accessToken, _accessToken));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      lastCheckedAt,
      lastErroredAt,
      const DeepCollectionEquality().hash(_response),
      const DeepCollectionEquality().hash(_issuerMetadata),
      const DeepCollectionEquality().hash(_accessToken));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeferredCredentialRecordImplCopyWith<_$DeferredCredentialRecordImpl>
      get copyWith => __$$DeferredCredentialRecordImplCopyWithImpl<
          _$DeferredCredentialRecordImpl>(this, _$identity);
}

abstract class _DeferredCredentialRecord implements DeferredCredentialRecord {
  const factory _DeferredCredentialRecord(
          {required final String id,
          required final DateTime createdAt,
          required final DateTime lastCheckedAt,
          final DateTime? lastErroredAt,
          required final Map<String, dynamic> response,
          required final Map<String, dynamic> issuerMetadata,
          required final Map<String, dynamic> accessToken}) =
      _$DeferredCredentialRecordImpl;

  @override

  /// Identificador único del registro (UUID v4).
  String get id;
  @override

  /// Fecha de creación del registro.
  DateTime get createdAt;
  @override

  /// Última vez que se consultó el deferred credential endpoint.
  DateTime get lastCheckedAt;
  @override

  /// Última vez que ocurrió un error al consultar el endpoint.
  DateTime? get lastErroredAt;
  @override

  /// Respuesta original del credential endpoint con el `transaction_id`.
  Map<String, dynamic> get response;
  @override

  /// Metadata del issuer necesaria para construir la URL de deferred credential.
  Map<String, dynamic> get issuerMetadata;
  @override

  /// Access token para autenticar la request de deferred credential.
  Map<String, dynamic> get accessToken;
  @override
  @JsonKey(ignore: true)
  _$$DeferredCredentialRecordImplCopyWith<_$DeferredCredentialRecordImpl>
      get copyWith => throw _privateConstructorUsedError;
}
