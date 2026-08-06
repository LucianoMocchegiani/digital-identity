// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConnectionRecord {
  /// UUID de la conexión.
  String get connectionId => throw _privateConstructorUsedError;

  /// DID local generado para esta conexión (normalmente `did:peer:2`).
  String get myDid => throw _privateConstructorUsedError;

  /// DID del par remoto.
  String get theirDid => throw _privateConstructorUsedError;

  /// Estado actual del protocolo de conexión.
  ConnectionState get state => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Nombre legible del par (del campo `label` de la invitación).
  String? get label => throw _privateConstructorUsedError;

  /// Código de objetivo de la invitación (p.ej. `issue-vc`).
  String? get goalCode => throw _privateConstructorUsedError;

  /// DID Document del par, almacenado al completar el handshake.
  Map<String, dynamic>? get theirDidDoc => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConnectionRecordCopyWith<ConnectionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionRecordCopyWith<$Res> {
  factory $ConnectionRecordCopyWith(
          ConnectionRecord value, $Res Function(ConnectionRecord) then) =
      _$ConnectionRecordCopyWithImpl<$Res, ConnectionRecord>;
  @useResult
  $Res call(
      {String connectionId,
      String myDid,
      String theirDid,
      ConnectionState state,
      DateTime createdAt,
      String? label,
      String? goalCode,
      Map<String, dynamic>? theirDidDoc});
}

/// @nodoc
class _$ConnectionRecordCopyWithImpl<$Res, $Val extends ConnectionRecord>
    implements $ConnectionRecordCopyWith<$Res> {
  _$ConnectionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionId = null,
    Object? myDid = null,
    Object? theirDid = null,
    Object? state = null,
    Object? createdAt = null,
    Object? label = freezed,
    Object? goalCode = freezed,
    Object? theirDidDoc = freezed,
  }) {
    return _then(_value.copyWith(
      connectionId: null == connectionId
          ? _value.connectionId
          : connectionId // ignore: cast_nullable_to_non_nullable
              as String,
      myDid: null == myDid
          ? _value.myDid
          : myDid // ignore: cast_nullable_to_non_nullable
              as String,
      theirDid: null == theirDid
          ? _value.theirDid
          : theirDid // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as ConnectionState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      goalCode: freezed == goalCode
          ? _value.goalCode
          : goalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      theirDidDoc: freezed == theirDidDoc
          ? _value.theirDidDoc
          : theirDidDoc // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionRecordImplCopyWith<$Res>
    implements $ConnectionRecordCopyWith<$Res> {
  factory _$$ConnectionRecordImplCopyWith(_$ConnectionRecordImpl value,
          $Res Function(_$ConnectionRecordImpl) then) =
      __$$ConnectionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String connectionId,
      String myDid,
      String theirDid,
      ConnectionState state,
      DateTime createdAt,
      String? label,
      String? goalCode,
      Map<String, dynamic>? theirDidDoc});
}

/// @nodoc
class __$$ConnectionRecordImplCopyWithImpl<$Res>
    extends _$ConnectionRecordCopyWithImpl<$Res, _$ConnectionRecordImpl>
    implements _$$ConnectionRecordImplCopyWith<$Res> {
  __$$ConnectionRecordImplCopyWithImpl(_$ConnectionRecordImpl _value,
      $Res Function(_$ConnectionRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionId = null,
    Object? myDid = null,
    Object? theirDid = null,
    Object? state = null,
    Object? createdAt = null,
    Object? label = freezed,
    Object? goalCode = freezed,
    Object? theirDidDoc = freezed,
  }) {
    return _then(_$ConnectionRecordImpl(
      connectionId: null == connectionId
          ? _value.connectionId
          : connectionId // ignore: cast_nullable_to_non_nullable
              as String,
      myDid: null == myDid
          ? _value.myDid
          : myDid // ignore: cast_nullable_to_non_nullable
              as String,
      theirDid: null == theirDid
          ? _value.theirDid
          : theirDid // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as ConnectionState,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      goalCode: freezed == goalCode
          ? _value.goalCode
          : goalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      theirDidDoc: freezed == theirDidDoc
          ? _value._theirDidDoc
          : theirDidDoc // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ConnectionRecordImpl implements _ConnectionRecord {
  const _$ConnectionRecordImpl(
      {required this.connectionId,
      required this.myDid,
      required this.theirDid,
      required this.state,
      required this.createdAt,
      this.label,
      this.goalCode,
      final Map<String, dynamic>? theirDidDoc})
      : _theirDidDoc = theirDidDoc;

  /// UUID de la conexión.
  @override
  final String connectionId;

  /// DID local generado para esta conexión (normalmente `did:peer:2`).
  @override
  final String myDid;

  /// DID del par remoto.
  @override
  final String theirDid;

  /// Estado actual del protocolo de conexión.
  @override
  final ConnectionState state;
  @override
  final DateTime createdAt;

  /// Nombre legible del par (del campo `label` de la invitación).
  @override
  final String? label;

  /// Código de objetivo de la invitación (p.ej. `issue-vc`).
  @override
  final String? goalCode;

  /// DID Document del par, almacenado al completar el handshake.
  final Map<String, dynamic>? _theirDidDoc;

  /// DID Document del par, almacenado al completar el handshake.
  @override
  Map<String, dynamic>? get theirDidDoc {
    final value = _theirDidDoc;
    if (value == null) return null;
    if (_theirDidDoc is EqualUnmodifiableMapView) return _theirDidDoc;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ConnectionRecord(connectionId: $connectionId, myDid: $myDid, theirDid: $theirDid, state: $state, createdAt: $createdAt, label: $label, goalCode: $goalCode, theirDidDoc: $theirDidDoc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionRecordImpl &&
            (identical(other.connectionId, connectionId) ||
                other.connectionId == connectionId) &&
            (identical(other.myDid, myDid) || other.myDid == myDid) &&
            (identical(other.theirDid, theirDid) ||
                other.theirDid == theirDid) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.goalCode, goalCode) ||
                other.goalCode == goalCode) &&
            const DeepCollectionEquality()
                .equals(other._theirDidDoc, _theirDidDoc));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      connectionId,
      myDid,
      theirDid,
      state,
      createdAt,
      label,
      goalCode,
      const DeepCollectionEquality().hash(_theirDidDoc));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionRecordImplCopyWith<_$ConnectionRecordImpl> get copyWith =>
      __$$ConnectionRecordImplCopyWithImpl<_$ConnectionRecordImpl>(
          this, _$identity);
}

abstract class _ConnectionRecord implements ConnectionRecord {
  const factory _ConnectionRecord(
      {required final String connectionId,
      required final String myDid,
      required final String theirDid,
      required final ConnectionState state,
      required final DateTime createdAt,
      final String? label,
      final String? goalCode,
      final Map<String, dynamic>? theirDidDoc}) = _$ConnectionRecordImpl;

  @override

  /// UUID de la conexión.
  String get connectionId;
  @override

  /// DID local generado para esta conexión (normalmente `did:peer:2`).
  String get myDid;
  @override

  /// DID del par remoto.
  String get theirDid;
  @override

  /// Estado actual del protocolo de conexión.
  ConnectionState get state;
  @override
  DateTime get createdAt;
  @override

  /// Nombre legible del par (del campo `label` de la invitación).
  String? get label;
  @override

  /// Código de objetivo de la invitación (p.ej. `issue-vc`).
  String? get goalCode;
  @override

  /// DID Document del par, almacenado al completar el handshake.
  Map<String, dynamic>? get theirDidDoc;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionRecordImplCopyWith<_$ConnectionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
