/// Eventos emitidos por [DidCommFlowSession] durante un flujo activo.
sealed class DidCommFlowEvent {}

/// Mensaje DIDComm desencriptado clasificado por tipo de protocolo.
class DidCommProtocolMessage extends DidCommFlowEvent {
  DidCommProtocolMessage({
    required this.message,
    required this.kind,
  });

  /// Payload JSON del mensaje (post-unpack).
  final Map<String, dynamic> message;

  /// Clasificación para routing en la wallet.
  final DidCommProtocolMessageKind kind;
}

/// Error al desencriptar o procesar un frame entrante.
class DidCommFlowError extends DidCommFlowEvent {
  DidCommFlowError(this.error);

  final Object error;
}

/// La sesión de flujo finalizó (socket cerrado).
class DidCommFlowClosed extends DidCommFlowEvent {}

/// Tipos de mensaje DIDComm reconocidos en el MVP.
enum DidCommProtocolMessageKind {
  credentialOffer,
  issueCredential,
  presentationRequest,
  presentationAck,
  problemReport,
  unknown,
}
