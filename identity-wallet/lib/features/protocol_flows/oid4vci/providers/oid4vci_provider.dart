import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../../core/errors/flow_error_message.dart';
import '../../../../core/oauth/oid4vci_redirect.dart';
import '../../../../core/providers/wallet_notifier.dart';
import '../../../credentials/mappers/credential_ui_mapper.dart';

// — Estado del flujo —

/// Suma discriminada del flujo OID4VCI (oferta → vista previa → emisión → resultado).
///
/// Consumida por [Oid4VciNotificationScreen] con `switch` exhaustivo sobre subtipos.

sealed class Oid4VciFlowState {}

/// Oferta resuelta: el usuario debe confirmar el emisor antes de continuar.

class Oid4VciVerifyIssuerState extends Oid4VciFlowState {
  Oid4VciVerifyIssuerState(this.offer);
  final ResolvedCredentialOffer offer;
}

/// Vista previa de la oferta antes de solicitar la credencial al issuer.

class Oid4VciPreviewState extends Oid4VciFlowState {
  Oid4VciPreviewState(this.offer);
  final ResolvedCredentialOffer offer;
}

/// Browser/WebView con el authorization endpoint del issuer (authorization_code).

class Oid4VciAuthCodeBrowserState extends Oid4VciFlowState {
  Oid4VciAuthCodeBrowserState(this.prepared);
  final PreparedAuthCodeFlow prepared;
}

/// El flujo exige código de transacción ([Oid4VciFlow.preAuthWithTxCode]) y aún no se ingresó.

class Oid4VciTxCodeState extends Oid4VciFlowState {
  Oid4VciTxCodeState(this.offer);
  final ResolvedCredentialOffer offer;
}

/// Llamada en curso a [Oid4VciService.acquireCredentials].

class Oid4VciAcquiringState extends Oid4VciFlowState {}

/// Credenciales emitidas y persistidas en el wallet.

class Oid4VciSuccessState extends Oid4VciFlowState {
  Oid4VciSuccessState(this.credentials);
  final List<CredentialRecord> credentials;
}

/// Error al resolver la URL o al adquirir la credencial.

class Oid4VciErrorState extends Oid4VciFlowState {
  Oid4VciErrorState(this.message, {this.offer});

  final String message;

  /// Oferta asociada para mantener el sheet de confirmación bajo el modal de error.
  final ResolvedCredentialOffer? offer;
}

// — Notifier —

/// Orquesta la emisión OID4VCI desde una URL de oferta.

class Oid4VciNotifier extends FamilyAsyncNotifier<Oid4VciFlowState, String> {
  @override
  Future<Oid4VciFlowState> build(String url) async {
    final session = ref.read(walletNotifierProvider.notifier).session;
    final result = await session.invitation.resolve(url);
    switch (result) {
      case Oid4VciInvitationResult(:final offer):
        return Oid4VciVerifyIssuerState(offer);
      case InvitationErrorResult result:
        return Oid4VciErrorState(invitationErrorMessage(result));
      default:
        return Oid4VciErrorState('La URL no corresponde a una oferta de credencial.');
    }
  }

  void confirmIssuer() {
    final current = state.valueOrNull;
    if (current is! Oid4VciVerifyIssuerState) return;
    state = AsyncData(Oid4VciPreviewState(current.offer));
  }

  Future<void> accept({String? txCode}) async {
    final current = state.valueOrNull;
    ResolvedCredentialOffer? offer;

    if (current is Oid4VciPreviewState) {
      offer = current.offer;
      if (offer.flow == Oid4VciFlow.authCode) {
        await _startAuthCodeFlow(offer);
        return;
      }
      if (offer.flow == Oid4VciFlow.preAuthWithTxCode && txCode == null) {
        state = AsyncData(Oid4VciTxCodeState(offer));
        return;
      }
    } else if (current is Oid4VciTxCodeState) {
      offer = current.offer;
    } else {
      return;
    }

    await _acquirePreAuthorized(offer, txCode: txCode);
  }

  /// Completa el flujo tras el redirect OAuth desde la WebView del issuer.
  Future<void> completeAuthCode(String callbackUri) async {
    final current = state.valueOrNull;
    if (current is! Oid4VciAuthCodeBrowserState) return;

    final prepared = current.prepared;
    if (!isOid4VciAuthRedirect(
      callbackUri: callbackUri,
      redirectUri: prepared.redirectUri,
    )) {
      return;
    }

    final parsed = parseOid4VciAuthRedirect(callbackUri);
    if (parsed.error != null) {
      state = AsyncData(
        Oid4VciErrorState(
          parsed.errorDescription ?? parsed.error ?? 'Autorización rechazada.',
          offer: prepared.resolvedOffer,
        ),
      );
      return;
    }
    if (parsed.state != prepared.state) {
      state = AsyncData(
        Oid4VciErrorState('State OAuth inválido.', offer: prepared.resolvedOffer),
      );
      return;
    }
    final code = parsed.code;
    if (code == null || code.isEmpty) {
      state = AsyncData(
        Oid4VciErrorState(
          'No se recibió authorization code.',
          offer: prepared.resolvedOffer,
        ),
      );
      return;
    }

    state = AsyncData(Oid4VciAcquiringState());
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      final result = await session.openid4vci.acquireCredentialsWithAuthCode(
        resolvedOffer: prepared.resolvedOffer,
        authorizationCode: code,
        codeVerifier: prepared.codeVerifier,
        redirectUri: prepared.redirectUri,
      );
      await _finishWithCredentials(result.credentials, prepared.resolvedOffer);
    } catch (e, st) {
      debugPrint('OID4VCI completeAuthCode() error: $e\n$st');
      state = AsyncData(
        Oid4VciErrorState(
          formatFlowErrorMessage(e),
          offer: prepared.resolvedOffer,
        ),
      );
    }
  }

  Future<void> _startAuthCodeFlow(ResolvedCredentialOffer offer) async {
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      final prepared = await session.openid4vci.prepareAuthCodeFlow(
        resolvedOffer: offer,
        redirectUri: kOid4VciRedirectUri,
      );
      state = AsyncData(Oid4VciAuthCodeBrowserState(prepared));
    } catch (e, st) {
      debugPrint('OID4VCI prepareAuthCodeFlow() error: $e\n$st');
      state = AsyncData(
        Oid4VciErrorState(
          formatFlowErrorMessage(e),
          offer: offer,
        ),
      );
    }
  }

  Future<void> _acquirePreAuthorized(
    ResolvedCredentialOffer offer, {
    String? txCode,
  }) async {
    state = AsyncData(Oid4VciAcquiringState());
    final started = DateTime.now();
    // Mínimo visible del spinner para que no parpadee si la emisión es muy rápida.
    const minVisible = Duration(milliseconds: 1200);
    try {
      final session = ref.read(walletNotifierProvider.notifier).session;
      final result = await session.openid4vci.acquireCredentials(
        resolvedOffer: offer,
        txCode: txCode,
      );
      final elapsed = DateTime.now().difference(started);
      if (elapsed < minVisible) {
        await Future.delayed(minVisible - elapsed);
      }
      await _finishWithCredentials(result.credentials, offer);
    } catch (e, st) {
      debugPrint('OID4VCI accept() error: $e\n$st');
      state = AsyncData(
        Oid4VciErrorState(
          formatFlowErrorMessage(e),
          offer: offer,
        ),
      );
    }
  }

  Future<void> _finishWithCredentials(
    List<CredentialRecord> credentials,
    ResolvedCredentialOffer offer,
  ) async {
    final session = ref.read(walletNotifierProvider.notifier).session;
    final enrichedCredentials = <CredentialRecord>[];
    for (final credential in credentials) {
      final enriched = CredentialUiMapper.enrichFromOffer(credential, offer);
      await session.credentialStore.update(enriched);
      final stored = await session.credentialStore.getById(enriched.id);
      if (stored != null) {
        enrichedCredentials.add(stored);
      } else {
        enrichedCredentials.add(enriched);
      }
    }
    state = AsyncData(Oid4VciSuccessState(enrichedCredentials));
  }
}

/// Provider familiar: una instancia de [Oid4VciNotifier] por URL de oferta.

final oid4vciNotifierProvider =
    AsyncNotifierProvider.family<Oid4VciNotifier, Oid4VciFlowState, String>(
  Oid4VciNotifier.new,
);
