// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_presentation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubmitPresentationResult {
  /// Verdadero si el verifier aceptó la presentación.
  bool get success => throw _privateConstructorUsedError;

  /// URI de redirect si el verifier lo requiere (ej. flujo authorization code).
  String? get redirectUri => throw _privateConstructorUsedError;

  /// Mensaje de error si [success] es false.
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubmitPresentationResultCopyWith<SubmitPresentationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitPresentationResultCopyWith<$Res> {
  factory $SubmitPresentationResultCopyWith(SubmitPresentationResult value,
          $Res Function(SubmitPresentationResult) then) =
      _$SubmitPresentationResultCopyWithImpl<$Res, SubmitPresentationResult>;
  @useResult
  $Res call({bool success, String? redirectUri, String? error});
}

/// @nodoc
class _$SubmitPresentationResultCopyWithImpl<$Res,
        $Val extends SubmitPresentationResult>
    implements $SubmitPresentationResultCopyWith<$Res> {
  _$SubmitPresentationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? redirectUri = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      redirectUri: freezed == redirectUri
          ? _value.redirectUri
          : redirectUri // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubmitPresentationResultImplCopyWith<$Res>
    implements $SubmitPresentationResultCopyWith<$Res> {
  factory _$$SubmitPresentationResultImplCopyWith(
          _$SubmitPresentationResultImpl value,
          $Res Function(_$SubmitPresentationResultImpl) then) =
      __$$SubmitPresentationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String? redirectUri, String? error});
}

/// @nodoc
class __$$SubmitPresentationResultImplCopyWithImpl<$Res>
    extends _$SubmitPresentationResultCopyWithImpl<$Res,
        _$SubmitPresentationResultImpl>
    implements _$$SubmitPresentationResultImplCopyWith<$Res> {
  __$$SubmitPresentationResultImplCopyWithImpl(
      _$SubmitPresentationResultImpl _value,
      $Res Function(_$SubmitPresentationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? redirectUri = freezed,
    Object? error = freezed,
  }) {
    return _then(_$SubmitPresentationResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      redirectUri: freezed == redirectUri
          ? _value.redirectUri
          : redirectUri // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SubmitPresentationResultImpl implements _SubmitPresentationResult {
  const _$SubmitPresentationResultImpl(
      {required this.success, this.redirectUri, this.error});

  /// Verdadero si el verifier aceptó la presentación.
  @override
  final bool success;

  /// URI de redirect si el verifier lo requiere (ej. flujo authorization code).
  @override
  final String? redirectUri;

  /// Mensaje de error si [success] es false.
  @override
  final String? error;

  @override
  String toString() {
    return 'SubmitPresentationResult(success: $success, redirectUri: $redirectUri, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitPresentationResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.redirectUri, redirectUri) ||
                other.redirectUri == redirectUri) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, success, redirectUri, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitPresentationResultImplCopyWith<_$SubmitPresentationResultImpl>
      get copyWith => __$$SubmitPresentationResultImplCopyWithImpl<
          _$SubmitPresentationResultImpl>(this, _$identity);
}

abstract class _SubmitPresentationResult implements SubmitPresentationResult {
  const factory _SubmitPresentationResult(
      {required final bool success,
      final String? redirectUri,
      final String? error}) = _$SubmitPresentationResultImpl;

  @override

  /// Verdadero si el verifier aceptó la presentación.
  bool get success;
  @override

  /// URI de redirect si el verifier lo requiere (ej. flujo authorization code).
  String? get redirectUri;
  @override

  /// Mensaje de error si [success] es false.
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$SubmitPresentationResultImplCopyWith<_$SubmitPresentationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
