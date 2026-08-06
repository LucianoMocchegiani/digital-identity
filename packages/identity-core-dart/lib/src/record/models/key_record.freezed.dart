// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$KeyRecord {
  /// Identificador único de la clave (UUID v4).
  String get keyId => throw _privateConstructorUsedError;

  /// Tipo de curva criptográfica.
  KeyType get keyType => throw _privateConstructorUsedError;

  /// JWK público (sin campo `d`), seguro para compartir.
  Map<String, dynamic> get publicJwk => throw _privateConstructorUsedError;

  /// JWK privado completo (incluye campo `d`).
  ///
  /// `null` para claves hardware-backed, donde la clave privada reside
  /// en el chip y nunca puede ser exportada.
  Map<String, dynamic>? get privateJwk => throw _privateConstructorUsedError;

  /// Indica si la clave privada está protegida por hardware (SE/TEE).
  ///
  /// Cuando es `true`, las operaciones de firma se realizan via platform channel
  /// hacia [HardwareKmsService] (Fase 8).
  bool get isHardwareBacked => throw _privateConstructorUsedError;

  /// Fecha de generación de la clave.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// DID asociado a esta clave, si fue creado como parte de una identidad.
  String? get did => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $KeyRecordCopyWith<KeyRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyRecordCopyWith<$Res> {
  factory $KeyRecordCopyWith(KeyRecord value, $Res Function(KeyRecord) then) =
      _$KeyRecordCopyWithImpl<$Res, KeyRecord>;
  @useResult
  $Res call(
      {String keyId,
      KeyType keyType,
      Map<String, dynamic> publicJwk,
      Map<String, dynamic>? privateJwk,
      bool isHardwareBacked,
      DateTime createdAt,
      String? did});
}

/// @nodoc
class _$KeyRecordCopyWithImpl<$Res, $Val extends KeyRecord>
    implements $KeyRecordCopyWith<$Res> {
  _$KeyRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyId = null,
    Object? keyType = null,
    Object? publicJwk = null,
    Object? privateJwk = freezed,
    Object? isHardwareBacked = null,
    Object? createdAt = null,
    Object? did = freezed,
  }) {
    return _then(_value.copyWith(
      keyId: null == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String,
      keyType: null == keyType
          ? _value.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as KeyType,
      publicJwk: null == publicJwk
          ? _value.publicJwk
          : publicJwk // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      privateJwk: freezed == privateJwk
          ? _value.privateJwk
          : privateJwk // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isHardwareBacked: null == isHardwareBacked
          ? _value.isHardwareBacked
          : isHardwareBacked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyRecordImplCopyWith<$Res>
    implements $KeyRecordCopyWith<$Res> {
  factory _$$KeyRecordImplCopyWith(
          _$KeyRecordImpl value, $Res Function(_$KeyRecordImpl) then) =
      __$$KeyRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String keyId,
      KeyType keyType,
      Map<String, dynamic> publicJwk,
      Map<String, dynamic>? privateJwk,
      bool isHardwareBacked,
      DateTime createdAt,
      String? did});
}

/// @nodoc
class __$$KeyRecordImplCopyWithImpl<$Res>
    extends _$KeyRecordCopyWithImpl<$Res, _$KeyRecordImpl>
    implements _$$KeyRecordImplCopyWith<$Res> {
  __$$KeyRecordImplCopyWithImpl(
      _$KeyRecordImpl _value, $Res Function(_$KeyRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyId = null,
    Object? keyType = null,
    Object? publicJwk = null,
    Object? privateJwk = freezed,
    Object? isHardwareBacked = null,
    Object? createdAt = null,
    Object? did = freezed,
  }) {
    return _then(_$KeyRecordImpl(
      keyId: null == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String,
      keyType: null == keyType
          ? _value.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as KeyType,
      publicJwk: null == publicJwk
          ? _value._publicJwk
          : publicJwk // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      privateJwk: freezed == privateJwk
          ? _value._privateJwk
          : privateJwk // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isHardwareBacked: null == isHardwareBacked
          ? _value.isHardwareBacked
          : isHardwareBacked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$KeyRecordImpl implements _KeyRecord {
  const _$KeyRecordImpl(
      {required this.keyId,
      required this.keyType,
      required final Map<String, dynamic> publicJwk,
      final Map<String, dynamic>? privateJwk,
      required this.isHardwareBacked,
      required this.createdAt,
      this.did})
      : _publicJwk = publicJwk,
        _privateJwk = privateJwk;

  /// Identificador único de la clave (UUID v4).
  @override
  final String keyId;

  /// Tipo de curva criptográfica.
  @override
  final KeyType keyType;

  /// JWK público (sin campo `d`), seguro para compartir.
  final Map<String, dynamic> _publicJwk;

  /// JWK público (sin campo `d`), seguro para compartir.
  @override
  Map<String, dynamic> get publicJwk {
    if (_publicJwk is EqualUnmodifiableMapView) return _publicJwk;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_publicJwk);
  }

  /// JWK privado completo (incluye campo `d`).
  ///
  /// `null` para claves hardware-backed, donde la clave privada reside
  /// en el chip y nunca puede ser exportada.
  final Map<String, dynamic>? _privateJwk;

  /// JWK privado completo (incluye campo `d`).
  ///
  /// `null` para claves hardware-backed, donde la clave privada reside
  /// en el chip y nunca puede ser exportada.
  @override
  Map<String, dynamic>? get privateJwk {
    final value = _privateJwk;
    if (value == null) return null;
    if (_privateJwk is EqualUnmodifiableMapView) return _privateJwk;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Indica si la clave privada está protegida por hardware (SE/TEE).
  ///
  /// Cuando es `true`, las operaciones de firma se realizan via platform channel
  /// hacia [HardwareKmsService] (Fase 8).
  @override
  final bool isHardwareBacked;

  /// Fecha de generación de la clave.
  @override
  final DateTime createdAt;

  /// DID asociado a esta clave, si fue creado como parte de una identidad.
  @override
  final String? did;

  @override
  String toString() {
    return 'KeyRecord(keyId: $keyId, keyType: $keyType, publicJwk: $publicJwk, privateJwk: $privateJwk, isHardwareBacked: $isHardwareBacked, createdAt: $createdAt, did: $did)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyRecordImpl &&
            (identical(other.keyId, keyId) || other.keyId == keyId) &&
            (identical(other.keyType, keyType) || other.keyType == keyType) &&
            const DeepCollectionEquality()
                .equals(other._publicJwk, _publicJwk) &&
            const DeepCollectionEquality()
                .equals(other._privateJwk, _privateJwk) &&
            (identical(other.isHardwareBacked, isHardwareBacked) ||
                other.isHardwareBacked == isHardwareBacked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.did, did) || other.did == did));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      keyId,
      keyType,
      const DeepCollectionEquality().hash(_publicJwk),
      const DeepCollectionEquality().hash(_privateJwk),
      isHardwareBacked,
      createdAt,
      did);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyRecordImplCopyWith<_$KeyRecordImpl> get copyWith =>
      __$$KeyRecordImplCopyWithImpl<_$KeyRecordImpl>(this, _$identity);
}

abstract class _KeyRecord implements KeyRecord {
  const factory _KeyRecord(
      {required final String keyId,
      required final KeyType keyType,
      required final Map<String, dynamic> publicJwk,
      final Map<String, dynamic>? privateJwk,
      required final bool isHardwareBacked,
      required final DateTime createdAt,
      final String? did}) = _$KeyRecordImpl;

  @override

  /// Identificador único de la clave (UUID v4).
  String get keyId;
  @override

  /// Tipo de curva criptográfica.
  KeyType get keyType;
  @override

  /// JWK público (sin campo `d`), seguro para compartir.
  Map<String, dynamic> get publicJwk;
  @override

  /// JWK privado completo (incluye campo `d`).
  ///
  /// `null` para claves hardware-backed, donde la clave privada reside
  /// en el chip y nunca puede ser exportada.
  Map<String, dynamic>? get privateJwk;
  @override

  /// Indica si la clave privada está protegida por hardware (SE/TEE).
  ///
  /// Cuando es `true`, las operaciones de firma se realizan via platform channel
  /// hacia [HardwareKmsService] (Fase 8).
  bool get isHardwareBacked;
  @override

  /// Fecha de generación de la clave.
  DateTime get createdAt;
  @override

  /// DID asociado a esta clave, si fue creado como parte de una identidad.
  String? get did;
  @override
  @JsonKey(ignore: true)
  _$$KeyRecordImplCopyWith<_$KeyRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
