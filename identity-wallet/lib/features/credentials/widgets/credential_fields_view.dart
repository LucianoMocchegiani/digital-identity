import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../models/wallet_credential.dart';
import 'credential_card.dart';

/// Par etiqueta-valor mostrado en la lista de datos de un flujo (agregar/compartir).
typedef CredentialField = ({String label, String value, bool verified});

/// Etiqueta de la fila de emisor, compartida por los flujos de agregar y
/// compartir para que ambas vistas usen el mismo texto.
const String kIssuerFieldLabel = 'Institución/Empresa emisora';

/// Filas de emisor + claims para sheets de agregar y compartir (mismo layout).
List<CredentialField> previewCredentialFields(
  WalletCredential credential,
  List<LabeledClaim> claims,
) {
  return [
    (
      label: kIssuerFieldLabel,
      value: credential.issuer,
      verified: credential.verified,
    ),
    for (final claim in claims)
      (
        label: claim.label,
        value: claim.value?.toString() ?? '',
        verified: false,
      ),
  ];
}

/// Vista compartida de los datos de una credencial: la tarjeta arriba y una
/// lista de campos etiqueta-valor debajo. Reutilizada por el sheet de agregar
/// (OID4VCI) y el de compartir (OID4VP); cada flujo decide qué [fields] pasar
/// (emisión: todos; verificación: emisor + los claims que pide el verificador).
///
/// La tarjeta no expande sus detalles inline (los datos viven en las filas).
///
/// Con [sectionTitle] (ej. "Atributos") y [showDividers] la lista imita la vista
/// de metadatos del detalle de credencial: el emisor queda arriba como contexto,
/// seguido de un encabezado de sección y los claims separados por divisores.
class CredentialFieldsView extends StatelessWidget {
  const CredentialFieldsView({
    super.key,
    required this.credential,
    required this.fields,
    this.sectionTitle,
    this.showDividers = false,
  });

  /// Credencial a previsualizar en la tarjeta superior.
  final WalletCredential credential;

  /// Campos etiqueta-valor a listar bajo la tarjeta.
  final List<CredentialField> fields;

  /// Encabezado opcional para el bloque de claims (ej. "Atributos"), como en el
  /// detalle. En `null` no se muestra encabezado y el emisor no se separa.
  final String? sectionTitle;

  /// Dibuja un divisor bajo cada claim, igual que el detalle de la credencial.
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    // Con encabezado, el emisor va arriba (contexto de confianza) y el resto de
    // los claims bajo la sección; sin encabezado se listan todos en orden.
    final grouped = sectionTitle != null;
    final issuerFields =
        grouped ? fields.where((f) => f.label == kIssuerFieldLabel).toList() : const <CredentialField>[];
    final claimFields =
        grouped ? fields.where((f) => f.label != kIssuerFieldLabel).toList() : fields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CredentialCard(
          credential: credential,
          // Los datos se listan como filas debajo: la tarjeta no los duplica.
          showExpandToggle: false,
        ),
        const SizedBox(height: 20),
        for (final field in issuerFields)
          SheetFieldRow(
            label: field.label,
            value: field.value,
            verified: field.verified,
          ),
        if (grouped && claimFields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              sectionTitle!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        for (final field in claimFields) ...[
          SheetFieldRow(
            label: field.label,
            value: field.value,
            verified: field.verified,
          ),
          if (showDividers) const Divider(height: 16),
        ],
      ],
    );
  }
}
