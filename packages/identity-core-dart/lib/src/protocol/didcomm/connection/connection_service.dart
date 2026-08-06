import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../did/did_peer.dart';
import '../../../kms/kms_service.dart';
import '../../../record/connection_record_store.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/connection_record.dart';
import '../../../record/models/key_record.dart';
import '../crypto/didcomm_encrypted_send.dart';
import '../crypto/didcomm_envelope_v1.dart';
import '../did_doc_recipient_key.dart';
import '../did_exchange_response_parser.dart';
import '../oob/oob_parser.dart';
import '../transport/http_transport.dart';
import '../transport/ws_transport.dart';
import 'connection_handshake_result.dart';

/// Gestiona el protocolo DIDComm de establecimiento de conexión (RFC 0023 DID Exchange).
class ConnectionService {
  ConnectionService({
    required KmsService kms,
    required KeyRecordStore keyStore,
    required ConnectionRecordStore connectionStore,
    HttpTransport? transport,
  })  : _kms = kms,
        _keyStore = keyStore,
        _connectionStore = connectionStore,
        _transport = transport ?? const HttpTransport();

  final KmsService _kms;
  final KeyRecordStore _keyStore;
  final ConnectionRecordStore _connectionStore;
  final HttpTransport _transport;

  static const _uuid = Uuid();

  /// Acepta una invitación OOB y establece una conexión DIDComm.
  ///
  /// Genera un `did:peer:4` dedicado para esta conexión, envía un DID Exchange
  /// Request al endpoint del invitador y persiste el [ConnectionRecord].
  /// Cierra el WebSocket al finalizar el handshake.
  Future<ConnectionRecord> acceptInvitation(
    Map<String, dynamic> invitation,
  ) async {
    final result = await establishConnection(invitation);
    await result.webSocket?.close();
    return result.connection;
  }

  /// Ejecuta el handshake DID Exchange y opcionalmente deja el WebSocket abierto.
  ///
  /// Con [keepWebSocketOpen] en `true`, [ConnectionHandshakeResult.webSocket]
  /// queda activo para [DidCommFlowSession].
  Future<ConnectionHandshakeResult> establishConnection(
    Map<String, dynamic> invitation, {
    bool keepWebSocketOpen = false,
  }) async {
    final endpoint = OobParser.extractServiceEndpoint(invitation);
    final recipientKeyDids = OobParser.extractRecipientKeys(invitation);

    final invitationId =
        invitation['@id'] as String? ?? invitation['id'] as String?;
    final label =
        invitation['label'] as String? ?? invitation['goal'] as String?;
    final goalCode = invitation['goal_code'] as String?;

    if (invitationId == null || invitationId.isEmpty) {
      throw StateError(
        'La invitación OOB no incluye @id; Credo requiere pthid en didexchange/complete.',
      );
    }

    final ed25519Key = await _kms.generateKey(KeyType.ed25519);
    final x25519Key = await _kms.generateKey(KeyType.x25519);

    final myDid = DidPeer.createNumAlgo4(
      ed25519PublicJwk: ed25519Key.publicJwk,
      x25519PublicJwk: x25519Key.publicJwk,
    );

    await _keyStore.save(ed25519Key.copyWith(did: myDid));
    await _keyStore.save(x25519Key.copyWith(did: myDid));

    final connectionId = _uuid.v4();
    var activeRecipientKeyDid =
        recipientKeyDids.isNotEmpty ? recipientKeyDids.first : null;
    final theirDid = activeRecipientKeyDid ?? '';

    var connection = ConnectionRecord(
      connectionId: connectionId,
      myDid: myDid,
      theirDid: theirDid,
      state: ConnectionState.invited,
      createdAt: DateTime.now().toUtc(),
      label: label,
      goalCode: goalCode,
    );
    await _connectionStore.save(connection);

    WsConnection? webSocket;

    if (endpoint != null) {
      if (activeRecipientKeyDid == null) {
        throw StateError(
          'La invitación OOB no incluye recipientKeys; no se puede cifrar para Credo.',
        );
      }

      // Handshake por el mismo WebSocket (patrón holder mobile + return_route).
      // Credo asocia la sesión inbound a la conexión en este canal; es la vía
      // para recibir offer-credential / request-presentation después.
      webSocket = await WsConnection.connect(endpoint);
      final wsResponseFuture = webSocket
          .receiveFirst(timeout: const Duration(seconds: 15))
          .catchError((_) => null);

      final requestMsg = _buildRequest(
        myDid: myDid,
        invitationId: invitationId,
      );
      var requestId = requestMsg['@id'] as String;

      await DidCommEncryptedSend.send(
        message: requestMsg,
        recipientKeyDid: activeRecipientKeyDid,
        endpoint: endpoint,
        senderKey: ed25519Key,
        transport: _transport,
        webSocket: webSocket,
        deliverViaWebSocket: true,
      );

      connection = connection.copyWith(state: ConnectionState.requested);
      await _connectionStore.save(connection);

      var encryptedJson = await wsResponseFuture;

      // Fallback HTTP si el issuer no respondió por WS (p. ej. proxy sin WS).
      if (encryptedJson == null || encryptedJson.trim().isEmpty) {
        final fallbackRequest = _buildRequest(
          myDid: myDid,
          invitationId: invitationId,
        );
        requestId = fallbackRequest['@id'] as String;
        encryptedJson = await DidCommEncryptedSend.send(
          message: fallbackRequest,
          recipientKeyDid: activeRecipientKeyDid,
          endpoint: endpoint,
          senderKey: ed25519Key,
          transport: _transport,
        );
      }

      if (encryptedJson == null || encryptedJson.trim().isEmpty) {
        await webSocket.close();
        throw StateError(
          'No se recibió didexchange/response del issuer.',
        );
      }

      final responseMsg = await DidCommEnvelopeV1.unpack(
        envelope: jsonDecode(encryptedJson) as Map<String, dynamic>,
        recipientEd25519PrivateJwk: ed25519Key.privateJwk!,
        recipientEd25519PublicJwk: ed25519Key.publicJwk,
      );
      connection = await _applyExchangeResponse(connection, responseMsg);

      final theirDidDoc =
          connection.theirDidDoc ??
          DidExchangeResponseParser.resolveDidDocument(responseMsg);
      if (theirDidDoc != null && connection.theirDidDoc == null) {
        connection = connection.copyWith(theirDidDoc: theirDidDoc);
      }

      // Tras el response, Credo rota a un did:peer nuevo: el complete debe
      // cifrarse con las claves del DID de respuesta (no las de la invitación).
      final responseRecipientKeyDid = DidDocRecipientKey.extractEd25519KeyDid(
        theirDidDoc ?? const {},
      );
      if (responseRecipientKeyDid == null) {
        await webSocket.close();
        throw StateError(
          'No se pudo obtener la clave Ed25519 del DID de respuesta del issuer. '
          'Verificá que el response incluya did:peer long-form o did_doc~attach.',
        );
      }

      final completeRecipientKeyDid = responseRecipientKeyDid;

      // thid/pthid fijos: Credo valida thid=request @id y pthid=OOB @id.
      final completeMsg = _buildComplete(
        requestId: requestId,
        invitationId: invitationId,
      );

      // Complete solo por WS: registra la sesión inbound persistente para
      // entrega asíncrona (offer-credential). HTTP cerraría el canal ~10s.
      await DidCommEncryptedSend.send(
        message: completeMsg,
        recipientKeyDid: completeRecipientKeyDid,
        endpoint: endpoint,
        senderKey: ed25519Key,
        transport: _transport,
        webSocket: webSocket,
        deliverViaWebSocket: true,
      );

      connection = connection.copyWith(state: ConnectionState.complete);

      await _connectionStore.save(connection);

      if (connection.state != ConnectionState.complete) {
        await webSocket.close();
        throw StateError(
          'El issuer no completó el handshake DID Exchange '
          '(estado: ${connection.state.name}).',
        );
      }

      if (!keepWebSocketOpen) {
        await webSocket.close();
        webSocket = null;
      }

      activeRecipientKeyDid = completeRecipientKeyDid;
    }

    return ConnectionHandshakeResult(
      connection: connection,
      webSocket: webSocket,
      serviceEndpoint: endpoint,
      recipientKeyDid: activeRecipientKeyDid,
    );
  }

  Map<String, dynamic> _buildRequest({
    required String myDid,
    required String invitationId,
  }) {
    return {
      '@type': 'https://didcomm.org/didexchange/1.1/request',
      '@id': _uuid.v4(),
      '~thread': {'pthid': invitationId},
      '~transport': {'return_route': 'all'},
      'label': 'QuarkWallet',
      'did': myDid,
    };
  }

  /// Credo valida `~thread.thid` (= request @id) y `~thread.pthid` (= OOB @id).
  Map<String, dynamic> _buildComplete({
    required String requestId,
    required String invitationId,
  }) {
    return {
      '@type': 'https://didcomm.org/didexchange/1.1/complete',
      '@id': _uuid.v4(),
      '~thread': {
        'thid': requestId,
        'pthid': invitationId,
      },
      '~transport': {'return_route': 'all'},
    };
  }

  Future<ConnectionRecord> _applyExchangeResponse(
    ConnectionRecord connection,
    Map<String, dynamic> message,
  ) async {
    final type = message['@type'] as String? ?? message['type'] as String? ?? '';
    if (!type.endsWith('didexchange/1.1/response') &&
        !type.endsWith('didexchange/2.0/response')) {
      throw StateError('Mensaje inesperado tras DID Exchange request: $type');
    }

    final theirDid = message['did'] as String? ?? connection.theirDid;
    final theirDidDoc =
        DidExchangeResponseParser.resolveDidDocument(message) ??
        (theirDid.startsWith('did:peer:')
            ? _tryResolvePeerDid(theirDid)
            : null);

    return connection.copyWith(
      state: ConnectionState.responded,
      theirDid: theirDid,
      theirDidDoc: theirDidDoc,
    );
  }

  Map<String, dynamic>? _tryResolvePeerDid(String theirDid) {
    try {
      return DidPeer.resolve(theirDid);
    } catch (_) {
      return null;
    }
  }
}
