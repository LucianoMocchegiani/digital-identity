import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../models/wallet_credential.dart';
import 'credential_fields_view.dart';

/// Drawer de detalle de una credencial (componente `Modal-Credencial`).
///
/// Se eleva desde abajo sobre el home oscurecido (vía [showCredentialDetail]) y
/// reutiliza [CredentialFieldsView]: la tarjeta arriba y, debajo, el emisor con
/// su insignia seguido de los [labeledClaims] como filas etiqueta/valor. Es la
/// misma composición que el sheet de compartir, para que ver una credencial y
/// presentarla se lean igual.
///
/// El botón **Eliminar** ([onDelete]) queda fijo al pie y pide confirmación con
/// [IdentityConfirmModal]. El botón `Cross` circular por encima del drawer cierra.
class CredentialDetailDrawer extends StatelessWidget {
  const CredentialDetailDrawer({
    super.key,
    required this.credential,
    this.labeledClaims = const [],
    this.onDelete,
  });

  /// Credencial a mostrar (datos reales del SDK o mock).
  final WalletCredential credential;

  /// Claims con etiqueta legible y valor para la lista de atributos.
  final List<LabeledClaim> labeledClaims;

  /// Acción del botón "Eliminar"; si es `null`, el botón no se muestra.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Altura del drawer: casi toda la pantalla, dejando ver el backdrop arriba.
    final height = MediaQuery.of(context).size.height * 0.9;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: height,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.backgroundNeutralSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: CredentialFieldsView(
                    credential: credential,
                    fields: _fields(),
                  ),
                ),
              ),
              if (onDelete != null) _buildDeleteBar(context),
            ],
          ),
        ),
        // Botón cerrar: por fuera del drawer, sobre el área oscurecida (top
        // negativo). Clip.none del Stack permite que sobresalga hacia arriba.
        Positioned(
          right: 16,
          top: -46,
          child: IdentitySheetCloseButton(onTap: () => Navigator.of(context).pop()),
        ),
      ],
    );
  }

  /// Emisor (con insignia si está verificado) seguido de un campo por claim.
  ///
  /// No usa `previewCredentialFields` porque los valores del detalle pasan por
  /// [_formatValue], que resuelve mapas, listas y booleanos a una línea legible.
  List<CredentialField> _fields() {
    return [
      (
        label: kIssuerFieldLabel,
        value: credential.issuer,
        verified: credential.verified,
      ),
      for (final claim in labeledClaims)
        (
          label: claim.label,
          value: _formatValue(claim.value),
          verified: false,
        ),
    ];
  }

  /// Barra inferior fija (`Botones`): fondo blanco, borde superior y radio 12px,
  /// que contiene el botón "Eliminar".
  Widget _buildDeleteBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderNeutral)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: IdentityDangerButton(
        label: 'Eliminar',
        onTap: () => _confirmDelete(context),
      ),
    );
  }

  /// Pide confirmación; si acepta, cierra el drawer e invoca [onDelete].
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await IdentityConfirmModal.show(
      context,
      title: 'Eliminar credencial',
      description:
          'La credencial se borrará de esta wallet y no se puede deshacer.',
    );
    if (!confirmed || !context.mounted) return;
    Navigator.of(context).pop(); // cierra el drawer
    onDelete?.call();
  }

  /// Representación en una línea de un valor de claim (null, bool, map, list).
  String _formatValue(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    if (value is List) return value.map(_formatValue).join(', ');
    return value.toString();
  }
}

/// Eleva el drawer de detalle de [credential] desde abajo sobre el home.
///
/// [labeledClaims] son los claims a listar; [onDelete] (opcional) cablea el botón
/// "Eliminar". Backdrop oscurecido (`rgba(0,0,0,0.6)`) y animación nativos del
/// bottom sheet. Devuelve cuando el usuario lo cierra (Cross o tap fuera).
Future<void> showCredentialDetail(
  BuildContext context,
  WalletCredential credential, {
  List<LabeledClaim> labeledClaims = const [],
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    // Clip.none deja que el botón cerrar sobresalga por encima del drawer.
    clipBehavior: Clip.none,
    builder: (_) => CredentialDetailDrawer(
      credential: credential,
      labeledClaims: labeledClaims,
      onDelete: onDelete,
    ),
  );
}
