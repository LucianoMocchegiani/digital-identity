/// Preferencias de organización de una credencial emitida.
///
/// Complementa al [CredentialRecord] del SDK (`identity_core_dart`) sin
/// modificar el almacenamiento SSI. Cada entrada se indexa por el mismo
/// [CredentialRecord.id] (ej. `sd-jwt-vc-abc123`).
///
/// Una credencial puede pertenecer a **varias categorías** (relación N:M) y
/// marcarse como favorita de forma independiente.
class CredentialUxData {
  const CredentialUxData({
    this.isFavorite = false,
    this.categoryIds = const [],
  });

  /// Indica si la credencial aparece en la pestaña "Favoritas" del home.
  final bool isFavorite;

  /// IDs de [CategoryData] a los que está asignada esta credencial.
  final List<String> categoryIds;

  /// Devuelve una copia con los campos indicados reemplazados.
  CredentialUxData copyWith({
    bool? isFavorite,
    List<String>? categoryIds,
  }) {
    return CredentialUxData(
      isFavorite: isFavorite ?? this.isFavorite,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }

  /// Serializa las preferencias para el mapa `credentialUx` del JSON.
  Map<String, dynamic> toJson() => {
        'isFavorite': isFavorite,
        'categoryIds': categoryIds,
      };

  /// Reconstruye las preferencias desde el JSON persistido.
  factory CredentialUxData.fromJson(Map<String, dynamic> json) {
    return CredentialUxData(
      isFavorite: json['isFavorite'] as bool? ?? false,
      categoryIds: (json['categoryIds'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }
}
