import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../core/errors/flow_error_message.dart';
import '../../../core/providers/onboarding_progress_notifier.dart';
import '../../credentials/mappers/credential_ui_mapper.dart';
import '../../credentials/models/wallet_credential.dart';
import 'providers/oid4vci_provider.dart';
import 'slides/add_credential_sheet.dart';
import 'slides/auth_code_browser_slide.dart';
import 'slides/tx_code_slide.dart';

/// Pantalla contenedora del flujo de emisión **OID4VCI** a partir de una URL de oferta.
///
/// Observa [oid4vciNotifierProvider] con [url] como parámetro de familia (una instancia
/// de [Oid4VciNotifier] por oferta). Con [WidgetRef.watch] reconstruye la UI ante cambios
/// de `AsyncValue`; con [WidgetRef.read] obtiene el notifier para
/// [Oid4VciNotifier.confirmIssuer] y [Oid4VciNotifier.accept] sin suscripción extra.
///
/// Mapea cada subtipo de [Oid4VciFlowState] a un slide; en `loading` y errores usa
/// [FlowProgressView] y [FlowErrorModalLauncher] de `shared`. El cierre usa extensiones de
/// `go_router` sobre [BuildContext]: pop si la pila lo permite, si no navegación a `/home`.
///
/// Durante [Oid4VciAcquiringState] y [Oid4VciAuthCodeBrowserState] envuelve el contenido
/// en [PopScope] con `canPop: false` para evitar salidas accidentales.
class Oid4VciNotificationScreen extends ConsumerWidget {
  const Oid4VciNotificationScreen({super.key, required this.url});

  /// URI original de la oferta (mismo string que el query `url` en la ruta de notificación).
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(oid4vciNotifierProvider(url));
    final notifier = ref.read(oid4vciNotifierProvider(url).notifier);

    void cancel() => context.popOrGoHome();

    Future<void> done() async {
      if (!isOnboardingComplete(ref.read(onboardingProgressNotifierProvider))) {
        await ref.read(onboardingProgressNotifierProvider.notifier).markComplete();
      }
      if (context.mounted) context.go('/home');
    }

    const errorTitle = 'No se pudo obtener la credencial';

    void confirmAndAccept() {
      notifier.confirmIssuer();
      notifier.accept();
    }

    final slide = async.when(
      loading: () => const FlowProgressView(message: 'Verificando oferta...'),
      error: (e, _) => FlowErrorModalLauncher(
        title: errorTitle,
        description: formatFlowErrorMessage(e),
        onClose: cancel,
      ),
      data: (flowState) => switch (flowState) {
        Oid4VciVerifyIssuerState(:final offer) => _ConfirmSheetScaffold(
            credential: CredentialUiMapper.fromResolvedOffer(offer),
            claims: CredentialUiMapper.labeledClaimsFromOffer(offer),
            onReject: cancel,
            onAccept: confirmAndAccept,
          ),
        Oid4VciPreviewState(:final offer) => _ConfirmSheetScaffold(
            credential: CredentialUiMapper.fromResolvedOffer(offer),
            claims: CredentialUiMapper.labeledClaimsFromOffer(offer),
            onReject: cancel,
            onAccept: () => notifier.accept(),
          ),
        Oid4VciAuthCodeBrowserState(:final prepared) => AuthCodeBrowserSlide(
            prepared: prepared,
            onRedirect: notifier.completeAuthCode,
            onCancel: cancel,
          ),
        Oid4VciTxCodeState(:final offer) => TxCodeSlide(
            offer: offer,
            onConfirm: (code) => notifier.accept(txCode: code),
            onCancel: cancel,
          ),
        Oid4VciAcquiringState() => const Scaffold(
            backgroundColor: Colors.transparent,
            body: CredentialLoadingOverlay(),
          ),
        Oid4VciSuccessState() => FlowSuccessModalLauncher(
            title: 'Credencial verificada y almacenada',
            description: 'La credencial fue incorporada exitosamente a tu wallet y '
                'ya está disponible para usar.',
            onDone: done,
          ),
        Oid4VciErrorState(:final message, :final offer) when offer != null =>
          _ConfirmErrorStack(
            offer: offer,
            errorTitle: errorTitle,
            message: message,
            onClose: cancel,
          ),
        Oid4VciErrorState(:final message) => FlowErrorModalLauncher(
            title: errorTitle,
            description: message,
            onClose: cancel,
          ),
      },
    );

    final isAcquiring = async.valueOrNull is Oid4VciAcquiringState;
    final isAuthBrowser = async.valueOrNull is Oid4VciAuthCodeBrowserState;

    return PopScope(
      canPop: !isAcquiring && !isAuthBrowser,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_slideKey(async)), child: slide),
      ),
    );
  }
}

String _slideKey(AsyncValue<Oid4VciFlowState> async) {
  return async.when(
    loading: () => 'loading',
    error: (e, _) => 'error:${e.runtimeType}',
    data: (state) => switch (state) {
      Oid4VciVerifyIssuerState() || Oid4VciPreviewState() => 'confirm',
      Oid4VciErrorState(:final offer) when offer != null => 'confirm',
      _ => state.runtimeType.toString(),
    },
  );
}

/// Aloja el [AddCredentialSheet] anclado abajo sobre un velo oscuro.
class _ConfirmSheetScaffold extends StatelessWidget {
  const _ConfirmSheetScaffold({
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

/// Mantiene el sheet de confirmación visible bajo el modal de error.
class _ConfirmErrorStack extends StatelessWidget {
  const _ConfirmErrorStack({
    required this.offer,
    required this.errorTitle,
    required this.message,
    required this.onClose,
  });

  final ResolvedCredentialOffer offer;
  final String errorTitle;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: _ConfirmSheetScaffold(
            credential: CredentialUiMapper.fromResolvedOffer(offer),
            claims: CredentialUiMapper.labeledClaimsFromOffer(offer),
            onReject: () {},
            onAccept: () {},
          ),
        ),
        FlowErrorModalLauncher(
          title: errorTitle,
          description: message,
          onClose: onClose,
        ),
      ],
    );
  }
}

