import 'package:uuid/uuid.dart';

import '../../../record/models/connection_record.dart';
import '../../../record/models/key_record.dart';
import '../crypto/didcomm_encrypted_send.dart';
import '../did_doc_recipient_key.dart';
import '../models/proof_exchange_record.dart';
import '../transport/http_transport.dart';
import '../transport/ws_transport.dart';

/// Implementa el protocolo RFC 0037 (present-proof) desde la perspectiva del holder.
///
/// Flujo: request-presentation → presentation → ack.
class ProofExchangeService {
  ProofExchangeService({HttpTransport? transport})
      : _transport = transport ?? const HttpTransport();

  final HttpTransport _transport;

  static const _uuid = Uuid();

  static const _typePresentation =
      'https://didcomm.org/present-proof/2.0/presentation';

  /// Identificador de formato DIF PEX para el attachment de presentación
  /// (debe coincidir con el que espera Credo-TS).
  static const _formatPexSubmission =
      'dif/presentation-exchange/submission@v1.0';

  /// Procesa un mensaje `request-presentation` y crea el exchange record.
  Future<ProofExchangeRecord> handleRequestPresentation({
    required Map<String, dynamic> message,
    required ConnectionRecord connection,
  }) async {
    final thread = message['~thread'];
    final threadId = (thread is Map ? thread['thid'] as String? : null) ??
        message['@id'] as String? ??
        _uuid.v4();
    final requestAttach = (message['request_presentations~attach'] as List?)
        ?.cast<Map<String, dynamic>>();

    return ProofExchangeRecord(
      exchangeId: _uuid.v4(),
      connectionId: connection.connectionId,
      state: ProofExchangeState.requestReceived,
      createdAt: DateTime.now().toUtc(),
      threadId: threadId,
      requestAttach: requestAttach?.isNotEmpty == true
          ? requestAttach!.first
          : null,
    );
  }

  /// Envía la presentación [vpDocument] cifrada al verifier.
  Future<ProofExchangeRecord> sendPresentation({
    required ProofExchangeRecord exchangeRecord,
    required Map<String, dynamic> vpDocument,
    required ConnectionRecord connection,
    required KeyRecord senderKey,
    required String recipientKeyDid,
    required String endpoint,
    WsConnection? webSocket,
  }) async {
    final attachId = _uuid.v4();
    final presentationMsg = {
      '@type': _typePresentation,
      '@id': _uuid.v4(),
      if (exchangeRecord.threadId != null)
        '~thread': {'thid': exchangeRecord.threadId},
      '~transport': {'return_route': 'all'},
      // Credo exige `formats` vinculado por attach_id para elegir el
      // format service (DIF PEX); sin esto el mensaje se descarta.
      'formats': [
        {
          'attach_id': attachId,
          'format': _formatPexSubmission,
        },
      ],
      'presentations~attach': [
        {
          '@id': attachId,
          'mime-type': 'application/json',
          'data': {'json': vpDocument},
        },
      ],
    };

    await DidCommEncryptedSend.send(
      message: presentationMsg,
      recipientKeyDid: recipientKeyDid,
      endpoint: endpoint,
      senderKey: senderKey,
      transport: _transport,
      webSocket: webSocket,
      deliverViaWebSocket: webSocket != null,
    );

    return exchangeRecord.copyWith(state: ProofExchangeState.presentationSent);
  }

  /// Resuelve la clave Ed25519 del verifier desde el DID Document de la conexión.
  static String? recipientKeyDid(ConnectionRecord connection) {
    return DidDocRecipientKey.extractEd25519KeyDid(
      connection.theirDidDoc ?? const {},
    );
  }

  static String? serviceEndpoint(ConnectionRecord connection) {
    final didDoc = connection.theirDidDoc;
    if (didDoc == null) return null;
    final services = didDoc['service'] as List?;
    if (services == null || services.isEmpty) return null;
    return (services.first as Map<String, dynamic>?)?['serviceEndpoint']
        as String?;
  }
}
