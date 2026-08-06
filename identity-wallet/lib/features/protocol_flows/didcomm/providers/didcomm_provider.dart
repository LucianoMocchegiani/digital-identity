import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../../core/errors/flow_error_message.dart';
import '../../../../core/providers/wallet_notifier.dart';
import '../../../credentials/mappers/credential_ui_mapper.dart';
import '../../../credentials/models/wallet_credential.dart';
import '../mappers/didcomm_credential_mapper.dart';

// — Estado del flujo —

/// Suma discriminada del flujo de invitación DIDComm en la pantalla de notificación.
sealed class DidCommFlowState {}

/// Invitación OOB resuelta: el usuario debe confirmar antes de conectar.
class DidCommVerifyPartyState extends DidCommFlowState {
  DidCommVerifyPartyState({required this.invitation, required this.flowType});
  final Map<String, dynamic> invitation;
  final DidCommFlowType flowType;
}

/// Handshake DID Exchange en curso.
class DidCommConnectingState extends DidCommFlowState {
  DidCommConnectingState({this.flowType});

  /// Tipo de flujo; en verify unifica el copy de carga con el waiting.
  final DidCommFlowType? flowType;
}

/// Conexión lista; esperando `offer-credential` o `request-presentation` por WS.
class DidCommWaitingProtocolState extends DidCommFlowState {
  DidCommWaitingProtocolState({
    required this.connection,
    required this.flowType,
    this.displayName,
  });

  final ConnectionRecord connection;
  final DidCommFlowType flowType;
  final String? displayName;
}

/// Offer DIDComm recibido; el usuario debe confirmar antes de solicitar la VC.
class DidCommCredentialOfferState extends DidCommFlowState {
  DidCommCredentialOfferState({
    required this.connection,
    required this.offerMessage,
    required this.preview,
    required this.claims,
    this.displayName,
  });

  final ConnectionRecord connection;
  final Map<String, dynamic> offerMessage;
  final WalletCredential preview;
  final List<LabeledClaim> claims;
  final String? displayName;
}

/// `request-credential` enviado; esperando `issue-credential`.
class DidCommAcquiringState extends DidCommFlowState {}

/// Solo conexión (sin emisión/verificación activa).
class DidCommSuccessState extends DidCommFlowState {
  DidCommSuccessState(this.connection, {this.displayName});
  final ConnectionRecord connection;
  final String? displayName;
}

/// Credencial W3C recibida y persistida.
class DidCommIssueSuccessState extends DidCommFlowState {
  DidCommIssueSuccessState(this.credential);
  final W3cCredentialRecord credential;
}

/// Solicitud de presentación resuelta; el usuario elige credenciales.
class DidCommPresentationSelectState extends DidCommFlowState {
  DidCommPresentationSelectState({
    required this.requestMessage,
    required this.presentationDefinitionJson,
    required this.challenge,
    required this.request,
    this.selected = const {},
    this.displayName,
  });

  final Map<String, dynamic> requestMessage;
  final Map<String, dynamic> presentationDefinitionJson;
  final String challenge;
  final CredentialsForRequest request;
  final Map<String, String> selected;
  final String? displayName;
}

/// Confirmación de share DIDComm (misma UI que OID4VP).
class DidCommPresentationShareState extends DidCommFlowState {
  DidCommPresentationShareState({
    required this.requestMessage,
    required this.presentationDefinitionJson,
    required this.challenge,
    required this.selectedByDescriptor,
    required this.preview,
    required this.claims,
    this.displayName,
  });

  final Map<String, dynamic> requestMessage;
  final Map<String, dynamic> presentationDefinitionJson;
  final String challenge;
  final Map<String, W3cCredentialRecord> selectedByDescriptor;
  final WalletCredential preview;
  final List<LabeledClaim> claims;
  final String? displayName;
}

/// Presentación enviada; esperando ack del verificador.
class DidCommPresentationSubmittingState extends DidCommFlowState {
  DidCommPresentationSubmittingState({required this.share});
  final DidCommPresentationShareState share;
}

/// Presentación aceptada (ack o timeout post-envío).
class DidCommPresentationSuccessState extends DidCommFlowState {
  DidCommPresentationSuccessState({required this.share});
  final DidCommPresentationShareState share;
}

/// Error de flujo con mensaje listo para UI.
class DidCommErrorState extends DidCommFlowState {
  DidCommErrorState(this.message);
  final String message;
}

// — Notifier —

/// Orquesta resolver una URL DIDComm, el handshake y la sesión WS activa.
class DidCommNotifier extends FamilyAsyncNotifier<DidCommFlowState, String> {
  DidCommFlowSession? _flowSession;
  StreamSubscription<DidCommFlowEvent>? _eventsSub;
  CredentialExchangeRecord? _pendingExchange;
  Map<String, dynamic>? _pendingOfferMessage;
  String? _issuerDisplayName;

  @override
  Future<DidCommFlowState> build(String url) async {
    ref.onDispose(_disposeFlow);
    final session = ref.read(walletNotifierProvider.notifier).session;
    final result = await session.invitation.resolve(url);
    switch (result) {
      case DidCommInvitationResult(:final invitation, :final flowType):
        // Emisión / verificación: sin pantalla “Conectar”; el consentimiento
        // es el sheet de oferta o el de compartir credenciales.
        if (flowType == DidCommFlowType.verify ||
            flowType == DidCommFlowType.issue) {
          Future.microtask(() => _autoConnect(invitation, flowType));
          return DidCommConnectingState(flowType: flowType);
        }
        return DidCommVerifyPartyState(
          invitation: invitation,
          flowType: flowType,
        );
      case InvitationErrorResult result:
        return DidCommErrorState(invitationErrorMessage(result));
      default:
        return DidCommErrorState(
          'La URL no corresponde a una invitación DIDComm.',
        );
    }
  }

  /// Handshake automático (issue / verify) sin slide de confirmación de parte.
  Future<void> _autoConnect(
    Map<String, dynamic> invitation,
    DidCommFlowType flowType,
  ) async {
    try {
      final next = await _connectAfterInvitation(invitation, flowType);
      state = AsyncData(next);
    } catch (e) {
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  /// Confirma la conexión (flujo `connect` con slide de parte).
  Future<void> acceptConnection() async {
    final current = state.valueOrNull;
    if (current is! DidCommVerifyPartyState) return;
    state = AsyncData(DidCommConnectingState(flowType: current.flowType));
    try {
      final next = await _connectAfterInvitation(
        current.invitation,
        current.flowType,
      );
      state = AsyncData(next);
    } catch (e) {
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  Future<DidCommFlowState> _connectAfterInvitation(
    Map<String, dynamic> invitation,
    DidCommFlowType flowType,
  ) async {
    final session = ref.read(walletNotifierProvider.notifier).session;
    final displayName = _displayNameFromInvitation(invitation);
    final flowSession =
        await session.didcomm.acceptInvitationWithFlowSession(invitation);
    _flowSession = flowSession;
    _listenEvents(flowSession, flowType, displayName);

    if (flowType == DidCommFlowType.connect) {
      return DidCommSuccessState(
        flowSession.connection,
        displayName: displayName,
      );
    }
    return DidCommWaitingProtocolState(
      connection: flowSession.connection,
      flowType: flowType,
      displayName: displayName,
    );
  }

  /// Confirma el offer y envía `request-credential`.
  Future<void> acceptCredentialOffer() async {
    final current = state.valueOrNull;
    if (current is! DidCommCredentialOfferState) return;

    state = AsyncData(DidCommAcquiringState());
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      _pendingExchange = await session.didcomm.sendCredentialRequest(
        flowSession: _flowSession!,
        offerMessage: current.offerMessage,
      );
    } catch (e) {
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  /// Confirma y envía la presentación DIDComm al verificador.
  Future<void> sharePresentation() async {
    final current = state.valueOrNull;
    if (current is! DidCommPresentationShareState) return;
    final flowSession = _flowSession;
    if (flowSession == null) {
      state = AsyncData(
        DidCommErrorState(
          'Se perdió la sesión con el verificador. Volvé a escanear el código QR.',
        ),
      );
      return;
    }

    state = AsyncData(DidCommPresentationSubmittingState(share: current));
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      await session.didcomm.sendPresentation(
        flowSession: flowSession,
        requestMessage: current.requestMessage,
        presentationDefinitionJson: current.presentationDefinitionJson,
        selectedByDescriptor: current.selectedByDescriptor,
        challenge: current.challenge,
      );

      // Esperar ack un rato; si no llega, el envío ya ocurrió → éxito.
      final deadline = DateTime.now().add(const Duration(seconds: 8));
      while (state.valueOrNull is DidCommPresentationSubmittingState &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (state.valueOrNull is DidCommPresentationSubmittingState) {
        await _disposeFlow();
        state = AsyncData(DidCommPresentationSuccessState(share: current));
      }
    } catch (e, st) {
      debugPrint('[DIDComm] sharePresentation error: $e\n$st');
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  /// Registra la credencial elegida para un requisito del PEX DIDComm.
  void selectCredential(String inputDescriptorId, String credentialId) {
    final current = state.valueOrNull;
    if (current is! DidCommPresentationSelectState) return;
    final isValidChoice = current.request.submission.entries.any(
      (entry) =>
          entry.inputDescriptorId == inputDescriptorId &&
          (entry.matchingCredentials?.any((c) => c.id == credentialId) ??
              false),
    );
    if (!isValidChoice) return;
    state = AsyncData(
      DidCommPresentationSelectState(
        requestMessage: current.requestMessage,
        presentationDefinitionJson: current.presentationDefinitionJson,
        challenge: current.challenge,
        request: current.request,
        selected: {...current.selected, inputDescriptorId: credentialId},
        displayName: current.displayName,
      ),
    );
  }

  /// Avanza a la confirmación de share con las credenciales elegidas.
  void confirmSelection() {
    final current = state.valueOrNull;
    if (current is! DidCommPresentationSelectState) return;

    final requiredIds = [
      for (final entry in current.request.submission.entries)
        if (entry.isSatisfied &&
            (entry.matchingCredentials?.isNotEmpty ?? false))
          entry.inputDescriptorId,
    ];
    if (requiredIds.isEmpty ||
        !requiredIds.every(current.selected.containsKey)) {
      return;
    }

    final selectedByDescriptor = <String, W3cCredentialRecord>{};
    for (final descriptorId in requiredIds) {
      final credentialId = current.selected[descriptorId]!;
      final entry = current.request.submission.entries.firstWhere(
        (e) => e.inputDescriptorId == descriptorId,
      );
      final record = entry.matchingCredentials
          ?.whereType<W3cCredentialRecord>()
          .where((c) => c.id == credentialId)
          .firstOrNull;
      if (record == null) return;
      selectedByDescriptor[descriptorId] = record;
    }

    final first = selectedByDescriptor.values.first;
    final preview = CredentialUiMapper.toWalletCredential(first);
    final allClaims = CredentialUiMapper.labeledClaimsFor(first, locale: 'es');
    final claims = filterClaimsByPresentationDefinition<LabeledClaim>(
      claims: allClaims,
      presentationDefinition: current.presentationDefinitionJson,
      claimKey: (c) => c.key,
    );

    state = AsyncData(
      DidCommPresentationShareState(
        requestMessage: current.requestMessage,
        presentationDefinitionJson: current.presentationDefinitionJson,
        challenge: current.challenge,
        selectedByDescriptor: selectedByDescriptor,
        preview: preview,
        claims: claims,
        displayName: current.displayName,
      ),
    );
  }

  /// Cancela el flujo y libera la sesión WS.
  Future<void> abandonFlow() async {
    await _disposeFlow();
  }

  void _listenEvents(
    DidCommFlowSession flowSession,
    DidCommFlowType flowType,
    String? displayName,
  ) {
    _eventsSub?.cancel();
    _eventsSub = flowSession.events.listen((event) async {
      switch (event) {
        case DidCommProtocolMessage(:final kind, :final message):
          await _onProtocolMessage(
            kind: kind,
            message: message,
            flowType: flowType,
            displayName: displayName,
          );
        case DidCommFlowError(:final error):
          await _disposeFlow();
          state = AsyncData(DidCommErrorState(formatFlowErrorMessage(error)));
        case DidCommFlowClosed():
          break;
      }
    });
  }

  Future<void> _onProtocolMessage({
    required DidCommProtocolMessageKind kind,
    required Map<String, dynamic> message,
    required DidCommFlowType flowType,
    String? displayName,
  }) async {
    switch (kind) {
      case DidCommProtocolMessageKind.credentialOffer:
        if (flowType == DidCommFlowType.verify) return;
        final connection = _flowSession?.connection;
        if (connection == null) return;
        state = AsyncData(
          DidCommCredentialOfferState(
            connection: connection,
            offerMessage: message,
            preview: DidCommCredentialMapper.previewFromOfferMessage(
              message,
              issuerLabel: displayName,
            ),
            claims: DidCommCredentialMapper.labeledClaimsFromOfferMessage(
              message,
            ),
            displayName: displayName,
          ),
        );
        _issuerDisplayName = displayName;
        _pendingOfferMessage = message;
      case DidCommProtocolMessageKind.issueCredential:
        await _onIssueCredential(message);
      case DidCommProtocolMessageKind.presentationRequest:
        // Se acepta también en flujo `connect`: invitaciones sin goal_code
        // caen ahí y el request-presentation define la intención real.
        if (flowType == DidCommFlowType.issue) return;
        await _onPresentationRequest(message, displayName);
      case DidCommProtocolMessageKind.presentationAck:
        if (flowType == DidCommFlowType.issue) return;
        final submitting = state.valueOrNull;
        final share = submitting is DidCommPresentationSubmittingState
            ? submitting.share
            : null;
        await _disposeFlow();
        if (share == null) {
          state = AsyncData(
            DidCommErrorState(
              'Presentación aceptada, pero se perdió el contexto de UI.',
            ),
          );
          return;
        }
        state = AsyncData(DidCommPresentationSuccessState(share: share));
      case DidCommProtocolMessageKind.problemReport:
        final description = message['description'];
        final reason = description is Map
            ? description['en'] as String? ??
                description.values.firstOrNull?.toString()
            : message['comment'] as String?;
        await _disposeFlow();
        state = AsyncData(
          DidCommErrorState(
            reason == null || reason.isEmpty
                ? 'El agente reportó un problema durante el flujo.'
                : 'El agente reportó un problema: $reason',
          ),
        );
      case DidCommProtocolMessageKind.unknown:
        break;
    }
  }

  Future<void> _onPresentationRequest(
    Map<String, dynamic> message,
    String? displayName,
  ) async {
    try {
      final pd = DidCommProofAttach.presentationDefinitionFromMessage(message);
      if (pd == null) {
        throw StateError('La solicitud no incluye presentation definition.');
      }

      final challenge =
          DidCommProofAttach.challengeFromMessage(message) ??
              'challenge-${DateTime.now().millisecondsSinceEpoch}';

      final walletSession = ref.read(walletNotifierProvider.notifier).session;
      final credentials = await walletSession.credentialStore.getAll();
      final submission = await DidCommPresentationBuilder.matchCredentials(
        presentationDefinitionJson: pd,
        credentials: credentials,
      );

      if (!submission.areAllSatisfied) {
        state = AsyncData(
          DidCommErrorState(
            'No tenés credenciales compatibles con esta solicitud.',
          ),
        );
        return;
      }

      final hasCandidates = submission.entries.any(
        (entry) =>
            entry.isSatisfied &&
            (entry.matchingCredentials?.isNotEmpty ?? false),
      );
      if (!hasCandidates) {
        state = AsyncData(
          DidCommErrorState('No se encontraron credenciales para presentar.'),
        );
        return;
      }

      // Misma UI de selección que OID4VP: sin preselección automática.
      state = AsyncData(
        DidCommPresentationSelectState(
          requestMessage: message,
          presentationDefinitionJson: pd,
          challenge: challenge,
          request: CredentialsForRequest(
            queryType: QueryType.pex,
            submission: submission,
            verifierClientId: displayName ?? 'didcomm-verifier',
            nonce: challenge,
            presentationDefinitionId: pd['id'] as String?,
          ),
          displayName: displayName,
        ),
      );
    } catch (e) {
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  Future<void> _onIssueCredential(Map<String, dynamic> message) async {
    final exchange = _pendingExchange;
    if (exchange == null) return;

    try {
      final walletSession = ref.read(walletNotifierProvider.notifier).session;
      await walletSession.didcomm.credentialExchange.handleIssueCredential(
        message: message,
        exchangeRecord: exchange,
      );

      final holderDid =
          (await walletSession.dids.getSigningDid(KeyType.ed25519)).did;
      final record = DidCommCredentialMapper.recordFromIssueMessage(
        message,
        holderDid: holderDid,
        offerAttach: exchange.offerAttach,
        offerMessage: _pendingOfferMessage,
        issuerLabel: _issuerDisplayName,
      );
      if (record == null) {
        throw StateError('No se pudo interpretar la credencial recibida.');
      }

      await walletSession.credentialStore.save(record);
      await _disposeFlow();
      state = AsyncData(DidCommIssueSuccessState(record));
    } catch (e) {
      await _disposeFlow();
      state = AsyncData(DidCommErrorState(formatFlowErrorMessage(e)));
    }
  }

  /// Nombre visible del peer: solo `label` OOB (no `goal`, que es el propósito).
  String? _displayNameFromInvitation(Map<String, dynamic> invitation) {
    final label = invitation['label'] as String?;
    if (label != null && label.trim().isNotEmpty) return label.trim();
    return null;
  }

  Future<void> _disposeFlow() async {
    await _eventsSub?.cancel();
    _eventsSub = null;
    await _flowSession?.dispose();
    _flowSession = null;
    _pendingExchange = null;
    _pendingOfferMessage = null;
    _issuerDisplayName = null;
  }
}

final didCommNotifierProvider =
    AsyncNotifierProvider.family<DidCommNotifier, DidCommFlowState, String>(
  DidCommNotifier.new,
);
