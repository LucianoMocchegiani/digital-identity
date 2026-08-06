// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retrieve_credentials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RetrieveCredentialsResult {
  List<CredentialRecord> get credentials => throw _privateConstructorUsedError;
  List<DeferredCredentialRecord> get deferredCredentials =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RetrieveCredentialsResultCopyWith<RetrieveCredentialsResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetrieveCredentialsResultCopyWith<$Res> {
  factory $RetrieveCredentialsResultCopyWith(RetrieveCredentialsResult value,
          $Res Function(RetrieveCredentialsResult) then) =
      _$RetrieveCredentialsResultCopyWithImpl<$Res, RetrieveCredentialsResult>;
  @useResult
  $Res call(
      {List<CredentialRecord> credentials,
      List<DeferredCredentialRecord> deferredCredentials});
}

/// @nodoc
class _$RetrieveCredentialsResultCopyWithImpl<$Res,
        $Val extends RetrieveCredentialsResult>
    implements $RetrieveCredentialsResultCopyWith<$Res> {
  _$RetrieveCredentialsResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
    Object? deferredCredentials = null,
  }) {
    return _then(_value.copyWith(
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<CredentialRecord>,
      deferredCredentials: null == deferredCredentials
          ? _value.deferredCredentials
          : deferredCredentials // ignore: cast_nullable_to_non_nullable
              as List<DeferredCredentialRecord>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RetrieveCredentialsResultImplCopyWith<$Res>
    implements $RetrieveCredentialsResultCopyWith<$Res> {
  factory _$$RetrieveCredentialsResultImplCopyWith(
          _$RetrieveCredentialsResultImpl value,
          $Res Function(_$RetrieveCredentialsResultImpl) then) =
      __$$RetrieveCredentialsResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CredentialRecord> credentials,
      List<DeferredCredentialRecord> deferredCredentials});
}

/// @nodoc
class __$$RetrieveCredentialsResultImplCopyWithImpl<$Res>
    extends _$RetrieveCredentialsResultCopyWithImpl<$Res,
        _$RetrieveCredentialsResultImpl>
    implements _$$RetrieveCredentialsResultImplCopyWith<$Res> {
  __$$RetrieveCredentialsResultImplCopyWithImpl(
      _$RetrieveCredentialsResultImpl _value,
      $Res Function(_$RetrieveCredentialsResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
    Object? deferredCredentials = null,
  }) {
    return _then(_$RetrieveCredentialsResultImpl(
      credentials: null == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<CredentialRecord>,
      deferredCredentials: null == deferredCredentials
          ? _value._deferredCredentials
          : deferredCredentials // ignore: cast_nullable_to_non_nullable
              as List<DeferredCredentialRecord>,
    ));
  }
}

/// @nodoc

class _$RetrieveCredentialsResultImpl implements _RetrieveCredentialsResult {
  const _$RetrieveCredentialsResultImpl(
      {required final List<CredentialRecord> credentials,
      required final List<DeferredCredentialRecord> deferredCredentials})
      : _credentials = credentials,
        _deferredCredentials = deferredCredentials;

  final List<CredentialRecord> _credentials;
  @override
  List<CredentialRecord> get credentials {
    if (_credentials is EqualUnmodifiableListView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_credentials);
  }

  final List<DeferredCredentialRecord> _deferredCredentials;
  @override
  List<DeferredCredentialRecord> get deferredCredentials {
    if (_deferredCredentials is EqualUnmodifiableListView)
      return _deferredCredentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deferredCredentials);
  }

  @override
  String toString() {
    return 'RetrieveCredentialsResult(credentials: $credentials, deferredCredentials: $deferredCredentials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetrieveCredentialsResultImpl &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials) &&
            const DeepCollectionEquality()
                .equals(other._deferredCredentials, _deferredCredentials));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_credentials),
      const DeepCollectionEquality().hash(_deferredCredentials));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RetrieveCredentialsResultImplCopyWith<_$RetrieveCredentialsResultImpl>
      get copyWith => __$$RetrieveCredentialsResultImplCopyWithImpl<
          _$RetrieveCredentialsResultImpl>(this, _$identity);
}

abstract class _RetrieveCredentialsResult implements RetrieveCredentialsResult {
  const factory _RetrieveCredentialsResult(
          {required final List<CredentialRecord> credentials,
          required final List<DeferredCredentialRecord> deferredCredentials}) =
      _$RetrieveCredentialsResultImpl;

  @override
  List<CredentialRecord> get credentials;
  @override
  List<DeferredCredentialRecord> get deferredCredentials;
  @override
  @JsonKey(ignore: true)
  _$$RetrieveCredentialsResultImplCopyWith<_$RetrieveCredentialsResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
