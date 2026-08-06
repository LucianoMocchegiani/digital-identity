import 'dart:convert';

import 'package:dio/dio.dart';

import '../protocol/didcomm/oob/oob_parser.dart';
import '../protocol/didcomm/oob/oob_resolver.dart';
import '../protocol/openid4vc/oid4vci/oid4vci_service.dart';
import '../protocol/openid4vc/oid4vp/oid4vp_service.dart';
import 'invitation_parser.dart';
import 'models/invitation_result.dart';

export 'models/invitation_result.dart';
export 'models/invitation_type.dart';

/// Rutea una URL de invitación al servicio correspondiente y retorna un
/// [InvitationResult] listo para consumir en la capa de UI.
///
/// Maneja OID4VCI, OID4VP y DIDComm (OOB embebido o short URL RFC 0434).
class InvitationResolver {
  InvitationResolver({
    required Oid4VciService oid4vciService,
    required Oid4VpService oid4vpService,
    Dio? dio,
  })  : _oid4vci = oid4vciService,
        _oid4vp = oid4vpService,
        _dio = dio ?? Dio();

  final Oid4VciService _oid4vci;
  final Oid4VpService _oid4vp;
  final Dio _dio;

  /// Resuelve [url] y retorna el resultado tipado.
  ///
  /// Nunca lanza excepciones — los errores se devuelven como [InvitationErrorResult].
  Future<InvitationResult> resolve(String url) async {
    final canonicalUrl = InvitationParser.canonicalizeForResolve(url);
    final type = InvitationParser.detectType(canonicalUrl);

    if (type == null) {
      return const InvitationErrorResult(
        message: 'Formato de invitación no reconocido.',
        type: InvitationErrorType.unknownFormat,
      );
    }

    return switch (type) {
      InvitationType.openid4vciOffer => _resolveOid4Vci(canonicalUrl),
      InvitationType.openid4vpRequest => _resolveOid4Vp(canonicalUrl),
      InvitationType.didcommInvitation => _resolveDidComm(canonicalUrl),
    };
  }

  // — OID4VCI —

  Future<InvitationResult> _resolveOid4Vci(String url) async {
    try {
      final offer = await _oid4vci.resolveOffer(url);
      return Oid4VciInvitationResult(offer);
    } on DioException catch (e) {
      return InvitationErrorResult(
        message: e.message ?? 'Error al obtener la oferta de credencial.',
        type: InvitationErrorType.fetchFailed,
      );
    } on FormatException catch (e) {
      return InvitationErrorResult(
        message: e.message,
        type: InvitationErrorType.invalidPayload,
      );
    } catch (e) {
      return InvitationErrorResult(
        message: e.toString(),
        type: InvitationErrorType.invalidPayload,
      );
    }
  }

  // — OID4VP —

  Future<InvitationResult> _resolveOid4Vp(String url) async {
    try {
      final request = await _oid4vp.resolveRequest(url);

      if (!request.submission.areAllSatisfied) {
        return const InvitationErrorResult(
          message: 'No hay credenciales locales que satisfagan la solicitud.',
          type: InvitationErrorType.noMatchingCredentials,
        );
      }

      return Oid4VpInvitationResult(request);
    } on DioException catch (e) {
      return InvitationErrorResult(
        message: e.message ?? 'Error al obtener la solicitud de presentación.',
        type: InvitationErrorType.fetchFailed,
      );
    } on FormatException catch (e) {
      return InvitationErrorResult(
        message: e.message,
        type: InvitationErrorType.invalidPayload,
      );
    } catch (e) {
      return InvitationErrorResult(
        message: e.toString(),
        type: InvitationErrorType.invalidPayload,
      );
    }
  }

  // — DIDComm —

  Future<InvitationResult> _resolveDidComm(String url) async {
    try {
      var payload = OobParser.parse(url);
      if (!_isOobInvitationPayload(payload)) {
        payload = await _fetchShortInvitation(url);
      }
      if (!_isOobInvitationPayload(payload)) {
        return const InvitationErrorResult(
          message: 'No se pudo obtener la invitación DIDComm.',
          type: InvitationErrorType.invalidPayload,
        );
      }
      final flowType = OobResolver.detectFlowType(payload!);
      return DidCommInvitationResult(invitation: payload, flowType: flowType);
    } on DioException catch (e) {
      return InvitationErrorResult(
        message: e.message ?? 'Error al obtener la invitación DIDComm.',
        type: InvitationErrorType.fetchFailed,
      );
    } on FormatException catch (e) {
      return InvitationErrorResult(
        message: e.message,
        type: InvitationErrorType.invalidPayload,
      );
    } catch (e) {
      return InvitationErrorResult(
        message: e.toString(),
        type: InvitationErrorType.invalidPayload,
      );
    }
  }

  /// Descarga una short URL OOB (RFC 0434 / Credo `parseInvitationShortUrl`).
  ///
  /// GET con `Accept: application/json`. Acepta cuerpo JSON o redirect a `?oob=`.
  Future<Map<String, dynamic>> _fetchShortInvitation(String url) async {
    final response = await _dio.get<dynamic>(
      url,
      options: Options(
        headers: const {'Accept': 'application/json'},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && _isOobInvitationPayload(data)) {
      return data;
    }
    if (data is String && data.trim().startsWith('{')) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic> && _isOobInvitationPayload(decoded)) {
        return decoded;
      }
    }

    final location = response.headers.value('location');
    if (location != null && location.isNotEmpty) {
      final fromLocation = OobParser.parse(location);
      if (_isOobInvitationPayload(fromLocation)) return fromLocation!;
    }

    final finalUrl = response.realUri.toString();
    if (finalUrl != url) {
      final fromFinal = OobParser.parse(finalUrl);
      if (_isOobInvitationPayload(fromFinal)) return fromFinal!;
    }

    throw const FormatException(
      'La short URL no devolvió un mensaje OOB válido.',
    );
  }

  static bool _isOobInvitationPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) return false;
    final type = payload['@type'] ?? payload['type'];
    return type is String && type.toLowerCase().contains('out-of-band');
  }
}
