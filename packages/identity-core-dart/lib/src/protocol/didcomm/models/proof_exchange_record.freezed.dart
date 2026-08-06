// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proof_exchange_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProofExchangeRecord {
  String get exchangeId => throw _privateConstructorUsedError;
  String get connectionId => throw _privateConstructorUsedError;
  ProofExchangeState get state => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get requestAttach => throw _privateConstructorUsedError;
  String? get threadId => throw _privateConstructorUsedError;
  String? get presentationId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProofExchangeRecordCopyWith<ProofExchangeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProofExchangeRecordCopyWith<$Res> {
  factory $ProofExchangeRecordCopyWith(
          ProofExchangeRecord value, $Res Function(ProofExchangeRecord) then) =
      _$ProofExchangeRecordCopyWithImpl<$Res, ProofExchangeRecord>;
  @useResult
  $Res call(
      {String exchangeId,
      String connectionId,
      ProofExchangeState state,
      DateTime createdAt,
      Map<String, dynamic>? requestAttach,
      String? threadId,
      String? presentationId,
      String? error});
}

/// @nodoc
class _$ProofExchangeRecordCopyWithImpl<$Res, $Val extends ProofExchangeRecord>
    implements $ProofExchangeRecordCopyWith<$Res> {
  _$ProofExchangeRecordCopyWithImpl(this._value, this._then);

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
    Object? requestAttach = freezed,
    Object? threadId = freezed,
    Object? presentationId = freezed,
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
              as ProofExchangeState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestAttach: freezed == requestAttach
          ? _value.requestAttach
          : requestAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      threadId: freezed == threadId
          ? _value.threadId
          : threadId // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationId: freezed == presentationId
          ? _value.presentationId
          : presentationId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProofExchangeRecordImplCopyWith<$Res>
    implements $ProofExchangeRecordCopyWith<$Res> {
  factory _$$ProofExchangeRecordImplCopyWith(_$ProofExchangeRecordImpl value,
          $Res Function(_$ProofExchangeRecordImpl) then) =
      __$$ProofExchangeRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exchangeId,
      String connectionId,
      ProofExchangeState state,
      DateTime createdAt,
      Map<String, dynamic>? requestAttach,
      String? threadId,
      String? presentationId,
      String? error});
}

/// @nodoc
class __$$ProofExchangeRecordImplCopyWithImpl<$Res>
    extends _$ProofExchangeRecordCopyWithImpl<$Res, _$ProofExchangeRecordImpl>
    implements _$$ProofExchangeRecordImplCopyWith<$Res> {
  __$$ProofExchangeRecordImplCopyWithImpl(_$ProofExchangeRecordImpl _value,
      $Res Function(_$ProofExchangeRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exchangeId = null,
    Object? connectionId = null,
    Object? state = null,
    Object? createdAt = null,
    Object? requestAttach = freezed,
    Object? threadId = freezed,
    Object? presentationId = freezed,
    Object? error = freezed,
  }) {
    return _then(_$ProofExchangeRecordImpl(
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
              as ProofExchangeState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestAttach: freezed == requestAttach
          ? _value._requestAttach
          : requestAttach // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      threadId: freezed == threadId
          ? _value.threadId
          : threadId // ignore: cast_nullable_to_non_nullable
              as String?,
      presentationId: freezed == presentationId
          ? _value.presentationId
          : presentationId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProofExchangeRecordImpl implements _ProofExchangeRecord {
  const _$ProofExchangeRecordImpl(
      {required this.exchangeId,
      required this.connectionId,
      required this.state,
      required this.createdAt,
      final Map<String, dynamic>? requestAttach,
      this.threadId,
      this.presentationId,
      this.error})
      : _requestAttach = requestAttach;

  @override
  final String exchangeId;
  @override
  final String connectionId;
  @override
  final ProofExchangeState state;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _requestAttach;
  @override
  Map<String, dynamic>? get requestAttach {
    final value = _requestAttach;
    if (value == null) return null;
    if (_requestAttach is EqualUnmodifiableMapView) return _requestAttach;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? threadId;
  @override
  final String? presentationId;
  @override
  final String? error;

  @override
  String toString() {
    return 'ProofExchangeRecord(exchangeId: $exchangeId, connectionId: $connectionId, state: $state, createdAt: $createdAt, requestAttach: $requestAttach, threadId: $threadId, presentationId: $presentationId, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProofExchangeRecordImpl &&
            (identical(other.exchangeId, exchangeId) ||
                other.exchangeId == exchangeId) &&
            (identical(other.connectionId, connectionId) ||
                other.connectionId == connectionId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._requestAttach, _requestAttach) &&
            (identical(other.threadId, threadId) ||
                other.threadId == threadId) &&
            (identical(other.presentationId, presentationId) ||
                other.presentationId == presentationId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      exchangeId,
      connectionId,
      state,
      createdAt,
      const DeepCollectionEquality().hash(_requestAttach),
      threadId,
      presentationId,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProofExchangeRecordImplCopyWith<_$ProofExchangeRecordImpl> get copyWith =>
      __$$ProofExchangeRecordImplCopyWithImpl<_$ProofExchangeRecordImpl>(
          this, _$identity);
}

abstract class _ProofExchangeRecord implements ProofExchangeRecord {
  const factory _ProofExchangeRecord(
      {required final String exchangeId,
      required final String connectionId,
      required final ProofExchangeState state,
      required final DateTime createdAt,
      final Map<String, dynamic>? requestAttach,
      final String? threadId,
      final String? presentationId,
      final String? error}) = _$ProofExchangeRecordImpl;

  @override
  String get exchangeId;
  @override
  String get connectionId;
  @override
  ProofExchangeState get state;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get requestAttach;
  @override
  String? get threadId;
  @override
  String? get presentationId;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ProofExchangeRecordImplCopyWith<_$ProofExchangeRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
