import 'package:flutter/material.dart';

import '../../credentials/models/wallet_credential.dart';

/// Categoría del wallet mostrada en el panel desplegable de categorías.
///
/// [iconAsset] es un badge circular (ya incluye su color de fondo). [rowColor]
/// es el tinte de fondo de la fila ([accordion]). [credentials] son las
/// credenciales asignadas; si está vacía, el acordeón muestra el estado vacío.
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
  });

  /// Identificador de [CategoryData.id]; `null` solo en instancias transitorias.
  final String? id;

  /// Nombre de la categoría (ej. "Identidad").
  final String label;

  /// Ruta del badge circular de la categoría.
  final String iconAsset;

  /// Tinte de fondo de la fila.
  final Color rowColor;

  /// Índice del ícono en el catálogo ([kCategoryIconAssets]); para precargar la edición.
  final int? iconIndex;

  /// Color persistido (ARGB) de la categoría; para precargar la edición.
  final int? colorArgb;

  /// Credenciales asignadas a la categoría.
  final List<WalletCredential> credentials;

  /// Cantidad de credenciales en la categoría.
  int get itemCount => credentials.length;

  /// Subtítulo formateado según la cantidad de ítems.
  String get subtitle => itemCount == 1 ? '1 item' : '$itemCount items';
}
