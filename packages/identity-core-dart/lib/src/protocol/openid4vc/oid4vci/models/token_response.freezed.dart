// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) {
  return _TokenResponse.fromJson(json);
}

/// @nodoc
mixin _$TokenResponse {
  /// Access token para autorizar requests al credential endpoint.
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;

  /// Tipo de token, normalmente `'Bearer'`.
  @JsonKey(name: 'token_type')
  String get tokenType => throw _privateConstructorUsedError;

  /// Segundos hasta la expiración del token.
  @JsonKey(name: 'expires_in')
  int? get expiresIn => throw _privateConstructorUsedError;

  /// Nonce para incluir en el proof JWT del credential request.
  @JsonKey(name: 'c_nonce')
  String? get cNonce => throw _privateConstructorUsedError;

  /// Segundos hasta la expiración del c_nonce.
  @JsonKey(name: 'c_nonce_expires_in')
  int? get cNonceExpiresIn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenResponseCopyWith<TokenResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenResponseCopyWith<$Res> {
  factory $TokenResponseCopyWith(
          TokenResponse value, $Res Function(TokenResponse) then) =
      _$TokenResponseCopyWithImpl<$Res, TokenResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int? expiresIn,
      @JsonKey(name: 'c_nonce') String? cNonce,
      @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn});
}

/// @nodoc
class _$TokenResponseCopyWithImpl<$Res, $Val extends TokenResponse>
    implements $TokenResponseCopyWith<$Res> {
  _$TokenResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = freezed,
    Object? cNonce = freezed,
    Object? cNonceExpiresIn = freezed,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: freezed == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
      cNonce: freezed == cNonce
          ? _value.cNonce
          : cNonce // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonceExpiresIn: freezed == cNonceExpiresIn
          ? _value.cNonceExpiresIn
          : cNonceExpiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenResponseImplCopyWith<$Res>
    implements $TokenResponseCopyWith<$Res> {
  factory _$$TokenResponseImplCopyWith(
          _$TokenResponseImpl value, $Res Function(_$TokenResponseImpl) then) =
      __$$TokenResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int? expiresIn,
      @JsonKey(name: 'c_nonce') String? cNonce,
      @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn});
}

/// @nodoc
class __$$TokenResponseImplCopyWithImpl<$Res>
    extends _$TokenResponseCopyWithImpl<$Res, _$TokenResponseImpl>
    implements _$$TokenResponseImplCopyWith<$Res> {
  __$$TokenResponseImplCopyWithImpl(
      _$TokenResponseImpl _value, $Res Function(_$TokenResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = freezed,
    Object? cNonce = freezed,
    Object? cNonceExpiresIn = freezed,
  }) {
    return _then(_$TokenResponseImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: freezed == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
      cNonce: freezed == cNonce
          ? _value.cNonce
          : cNonce // ignore: cast_nullable_to_non_nullable
              as String?,
      cNonceExpiresIn: freezed == cNonceExpiresIn
          ? _value.cNonceExpiresIn
          : cNonceExpiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenResponseImpl implements _TokenResponse {
  const _$TokenResponseImpl(
      {@JsonKey(name: 'access_token') required this.accessToken,
      @JsonKey(name: 'token_type') required this.tokenType,
      @JsonKey(name: 'expires_in') this.expiresIn,
      @JsonKey(name: 'c_nonce') this.cNonce,
      @JsonKey(name: 'c_nonce_expires_in') this.cNonceExpiresIn});

  factory _$TokenResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenResponseImplFromJson(json);

  /// Access token para autorizar requests al credential endpoint.
  @override
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// Tipo de token, normalmente `'Bearer'`.
  @override
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// Segundos hasta la expiración del token.
  @override
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  /// Nonce para incluir en el proof JWT del credential request.
  @override
  @JsonKey(name: 'c_nonce')
  final String? cNonce;

  /// Segundos hasta la expiración del c_nonce.
  @override
  @JsonKey(name: 'c_nonce_expires_in')
  final int? cNonceExpiresIn;

  @override
  String toString() {
    return 'TokenResponse(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, cNonce: $cNonce, cNonceExpiresIn: $cNonceExpiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.cNonce, cNonce) || other.cNonce == cNonce) &&
            (identical(other.cNonceExpiresIn, cNonceExpiresIn) ||
                other.cNonceExpiresIn == cNonceExpiresIn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, accessToken, tokenType, expiresIn, cNonce, cNonceExpiresIn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      __$$TokenResponseImplCopyWithImpl<_$TokenResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenResponseImplToJson(
      this,
    );
  }
}

abstract class _TokenResponse implements TokenResponse {
  const factory _TokenResponse(
          {@JsonKey(name: 'access_token') required final String accessToken,
          @JsonKey(name: 'token_type') required final String tokenType,
          @JsonKey(name: 'expires_in') final int? expiresIn,
          @JsonKey(name: 'c_nonce') final String? cNonce,
          @JsonKey(name: 'c_nonce_expires_in') final int? cNonceExpiresIn}) =
      _$TokenResponseImpl;

  factory _TokenResponse.fromJson(Map<String, dynamic> json) =
      _$TokenResponseImpl.fromJson;

  @override

  /// Access token para autorizar requests al credential endpoint.
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override

  /// Tipo de token, normalmente `'Bearer'`.
  @JsonKey(name: 'token_type')
  String get tokenType;
  @override

  /// Segundos hasta la expiración del token.
  @JsonKey(name: 'expires_in')
  int? get expiresIn;
  @override

  /// Nonce para incluir en el proof JWT del credential request.
  @JsonKey(name: 'c_nonce')
  String? get cNonce;
  @override

  /// Segundos hasta la expiración del c_nonce.
  @JsonKey(name: 'c_nonce_expires_in')
  int? get cNonceExpiresIn;
  @override
  @JsonKey(ignore: true)
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
