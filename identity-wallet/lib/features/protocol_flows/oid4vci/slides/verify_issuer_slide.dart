import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Primera pantalla del flujo OID4VCI: el usuario confirma el **emisor** de la oferta.
///
/// Se muestra desde [Oid4VciNotificationScreen] en [Oid4VciVerifyIssuerState]. Usa
/// [ResolvedCredentialOffer.issuerMetadata] (nombre y logo) y el `credentialIssuer`
/// de la oferta. [onContinue] suele ser [Oid4VciNotifier.confirmIssuer]; [onCancel]
/// aborta el flujo.

class VerifyIssuerSlide extends StatelessWidget {
  const VerifyIssuerSlide({
    super.key,
    required this.offer,
    required this.onContinue,
    required this.onCancel,
  });

  /// Oferta resuelta con metadatos del issuer.
  final ResolvedCredentialOffer offer;

  /// Pasa a la vista previa de la credencial.
  final VoidCallback onContinue;

  /// Cierra sin emitir.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final issuerDisplay = offer.issuerMetadata.display?.firstOrNull;
    final issuerName = issuerDisplay?['name'] as String? ?? offer.offer.credentialIssuer;
    final logoUrl = issuerDisplay?['logo']?['uri'] as String?;

    return Scaffold(
      appBar: FlowStepAppBar.build(
        title: 'Emisor de credencial',
        progress: 1 / 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NetworkLogoOrPlaceholder(
                    logoUrl: logoUrl,
                    placeholder: _issuerIcon(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    issuerName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.offer.credentialIssuer,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _TrustBadge(credentialIssuer: offer.offer.credentialIssuer),
                ],
              ),
            ),
            FlowActionRow(
              onCancel: onCancel,
              onPrimary: onContinue,
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar por defecto cuando no hay logo de red o falla la carga.

  Widget _issuerIcon() => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.business, size: 40),
      );
}

/// Indicador visual heurístico: HTTPS en el `credentialIssuer` vs no (no sustituye una lista de confianza).

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.credentialIssuer});

  final String credentialIssuer;

  @override
  Widget build(BuildContext context) {
    final isHttps = credentialIssuer.startsWith('https://');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHttps ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHttps ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHttps ? Icons.verified_outlined : Icons.info_outline,
            size: 16,
            color: isHttps ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isHttps ? 'Conexión segura (HTTPS)' : 'Sin verificación de confianza',
            style: TextStyle(
              fontSize: 12,
              color: isHttps ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
