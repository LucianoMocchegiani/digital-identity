import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/shared/quark_shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Paso OID4VCI: WebView con el login del issuer (flujo authorization_code).
///
/// Intercepta la navegación al [PreparedAuthCodeFlow.redirectUri] y delega el
/// callback a [onRedirect].
class AuthCodeBrowserSlide extends StatefulWidget {
  const AuthCodeBrowserSlide({
    super.key,
    required this.prepared,
    required this.onRedirect,
    required this.onCancel,
  });

  final PreparedAuthCodeFlow prepared;
  final ValueChanged<String> onRedirect;
  final VoidCallback onCancel;

  @override
  State<AuthCodeBrowserSlide> createState() => _AuthCodeBrowserSlideState();
}

class _AuthCodeBrowserSlideState extends State<AuthCodeBrowserSlide> {
  late final WebViewController _controller;
  var _loading = true;
  var _redirectHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (_redirectHandled) return;
            setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (_redirectHandled) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Android muestra "error desconocido" en bucle al intentar cargar el
            // custom scheme del redirect OAuth; lo ignoramos tras interceptar.
            if (_redirectHandled) return;
            final desc = error.description.toLowerCase();
            if (desc.contains('unknown url scheme') ||
                desc.contains('err_unknown_url_scheme') ||
                desc.contains('scheme desconocido')) {
              return;
            }
          },
          onNavigationRequest: (request) {
            if (_redirectHandled) {
              return NavigationDecision.prevent;
            }
            final url = request.url;
            if (isOid4VciAuthRedirect(
              callbackUri: url,
              redirectUri: widget.prepared.redirectUri,
            )) {
              _redirectHandled = true;
              setState(() => _loading = false);
              widget.onRedirect(url);
              _controller.loadRequest(Uri.parse('about:blank'));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.prepared.authorizationUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlowStepAppBar.build(
        title: 'Iniciar sesión en el emisor',
        progress: 2 / 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
