import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../credentials/models/wallet_credential.dart';
import '../../credentials/providers/credential_ux_provider.dart';
import '../oid4vci/slides/add_credential_sheet.dart';
import '../oid4vp/slides/select_credentials_slide.dart';
import 'providers/didcomm_provider.dart';
import 'slides/didcomm_share_presentation_sheet.dart';
import 'slides/verify_party_slide.dart';

/// Pantalla modal de flujo DIDComm al abrir un deeplink de invitación.
///
/// La ruta es transparente (`opaque: false`): los sheets y el modal de éxito
/// se componen sobre home/cámara, igual que OID4VCI/OID4VP.
class DidCommNotificationScreen extends ConsumerWidget {
  const DidCommNotificationScreen({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(didCommNotifierProvider(url));
    final notifier = ref.read(didCommNotifierProvider(url).notifier);

    Future<void> cancel() async {
      await notifier.abandonFlow();
      if (context.mounted) context.popOrGoHome();
    }

    void doneInbox() => context.go('/home/inbox');
    void doneHome() => context.go('/home');

    // Ids favoritos para el tab "Favoritas" del selector (mismo que OID4VP).
    final favoriteIds = {
      for (final entry in ref.watch(credentialUxMapProvider).entries)
        if (entry.value.isFavorite) entry.key,
    };

    const connectErrorTitle = 'Error al conectar';

    final slide = async.when(
      loading: () => const FlowProgressView(message: 'Verificando...'),
      error: (e, _) => FlowErrorModalLauncher(
        title: connectErrorTitle,
        description: e.toString(),
        onClose: cancel,
      ),
      data: (flowState) => switch (flowState) {
        DidCommVerifyPartyState(:final invitation, :final flowType) =>
          VerifyPartySlide(
            invitation: invitation,
            flowType: flowType,
            onAccept: notifier.acceptConnection,
            onCancel: cancel,
          ),
        // Issue: carga unificada como OID4VCI (“Verificando oferta…”).
        DidCommConnectingState(flowType: DidCommFlowType.issue) ||
        DidCommWaitingProtocolState(flowType: DidCommFlowType.issue) =>
          const FlowProgressView(message: 'Verificando oferta...'),
        // Verify: carga unificada como OID4VP (“Verificando solicitud…”).
        DidCommConnectingState(flowType: DidCommFlowType.verify) ||
        DidCommWaitingProtocolState(flowType: DidCommFlowType.verify) =>
          const FlowProgressView(message: 'Verificando solicitud...'),
        DidCommConnectingState() =>
          const FlowProgressView(message: 'Estableciendo conexión...'),
        DidCommWaitingProtocolState(:final displayName) =>
          FlowProgressView(
            message:
                'Conexión lista. Esperando mensaje de ${displayName ?? 'el agente'}...',
          ),
        DidCommCredentialOfferState(:final preview, :final claims) =>
          _CredentialOfferSheet(
            credential: preview,
            claims: claims,
            onReject: cancel,
            onAccept: notifier.acceptCredentialOffer,
          ),
        DidCommAcquiringState() => const Scaffold(
            backgroundColor: Colors.transparent,
            body: CredentialLoadingOverlay(),
          ),
        DidCommSuccessState(:final connection, :final displayName) =>
          FlowSuccessModalLauncher(
            title: 'Conexión establecida',
            description: _connectionSuccessDescription(
              connection: connection,
              displayName: displayName,
            ),
            onDone: doneInbox,
          ),
        DidCommIssueSuccessState() => FlowSuccessModalLauncher(
            title: 'Credencial verificada y almacenada',
            description: 'La credencial fue incorporada exitosamente a tu wallet '
                'y ya está disponible para usar.',
            onDone: doneHome,
          ),
        DidCommPresentationSelectState(:final request, :final selected) =>
          SelectCredentialsSlide(
            request: request,
            selected: selected,
            favoriteIds: favoriteIds,
            onSelect: notifier.selectCredential,
            onContinue: notifier.confirmSelection,
            onCancel: cancel,
          ),
        DidCommPresentationShareState() ||
        DidCommPresentationSubmittingState() ||
        DidCommPresentationSuccessState() =>
          _PresentationFlowStack(
            state: flowState,
            onShare: () {
              notifier.sharePresentation();
            },
            onCancel: cancel,
            onDone: doneHome,
          ),
        DidCommErrorState(:final message) => FlowErrorModalLauncher(
            title: connectErrorTitle,
            description: message,
            onClose: cancel,
          ),
      },
    );

    final flowState = async.valueOrNull;
    final blockPop = flowState is DidCommConnectingState ||
        flowState is DidCommWaitingProtocolState ||
        flowState is DidCommAcquiringState ||
        flowState is DidCommPresentationSubmittingState;

    return PopScope(
      canPop: !blockPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          notifier.abandonFlow();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_slideKey(async)), child: slide),
      ),
    );
  }
}

String _slideKey(AsyncValue<DidCommFlowState> async) {
  return async.when(
    loading: () => 'loading',
    error: (_, __) => 'error',
    data: (state) => switch (state) {
      DidCommVerifyPartyState() => 'verify',
      DidCommConnectingState(flowType: DidCommFlowType.issue) ||
      DidCommWaitingProtocolState(flowType: DidCommFlowType.issue) =>
        'issue-preparing',
      DidCommConnectingState(flowType: DidCommFlowType.verify) ||
      DidCommWaitingProtocolState(flowType: DidCommFlowType.verify) =>
        'verify-preparing',
      DidCommConnectingState() => 'connecting',
      DidCommWaitingProtocolState() => 'waiting',
      DidCommCredentialOfferState() => 'offer',
      DidCommAcquiringState() => 'acquiring',
      DidCommSuccessState() => 'success-connect',
      DidCommIssueSuccessState() => 'success-issue',
      DidCommPresentationSelectState() => 'presentation-select',
      DidCommPresentationShareState() ||
      DidCommPresentationSubmittingState() ||
      DidCommPresentationSuccessState() =>
        'presentation-flow',
      DidCommErrorState() => 'error-flow',
    },
  );
}

String _connectionSuccessDescription({
  required ConnectionRecord connection,
  String? displayName,
}) {
  final name = displayName?.trim().isNotEmpty == true
      ? displayName!.trim()
      : connection.label?.trim().isNotEmpty == true
          ? connection.label!.trim()
          : null;
  if (name != null) return 'Conectado con $name.';
  return 'La conexión DIDComm quedó lista.';
}

/// Mantiene el sheet de compartir visible y superpone carga o éxito encima.
class _PresentationFlowStack extends StatelessWidget {
  const _PresentationFlowStack({
    required this.state,
    required this.onShare,
    required this.onCancel,
    required this.onDone,
  });

  final DidCommFlowState state;
  final VoidCallback onShare;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  DidCommPresentationShareState get _share => switch (state) {
        DidCommPresentationShareState share => share,
        DidCommPresentationSubmittingState(:final share) => share,
        DidCommPresentationSuccessState(:final share) => share,
        _ => throw StateError(
            'Estado inesperado en _PresentationFlowStack: $state',
          ),
      };

  bool get _interactive => state is DidCommPresentationShareState;

  @override
  Widget build(BuildContext context) {
    final share = _share;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: !_interactive,
          child: DidCommSharePresentationSheet(
            credential: share.preview,
            claims: share.claims,
            onReject: onCancel,
            onAccept: onShare,
          ),
        ),
        if (state is DidCommPresentationSubmittingState)
          const CredentialLoadingOverlay(
            title: 'Enviando credenciales...',
            description:
                'Aguarde unos instantes. Estamos compartiendo los datos con el verificador.',
          ),
        if (state is DidCommPresentationSuccessState)
          FlowSuccessModalLauncher(
            title: 'Credenciales compartidas',
            description: 'La verificación se completó correctamente. '
                'El verificador recibió los datos solicitados.',
            onDone: onDone,
          ),
      ],
    );
  }
}

class _CredentialOfferSheet extends StatelessWidget {
  const _CredentialOfferSheet({
    required this.credential,
    required this.claims,
    required this.onReject,
    required this.onAccept,
  });

  final WalletCredential credential;
  final List<LabeledClaim> claims;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return FlowSheetScaffold(
      sheet: AddCredentialSheet(
        credential: credential,
        claims: claims,
        onReject: onReject,
        onAccept: onAccept,
      ),
    );
  }
}
