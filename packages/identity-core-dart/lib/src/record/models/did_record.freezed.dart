// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'did_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DidRecord {
  /// El DID completo (ej. `'did:key:z6Mk...'`).
  String get did => throw _privateConstructorUsedError;

  /// Método DID (`'key'`, `'jwk'`, `'peer'`, `'web'`).
  String get method => throw _privateConstructorUsedError;

  /// DID Document completo en formato JSON.
  Map<String, dynamic> get document => throw _privateConstructorUsedError;

  /// IDs de las claves asociadas en [KeyRecordStore].
  List<String> get keyIds => throw _privateConstructorUsedError;

  /// Fecha de creación del DID.
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DidRecordCopyWith<DidRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DidRecordCopyWith<$Res> {
  factory $DidRecordCopyWith(DidRecord value, $Res Function(DidRecord) then) =
      _$DidRecordCopyWithImpl<$Res, DidRecord>;
  @useResult
  $Res call(
      {String did,
      String method,
      Map<String, dynamic> document,
      List<String> keyIds,
      DateTime createdAt});
}

/// @nodoc
class _$DidRecordCopyWithImpl<$Res, $Val extends DidRecord>
    implements $DidRecordCopyWith<$Res> {
  _$DidRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? method = null,
    Object? document = null,
    Object? keyIds = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      document: null == document
          ? _value.document
          : document // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keyIds: null == keyIds
          ? _value.keyIds
          : keyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DidRecordImplCopyWith<$Res>
    implements $DidRecordCopyWith<$Res> {
  factory _$$DidRecordImplCopyWith(
          _$DidRecordImpl value, $Res Function(_$DidRecordImpl) then) =
      __$$DidRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String did,
      String method,
      Map<String, dynamic> document,
      List<String> keyIds,
      DateTime createdAt});
}

/// @nodoc
class __$$DidRecordImplCopyWithImpl<$Res>
    extends _$DidRecordCopyWithImpl<$Res, _$DidRecordImpl>
    implements _$$DidRecordImplCopyWith<$Res> {
  __$$DidRecordImplCopyWithImpl(
      _$DidRecordImpl _value, $Res Function(_$DidRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? method = null,
    Object? document = null,
    Object? keyIds = null,
    Object? createdAt = null,
  }) {
    return _then(_$DidRecordImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      document: null == document
          ? _value._document
          : document // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keyIds: null == keyIds
          ? _value._keyIds
          : keyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$DidRecordImpl implements _DidRecord {
  const _$DidRecordImpl(
      {required this.did,
      required this.method,
      required final Map<String, dynamic> document,
      required final List<String> keyIds,
      required this.createdAt})
      : _document = document,
        _keyIds = keyIds;

  /// El DID completo (ej. `'did:key:z6Mk...'`).
  @override
  final String did;

  /// Método DID (`'key'`, `'jwk'`, `'peer'`, `'web'`).
  @override
  final String method;

  /// DID Document completo en formato JSON.
  final Map<String, dynamic> _document;

  /// DID Document completo en formato JSON.
  @override
  Map<String, dynamic> get document {
    if (_document is EqualUnmodifiableMapView) return _document;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_document);
  }

  /// IDs de las claves asociadas en [KeyRecordStore].
  final List<String> _keyIds;

  /// IDs de las claves asociadas en [KeyRecordStore].
  @override
  List<String> get keyIds {
    if (_keyIds is EqualUnmodifiableListView) return _keyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyIds);
  }

  /// Fecha de creación del DID.
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DidRecord(did: $did, method: $method, document: $document, keyIds: $keyIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DidRecordImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._document, _document) &&
            const DeepCollectionEquality().equals(other._keyIds, _keyIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      did,
      method,
      const DeepCollectionEquality().hash(_document),
      const DeepCollectionEquality().hash(_keyIds),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DidRecordImplCopyWith<_$DidRecordImpl> get copyWith =>
      __$$DidRecordImplCopyWithImpl<_$DidRecordImpl>(this, _$identity);
}

abstract class _DidRecord implements DidRecord {
  const factory _DidRecord(
      {required final String did,
      required final String method,
      required final Map<String, dynamic> document,
      required final List<String> keyIds,
      required final DateTime createdAt}) = _$DidRecordImpl;

  @override

  /// El DID completo (ej. `'did:key:z6Mk...'`).
  String get did;
  @override

  /// Método DID (`'key'`, `'jwk'`, `'peer'`, `'web'`).
  String get method;
  @override

  /// DID Document completo en formato JSON.
  Map<String, dynamic> get document;
  @override

  /// IDs de las claves asociadas en [KeyRecordStore].
  List<String> get keyIds;
  @override

  /// Fecha de creación del DID.
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$DidRecordImplCopyWith<_$DidRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
