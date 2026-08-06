// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'didcomm_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DidCommMessage _$DidCommMessageFromJson(Map<String, dynamic> json) {
  return _DidCommMessage.fromJson(json);
}

/// @nodoc
mixin _$DidCommMessage {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get from => throw _privateConstructorUsedError;
  List<String>? get to => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_time')
  int? get createdTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_time')
  int? get expiresTime => throw _privateConstructorUsedError;
  Map<String, dynamic>? get body => throw _privateConstructorUsedError;
  @JsonKey(name: '~attach')
  List<Map<String, dynamic>>? get attachments =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DidCommMessageCopyWith<DidCommMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DidCommMessageCopyWith<$Res> {
  factory $DidCommMessageCopyWith(
          DidCommMessage value, $Res Function(DidCommMessage) then) =
      _$DidCommMessageCopyWithImpl<$Res, DidCommMessage>;
  @useResult
  $Res call(
      {String id,
      String type,
      String? from,
      List<String>? to,
      @JsonKey(name: 'created_time') int? createdTime,
      @JsonKey(name: 'expires_time') int? expiresTime,
      Map<String, dynamic>? body,
      @JsonKey(name: '~attach') List<Map<String, dynamic>>? attachments});
}

/// @nodoc
class _$DidCommMessageCopyWithImpl<$Res, $Val extends DidCommMessage>
    implements $DidCommMessageCopyWith<$Res> {
  _$DidCommMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? from = freezed,
    Object? to = freezed,
    Object? createdTime = freezed,
    Object? expiresTime = freezed,
    Object? body = freezed,
    Object? attachments = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdTime: freezed == createdTime
          ? _value.createdTime
          : createdTime // ignore: cast_nullable_to_non_nullable
              as int?,
      expiresTime: freezed == expiresTime
          ? _value.expiresTime
          : expiresTime // ignore: cast_nullable_to_non_nullable
              as int?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DidCommMessageImplCopyWith<$Res>
    implements $DidCommMessageCopyWith<$Res> {
  factory _$$DidCommMessageImplCopyWith(_$DidCommMessageImpl value,
          $Res Function(_$DidCommMessageImpl) then) =
      __$$DidCommMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String? from,
      List<String>? to,
      @JsonKey(name: 'created_time') int? createdTime,
      @JsonKey(name: 'expires_time') int? expiresTime,
      Map<String, dynamic>? body,
      @JsonKey(name: '~attach') List<Map<String, dynamic>>? attachments});
}

/// @nodoc
class __$$DidCommMessageImplCopyWithImpl<$Res>
    extends _$DidCommMessageCopyWithImpl<$Res, _$DidCommMessageImpl>
    implements _$$DidCommMessageImplCopyWith<$Res> {
  __$$DidCommMessageImplCopyWithImpl(
      _$DidCommMessageImpl _value, $Res Function(_$DidCommMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? from = freezed,
    Object? to = freezed,
    Object? createdTime = freezed,
    Object? expiresTime = freezed,
    Object? body = freezed,
    Object? attachments = freezed,
  }) {
    return _then(_$DidCommMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value._to
          : to // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdTime: freezed == createdTime
          ? _value.createdTime
          : createdTime // ignore: cast_nullable_to_non_nullable
              as int?,
      expiresTime: freezed == expiresTime
          ? _value.expiresTime
          : expiresTime // ignore: cast_nullable_to_non_nullable
              as int?,
      body: freezed == body
          ? _value._body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DidCommMessageImpl implements _DidCommMessage {
  const _$DidCommMessageImpl(
      {required this.id,
      required this.type,
      this.from,
      final List<String>? to,
      @JsonKey(name: 'created_time') this.createdTime,
      @JsonKey(name: 'expires_time') this.expiresTime,
      final Map<String, dynamic>? body,
      @JsonKey(name: '~attach') final List<Map<String, dynamic>>? attachments})
      : _to = to,
        _body = body,
        _attachments = attachments;

  factory _$DidCommMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DidCommMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String? from;
  final List<String>? _to;
  @override
  List<String>? get to {
    final value = _to;
    if (value == null) return null;
    if (_to is EqualUnmodifiableListView) return _to;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_time')
  final int? createdTime;
  @override
  @JsonKey(name: 'expires_time')
  final int? expiresTime;
  final Map<String, dynamic>? _body;
  @override
  Map<String, dynamic>? get body {
    final value = _body;
    if (value == null) return null;
    if (_body is EqualUnmodifiableMapView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Map<String, dynamic>>? _attachments;
  @override
  @JsonKey(name: '~attach')
  List<Map<String, dynamic>>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DidCommMessage(id: $id, type: $type, from: $from, to: $to, createdTime: $createdTime, expiresTime: $expiresTime, body: $body, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DidCommMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.from, from) || other.from == from) &&
            const DeepCollectionEquality().equals(other._to, _to) &&
            (identical(other.createdTime, createdTime) ||
                other.createdTime == createdTime) &&
            (identical(other.expiresTime, expiresTime) ||
                other.expiresTime == expiresTime) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      from,
      const DeepCollectionEquality().hash(_to),
      createdTime,
      expiresTime,
      const DeepCollectionEquality().hash(_body),
      const DeepCollectionEquality().hash(_attachments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DidCommMessageImplCopyWith<_$DidCommMessageImpl> get copyWith =>
      __$$DidCommMessageImplCopyWithImpl<_$DidCommMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DidCommMessageImplToJson(
      this,
    );
  }
}

abstract class _DidCommMessage implements DidCommMessage {
  const factory _DidCommMessage(
      {required final String id,
      required final String type,
      final String? from,
      final List<String>? to,
      @JsonKey(name: 'created_time') final int? createdTime,
      @JsonKey(name: 'expires_time') final int? expiresTime,
      final Map<String, dynamic>? body,
      @JsonKey(name: '~attach')
      final List<Map<String, dynamic>>? attachments}) = _$DidCommMessageImpl;

  factory _DidCommMessage.fromJson(Map<String, dynamic> json) =
      _$DidCommMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String? get from;
  @override
  List<String>? get to;
  @override
  @JsonKey(name: 'created_time')
  int? get createdTime;
  @override
  @JsonKey(name: 'expires_time')
  int? get expiresTime;
  @override
  Map<String, dynamic>? get body;
  @override
  @JsonKey(name: '~attach')
  List<Map<String, dynamic>>? get attachments;
  @override
  @JsonKey(ignore: true)
  _$$DidCommMessageImplCopyWith<_$DidCommMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
