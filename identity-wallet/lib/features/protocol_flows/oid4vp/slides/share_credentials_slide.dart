import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../credentials/mappers/credential_ui_mapper.dart';
import '../../../credentials/models/wallet_credential.dart';
import '../../../credentials/widgets/credential_fields_view.dart';

/// Slide que resume qué credencial y qué claims se enviarán al verificador
/// (OID4VP), como bottom sheet del design system ([IdentityFlowSheet]).
///
/// Lista las entradas de [request.submission] con etiqueta + valor real de
/// cada dato a revelar; [onShare] dispara [Oid4VpNotifier.share] si
/// `areAllSatisfied` (si no, el botón queda deshabilitado); [onCancel] aborta.
class ShareCredentialsSlide extends StatelessWidget {
  const ShareCredentialsSlide({
    super.key,
    required this.request,
    required this.selectedCredentials,
    required this.selectedDisclosures,
    required this.onShare,
    required this.onCancel,
  });

  /// Solicitud resuelta con requisitos y credenciales candidatas.
  final CredentialsForRequest request;

  /// Descriptor de entrada → id de credencial elegida.
  final Map<String, String> selectedCredentials;

  /// Descriptor de entrada → rutas de claims a revelar.
  final Map<String, List<String>> selectedDisclosures;

  /// Invoca el envío de la presentación al verificador.
  final VoidCallback onShare;

  /// Cancela y vuelve o cierra según el contenedor.
  final VoidCallback onCancel;

  /// Mapea cada entrada de la submission a su view-model de UI.
  List<ShareEntryUi> _buildEntries() {
    return [
      for (final entry in request.submission.entries)
        if (!entry.isSatisfied)
          ShareEntryUi(
            missingName: entry.name ?? 'Credencial requerida no disponible',
          )
        else
          _satisfiedEntry(entry),
    ];
  }

  ShareEntryUi _satisfiedEntry(FormattedSubmissionEntry entry) {
    // Resuelve la credencial elegida por el usuario; si el mapa no trae
    // entrada (defensa/tests), cae a la primera candidata.
    final selectedId = selectedCredentials[entry.inputDescriptorId];
    final candidates = entry.matchingCredentials ?? const [];
    final record = candidates
            .where((credential) => credential.id == selectedId)
            .firstOrNull ??
        candidates.firstOrNull;
    final paths = selectedDisclosures[entry.inputDescriptorId] ?? const [];
    return ShareEntryUi(
      credential: record != null
          ? CredentialUiMapper.toWalletCredential(record)
          : null,
      claims: record != null && paths.isNotEmpty
          ? CredentialUiMapper.claimsForDisclosurePaths(
              CredentialUiMapper.labeledClaimsFor(record, locale: 'es'),
              paths,
            )
          : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowSheetScaffold(
      sheet: IdentityFlowSheet(
        title: '¿Deseás compartir estos datos?',
        secondaryLabel: 'Cancelar',
        onSecondary: onCancel,
        primaryLabel: 'Compartir',
        onPrimary: request.submission.areAllSatisfied ? onShare : null,
        children: [
          ShareSheetContent(entries: _buildEntries()),
        ],
      ),
    );
  }
}

/// View-model de una entrada de la submission para [ShareSheetContent].
///
/// Con [missingName] representa una entrada insatisfecha; si no, [credential]
/// y [claims] describen qué se comparte.
class ShareEntryUi {
  const ShareEntryUi({
    this.credential,
    this.claims = const [],
    this.missingName,
  });

  /// Credencial a previsualizar; `null` en entradas insatisfechas.
  final WalletCredential? credential;

  /// Claims a revelar (etiqueta + valor). Vacío = credencial completa.
  final List<LabeledClaim> claims;

  /// Nombre del requisito faltante; no-`null` marca la entrada como error.
  final String? missingName;
}

/// Contenido presentacional del sheet de compartir (testeable sin
/// [CredentialsForRequest] ni [CredentialRecord]).
class ShareSheetContent extends StatelessWidget {
  const ShareSheetContent({super.key, required this.entries});

  /// Entradas a renderizar en orden.
  final List<ShareEntryUi> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries) ...[
          if (entry.missingName != null)
            _MissingCredentialRow(name: entry.missingName!)
          else if (entry.credential != null) ...[
            CredentialFieldsView(
              credential: entry.credential!,
              fields: previewCredentialFields(
                entry.credential!,
                entry.claims,
              ),
            ),
            if (entry.claims.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Se compartirá la credencial completa.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textNeutralSecondary,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

/// Fila de error para un requisito sin credencial que lo satisfaga.
class _MissingCredentialRow extends StatelessWidget {
  const _MissingCredentialRow({required this.name});

  /// Nombre del requisito faltante.
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.errorText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: AppColors.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
