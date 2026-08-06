import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Escucha deeplinks del sistema operativo y los traduce a navegación con [GoRouter].
///
/// Se instancia desde [IdentityWalletApp] (`main.dart`) con el [GoRouter] de
/// [routerProvider], el mismo que recibe [MaterialApp.router].
///
/// [start] procesa el link inicial (app abierta desde un enlace) y se suscribe al
/// stream de enlaces mientras la app sigue viva. [dispose] cancela esa suscripción
/// y debe llamarse desde [State.dispose] del widget que posee el handler.
///
/// Clasificación y destinos:
/// - **OID4VCI (oferta):** esquemas `openid-credential-offer`, `haip-vci` u
///   `openid-initiate-issuance`, o `https` cuya ruta contiene `credential_offer`
///   → [GoRouter.push] a `/notifications/oid4vci?url=...`.
/// - **OID4VP (presentación):** esquemas `openid4vp`, `openid-vp` u `openid`, o
///   `https` con ruta que contiene `authorize` o query `request_uri` →
///   `/notifications/oid4vp?url=...`.
///
/// El query `url` lleva el URI original codificado con [Uri.encodeComponent] para que
/// las pantallas de notificación lo decodifiquen y sigan el flujo del protocolo.
///
/// La ruta `/notifications/didcomm` existe en el router pero este handler no la usa;
/// habría que extender la lógica si se agregan enlaces nativos DIDComm.

class AppLinksHandler {
  /// Crea el manejador usando [router] para todos los [GoRouter.push].
  AppLinksHandler(this._router);

  final GoRouter _router;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Lee el link inicial y escucha [AppLinks.uriLinkStream] hasta [dispose].
  Future<void> start() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _route(initial);
    _subscription = _appLinks.uriLinkStream.listen(_route);
  }

  /// Cancela la suscripción al stream de enlaces.
  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  void _route(Uri uri) {
    final raw = Uri.encodeComponent(uri.toString());
    if (_isOffer(uri)) {
      _router.push('/notifications/oid4vci?url=$raw');
    } else if (_isRequest(uri)) {
      _router.push('/notifications/oid4vp?url=$raw');
    }
  }

  bool _isOffer(Uri uri) {
    if (uri.isScheme('openid-credential-offer') ||
        uri.isScheme('haip-vci') ||
        uri.isScheme('openid-initiate-issuance')) {
      return true;
    }
    if (uri.isScheme('https') && uri.path.contains('credential_offer')) return true;
    return false;
  }

  bool _isRequest(Uri uri) {
    if (uri.isScheme('openid4vp') || uri.isScheme('openid-vp') || uri.isScheme('openid')) {
      return true;
    }
    if (uri.isScheme('https') &&
        (uri.path.contains('authorize') || uri.queryParameters.containsKey('request_uri'))) {
      return true;
    }
    return false;
  }
}
