import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'jarm_encrypt.dart';

part 'submit_presentation.freezed.dart';

/// Resultado del envío de la presentación al verifier.
@freezed
class SubmitPresentationResult with _$SubmitPresentationResult {
  const factory SubmitPresentationResult({
    /// Verdadero si el verifier aceptó la presentación.
    required bool success,

    /// URI de redirect si el verifier lo requiere (ej. flujo authorization code).
    String? redirectUri,

    /// Mensaje de error si [success] es false.
    String? error,
  }) = _SubmitPresentationResult;
}

/// Envía la VP Token al verifier via POST (`application/x-www-form-urlencoded`).
///
/// - `direct_post`: `vp_token`, `state`, opcionalmente `presentation_submission`.
/// - `direct_post.jwt` (EUDI): `response` con JWE que contiene `state` + `vp_token`.
Future<SubmitPresentationResult> submitPresentation({
  required String responseUri,
  required dynamic vpToken,
  Map<String, dynamic>? presentationSubmission,
  String? state,
  String? responseMode,
  Map<String, dynamic>? clientMetadata,
  String? nonce,
  String encAlg = 'A128GCM',
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final isJwtMode = responseMode == 'direct_post.jwt';

  final Map<String, dynamic> data;
  if (isJwtMode) {
    final recipientJwk = JarmEncrypt.pickEncryptionJwk(clientMetadata);
    if (recipientJwk == null) {
      return const SubmitPresentationResult(
        success: false,
        error: 'El verifier requiere respuesta cifrada pero no envió jwks.',
      );
    }

    final responsePayload = <String, dynamic>{
      if (state != null) 'state': state,
      'vp_token': _vpTokenObject(vpToken),
    };

    try {
      final encrypted = await JarmEncrypt.encryptAuthorizationResponse(
        payload: responsePayload,
        recipientJwk: recipientJwk,
        enc: encAlg,
        apv: nonce,
      );
      data = {'response': encrypted};
    } catch (e) {
      return SubmitPresentationResult(
        success: false,
        error: 'Error al cifrar la respuesta: $e',
      );
    }
  } else {
    data = <String, dynamic>{
      'vp_token': vpToken is String ? vpToken : jsonEncode(vpToken),
      if (presentationSubmission != null)
        'presentation_submission': jsonEncode(presentationSubmission),
      if (state != null) 'state': state,
    };
  }

  try {
    final response = await client.post<dynamic>(
      responseUri,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final body = response.data;
    if (body is Map) {
      final error = body['error'] ?? body['error_description'];
      if (error != null) {
        return SubmitPresentationResult(success: false, error: error.toString());
      }
      final redirectUri = body['redirect_uri'] as String?;
      return SubmitPresentationResult(success: true, redirectUri: redirectUri);
    }

    return const SubmitPresentationResult(success: true);
  } on DioException catch (e) {
    final errorBody = e.response?.data;
    final errorMsg = errorBody is Map
        ? (errorBody['error_description'] ?? errorBody['error'] ?? errorBody['message'])
            .toString()
        : e.message ?? 'Error desconocido al enviar presentación.';

    return SubmitPresentationResult(success: false, error: errorMsg);
  }
}

Map<String, dynamic> _vpTokenObject(dynamic vpToken) {
  if (vpToken is Map<String, dynamic>) return vpToken;
  if (vpToken is Map) return Map<String, dynamic>.from(vpToken);
  if (vpToken is String) {
    final decoded = jsonDecode(vpToken);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  throw ArgumentError('vp_token debe ser un objeto JSON.');
}
