import 'dart:convert';

import 'package:dio/dio.dart';

import '../../credential/bbs/constants.dart';
import '../../credential/models/w3c_credential_record.dart';
import '../../did/did_service.dart';
import '../../kms/kms_service.dart';
import '../../record/connection_record_store.dart';
import '../../record/key_record_store.dart';
import '../../record/models/connection_record.dart';
import '../../record/models/key_record.dart';
import 'connection/connection_handshake_result.dart';
import 'connection/connection_service.dart';
import 'credential/credential_exchange_service.dart';
import 'crypto/didcomm_envelope_v1.dart';
import 'did_doc_recipient_key.dart';
import 'flow/didcomm_flow_session.dart';
import 'models/credential_exchange_record.dart';
import 'models/proof_exchange_record.dart';
import 'proof/didcomm_presentation_builder.dart';
import 'proof/proof_exchange_service.dart';
import 'transport/http_transport.dart';

/// Fachada de alto nivel para la capa DIDComm del wallet.
///
/// Orquesta conexiones (RFC 0023), intercambio de credenciales (RFC 0036)
/// y presentación de prueba (RFC 0037).
class DidCommService {
  DidCommService({
    required KmsService kms,
    required DidService didService,
    required KeyRecordStore keyStore,
    required ConnectionRecordStore connectionStore,
    Dio? dio,
  })  : _kms = kms,
        _didService = didService,
        _connectionStore = connectionStore,
        _keyStore = keyStore,
        _connectionService = ConnectionService(
          kms: kms,
          keyStore: keyStore,
          connectionStore: connectionStore,
          transport: HttpTransport(dio: dio),
        ),
        credentialExchange = CredentialExchangeService(
          transport: HttpTransport(dio: dio),
        ),
        proofExchange = ProofExchangeService(
          transport: HttpTransport(dio: dio),
        );

  final ConnectionRecordStore _connectionStore;
  final KeyRecordStore _keyStore;
  final KmsService _kms;
  final DidService _didService;
  final ConnectionService _connectionService;

  /// Servicio de intercambio de credenciales DIDComm (RFC 0036).
  final CredentialExchangeService credentialExchange;

  /// Servicio de presentación de prueba DIDComm (RFC 0037).
  final ProofExchangeService proofExchange;

  /// Stream reactivo de todas las conexiones almacenadas.
  Stream<List<ConnectionRecord>> get connections =>
      _connectionStore.watchAll();

  /// Acepta una invitación OOB y establece la conexión DIDComm.
  ///
  /// Genera un `did:peer:4`, envía el DID Exchange Request y persiste
  /// el [ConnectionRecord]. Cierra el WebSocket al terminar el handshake.
  Future<ConnectionRecord> acceptInvitation(
    Map<String, dynamic> invitation,
  ) {
    return _connectionService.acceptInvitation(invitation);
  }

  /// Handshake DID Exchange dejando el WebSocket abierto para el flujo activo.
  Future<ConnectionHandshakeResult> establishConnection(
    Map<String, dynamic> invitation, {
    bool keepWebSocketOpen = true,
  }) {
    return _connectionService.establishConnection(
      invitation,
      keepWebSocketOpen: keepWebSocketOpen,
    );
  }

  /// Crea una [DidCommFlowSession] sobre un handshake con socket activo.
  Future<DidCommFlowSession> startFlowSession(
    ConnectionHandshakeResult handshake,
  ) async {
    final webSocket = handshake.webSocket;
    if (webSocket == null) {
      throw StateError(
        'No hay WebSocket activo: el handshake debe usar keepWebSocketOpen.',
      );
    }
    final ed25519Key = await _ed25519KeyForConnection(handshake.connection);
    return DidCommFlowSession(
      connection: handshake.connection,
      webSocket: webSocket,
      ed25519Key: ed25519Key,
      serviceEndpoint: handshake.serviceEndpoint,
    );
  }

  /// Envía `request-credential` cifrado por la sesión WS activa del flujo.
  Future<CredentialExchangeRecord> sendCredentialRequest({
    required DidCommFlowSession flowSession,
    required Map<String, dynamic> offerMessage,
  }) async {
    final connection = flowSession.connection;
    final endpoint = flowSession.serviceEndpoint;
    if (endpoint == null || endpoint.isEmpty) {
      throw StateError('Sin endpoint DIDComm del emisor.');
    }

    final senderKey = await _ed25519KeyForConnection(connection);
    final recipientKeyDid = DidDocRecipientKey.extractEd25519KeyDid(
      connection.theirDidDoc ?? const {},
    );
    if (recipientKeyDid == null) {
      throw StateError(
        'No se pudo obtener la clave Ed25519 del emisor para cifrar el request.',
      );
    }

    return credentialExchange.handleOfferCredential(
      message: offerMessage,
      connection: connection,
      senderKey: senderKey,
      recipientKeyDid: recipientKeyDid,
      endpoint: endpoint,
      webSocket: flowSession.webSocket,
    );
  }

  /// Construye y envía una presentación JSON-LD firmada ante un `request-presentation`.
  Future<ProofExchangeRecord> sendPresentation({
    required DidCommFlowSession flowSession,
    required Map<String, dynamic> requestMessage,
    required Map<String, dynamic> presentationDefinitionJson,
    required Map<String, W3cCredentialRecord> selectedByDescriptor,
    required String challenge,
  }) async {
    final connection = flowSession.connection;
    final endpoint = flowSession.serviceEndpoint ??
        ProofExchangeService.serviceEndpoint(connection);
    if (endpoint == null || endpoint.isEmpty) {
      throw StateError('Sin endpoint DIDComm del verificador.');
    }

    final senderKey = await _ed25519KeyForConnection(connection);
    final recipientKeyDid = ProofExchangeService.recipientKeyDid(connection);
    if (recipientKeyDid == null) {
      throw StateError(
        'No se pudo obtener la clave Ed25519 del verificador para cifrar la presentación.',
      );
    }

    final exchange = await proofExchange.handleRequestPresentation(
      message: requestMessage,
      connection: connection,
    );

    final issuerDidDocument = await _resolveIssuerDidDocumentForBbs(
      selectedByDescriptor.values,
    );

    final bundle = await DidCommPresentationBuilder.build(
      presentationDefinitionJson: presentationDefinitionJson,
      selectedByDescriptor: selectedByDescriptor,
      challenge: challenge,
      kms: _kms,
      keyStore: _keyStore,
      didService: _didService,
      issuerDidDocument: issuerDidDocument,
    );

    return proofExchange.sendPresentation(
      exchangeRecord: exchange,
      vpDocument: bundle.vpDocument,
      connection: connection,
      senderKey: senderKey,
      recipientKeyDid: recipientKeyDid,
      endpoint: endpoint,
      webSocket: flowSession.webSocket,
    );
  }

  /// Conecta, completa el handshake y abre sesión de flujo en un solo paso.
  Future<DidCommFlowSession> acceptInvitationWithFlowSession(
    Map<String, dynamic> invitation,
  ) async {
    final handshake = await establishConnection(
      invitation,
      keepWebSocketOpen: true,
    );
    return startFlowSession(handshake);
  }

  /// Lista todas las conexiones existentes.
  Future<List<ConnectionRecord>> getConnections() =>
      _connectionStore.getAll();

  /// Desencripta un mensaje DIDComm entrante (envelope Credo V1 / Authcrypt).
  ///
  /// Preferir [DidCommFlowSession] (WS abierto) en flujos emit/verify; este
  /// método sirve para inbound ad-hoc (push, polling, tests).
  ///
  /// Prueba las claves Ed25519 del store hasta encontrar el `kid` del envelope.
  Future<Map<String, dynamic>> handleIncomingMessage(
    String encryptedJson,
  ) async {
    final envelope = jsonDecode(encryptedJson) as Map<String, dynamic>;
    final keys = await _keyStore.getAll();
    final ed25519Keys = keys
        .where((k) => k.keyType == KeyType.ed25519 && k.privateJwk != null)
        .toList();
    if (ed25519Keys.isEmpty) {
      throw StateError(
        'No se encontró clave Ed25519 con privateJwk en el store',
      );
    }

    Object? lastError;
    for (final key in ed25519Keys) {
      try {
        return await DidCommEnvelopeV1.unpack(
          envelope: envelope,
          recipientEd25519PrivateJwk: key.privateJwk!,
          recipientEd25519PublicJwk: key.publicJwk,
        );
      } catch (e) {
        lastError = e;
      }
    }
    throw StateError('No se pudo desencriptar el mensaje DIDComm: $lastError');
  }

  Future<KeyRecord> _ed25519KeyForConnection(ConnectionRecord connection) async {
    final keys = await _keyStore.getAll();
    final match = keys.where(
      (k) =>
          k.keyType == KeyType.ed25519 &&
          k.did == connection.myDid &&
          k.privateJwk != null,
    );
    final key = match.isNotEmpty ? match.first : null;
    if (key != null) return key;

    throw StateError(
      'No se encontró clave Ed25519 para la conexión ${connection.connectionId}.',
    );
  }

  /// Resuelve el DID Document del issuer de la primera VC BBS seleccionada.
  ///
  /// Necesario para `DartBbsLdSuite` / bridge MATTR (clave pública BLS G2).
  Future<Map<String, dynamic>?> _resolveIssuerDidDocumentForBbs(
    Iterable<W3cCredentialRecord> credentials,
  ) async {
    for (final record in credentials) {
      final cred = record.credential;
      final proof = cred['proof'];
      final proofType = proof is Map ? proof['type'] as String? : null;
      if (proofType != kBbsProofType) continue;

      final issuerDid = _issuerDidFromCredential(cred);
      if (issuerDid == null || issuerDid.isEmpty) {
        throw StateError(
          'VC BBS sin issuer DID resoluble; no se puede derivar selective disclosure.',
        );
      }
      final doc = await _didService.resolve(issuerDid);
      if (doc == null) {
        throw StateError(
          'No se pudo resolver el DID Document del issuer BBS ($issuerDid).',
        );
      }
      return doc;
    }
    return null;
  }

  static String? _issuerDidFromCredential(Map<String, dynamic> credential) {
    final issuer = credential['issuer'];
    if (issuer is String) return issuer;
    if (issuer is Map) return issuer['id'] as String?;
    return null;
  }
}
