// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CredentialResponse _$CredentialResponseFromJson(Map<String, dynamic> json) {
  return _CredentialResponse.fromJson(json);
}

/// @nodoc
mixin _$CredentialResponse {
  /// Credencial emitida de forma inmediata (JWT, SD-JWT o base64url CBOR).
  String? get credential => throw _privateConstructorUsedError;

  /// ID de transacción para polling de credencial diferida.
  @JsonKey(name: 'transaction_id')
  String? get transactionId => throw _privateConstructorUsedError;

  /// Nonce fresco para el siguiente credential request.
  @JsonKey(name: 'c_nonce')
  String? get cNonce => throw _privateConstructorUsedError;

  /// Segundos hasta la expiración del nuevo c_nonce.
  @JsonKey(name: 'c_nonce_expires_in')
  int? get cNonceExpiresIn => throw _privateConstructorUsedError;

  /// ID de notificación para el notification endpoint (opcional).
  @JsonKey(name: 'notification_id')
  String? get notificationId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CredentialResponseCopyWith<CredentialResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialResponseCopyWith<$Res> {
  factory $CredentialResponseCopyWith(
          CredentialResponse value, $Res Function(CredentialResponse) then) =
      _$CredentialResponseCopyWithImpl<$Res, CredentialResponse>;
  @useResult
  $Res call(
      {String? credential,
      @JsonKey(name: 'transaction_id') String? transactionId,
      @JsonKey(name: 'c_nonce') String? cNonce,
      @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn,
      @JsonKey(name: 'notification_id') String? notificationId});
}

/// @nodoc
class _$CredentialResponseCopyWithImpl<$Res, $Val extends CredentialResponse>
    implements $CredentialResponseCopyWith<$Res> {
  _$CredentialResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credential = freezed,
    Object? transactionId = freezed,
    Object? cNonce = freezed,
    Object? cNonceExpiresIn = freezed,
    Object? notificationId = freezed,
  }) {
    return _then(_value.copyWith(
      credential: freezed == credential
          ? _value.credential
          : credential // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonce: freezed == cNonce
          ? _value.cNonce
          : cNonce // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonceExpiresIn: freezed == cNonceExpiresIn
          ? _value.cNonceExpiresIn
          : cNonceExpiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
      notificationId: freezed == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialResponseImplCopyWith<$Res>
    implements $CredentialResponseCopyWith<$Res> {
  factory _$$CredentialResponseImplCopyWith(_$CredentialResponseImpl value,
          $Res Function(_$CredentialResponseImpl) then) =
      __$$CredentialResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? credential,
      @JsonKey(name: 'transaction_id') String? transactionId,
      @JsonKey(name: 'c_nonce') String? cNonce,
      @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn,
      @JsonKey(name: 'notification_id') String? notificationId});
}

/// @nodoc
class __$$CredentialResponseImplCopyWithImpl<$Res>
    extends _$CredentialResponseCopyWithImpl<$Res, _$CredentialResponseImpl>
    implements _$$CredentialResponseImplCopyWith<$Res> {
  __$$CredentialResponseImplCopyWithImpl(_$CredentialResponseImpl _value,
      $Res Function(_$CredentialResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credential = freezed,
    Object? transactionId = freezed,
    Object? cNonce = freezed,
    Object? cNonceExpiresIn = freezed,
    Object? notificationId = freezed,
  }) {
    return _then(_$CredentialResponseImpl(
      credential: freezed == credential
          ? _value.credential
          : credential // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonce: freezed == cNonce
          ? _value.cNonce
          : cNonce // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonceExpiresIn: freezed == cNonceExpiresIn
          ? _value.cNonceExpiresIn
          : cNonceExpiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
      notificationId: freezed == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialResponseImpl implements _CredentialResponse {
  const _$CredentialResponseImpl(
      {this.credential,
      @JsonKey(name: 'transaction_id') this.transactionId,
      @JsonKey(name: 'c_nonce') this.cNonce,
      @JsonKey(name: 'c_nonce_expires_in') this.cNonceExpiresIn,
      @JsonKey(name: 'notification_id') this.notificationId});

  factory _$CredentialResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialResponseImplFromJson(json);

  /// Credencial emitida de forma inmediata (JWT, SD-JWT o base64url CBOR).
  @override
  final String? credential;

  /// ID de transacción para polling de credencial diferida.
  @override
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  /// Nonce fresco para el siguiente credential request.
  @override
  @JsonKey(name: 'c_nonce')
  final String? cNonce;

  /// Segundos hasta la expiración del nuevo c_nonce.
  @override
  @JsonKey(name: 'c_nonce_expires_in')
  final int? cNonceExpiresIn;

  /// ID de notificación para el notification endpoint (opcional).
  @override
  @JsonKey(name: 'notification_id')
  final String? notificationId;

  @override
  String toString() {
    return 'CredentialResponse(credential: $credential, transactionId: $transactionId, cNonce: $cNonce, cNonceExpiresIn: $cNonceExpiresIn, notificationId: $notificationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialResponseImpl &&
            (identical(other.credential, credential) ||
                other.credential == credential) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.cNonce, cNonce) || other.cNonce == cNonce) &&
            (identical(other.cNonceExpiresIn, cNonceExpiresIn) ||
                other.cNonceExpiresIn == cNonceExpiresIn) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, credential, transactionId,
      cNonce, cNonceExpiresIn, notificationId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialResponseImplCopyWith<_$CredentialResponseImpl> get copyWith =>
      __$$CredentialResponseImplCopyWithImpl<_$CredentialResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialResponseImplToJson(
      this,
    );
  }
}

abstract class _CredentialResponse implements CredentialResponse {
  const factory _CredentialResponse(
          {final String? credential,
          @JsonKey(name: 'transaction_id') final String? transactionId,
          @JsonKey(name: 'c_nonce') final String? cNonce,
          @JsonKey(name: 'c_nonce_expires_in') final int? cNonceExpiresIn,
          @JsonKey(name: 'notification_id') final String? notificationId}) =
      _$CredentialResponseImpl;

  factory _CredentialResponse.fromJson(Map<String, dynamic> json) =
      _$CredentialResponseImpl.fromJson;

  @override

  /// Credencial emitida de forma inmediata (JWT, SD-JWT o base64url CBOR).
  String? get credential;
  @override

  /// ID de transacción para polling de credencial diferida.
  @JsonKey(name: 'transaction_id')
  String? get transactionId;
  @override

  /// Nonce fresco para el siguiente credential request.
  @JsonKey(name: 'c_nonce')
  String? get cNonce;
  @override

  /// Segundos hasta la expiración del nuevo c_nonce.
  @JsonKey(name: 'c_nonce_expires_in')
  int? get cNonceExpiresIn;
  @override

  /// ID de notificación para el notification endpoint (opcional).
  @JsonKey(name: 'notification_id')
  String? get notificationId;
  @override
  @JsonKey(ignore: true)
  _$$CredentialResponseImplCopyWith<_$CredentialResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
