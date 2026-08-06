import 'dart:convert';

import 'package:dio/dio.dart';

/// Envía envelopes DIDComm v1 cifrados via HTTP POST.
class HttpTransport {
  const HttpTransport({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  Dio get _client => _dio ?? Dio();

  /// POST envelope cifrado DIDComm v1 (Credo) con `application/didcomm-envelope-enc`.
  ///
  /// Retorna el cuerpo de la respuesta HTTP si el agente remoto envía un mensaje
  /// de vuelta en la misma petición (p. ej. DID Exchange response).
  Future<String?> sendEncrypted({
    required String endpoint,
    required Map<String, dynamic> envelope,
  }) async {
    try {
      final response = await _client.post<String>(
        endpoint,
        data: jsonEncode(envelope),
        options: Options(
          contentType: 'application/didcomm-envelope-enc',
          responseType: ResponseType.plain,
        ),
      );
      final body = response.data;
      if (body == null || body.isEmpty) return null;
      return body;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: e.error,
          message: '${e.message ?? 'HTTP error'} — issuer: $data',
        );
      }
      rethrow;
    }
  }

  /// POST mensaje plano DIDComm v1 con `application/didcomm-envelope-plain`.
  Future<String?> sendPlain({
    required String endpoint,
    required Map<String, dynamic> message,
  }) async {
    final response = await _client.post<String>(
      endpoint,
      data: jsonEncode(message),
      options: Options(
        contentType: 'application/didcomm-envelope-plain',
        responseType: ResponseType.plain,
      ),
    );
    final body = response.data;
    if (body == null || body.isEmpty) return null;
    return body;
  }

  /// Envío plano sin cifrar — usado por exchange services internos.
  Future<void> send({
    required String endpoint,
    required Map<String, dynamic> message,
  }) async {
    await sendPlain(endpoint: endpoint, message: message);
  }
}
