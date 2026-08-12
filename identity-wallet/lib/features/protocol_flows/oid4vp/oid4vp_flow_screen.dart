import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../core/errors/flow_error_message.dart';
import '../../categories/providers/categories_provider.dart';
import 'providers/oid4vp_provider.dart';
import 'slides/select_credentials_slide.dart';
import 'slides/share_credentials_slide.dart';
import 'slides/verify_verifier_slide.dart';

/// Pantalla contenedora del flujo de presentación **OID4VP** desde una URL de solicitud.
///
/// Observa [oid4vpNotifierProvider] con [url] como parámetro de familia. Con [WidgetRef.watch]
/// reconstruye la UI ante cambios de `AsyncValue`; con [WidgetRef.read] obtiene el notifier
/// para [Oid4VpNotifier.confirmVerifier], [Oid4VpNotifier.selectCredential],
/// [Oid4VpNotifier.confirmSelection] y [Oid4VpNotifier.share].
///
/// Mapea cada subtipo de [Oid4VpFlowState] a un slide ([SelectCredentialsSlide] →
/// [ShareCredentialsSlide], [CredentialLoadingOverlay] al enviar, etc.); errores y
/// carga inicial con [FlowErrorModalLauncher] y [FlowProgressView].
/// El cierre usa extensiones de
/// `go_router` sobre [BuildContext]: pop si la pila lo permite, si no navegación a `/home`.
///
/// Durante [Oid4VpSubmittingState] envuelve el contenido en [PopScope] con `canPop: false`
/// para evitar salidas accidentales mientras se envía la presentación.
class Oid4VpNotificationScreen extends ConsumerWidget {
  const Oid4VpNotificationScreen({super.key, required this.url});

  /// URI original de la solicitud (mismo string que el query `url` en la ruta de notificación).
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(oid4vpNotifierProvider(url));
    final notifier = ref.read(oid4vpNotifierProvider(url).notifier);

    final categories = ref.watch(walletCategoriesProvider);

    void cancel() => context.popOrGoHome();
    void done() => context.go('/home');

    const errorTitle = 'No se pudo verificar';

    final slide = async.when(
      loading: () => const FlowProgressView(message: 'Verificando solicitud...'),
      error: (e, _) => FlowErrorModalLauncher(
        title: errorTitle,
        description: formatFlowErrorMessage(e),
        onClose: cancel,
      ),
      data: (flowState) => switch (flowState) {
        Oid4VpVerifyVerifierState(:final request) => VerifyVerifierSlide(
            request: request,
            onContinue: notifier.confirmVerifier,
            onCancel: cancel,
          ),
        Oid4VpSelectCredentialsState(:final request, :final selected) =>
          SelectCredentialsSlide(
            request: request,
            selected: selected,
            categories: categories,
            onSelect: notifier.selectCredential,
            onContinue: notifier.confirmSelection,
            onCancel: cancel,
          ),
        Oid4VpShareState() ||
        Oid4VpSubmittingState() ||
        Oid4VpSuccessState() =>
          _ShareFlowStack(
            state: flowState,
            errorTitle: errorTitle,
            onShare: notifier.share,
            onCancel: cancel,
            onDone: done,
          ),
        Oid4VpErrorState(:final share) when share != null =>
          _ShareFlowStack(
            state: flowState,
            errorTitle: errorTitle,
            onShare: notifier.share,
            onCancel: cancel,
            onDone: done,
          ),
        Oid4VpErrorState(:final message) => FlowErrorModalLauncher(
            title: errorTitle,
            description: message,
            onClose: cancel,
          ),
      },
    );

    final isSubmitting = async.valueOrNull is Oid4VpSubmittingState;

    return PopScope(
      canPop: !isSubmitting,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_slideKey(async)), child: slide),
      ),
    );
  }
}

String _slideKey(AsyncValue<Oid4VpFlowState> async) {
  return async.when(
    loading: () => 'loading',
    error: (e, _) => 'error:${e.runtimeType}',
    data: (state) => switch (state) {
      Oid4VpShareState() ||
      Oid4VpSubmittingState() ||
      Oid4VpSuccessState() =>
        'share-flow',
      Oid4VpErrorState(:final share) when share != null => 'share-flow',
      // Key constante entre selecciones: conserva búsqueda/filtro del slide.
      Oid4VpSelectCredentialsState() => 'select-credentials',
      _ => state.runtimeType.toString(),
    },
  );
}

/// Mantiene [ShareCredentialsSlide] visible y superpone carga, éxito o error encima.
class _ShareFlowStack extends StatelessWidget {
  const _ShareFlowStack({
    required this.state,
    required this.errorTitle,
    required this.onShare,
    required this.onCancel,
    required this.onDone,
  });

  final Oid4VpFlowState state;
  final String errorTitle;
  final VoidCallback onShare;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  Oid4VpShareState get _share => switch (state) {
        Oid4VpShareState share => share,
        Oid4VpSubmittingState(:final share) => share,
        Oid4VpSuccessState(:final share) => share,
        Oid4VpErrorState(:final share) when share != null => share,
        _ => throw StateError('Estado inesperado en _ShareFlowStack: $state'),
      };

  bool get _interactive => state is Oid4VpShareState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: !_interactive,
          child: ShareCredentialsSlide(
            request: _share.request,
            selectedCredentials: _share.selectedCredentials,
            selectedDisclosures: _share.selectedDisclosures,
            onShare: onShare,
            onCancel: onCancel,
          ),
        ),
        if (state is Oid4VpSubmittingState)
          const CredentialLoadingOverlay(
            title: 'Enviando credenciales...',
            description:
                'Aguarde unos instantes. Estamos compartiendo los datos con el verificador.',
          ),
        if (state is Oid4VpSuccessState)
          FlowSuccessModalLauncher(
            title: 'Credenciales compartidas',
            description: 'La verificación se completó correctamente. '
                'El verificador recibió los datos solicitados.',
            onDone: onDone,
          ),
        if (state case Oid4VpErrorState(:final message))
          FlowErrorModalLauncher(
            title: errorTitle,
            description: message,
            onClose: onCancel,
          ),
      ],
    );
  }
}
