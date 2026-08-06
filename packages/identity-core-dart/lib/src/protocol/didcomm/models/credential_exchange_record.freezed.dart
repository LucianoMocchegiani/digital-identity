// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_exchange_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CredentialExchangeRecord {
  String get exchangeId => throw _privateConstructorUsedError;
  String get connectionId => throw _privateConstructorUsedError;
  CredentialExchangeState get state => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get offerAttach => throw _privateConstructorUsedError;
  Map<String, dynamic>? get credentialAttach =>
      throw _privateConstructorUsedError;
  String? get threadId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CredentialExchangeRecordCopyWith<CredentialExchangeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialExchangeRecordCopyWith<$Res> {
  factory $CredentialExchangeRecordCopyWith(CredentialExchangeRecord value,
          $Res Function(CredentialExchangeRecord) then) =
      _$CredentialExchangeRecordCopyWithImpl<$Res, CredentialExchangeRecord>;
  @useResult
  $Res call(
      {String exchangeId,
      String connectionId,
      CredentialExchangeState state,
      DateTime createdAt,
      Map<String, dynamic>? offerAttach,
      Map<String, dynamic>? credentialAttach,
      String? threadId,
      String? error});
}

/// @nodoc
class _$CredentialExchangeRecordCopyWithImpl<$Res,
        $Val extends CredentialExchangeRecord>
    implements $CredentialExchangeRecordCopyWith<$Res> {
  _$CredentialExchangeRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exchangeId = null,
    Object? connectionId = null,
    Object? state = null,
    Object? createdAt = null,
    Object? offerAttach = freezed,
    Object? credentialAttach = freezed,
    Object? threadId = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      exchangeId: null == exchangeId
          ? _value.exchangeId
          : exchangeId // ignore: cast_nullable_to_non_nullable
              as String,
      connectionId: null == connectionId
          ? _value.connectionId
          : connectionId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as CredentialExchangeState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      offerAttach: freezed == offerAttach
          ? _value.offerAttach
          : offerAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      credentialAttach: freezed == credentialAttach
          ? _value.credentialAttach
          : credentialAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      threadId: freezed == threadId
          ? _value.threadId
          : threadId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialExchangeRecordImplCopyWith<$Res>
    implements $CredentialExchangeRecordCopyWith<$Res> {
  factory _$$CredentialExchangeRecordImplCopyWith(
          _$CredentialExchangeRecordImpl value,
          $Res Function(_$CredentialExchangeRecordImpl) then) =
      __$$CredentialExchangeRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exchangeId,
      String connectionId,
      CredentialExchangeState state,
      DateTime createdAt,
      Map<String, dynamic>? offerAttach,
      Map<String, dynamic>? credentialAttach,
      String? threadId,
      String? error});
}

/// @nodoc
class __$$CredentialExchangeRecordImplCopyWithImpl<$Res>
    extends _$CredentialExchangeRecordCopyWithImpl<$Res,
        _$CredentialExchangeRecordImpl>
    implements _$$CredentialExchangeRecordImplCopyWith<$Res> {
  __$$CredentialExchangeRecordImplCopyWithImpl(
      _$CredentialExchangeRecordImpl _value,
      $Res Function(_$CredentialExchangeRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exchangeId = null,
    Object? connectionId = null,
    Object? state = null,
    Object? createdAt = null,
    Object? offerAttach = freezed,
    Object? credentialAttach = freezed,
    Object? threadId = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CredentialExchangeRecordImpl(
      exchangeId: null == exchangeId
          ? _value.exchangeId
          : exchangeId // ignore: cast_nullable_to_non_nullable
              as String,
      connectionId: null == connectionId
          ? _value.connectionId
          : connectionId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as CredentialExchangeState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      offerAttach: freezed == offerAttach
          ? _value._offerAttach
          : offerAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      credentialAttach: freezed == credentialAttach
          ? _value._credentialAttach
          : credentialAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      threadId: freezed == threadId
          ? _value.threadId
          : threadId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CredentialExchangeRecordImpl implements _CredentialExchangeRecord {
  const _$CredentialExchangeRecordImpl(
      {required this.exchangeId,
      required this.connectionId,
      required this.state,
      required this.createdAt,
      final Map<String, dynamic>? offerAttach,
      final Map<String, dynamic>? credentialAttach,
      this.threadId,
      this.error})
      : _offerAttach = offerAttach,
        _credentialAttach = credentialAttach;

  @override
  final String exchangeId;
  @override
  final String connectionId;
  @override
  final CredentialExchangeState state;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _offerAttach;
  @override
  Map<String, dynamic>? get offerAttach {
    final value = _offerAttach;
    if (value == null) return null;
    if (_offerAttach is EqualUnmodifiableMapView) return _offerAttach;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _credentialAttach;
  @override
  Map<String, dynamic>? get credentialAttach {
    final value = _credentialAttach;
    if (value == null) return null;
    if (_credentialAttach is EqualUnmodifiableMapView) return _credentialAttach;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? threadId;
  @override
  final String? error;

  @override
  String toString() {
    return 'CredentialExchangeRecord(exchangeId: $exchangeId, connectionId: $connectionId, state: $state, createdAt: $createdAt, offerAttach: $offerAttach, credentialAttach: $credentialAttach, threadId: $threadId, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialExchangeRecordImpl &&
            (identical(other.exchangeId, exchangeId) ||
                other.exchangeId == exchangeId) &&
            (identical(other.connectionId, connectionId) ||
                other.connectionId == connectionId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._offerAttach, _offerAttach) &&
            const DeepCollectionEquality()
                .equals(other._credentialAttach, _credentialAttach) &&
            (identical(other.threadId, threadId) ||
                other.threadId == threadId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      exchangeId,
      connectionId,
      state,
      createdAt,
      const DeepCollectionEquality().hash(_offerAttach),
      const DeepCollectionEquality().hash(_credentialAttach),
      threadId,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialExchangeRecordImplCopyWith<_$CredentialExchangeRecordImpl>
      get copyWith => __$$CredentialExchangeRecordImplCopyWithImpl<
          _$CredentialExchangeRecordImpl>(this, _$identity);
}

abstract class _CredentialExchangeRecord implements CredentialExchangeRecord {
  const factory _CredentialExchangeRecord(
      {required final String exchangeId,
      required final String connectionId,
      required final CredentialExchangeState state,
      required final DateTime createdAt,
      final Map<String, dynamic>? offerAttach,
      final Map<String, dynamic>? credentialAttach,
      final String? threadId,
      final String? error}) = _$CredentialExchangeRecordImpl;

  @override
  String get exchangeId;
  @override
  String get connectionId;
  @override
  CredentialExchangeState get state;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get offerAttach;
  @override
  Map<String, dynamic>? get credentialAttach;
  @override
  String? get threadId;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$CredentialExchangeRecordImplCopyWith<_$CredentialExchangeRecordImpl>
      get copyWith => throw _privateConstructorUsedError;
}
