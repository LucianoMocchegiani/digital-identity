import 'package:uuid/uuid.dart';

import '../../../record/models/connection_record.dart';
import '../../../record/models/key_record.dart';
import 'didcomm_credential_attach.dart';
import '../crypto/didcomm_encrypted_send.dart';
import '../models/credential_exchange_record.dart';
import '../transport/http_transport.dart';
import '../transport/ws_transport.dart';

/// Implementa el protocolo RFC 0036 (issue-credential) desde la perspectiva del holder.
///
/// Flujo: offer-credential → request-credential → issue-credential → ack.
class CredentialExchangeService {
  CredentialExchangeService({HttpTransport? transport})
      : _transport = transport ?? const HttpTransport();

  final HttpTransport _transport;

  static const _uuid = Uuid();

  static const _typeRequest =
      'https://didcomm.org/issue-credential/2.0/request-credential';

  /// Procesa un mensaje `offer-credential` y envía `request-credential` cifrado.
  ///
  /// Con [webSocket] activo, el envío va por el mismo canal inbound (return_route).
  /// Retorna el [CredentialExchangeRecord] con estado [CredentialExchangeState.requestSent].
  Future<CredentialExchangeRecord> handleOfferCredential({
    required Map<String, dynamic> message,
    required ConnectionRecord connection,
    required KeyRecord senderKey,
    required String recipientKeyDid,
    required String endpoint,
    WsConnection? webSocket,
  }) async {
    final threadId = DidCommCredentialAttach.threadIdFromOfferMessage(message) ??
        message['@id'] as String? ??
        _uuid.v4();
    final offerAttachments =
        DidCommCredentialAttach.requestAttachmentsFromOffer(message);
    if (offerAttachments.isEmpty) {
      throw StateError(
        'El offer-credential no incluye adjuntos (offers~attach).',
      );
    }

    final record = CredentialExchangeRecord(
      exchangeId: _uuid.v4(),
      connectionId: connection.connectionId,
      state: CredentialExchangeState.offerReceived,
      createdAt: DateTime.now().toUtc(),
      threadId: threadId,
      offerAttach: offerAttachments.first,
    );

    final requestMsg = {
      '@type': _typeRequest,
      '@id': _uuid.v4(),
      '~thread': {'thid': threadId},
      '~transport': {'return_route': 'all'},
      'formats': message['formats'] ?? [],
      'requests~attach': offerAttachments,
    };

    await DidCommEncryptedSend.send(
      message: requestMsg,
      recipientKeyDid: recipientKeyDid,
      endpoint: endpoint,
      senderKey: senderKey,
      transport: _transport,
      webSocket: webSocket,
      deliverViaWebSocket: webSocket != null,
    );

    return record.copyWith(state: CredentialExchangeState.requestSent);
  }

  /// Procesa un mensaje `issue-credential` y retorna el record actualizado.
  ///
  /// El llamador es responsable de extraer y persistir la credencial del attachment.
  Future<CredentialExchangeRecord> handleIssueCredential({
    required Map<String, dynamic> message,
    required CredentialExchangeRecord exchangeRecord,
  }) async {
    final attach = (message['credentials~attach'] as List?)
        ?.cast<Map<String, dynamic>>();

    return exchangeRecord.copyWith(
      state: CredentialExchangeState.credentialReceived,
      credentialAttach:
          attach?.isNotEmpty == true ? attach!.first : null,
    );
  }
}
