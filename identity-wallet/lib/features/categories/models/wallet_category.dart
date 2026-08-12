import 'package:flutter/material.dart';

import '../../credentials/models/wallet_credential.dart';

/// Categoría del wallet mostrada en el panel desplegable de categorías.
///
/// [iconAsset] y [rowColor] definen el look del contenedor; [credentials] son
/// las asignadas (o todas, si [isSystem]).
@immutable
class WalletCategory {
  const WalletCategory({
    this.id,
    required this.label,
    required this.iconAsset,
    required this.rowColor,
    this.iconIndex,
    this.colorArgb,
    this.credentials = const [],
    this.isSystem = false,
  });

  /// Identificador de [CategoryData.id]; `null` solo en instancias transitorias.
  final String? id;

  /// Nombre de la categoría (ej. "Viajes").
  final String label;

  /// Ruta del asset del ícono (línea o badge).
  final String iconAsset;

  /// Tinte de fondo de la fila.
  final Color rowColor;

  /// Índice del ícono en el catálogo ([kCategoryIconAssets]); para precargar la edición.
  final int? iconIndex;

  /// Color persistido (ARGB) de la categoría; para precargar la edición.
  final int? colorArgb;

  /// Credenciales asignadas a la categoría.
  final List<WalletCredential> credentials;

  /// Categoría de sistema (ej. "Todas las credenciales"): no se elimina ni edita.
  final bool isSystem;

  /// Cantidad de credenciales en la categoría.
  int get itemCount => credentials.length;

  /// Subtítulo formateado según la cantidad de ítems.
  String get subtitle => itemCount == 1 ? '1 item' : '$itemCount items';
}
