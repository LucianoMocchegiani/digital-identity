/// Categoría personalizada del usuario persistida en el JSON local.
///
/// Representa los metadatos de una carpeta lógica (nombre, ícono, color y orden).
/// La **asignación de credenciales** no vive aquí: se guarda en
/// [CredentialUxData.categoryIds] indexado por `CredentialRecord.id` del SDK.
///
/// Los índices [iconIndex] y [colorArgb] referencian el catálogo visual definido
/// en [kCategoryIconAssets] y [kCategoryColors] (`category_catalog.dart`).
class CategoryData {
  const CategoryData({
    required this.id,
    required this.label,
    required this.iconIndex,
    required this.colorArgb,
    required this.sortOrder,
    required this.createdAt,
  });

  /// Identificador único generado al crear la categoría.
  final String id;

  /// Nombre visible elegido por el usuario (ej. "Identidad", "Viajes").
  final String label;

  /// Índice en [kCategoryIconAssets] del ícono representativo.
  final int iconIndex;

  /// Color en formato ARGB (`Color.value`) de la paleta de categorías.
  final int colorArgb;

  /// Posición en el panel de categorías; menor valor = más arriba.
  final int sortOrder;

  /// Marca de tiempo UTC de creación.
  final DateTime createdAt;

  /// Devuelve una copia con los campos indicados reemplazados.
  CategoryData copyWith({
    String? id,
    String? label,
    int? iconIndex,
    int? colorArgb,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryData(
      id: id ?? this.id,
      label: label ?? this.label,
      iconIndex: iconIndex ?? this.iconIndex,
      colorArgb: colorArgb ?? this.colorArgb,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serializa la categoría para el archivo `{walletId}_ux.json`.
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconIndex': iconIndex,
        'colorArgb': colorArgb,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Reconstruye una categoría desde el JSON persistido.
  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] as String,
      label: json['label'] as String,
      iconIndex: json['iconIndex'] as int,
      colorArgb: json['colorArgb'] as int,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
