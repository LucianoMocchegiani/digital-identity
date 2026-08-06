// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_for_display.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CredentialForDisplay {
  /// Identificador único, coincide con [CredentialRecord.id].
  String get id => throw _privateConstructorUsedError;

  /// Fecha de almacenamiento.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Formato subyacente de la credencial.
  ClaimFormat get claimFormat => throw _privateConstructorUsedError;

  /// Información de visualización (nombre, colores, logo).
  CredentialDisplay get display => throw _privateConstructorUsedError;

  /// Atributos formateados y listos para renderizar en UI.
  List<FormattedAttribute> get attributes => throw _privateConstructorUsedError;

  /// Claims crudos (sin formatear) para operaciones programáticas.
  Map<String, dynamic> get rawAttributes => throw _privateConstructorUsedError;

  /// Record original necesario para firmar y presentar la credencial.
  CredentialRecord get record => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CredentialForDisplayCopyWith<CredentialForDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialForDisplayCopyWith<$Res> {
  factory $CredentialForDisplayCopyWith(CredentialForDisplay value,
          $Res Function(CredentialForDisplay) then) =
      _$CredentialForDisplayCopyWithImpl<$Res, CredentialForDisplay>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      ClaimFormat claimFormat,
      CredentialDisplay display,
      List<FormattedAttribute> attributes,
      Map<String, dynamic> rawAttributes,
      CredentialRecord record});

  $CredentialDisplayCopyWith<$Res> get display;
}

/// @nodoc
class _$CredentialForDisplayCopyWithImpl<$Res,
        $Val extends CredentialForDisplay>
    implements $CredentialForDisplayCopyWith<$Res> {
  _$CredentialForDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? claimFormat = null,
    Object? display = null,
    Object? attributes = null,
    Object? rawAttributes = null,
    Object? record = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimFormat: null == claimFormat
          ? _value.claimFormat
          : claimFormat // ignore: cast_nullable_to_non_nullable
              as ClaimFormat,
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as CredentialDisplay,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<FormattedAttribute>,
      rawAttributes: null == rawAttributes
          ? _value.rawAttributes
          : rawAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as CredentialRecord,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CredentialDisplayCopyWith<$Res> get display {
    return $CredentialDisplayCopyWith<$Res>(_value.display, (value) {
      return _then(_value.copyWith(display: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialForDisplayImplCopyWith<$Res>
    implements $CredentialForDisplayCopyWith<$Res> {
  factory _$$CredentialForDisplayImplCopyWith(_$CredentialForDisplayImpl value,
          $Res Function(_$CredentialForDisplayImpl) then) =
      __$$CredentialForDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      ClaimFormat claimFormat,
      CredentialDisplay display,
      List<FormattedAttribute> attributes,
      Map<String, dynamic> rawAttributes,
      CredentialRecord record});

  @override
  $CredentialDisplayCopyWith<$Res> get display;
}

/// @nodoc
class __$$CredentialForDisplayImplCopyWithImpl<$Res>
    extends _$CredentialForDisplayCopyWithImpl<$Res, _$CredentialForDisplayImpl>
    implements _$$CredentialForDisplayImplCopyWith<$Res> {
  __$$CredentialForDisplayImplCopyWithImpl(_$CredentialForDisplayImpl _value,
      $Res Function(_$CredentialForDisplayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? claimFormat = null,
    Object? display = null,
    Object? attributes = null,
    Object? rawAttributes = null,
    Object? record = null,
  }) {
    return _then(_$CredentialForDisplayImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimFormat: null == claimFormat
          ? _value.claimFormat
          : claimFormat // ignore: cast_nullable_to_non_nullable
              as ClaimFormat,
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as CredentialDisplay,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<FormattedAttribute>,
      rawAttributes: null == rawAttributes
          ? _value._rawAttributes
          : rawAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as CredentialRecord,
    ));
  }
}

/// @nodoc

class _$CredentialForDisplayImpl implements _CredentialForDisplay {
  const _$CredentialForDisplayImpl(
      {required this.id,
      required this.createdAt,
      required this.claimFormat,
      required this.display,
      required final List<FormattedAttribute> attributes,
      required final Map<String, dynamic> rawAttributes,
      required this.record})
      : _attributes = attributes,
        _rawAttributes = rawAttributes;

  /// Identificador único, coincide con [CredentialRecord.id].
  @override
  final String id;

  /// Fecha de almacenamiento.
  @override
  final DateTime createdAt;

  /// Formato subyacente de la credencial.
  @override
  final ClaimFormat claimFormat;

  /// Información de visualización (nombre, colores, logo).
  @override
  final CredentialDisplay display;

  /// Atributos formateados y listos para renderizar en UI.
  final List<FormattedAttribute> _attributes;

  /// Atributos formateados y listos para renderizar en UI.
  @override
  List<FormattedAttribute> get attributes {
    if (_attributes is EqualUnmodifiableListView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attributes);
  }

  /// Claims crudos (sin formatear) para operaciones programáticas.
  final Map<String, dynamic> _rawAttributes;

  /// Claims crudos (sin formatear) para operaciones programáticas.
  @override
  Map<String, dynamic> get rawAttributes {
    if (_rawAttributes is EqualUnmodifiableMapView) return _rawAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawAttributes);
  }

  /// Record original necesario para firmar y presentar la credencial.
  @override
  final CredentialRecord record;

  @override
  String toString() {
    return 'CredentialForDisplay(id: $id, createdAt: $createdAt, claimFormat: $claimFormat, display: $display, attributes: $attributes, rawAttributes: $rawAttributes, record: $record)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialForDisplayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.claimFormat, claimFormat) ||
                other.claimFormat == claimFormat) &&
            (identical(other.display, display) || other.display == display) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            const DeepCollectionEquality()
                .equals(other._rawAttributes, _rawAttributes) &&
            (identical(other.record, record) || other.record == record));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      claimFormat,
      display,
      const DeepCollectionEquality().hash(_attributes),
      const DeepCollectionEquality().hash(_rawAttributes),
      record);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialForDisplayImplCopyWith<_$CredentialForDisplayImpl>
      get copyWith =>
          __$$CredentialForDisplayImplCopyWithImpl<_$CredentialForDisplayImpl>(
              this, _$identity);
}

abstract class _CredentialForDisplay implements CredentialForDisplay {
  const factory _CredentialForDisplay(
      {required final String id,
      required final DateTime createdAt,
      required final ClaimFormat claimFormat,
      required final CredentialDisplay display,
      required final List<FormattedAttribute> attributes,
      required final Map<String, dynamic> rawAttributes,
      required final CredentialRecord record}) = _$CredentialForDisplayImpl;

  @override

  /// Identificador único, coincide con [CredentialRecord.id].
  String get id;
  @override

  /// Fecha de almacenamiento.
  DateTime get createdAt;
  @override

  /// Formato subyacente de la credencial.
  ClaimFormat get claimFormat;
  @override

  /// Información de visualización (nombre, colores, logo).
  CredentialDisplay get display;
  @override

  /// Atributos formateados y listos para renderizar en UI.
  List<FormattedAttribute> get attributes;
  @override

  /// Claims crudos (sin formatear) para operaciones programáticas.
  Map<String, dynamic> get rawAttributes;
  @override

  /// Record original necesario para firmar y presentar la credencial.
  CredentialRecord get record;
  @override
  @JsonKey(ignore: true)
  _$$CredentialForDisplayImplCopyWith<_$CredentialForDisplayImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CredentialDisplay {
  /// Nombre descriptivo de la credencial (ej. `'Documento de identidad'`).
  String? get name => throw _privateConstructorUsedError;

  /// Descripción breve del propósito de la credencial.
  String? get description => throw _privateConstructorUsedError;

  /// Color del texto en formato hex (ej. `'#FFFFFF'`).
  String? get textColor => throw _privateConstructorUsedError;

  /// Color de fondo en formato hex (ej. `'#003399'`).
  String? get backgroundColor => throw _privateConstructorUsedError;

  /// URL de la imagen de fondo de la tarjeta.
  String? get backgroundImageUrl => throw _privateConstructorUsedError;

  /// Información de visualización del issuer.
  IssuerDisplay get issuer => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CredentialDisplayCopyWith<CredentialDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialDisplayCopyWith<$Res> {
  factory $CredentialDisplayCopyWith(
          CredentialDisplay value, $Res Function(CredentialDisplay) then) =
      _$CredentialDisplayCopyWithImpl<$Res, CredentialDisplay>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      String? textColor,
      String? backgroundColor,
      String? backgroundImageUrl,
      IssuerDisplay issuer});

  $IssuerDisplayCopyWith<$Res> get issuer;
}

/// @nodoc
class _$CredentialDisplayCopyWithImpl<$Res, $Val extends CredentialDisplay>
    implements $CredentialDisplayCopyWith<$Res> {
  _$CredentialDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? textColor = freezed,
    Object? backgroundColor = freezed,
    Object? backgroundImageUrl = freezed,
    Object? issuer = null,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundImageUrl: freezed == backgroundImageUrl
          ? _value.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as IssuerDisplay,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IssuerDisplayCopyWith<$Res> get issuer {
    return $IssuerDisplayCopyWith<$Res>(_value.issuer, (value) {
      return _then(_value.copyWith(issuer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialDisplayImplCopyWith<$Res>
    implements $CredentialDisplayCopyWith<$Res> {
  factory _$$CredentialDisplayImplCopyWith(_$CredentialDisplayImpl value,
          $Res Function(_$CredentialDisplayImpl) then) =
      __$$CredentialDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      String? textColor,
      String? backgroundColor,
      String? backgroundImageUrl,
      IssuerDisplay issuer});

  @override
  $IssuerDisplayCopyWith<$Res> get issuer;
}

/// @nodoc
class __$$CredentialDisplayImplCopyWithImpl<$Res>
    extends _$CredentialDisplayCopyWithImpl<$Res, _$CredentialDisplayImpl>
    implements _$$CredentialDisplayImplCopyWith<$Res> {
  __$$CredentialDisplayImplCopyWithImpl(_$CredentialDisplayImpl _value,
      $Res Function(_$CredentialDisplayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? textColor = freezed,
    Object? backgroundColor = freezed,
    Object? backgroundImageUrl = freezed,
    Object? issuer = null,
  }) {
    return _then(_$CredentialDisplayImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundImageUrl: freezed == backgroundImageUrl
          ? _value.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as IssuerDisplay,
    ));
  }
}

/// @nodoc

class _$CredentialDisplayImpl implements _CredentialDisplay {
  const _$CredentialDisplayImpl(
      {this.name,
      this.description,
      this.textColor,
      this.backgroundColor,
      this.backgroundImageUrl,
      required this.issuer});

  /// Nombre descriptivo de la credencial (ej. `'Documento de identidad'`).
  @override
  final String? name;

  /// Descripción breve del propósito de la credencial.
  @override
  final String? description;

  /// Color del texto en formato hex (ej. `'#FFFFFF'`).
  @override
  final String? textColor;

  /// Color de fondo en formato hex (ej. `'#003399'`).
  @override
  final String? backgroundColor;

  /// URL de la imagen de fondo de la tarjeta.
  @override
  final String? backgroundImageUrl;

  /// Información de visualización del issuer.
  @override
  final IssuerDisplay issuer;

  @override
  String toString() {
    return 'CredentialDisplay(name: $name, description: $description, textColor: $textColor, backgroundColor: $backgroundColor, backgroundImageUrl: $backgroundImageUrl, issuer: $issuer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialDisplayImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.issuer, issuer) || other.issuer == issuer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, description, textColor,
      backgroundColor, backgroundImageUrl, issuer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialDisplayImplCopyWith<_$CredentialDisplayImpl> get copyWith =>
      __$$CredentialDisplayImplCopyWithImpl<_$CredentialDisplayImpl>(
          this, _$identity);
}

abstract class _CredentialDisplay implements CredentialDisplay {
  const factory _CredentialDisplay(
      {final String? name,
      final String? description,
      final String? textColor,
      final String? backgroundColor,
      final String? backgroundImageUrl,
      required final IssuerDisplay issuer}) = _$CredentialDisplayImpl;

  @override

  /// Nombre descriptivo de la credencial (ej. `'Documento de identidad'`).
  String? get name;
  @override

  /// Descripción breve del propósito de la credencial.
  String? get description;
  @override

  /// Color del texto en formato hex (ej. `'#FFFFFF'`).
  String? get textColor;
  @override

  /// Color de fondo en formato hex (ej. `'#003399'`).
  String? get backgroundColor;
  @override

  /// URL de la imagen de fondo de la tarjeta.
  String? get backgroundImageUrl;
  @override

  /// Información de visualización del issuer.
  IssuerDisplay get issuer;
  @override
  @JsonKey(ignore: true)
  _$$CredentialDisplayImplCopyWith<_$CredentialDisplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IssuerDisplay {
  /// Nombre del issuer (ej. `'Ministerio del Interior'`).
  String? get name => throw _privateConstructorUsedError;

  /// Dominio del issuer (ej. `'interior.gob.es'`).
  String? get domain => throw _privateConstructorUsedError;

  /// URL del logo del issuer.
  String? get logoUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IssuerDisplayCopyWith<IssuerDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssuerDisplayCopyWith<$Res> {
  factory $IssuerDisplayCopyWith(
          IssuerDisplay value, $Res Function(IssuerDisplay) then) =
      _$IssuerDisplayCopyWithImpl<$Res, IssuerDisplay>;
  @useResult
  $Res call({String? name, String? domain, String? logoUrl});
}

/// @nodoc
class _$IssuerDisplayCopyWithImpl<$Res, $Val extends IssuerDisplay>
    implements $IssuerDisplayCopyWith<$Res> {
  _$IssuerDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? domain = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssuerDisplayImplCopyWith<$Res>
    implements $IssuerDisplayCopyWith<$Res> {
  factory _$$IssuerDisplayImplCopyWith(
          _$IssuerDisplayImpl value, $Res Function(_$IssuerDisplayImpl) then) =
      __$$IssuerDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? domain, String? logoUrl});
}

/// @nodoc
class __$$IssuerDisplayImplCopyWithImpl<$Res>
    extends _$IssuerDisplayCopyWithImpl<$Res, _$IssuerDisplayImpl>
    implements _$$IssuerDisplayImplCopyWith<$Res> {
  __$$IssuerDisplayImplCopyWithImpl(
      _$IssuerDisplayImpl _value, $Res Function(_$IssuerDisplayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? domain = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(_$IssuerDisplayImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$IssuerDisplayImpl implements _IssuerDisplay {
  const _$IssuerDisplayImpl({this.name, this.domain, this.logoUrl});

  /// Nombre del issuer (ej. `'Ministerio del Interior'`).
  @override
  final String? name;

  /// Dominio del issuer (ej. `'interior.gob.es'`).
  @override
  final String? domain;

  /// URL del logo del issuer.
  @override
  final String? logoUrl;

  @override
  String toString() {
    return 'IssuerDisplay(name: $name, domain: $domain, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssuerDisplayImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, domain, logoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IssuerDisplayImplCopyWith<_$IssuerDisplayImpl> get copyWith =>
      __$$IssuerDisplayImplCopyWithImpl<_$IssuerDisplayImpl>(this, _$identity);
}

abstract class _IssuerDisplay implements IssuerDisplay {
  const factory _IssuerDisplay(
      {final String? name,
      final String? domain,
      final String? logoUrl}) = _$IssuerDisplayImpl;

  @override

  /// Nombre del issuer (ej. `'Ministerio del Interior'`).
  String? get name;
  @override

  /// Dominio del issuer (ej. `'interior.gob.es'`).
  String? get domain;
  @override

  /// URL del logo del issuer.
  String? get logoUrl;
  @override
  @JsonKey(ignore: true)
  _$$IssuerDisplayImplCopyWith<_$IssuerDisplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
