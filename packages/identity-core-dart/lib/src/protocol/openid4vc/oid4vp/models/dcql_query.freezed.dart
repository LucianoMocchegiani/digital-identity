// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dcql_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DcqlQuery _$DcqlQueryFromJson(Map<String, dynamic> json) {
  return _DcqlQuery.fromJson(json);
}

/// @nodoc
mixin _$DcqlQuery {
  /// Lista de queries individuales de credencial.
  List<DcqlCredentialQuery> get credentials =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DcqlQueryCopyWith<DcqlQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DcqlQueryCopyWith<$Res> {
  factory $DcqlQueryCopyWith(DcqlQuery value, $Res Function(DcqlQuery) then) =
      _$DcqlQueryCopyWithImpl<$Res, DcqlQuery>;
  @useResult
  $Res call({List<DcqlCredentialQuery> credentials});
}

/// @nodoc
class _$DcqlQueryCopyWithImpl<$Res, $Val extends DcqlQuery>
    implements $DcqlQueryCopyWith<$Res> {
  _$DcqlQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
  }) {
    return _then(_value.copyWith(
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<DcqlCredentialQuery>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DcqlQueryImplCopyWith<$Res>
    implements $DcqlQueryCopyWith<$Res> {
  factory _$$DcqlQueryImplCopyWith(
          _$DcqlQueryImpl value, $Res Function(_$DcqlQueryImpl) then) =
      __$$DcqlQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DcqlCredentialQuery> credentials});
}

/// @nodoc
class __$$DcqlQueryImplCopyWithImpl<$Res>
    extends _$DcqlQueryCopyWithImpl<$Res, _$DcqlQueryImpl>
    implements _$$DcqlQueryImplCopyWith<$Res> {
  __$$DcqlQueryImplCopyWithImpl(
      _$DcqlQueryImpl _value, $Res Function(_$DcqlQueryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
  }) {
    return _then(_$DcqlQueryImpl(
      credentials: null == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<DcqlCredentialQuery>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DcqlQueryImpl implements _DcqlQuery {
  const _$DcqlQueryImpl({required final List<DcqlCredentialQuery> credentials})
      : _credentials = credentials;

  factory _$DcqlQueryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DcqlQueryImplFromJson(json);

  /// Lista de queries individuales de credencial.
  final List<DcqlCredentialQuery> _credentials;

  /// Lista de queries individuales de credencial.
  @override
  List<DcqlCredentialQuery> get credentials {
    if (_credentials is EqualUnmodifiableListView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_credentials);
  }

  @override
  String toString() {
    return 'DcqlQuery(credentials: $credentials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DcqlQueryImpl &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_credentials));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DcqlQueryImplCopyWith<_$DcqlQueryImpl> get copyWith =>
      __$$DcqlQueryImplCopyWithImpl<_$DcqlQueryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DcqlQueryImplToJson(
      this,
    );
  }
}

abstract class _DcqlQuery implements DcqlQuery {
  const factory _DcqlQuery(
      {required final List<DcqlCredentialQuery> credentials}) = _$DcqlQueryImpl;

  factory _DcqlQuery.fromJson(Map<String, dynamic> json) =
      _$DcqlQueryImpl.fromJson;

  @override

  /// Lista de queries individuales de credencial.
  List<DcqlCredentialQuery> get credentials;
  @override
  @JsonKey(ignore: true)
  _$$DcqlQueryImplCopyWith<_$DcqlQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DcqlCredentialQuery _$DcqlCredentialQueryFromJson(Map<String, dynamic> json) {
  return _DcqlCredentialQuery.fromJson(json);
}

/// @nodoc
mixin _$DcqlCredentialQuery {
  /// Identificador único de esta query (referenciado en la presentación).
  String get id => throw _privateConstructorUsedError;

  /// Formato de credencial requerido: `'dc+sd-jwt'`, `'mso_mdoc'`, etc.
  String get format => throw _privateConstructorUsedError;

  /// Metadatos de matching: `vct_values`, `doctype_value`, etc.
  Map<String, dynamic>? get meta => throw _privateConstructorUsedError;

  /// Claims requeridos para esta credencial.
  List<DcqlClaim>? get claims => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DcqlCredentialQueryCopyWith<DcqlCredentialQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DcqlCredentialQueryCopyWith<$Res> {
  factory $DcqlCredentialQueryCopyWith(
          DcqlCredentialQuery value, $Res Function(DcqlCredentialQuery) then) =
      _$DcqlCredentialQueryCopyWithImpl<$Res, DcqlCredentialQuery>;
  @useResult
  $Res call(
      {String id,
      String format,
      Map<String, dynamic>? meta,
      List<DcqlClaim>? claims});
}

/// @nodoc
class _$DcqlCredentialQueryCopyWithImpl<$Res, $Val extends DcqlCredentialQuery>
    implements $DcqlCredentialQueryCopyWith<$Res> {
  _$DcqlCredentialQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? format = null,
    Object? meta = freezed,
    Object? claims = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      meta: freezed == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      claims: freezed == claims
          ? _value.claims
          : claims // ignore: cast_nullable_to_non_nullable
              as List<DcqlClaim>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DcqlCredentialQueryImplCopyWith<$Res>
    implements $DcqlCredentialQueryCopyWith<$Res> {
  factory _$$DcqlCredentialQueryImplCopyWith(_$DcqlCredentialQueryImpl value,
          $Res Function(_$DcqlCredentialQueryImpl) then) =
      __$$DcqlCredentialQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String format,
      Map<String, dynamic>? meta,
      List<DcqlClaim>? claims});
}

/// @nodoc
class __$$DcqlCredentialQueryImplCopyWithImpl<$Res>
    extends _$DcqlCredentialQueryCopyWithImpl<$Res, _$DcqlCredentialQueryImpl>
    implements _$$DcqlCredentialQueryImplCopyWith<$Res> {
  __$$DcqlCredentialQueryImplCopyWithImpl(_$DcqlCredentialQueryImpl _value,
      $Res Function(_$DcqlCredentialQueryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? format = null,
    Object? meta = freezed,
    Object? claims = freezed,
  }) {
    return _then(_$DcqlCredentialQueryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      meta: freezed == meta
          ? _value._meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      claims: freezed == claims
          ? _value._claims
          : claims // ignore: cast_nullable_to_non_nullable
              as List<DcqlClaim>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DcqlCredentialQueryImpl implements _DcqlCredentialQuery {
  const _$DcqlCredentialQueryImpl(
      {required this.id,
      required this.format,
      final Map<String, dynamic>? meta,
      final List<DcqlClaim>? claims})
      : _meta = meta,
        _claims = claims;

  factory _$DcqlCredentialQueryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DcqlCredentialQueryImplFromJson(json);

  /// Identificador único de esta query (referenciado en la presentación).
  @override
  final String id;

  /// Formato de credencial requerido: `'dc+sd-jwt'`, `'mso_mdoc'`, etc.
  @override
  final String format;

  /// Metadatos de matching: `vct_values`, `doctype_value`, etc.
  final Map<String, dynamic>? _meta;

  /// Metadatos de matching: `vct_values`, `doctype_value`, etc.
  @override
  Map<String, dynamic>? get meta {
    final value = _meta;
    if (value == null) return null;
    if (_meta is EqualUnmodifiableMapView) return _meta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Claims requeridos para esta credencial.
  final List<DcqlClaim>? _claims;

  /// Claims requeridos para esta credencial.
  @override
  List<DcqlClaim>? get claims {
    final value = _claims;
    if (value == null) return null;
    if (_claims is EqualUnmodifiableListView) return _claims;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DcqlCredentialQuery(id: $id, format: $format, meta: $meta, claims: $claims)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DcqlCredentialQueryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.format, format) || other.format == format) &&
            const DeepCollectionEquality().equals(other._meta, _meta) &&
            const DeepCollectionEquality().equals(other._claims, _claims));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      format,
      const DeepCollectionEquality().hash(_meta),
      const DeepCollectionEquality().hash(_claims));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DcqlCredentialQueryImplCopyWith<_$DcqlCredentialQueryImpl> get copyWith =>
      __$$DcqlCredentialQueryImplCopyWithImpl<_$DcqlCredentialQueryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DcqlCredentialQueryImplToJson(
      this,
    );
  }
}

abstract class _DcqlCredentialQuery implements DcqlCredentialQuery {
  const factory _DcqlCredentialQuery(
      {required final String id,
      required final String format,
      final Map<String, dynamic>? meta,
      final List<DcqlClaim>? claims}) = _$DcqlCredentialQueryImpl;

  factory _DcqlCredentialQuery.fromJson(Map<String, dynamic> json) =
      _$DcqlCredentialQueryImpl.fromJson;

  @override

  /// Identificador único de esta query (referenciado en la presentación).
  String get id;
  @override

  /// Formato de credencial requerido: `'dc+sd-jwt'`, `'mso_mdoc'`, etc.
  String get format;
  @override

  /// Metadatos de matching: `vct_values`, `doctype_value`, etc.
  Map<String, dynamic>? get meta;
  @override

  /// Claims requeridos para esta credencial.
  List<DcqlClaim>? get claims;
  @override
  @JsonKey(ignore: true)
  _$$DcqlCredentialQueryImplCopyWith<_$DcqlCredentialQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DcqlClaim _$DcqlClaimFromJson(Map<String, dynamic> json) {
  return _DcqlClaim.fromJson(json);
}

/// @nodoc
mixin _$DcqlClaim {
  /// Ruta del claim. `null` en el último segmento indica contenedor de array (DCQL).
  @JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
  List<String?>? get path => throw _privateConstructorUsedError;

  /// Namespace para mDoc (reemplaza [path] en formato ISO 18013-5).
  String? get namespace => throw _privateConstructorUsedError;

  /// Nombre del claim en el namespace mDoc.
  @JsonKey(name: 'claim_name')
  String? get claimName => throw _privateConstructorUsedError;

  /// Si el claim es opcional o requerido.
  @JsonKey(defaultValue: false)
  bool? get optional => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DcqlClaimCopyWith<DcqlClaim> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DcqlClaimCopyWith<$Res> {
  factory $DcqlClaimCopyWith(DcqlClaim value, $Res Function(DcqlClaim) then) =
      _$DcqlClaimCopyWithImpl<$Res, DcqlClaim>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
      List<String?>? path,
      String? namespace,
      @JsonKey(name: 'claim_name') String? claimName,
      @JsonKey(defaultValue: false) bool? optional});
}

/// @nodoc
class _$DcqlClaimCopyWithImpl<$Res, $Val extends DcqlClaim>
    implements $DcqlClaimCopyWith<$Res> {
  _$DcqlClaimCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = freezed,
    Object? namespace = freezed,
    Object? claimName = freezed,
    Object? optional = freezed,
  }) {
    return _then(_value.copyWith(
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as List<String?>?,
      namespace: freezed == namespace
          ? _value.namespace
          : namespace // ignore: cast_nullable_to_non_nullable
              as String?,
      claimName: freezed == claimName
          ? _value.claimName
          : claimName // ignore: cast_nullable_to_non_nullable
              as String?,
      optional: freezed == optional
          ? _value.optional
          : optional // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DcqlClaimImplCopyWith<$Res>
    implements $DcqlClaimCopyWith<$Res> {
  factory _$$DcqlClaimImplCopyWith(
          _$DcqlClaimImpl value, $Res Function(_$DcqlClaimImpl) then) =
      __$$DcqlClaimImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
      List<String?>? path,
      String? namespace,
      @JsonKey(name: 'claim_name') String? claimName,
      @JsonKey(defaultValue: false) bool? optional});
}

/// @nodoc
class __$$DcqlClaimImplCopyWithImpl<$Res>
    extends _$DcqlClaimCopyWithImpl<$Res, _$DcqlClaimImpl>
    implements _$$DcqlClaimImplCopyWith<$Res> {
  __$$DcqlClaimImplCopyWithImpl(
      _$DcqlClaimImpl _value, $Res Function(_$DcqlClaimImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = freezed,
    Object? namespace = freezed,
    Object? claimName = freezed,
    Object? optional = freezed,
  }) {
    return _then(_$DcqlClaimImpl(
      path: freezed == path
          ? _value._path
          : path // ignore: cast_nullable_to_non_nullable
              as List<String?>?,
      namespace: freezed == namespace
          ? _value.namespace
          : namespace // ignore: cast_nullable_to_non_nullable
              as String?,
      claimName: freezed == claimName
          ? _value.claimName
          : claimName // ignore: cast_nullable_to_non_nullable
              as String?,
      optional: freezed == optional
          ? _value.optional
          : optional // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DcqlClaimImpl implements _DcqlClaim {
  const _$DcqlClaimImpl(
      {@JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
      final List<String?>? path,
      this.namespace,
      @JsonKey(name: 'claim_name') this.claimName,
      @JsonKey(defaultValue: false) this.optional})
      : _path = path;

  factory _$DcqlClaimImpl.fromJson(Map<String, dynamic> json) =>
      _$$DcqlClaimImplFromJson(json);

  /// Ruta del claim. `null` en el último segmento indica contenedor de array (DCQL).
  final List<String?>? _path;

  /// Ruta del claim. `null` en el último segmento indica contenedor de array (DCQL).
  @override
  @JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
  List<String?>? get path {
    final value = _path;
    if (value == null) return null;
    if (_path is EqualUnmodifiableListView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Namespace para mDoc (reemplaza [path] en formato ISO 18013-5).
  @override
  final String? namespace;

  /// Nombre del claim en el namespace mDoc.
  @override
  @JsonKey(name: 'claim_name')
  final String? claimName;

  /// Si el claim es opcional o requerido.
  @override
  @JsonKey(defaultValue: false)
  final bool? optional;

  @override
  String toString() {
    return 'DcqlClaim(path: $path, namespace: $namespace, claimName: $claimName, optional: $optional)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DcqlClaimImpl &&
            const DeepCollectionEquality().equals(other._path, _path) &&
            (identical(other.namespace, namespace) ||
                other.namespace == namespace) &&
            (identical(other.claimName, claimName) ||
                other.claimName == claimName) &&
            (identical(other.optional, optional) ||
                other.optional == optional));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_path),
      namespace,
      claimName,
      optional);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DcqlClaimImplCopyWith<_$DcqlClaimImpl> get copyWith =>
      __$$DcqlClaimImplCopyWithImpl<_$DcqlClaimImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DcqlClaimImplToJson(
      this,
    );
  }
}

abstract class _DcqlClaim implements DcqlClaim {
  const factory _DcqlClaim(
      {@JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
      final List<String?>? path,
      final String? namespace,
      @JsonKey(name: 'claim_name') final String? claimName,
      @JsonKey(defaultValue: false) final bool? optional}) = _$DcqlClaimImpl;

  factory _DcqlClaim.fromJson(Map<String, dynamic> json) =
      _$DcqlClaimImpl.fromJson;

  @override

  /// Ruta del claim. `null` en el último segmento indica contenedor de array (DCQL).
  @JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
  List<String?>? get path;
  @override

  /// Namespace para mDoc (reemplaza [path] en formato ISO 18013-5).
  String? get namespace;
  @override

  /// Nombre del claim en el namespace mDoc.
  @JsonKey(name: 'claim_name')
  String? get claimName;
  @override

  /// Si el claim es opcional o requerido.
  @JsonKey(defaultValue: false)
  bool? get optional;
  @override
  @JsonKey(ignore: true)
  _$$DcqlClaimImplCopyWith<_$DcqlClaimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
