import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../verifier_display.dart';

/// Primer paso OID4VP: muestra quién solicita la verificación y el nivel de
/// confianza, como bottom sheet del design system ([QuarkFlowSheet]).
///
/// Usa [CredentialsForRequest.trustedEntity] y [CredentialsForRequest.verifierClientId]
/// para nombre, logo y badge; [onContinue] avanza a [Oid4VpShareState] vía
/// [Oid4VpNotifier.confirmVerifier]; [onCancel] aborta el flujo.
class VerifyVerifierSlide extends StatelessWidget {
  const VerifyVerifierSlide({
    super.key,
    required this.request,
    required this.onContinue,
    required this.onCancel,
  });

  /// Solicitud resuelta con metadatos del verificador y propósito de la presentación.
  final CredentialsForRequest request;

  /// Confirma que el usuario acepta continuar con este verificador.
  final VoidCallback onContinue;

  /// Cancela y vuelve o cierra según el contenedor.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return FlowSheetScaffold(
      sheet: QuarkFlowSheet(
        title: 'Solicitud de verificación',
        secondaryLabel: 'Cancelar',
        onSecondary: onCancel,
        primaryLabel: 'Continuar',
        onPrimary: onContinue,
        children: [
          Builder(
            builder: (context) {
              final display = verifierDisplay(
                request.verifierClientId,
                request.trustedEntity?.relyingParty,
              );
              return VerifierSheetContent(
                name: display.name,
                domain: display.domain,
                logoUrl: request.trustedEntity?.relyingParty.logoUri,
                isVerified: request.trustedEntity?.isVerified ?? false,
                purpose: request.submission.purpose,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Contenido presentacional del sheet del verificador (testeable sin
/// construir [CredentialsForRequest]).
class VerifierSheetContent extends StatelessWidget {
  const VerifierSheetContent({
    super.key,
    required this.name,
    required this.domain,
    required this.logoUrl,
    required this.isVerified,
    required this.purpose,
  });

  /// Nombre a mostrar del verificador.
  final String name;

  /// Dominio legible del verificador (texto secundario); `null` lo oculta.
  final String? domain;

  /// URL del logo remoto; `null` usa el placeholder.
  final String? logoUrl;

  /// Nivel de confianza según metadatos ([TrustedEntity.isVerified]).
  final bool isVerified;

  /// Propósito de la presentación (opcional).
  final String? purpose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NetworkLogoOrPlaceholder(
          logoUrl: logoUrl,
          placeholder: _verifierIcon(),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 22 / 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textNeutralPrimary,
          ),
        ),
        if (domain != null) ...[
          const SizedBox(height: 4),
          Text(
            domain!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _TrustBadge(isVerified: isVerified),
        if (purpose != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundNeutralSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: Text(
              purpose!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textNeutralSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _verifierIcon() => Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.backgroundNeutralSecondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.verified_user_outlined,
          size: 40,
          color: AppColors.textNeutralSecondary,
        ),
      );
}

/// Indicador de confianza del verificador con tokens del design system:
/// verificado → check + azul de enlace; no verificado → badge de advertencia.
class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.isVerified});

  /// Si el verificador figura como verificado en metadatos de confianza.
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'public/images/icons/Badge-wrapper.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Verificador de confianza',
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.linkBlue,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.warningText),
          SizedBox(width: 6),
          Text(
            'Sin verificación de confianza',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: AppColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}
