import 'didcomm_flow_event.dart';

/// Clasifica mensajes DIDComm desencriptados por `@type` / `type`.
abstract final class DidCommMessageRouter {
  /// Determina el [DidCommProtocolMessageKind] a partir del mapa del mensaje.
  static DidCommProtocolMessageKind classify(Map<String, dynamic> message) {
    final type = _messageType(message);
    if (type == null) return DidCommProtocolMessageKind.unknown;

    if (type.contains('issue-credential') && type.endsWith('offer-credential')) {
      return DidCommProtocolMessageKind.credentialOffer;
    }
    if (type.contains('issue-credential') && type.endsWith('issue-credential')) {
      return DidCommProtocolMessageKind.issueCredential;
    }
    if (type.contains('present-proof') &&
        type.endsWith('request-presentation')) {
      return DidCommProtocolMessageKind.presentationRequest;
    }
    // Credo emite `https://didcomm.org/present-proof/2.0/ack`.
    if (type.contains('present-proof') &&
        (type.endsWith('/ack') || type.endsWith('presentation-ack'))) {
      return DidCommProtocolMessageKind.presentationAck;
    }
    if (type.contains('problem-report')) {
      return DidCommProtocolMessageKind.problemReport;
    }

    return DidCommProtocolMessageKind.unknown;
  }

  /// Envuelve [message] en [DidCommProtocolMessage].
  static DidCommProtocolMessage toEvent(Map<String, dynamic> message) {
    return DidCommProtocolMessage(
      message: message,
      kind: classify(message),
    );
  }

  static String? _messageType(Map<String, dynamic> message) {
    final raw = message['@type'] as String? ?? message['type'] as String?;
    return raw?.toLowerCase();
  }
}
