import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../../core/errors/flow_error_message.dart';
import '../../../../core/providers/wallet_notifier.dart';

// — Estado del flujo —

/// Suma discriminada del flujo **OID4VP** (elegir datos → enviar → resultado).
///
/// Consumida por [Oid4VpNotificationScreen] con `switch` exhaustivo sobre subtipos.
/// La pantalla intermedia de “verificar verifier” quedó fuera del camino feliz:
/// tras resolver se entra directo en [Oid4VpSelectCredentialsState].

sealed class Oid4VpFlowState {}

/// Solicitud resuelta: el usuario debe revisar al verificador antes de compartir datos.

class Oid4VpVerifyVerifierState extends Oid4VpFlowState {
  Oid4VpVerifyVerifierState(this.request);

  /// Solicitud de presentación y credenciales candidatas según identity-core.
  final CredentialsForRequest request;
}

/// Selección de credenciales: el usuario elige qué credencial satisface cada
/// requisito del verificador antes de confirmar qué datos se comparten.

class Oid4VpSelectCredentialsState extends Oid4VpFlowState {
  Oid4VpSelectCredentialsState({required this.request, this.selected = const {}});

  /// Misma solicitud que en [Oid4VpVerifyVerifierState].
  final CredentialsForRequest request;

  /// Por cada `inputDescriptorId`, id de la credencial elegida hasta ahora.
  /// Arranca vacío: no hay preselección (el usuario elige explícitamente).
  final Map<String, String> selected;
}

/// Vista de confirmación: credenciales y claims seleccionados para enviar al verificador.

class Oid4VpShareState extends Oid4VpFlowState {
  Oid4VpShareState({
    required this.request,
    required this.selectedCredentials,
    required this.selectedDisclosures,
  });

  /// Misma solicitud que en [Oid4VpVerifyVerifierState].
  final CredentialsForRequest request;

  /// Por cada `inputDescriptorId`, id de la credencial elegida para satisfacer el requisito.
  final Map<String, String> selectedCredentials;

  /// Por cada `inputDescriptorId`, rutas de claims (`requestedClaimPaths`) que se revelarán.
  final Map<String, List<String>> selectedDisclosures;
}

/// Envío de la presentación al verificador en curso ([Oid4VpNotifier.share]).

class Oid4VpSubmittingState extends Oid4VpFlowState {
  Oid4VpSubmittingState(this.share);

  /// Vista de confirmación que permanece visible bajo el overlay de carga.
  final Oid4VpShareState share;
}

/// El verificador aceptó la presentación ([OpenId4VpService.shareCredentials] con éxito).

class Oid4VpSuccessState extends Oid4VpFlowState {
  Oid4VpSuccessState(this.share);

  /// Vista de confirmación que permanece visible bajo el modal de éxito.
  final Oid4VpShareState share;
}

/// Error al resolver la URL, requisitos no satisfechos o rechazo del verificador.

class Oid4VpErrorState extends Oid4VpFlowState {
  Oid4VpErrorState(this.message, {this.share});

  /// Mensaje para mostrar en UI (excepción o texto de negocio).
  final String message;

  /// Vista de confirmación visible bajo el modal cuando el error ocurre al compartir.
  final Oid4VpShareState? share;
}

// — Notifier —

/// Orquesta la presentación **OID4VP** desde la URL de la solicitud.
///
/// [AutoDisposeFamilyAsyncNotifier] parametrizado por [url] (query `?url=` en la ruta de notificación).
/// En [build] usa [WalletNotifier.session] y [OpenId4VpService.resolveRequest]: si
/// `submission.areAllSatisfied` es falso devuelve [Oid4VpErrorState]; si no,
/// [Oid4VpSelectCredentialsState] (sin paso de confirmación del verifier).
///
/// [confirmVerifier] queda por compatibilidad si el estado legado aparece;
/// [selectCredential] registra la elección por descriptor y [confirmSelection]
/// avanza a [Oid4VpShareState] cuando todos los requisitos tienen credencial,
/// derivando disclosures de [CredentialsForRequest.submission].
///
/// [share] solo desde [Oid4VpShareState]: pone [Oid4VpSubmittingState], llama a
/// [OpenId4VpService.shareCredentials] y según el resultado [Oid4VpSuccessState] o
/// [Oid4VpErrorState]. Los fallos de red o excepción también se registran con [debugPrint].

class Oid4VpNotifier
    extends AutoDisposeFamilyAsyncNotifier<Oid4VpFlowState, String> {
  @override
  Future<Oid4VpFlowState> build(String url) async {
    final session = ref.read(walletNotifierProvider.notifier).session;
    try {
      final request = await session.openid4vp.resolveRequest(url);
      if (!request.submission.areAllSatisfied) {
        return Oid4VpErrorState(
          'No tenés las credenciales requeridas para esta solicitud.',
        );
      }
      // Sin pantalla intermedia de “verificar verifier”: el consentimiento
      // explícito es elegir qué credenciales compartir.
      return Oid4VpSelectCredentialsState(request: request);
    } catch (e) {
      return Oid4VpErrorState(formatFlowErrorMessage(e));
    }
  }

  void confirmVerifier() {
    final current = state.valueOrNull;
    if (current is! Oid4VpVerifyVerifierState) return;
    state = AsyncData(Oid4VpSelectCredentialsState(request: current.request));
  }

  /// Registra la credencial elegida para un requisito ([inputDescriptorId]).
  ///
  /// Solo válido en [Oid4VpSelectCredentialsState]; reemplaza la selección
  /// previa del mismo descriptor. Ignora combinaciones que no correspondan a
  /// una credencial candidata real de ese descriptor (defensa ante ids inválidos).
  void selectCredential(String inputDescriptorId, String credentialId) {
    final current = state.valueOrNull;
    if (current is! Oid4VpSelectCredentialsState) return;
    // Guardia: la credencial debe figurar entre las candidatas del descriptor.
    final isValidChoice = current.request.submission.entries.any(
      (entry) =>
          entry.inputDescriptorId == inputDescriptorId &&
          (entry.matchingCredentials?.any((c) => c.id == credentialId) ?? false),
    );
    if (!isValidChoice) return;
    state = AsyncData(
      Oid4VpSelectCredentialsState(
        request: current.request,
        selected: {...current.selected, inputDescriptorId: credentialId},
      ),
    );
  }

  /// Avanza a [Oid4VpShareState] con las credenciales elegidas.
  ///
  /// No hace nada si algún requisito satisfacible aún no tiene selección
  /// (la UI deshabilita el botón, esto es defensa adicional).
  void confirmSelection() {
    final current = state.valueOrNull;
    if (current is! Oid4VpSelectCredentialsState) return;
    final requiredIds = [
      for (final entry in current.request.submission.entries)
        if (entry.isSatisfied && (entry.matchingCredentials?.isNotEmpty ?? false))
          entry.inputDescriptorId,
    ];
    if (!requiredIds.every(current.selected.containsKey)) return;
    state = AsyncData(
      Oid4VpShareState(
        request: current.request,
        selectedCredentials: Map.unmodifiable(current.selected),
        selectedDisclosures: _buildSelectedDisclosures(current.request),
      ),
    );
  }

  Future<void> share() async {
    final current = state.valueOrNull;
    if (current is! Oid4VpShareState) return;

    state = AsyncData(Oid4VpSubmittingState(current));
    final started = DateTime.now();
    const minVisible = Duration(milliseconds: 1200);
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      final result = await session.openid4vp.shareCredentials(
        resolvedRequest: current.request,
        selectedCredentials: current.selectedCredentials,
        selectedDisclosures: current.selectedDisclosures,
      );
      final elapsed = DateTime.now().difference(started);
      if (elapsed < minVisible) {
        await Future.delayed(minVisible - elapsed);
      }
      if (result.success) {
        state = AsyncData(Oid4VpSuccessState(current));
      } else {
        state = AsyncData(
          Oid4VpErrorState(
            result.error ?? 'El verificador rechazó la presentación.',
            share: current,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('OID4VP share() error: $e\n$st');
      state = AsyncData(
        Oid4VpErrorState(formatFlowErrorMessage(e), share: current),
      );
    }
  }

  // — helpers —

  /// Construye el mapa descriptor → rutas de claims a revelar según la solicitud.
  Map<String, List<String>> _buildSelectedDisclosures(CredentialsForRequest request) {
    return {
      for (final entry in request.submission.entries)
        if (entry.requestedClaimPaths != null)
          entry.inputDescriptorId: entry.requestedClaimPaths!,
    };
  }
}

/// Provider familiar: una instancia de [Oid4VpNotifier] por [url] de solicitud OID4VP.
///
/// Consumido por [Oid4VpNotificationScreen] como `oid4vpNotifierProvider(url)`.
///
/// `autoDispose`: al cerrarse la pantalla del flujo (sin listeners) el notifier
/// se descarta, de modo que reingresar a la misma URL reinicia el flujo desde
/// el verificador en vez de reusar un estado terminal (compartido/error) previo.

final oid4vpNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<Oid4VpNotifier, Oid4VpFlowState, String>(
  Oid4VpNotifier.new,
);
