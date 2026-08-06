import 'package:identity_core_dart/identity_core.dart';

/// Mensaje legible para pantallas de error de flujos OID4VCI/OID4VP.
String formatFlowErrorMessage(Object error) {
  if (error is StateError) return error.message;
  if (error is FormatException) return error.message;

  final text = error.toString();
  if (text.startsWith('DioException')) {
    final status = RegExp(r'status code of (\d+)').firstMatch(text)?.group(1);
    final match = RegExp(
      r'error_description["\s:]+([^"\n}]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) return match.group(1)!.trim();
    if (status == '500') {
      return 'El servidor remoto rechazó la solicitud (error 500). '
          'Revisá los logs del issuer o intentá de nuevo.';
    }
    return 'Error de red al contactar al servidor${status != null ? ' (HTTP $status)' : ''}.';
  }

  return text.replaceFirst(RegExp(r'^[^:]+:\s*'), '');
}

/// Mensaje legible para [InvitationErrorResult].
String invitationErrorMessage(InvitationErrorResult result) {
  return switch (result.type) {
    InvitationErrorType.unknownFormat =>
      'Formato de invitación no reconocido.',
    InvitationErrorType.fetchFailed =>
      result.message.isNotEmpty
          ? result.message
          : 'No se pudo obtener la invitación del servidor.',
    InvitationErrorType.invalidPayload =>
      result.message.isNotEmpty
          ? result.message
          : 'La invitación tiene un formato inválido.',
    InvitationErrorType.noMatchingCredentials =>
      'No hay credenciales en la wallet que satisfagan la solicitud.',
  };
}
