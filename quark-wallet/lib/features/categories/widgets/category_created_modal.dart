import 'package:flutter/material.dart';

import '../../../shared/quark_shared.dart';

/// Modal de confirmación tras crear una categoría.
///
/// Es un envoltorio sobre [QuarkSuccessModal] con los textos de categoría.
abstract final class CategoryCreatedModal {
  /// Muestra el modal de "Categoría creada" sobre un fondo oscuro.
  static Future<void> show(BuildContext context) {
    return QuarkSuccessModal.show(
      context,
      title: 'Categoría creada',
      description:
          'Se añadió con éxito una nueva categoría en la wallet, lista para '
          'almacenar las credenciales correspondientes.',
    );
  }
}
