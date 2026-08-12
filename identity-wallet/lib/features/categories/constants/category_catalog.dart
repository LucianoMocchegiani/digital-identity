import 'package:flutter/material.dart';

/// Catálogo visual compartido entre persistencia, mapper y modales de categoría.
///
/// Los índices guardados en [CategoryData.iconIndex] y [CategoryData.colorArgb]
/// referencian estas listas. Centralizar aquí evita duplicar constantes entre
/// [CategoryCreationModal] y [CategoryMapper].

/// Rutas de assets de íconos representativos (orden = índice persistido).
const List<String> kCategoryIconAssets = [
  'public/images/icons/Case-Round.png',
  'public/images/icons/Square-Academic-Cap.png',
  'public/images/icons/Chef-Hat.png',
  'public/images/icons/Basketball.png',
  'public/images/icons/Home.png',
  'public/images/categorias/identidad-category.png',
  'public/images/icons/credenciales.png',
];

/// Índice en [kCategoryIconAssets] del ícono de la categoría "Identidad".
const int kIdentityIconIndex = 5;

/// Índice del ícono de la categoría de sistema "Todas las credenciales".
const int kAllCredentialsIconIndex = 6;

/// ID fijo de la categoría de sistema que agrupa todas las credenciales.
///
/// No se puede eliminar. El contenido se resuelve en el mapper (todas las del SDK).
const String kAllCredentialsCategoryId = 'system-all-credentials';

/// Nombre visible de la categoría de sistema.
const String kAllCredentialsCategoryLabel = 'Todas las credenciales';

/// Indica si [id] es la categoría de sistema protegida.
bool isSystemCategoryId(String? id) => id == kAllCredentialsCategoryId;

/// Paleta de colores seleccionables (orden = índice persistido como ARGB entero).
const List<Color> kCategoryColors = [
  Color(0xFF9E77ED),
  Color(0xFFF04438),
  Color(0xFFFDB022),
  Color(0xFF32D583),
  Color(0xFF717BBC),
  Color(0xFF36BFFA),
  Color(0xFF2E90FA),
  Color(0xFF6172F3),
  Color(0xFFEE46BC),
  Color(0xFFF63D68),
  Color(0xFFFB6514),
];

/// Calcula el tinte de fondo de fila del acordeón a partir del color persistido.
///
/// Aplica alpha bajo (0.08) para mantener legibilidad del texto sobre la fila.
Color categoryRowColor(int colorArgb) {
  return Color(colorArgb).withValues(alpha: 0.08);
}

/// Resuelve la ruta del asset de ícono para [iconIndex].
///
/// Si el índice está fuera de rango retorna el primer ícono como fallback seguro.
String categoryIconAssetForIndex(int iconIndex) {
  if (iconIndex < 0 || iconIndex >= kCategoryIconAssets.length) {
    return kCategoryIconAssets.first;
  }
  return kCategoryIconAssets[iconIndex];
}
