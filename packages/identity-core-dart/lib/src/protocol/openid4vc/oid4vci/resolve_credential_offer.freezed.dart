// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolve_credential_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ResolvedCredentialOffer {
  CredentialOffer get offer => throw _privateConstructorUsedError;
  IssuerMetadata get issuerMetadata => throw _privateConstructorUsedError;
  Oid4VciFlow get flow => throw _privateConstructorUsedError;

  /// Metadatos de display crudos de las credenciales ofrecidas.
  List<Map<String, dynamic>>? get credentialDisplay =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ResolvedCredentialOfferCopyWith<ResolvedCredentialOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResolvedCredentialOfferCopyWith<$Res> {
  factory $ResolvedCredentialOfferCopyWith(ResolvedCredentialOffer value,
          $Res Function(ResolvedCredentialOffer) then) =
      _$ResolvedCredentialOfferCopyWithImpl<$Res, ResolvedCredentialOffer>;
  @useResult
  $Res call(
      {CredentialOffer offer,
      IssuerMetadata issuerMetadata,
      Oid4VciFlow flow,
      List<Map<String, dynamic>>? credentialDisplay});

  $CredentialOfferCopyWith<$Res> get offer;
  $IssuerMetadataCopyWith<$Res> get issuerMetadata;
}

/// @nodoc
class _$ResolvedCredentialOfferCopyWithImpl<$Res,
        $Val extends ResolvedCredentialOffer>
    implements $ResolvedCredentialOfferCopyWith<$Res> {
  _$ResolvedCredentialOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offer = null,
    Object? issuerMetadata = null,
    Object? flow = null,
    Object? credentialDisplay = freezed,
  }) {
    return _then(_value.copyWith(
      offer: null == offer
          ? _value.offer
          : offer // ignore: cast_nullable_to_non_nullable
              as CredentialOffer,
      issuerMetadata: null == issuerMetadata
          ? _value.issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as IssuerMetadata,
      flow: null == flow
          ? _value.flow
          : flow // ignore: cast_nullable_to_non_nullable
              as Oid4VciFlow,
      credentialDisplay: freezed == credentialDisplay
          ? _value.credentialDisplay
          : credentialDisplay // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CredentialOfferCopyWith<$Res> get offer {
    return $CredentialOfferCopyWith<$Res>(_value.offer, (value) {
      return _then(_value.copyWith(offer: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $IssuerMetadataCopyWith<$Res> get issuerMetadata {
    return $IssuerMetadataCopyWith<$Res>(_value.issuerMetadata, (value) {
      return _then(_value.copyWith(issuerMetadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResolvedCredentialOfferImplCopyWith<$Res>
    implements $ResolvedCredentialOfferCopyWith<$Res> {
  factory _$$ResolvedCredentialOfferImplCopyWith(
          _$ResolvedCredentialOfferImpl value,
          $Res Function(_$ResolvedCredentialOfferImpl) then) =
      __$$ResolvedCredentialOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CredentialOffer offer,
      IssuerMetadata issuerMetadata,
      Oid4VciFlow flow,
      List<Map<String, dynamic>>? credentialDisplay});

  @override
  $CredentialOfferCopyWith<$Res> get offer;
  @override
  $IssuerMetadataCopyWith<$Res> get issuerMetadata;
}

/// @nodoc
class __$$ResolvedCredentialOfferImplCopyWithImpl<$Res>
    extends _$ResolvedCredentialOfferCopyWithImpl<$Res,
        _$ResolvedCredentialOfferImpl>
    implements _$$ResolvedCredentialOfferImplCopyWith<$Res> {
  __$$ResolvedCredentialOfferImplCopyWithImpl(
      _$ResolvedCredentialOfferImpl _value,
      $Res Function(_$ResolvedCredentialOfferImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offer = null,
    Object? issuerMetadata = null,
    Object? flow = null,
    Object? credentialDisplay = freezed,
  }) {
    return _then(_$ResolvedCredentialOfferImpl(
      offer: null == offer
          ? _value.offer
          : offer // ignore: cast_nullable_to_non_nullable
              as CredentialOffer,
      issuerMetadata: null == issuerMetadata
          ? _value.issuerMetadata
          : issuerMetadata // ignore: cast_nullable_to_non_nullable
              as IssuerMetadata,
      flow: null == flow
          ? _value.flow
          : flow // ignore: cast_nullable_to_non_nullable
              as Oid4VciFlow,
      credentialDisplay: freezed == credentialDisplay
          ? _value._credentialDisplay
          : credentialDisplay // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc

class _$ResolvedCredentialOfferImpl implements _ResolvedCredentialOffer {
  const _$ResolvedCredentialOfferImpl(
      {required this.offer,
      required this.issuerMetadata,
      required this.flow,
      final List<Map<String, dynamic>>? credentialDisplay})
      : _credentialDisplay = credentialDisplay;

  @override
  final CredentialOffer offer;
  @override
  final IssuerMetadata issuerMetadata;
  @override
  final Oid4VciFlow flow;

  /// Metadatos de display crudos de las credenciales ofrecidas.
  final List<Map<String, dynamic>>? _credentialDisplay;

  /// Metadatos de display crudos de las credenciales ofrecidas.
  @override
  List<Map<String, dynamic>>? get credentialDisplay {
    final value = _credentialDisplay;
    if (value == null) return null;
    if (_credentialDisplay is EqualUnmodifiableListView)
      return _credentialDisplay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ResolvedCredentialOffer(offer: $offer, issuerMetadata: $issuerMetadata, flow: $flow, credentialDisplay: $credentialDisplay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResolvedCredentialOfferImpl &&
            (identical(other.offer, offer) || other.offer == offer) &&
            (identical(other.issuerMetadata, issuerMetadata) ||
                other.issuerMetadata == issuerMetadata) &&
            (identical(other.flow, flow) || other.flow == flow) &&
            const DeepCollectionEquality()
                .equals(other._credentialDisplay, _credentialDisplay));
  }

  @override
  int get hashCode => Object.hash(runtimeType, offer, issuerMetadata, flow,
      const DeepCollectionEquality().hash(_credentialDisplay));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResolvedCredentialOfferImplCopyWith<_$ResolvedCredentialOfferImpl>
      get copyWith => __$$ResolvedCredentialOfferImplCopyWithImpl<
          _$ResolvedCredentialOfferImpl>(this, _$identity);
}

abstract class _ResolvedCredentialOffer implements ResolvedCredentialOffer {
  const factory _ResolvedCredentialOffer(
          {required final CredentialOffer offer,
          required final IssuerMetadata issuerMetadata,
          required final Oid4VciFlow flow,
          final List<Map<String, dynamic>>? credentialDisplay}) =
      _$ResolvedCredentialOfferImpl;

  @override
  CredentialOffer get offer;
  @override
  IssuerMetadata get issuerMetadata;
  @override
  Oid4VciFlow get flow;
  @override

  /// Metadatos de display crudos de las credenciales ofrecidas.
  List<Map<String, dynamic>>? get credentialDisplay;
  @override
  @JsonKey(ignore: true)
  _$$ResolvedCredentialOfferImplCopyWith<_$ResolvedCredentialOfferImpl>
      get copyWith => throw _privateConstructorUsedError;
}
