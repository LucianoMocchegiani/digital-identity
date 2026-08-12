import 'category_data.dart';
import 'credential_ux_data.dart';

/// Documento raíz del archivo JSON de preferencias del wallet.
///
/// Se persiste en `{appDocuments}/{walletId}_ux.json` junto al archivo Isar
/// del SDK. Contiene **solo metadata de producto** (categorías, favoritas,
/// asignaciones); las credenciales reales siguen en `CredentialRecordStore`.
///
/// Ejemplo de estructura en disco:
/// ```json
/// {
///   "version": 1,
///   "categories": [ { "id": "...", "label": "Viajes", ... } ],
///   "credentialUx": {
///     "sd-jwt-vc-abc": { "isFavorite": true, "categoryIds": ["cat-1"] }
///   }
/// }
/// ```
class WalletUxData {
  const WalletUxData({
    this.version = currentVersion,
    this.categories = const [],
    this.credentialUx = const {},
    this.seededDefaults = false,
  });

  /// Versión del esquema JSON; permite migraciones futuras sin romper datos.
  static const int currentVersion = 1;

  /// Versión leída o escrita en el archivo.
  final int version;

  /// Categorías creadas por el usuario.
  final List<CategoryData> categories;

  /// Preferencias por credencial, indexadas por [CredentialRecord.id].
  final Map<String, CredentialUxData> credentialUx;

  /// Indica si ya se sembraron defaults de categorías.
  ///
  /// Hoy solo asegura "Todas las credenciales"; el viejo default "Identidad"
  /// se elimina en migración y no vuelve a crearse.
  final bool seededDefaults;

  /// Estado vacío usado antes del primer guardado o con wallet bloqueada.
  static const empty = WalletUxData();

  /// Devuelve una copia con las colecciones indicadas reemplazadas.
  WalletUxData copyWith({
    int? version,
    List<CategoryData>? categories,
    Map<String, CredentialUxData>? credentialUx,
    bool? seededDefaults,
  }) {
    return WalletUxData(
      version: version ?? this.version,
      categories: categories ?? this.categories,
      credentialUx: credentialUx ?? this.credentialUx,
      seededDefaults: seededDefaults ?? this.seededDefaults,
    );
  }

  /// Serializa el documento completo para escritura en disco.
  Map<String, dynamic> toJson() => {
        'version': version,
        'categories': categories.map((c) => c.toJson()).toList(),
        'credentialUx': credentialUx.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'seededDefaults': seededDefaults,
      };

  /// Reconstruye el documento desde el JSON leído del archivo.
  factory WalletUxData.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List<dynamic>? ?? const [];
    final rawCredentialUx =
        json['credentialUx'] as Map<String, dynamic>? ?? const {};

    return WalletUxData(
      version: json['version'] as int? ?? currentVersion,
      categories: rawCategories
          .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
      credentialUx: rawCredentialUx.map(
        (key, value) => MapEntry(
          key,
          CredentialUxData.fromJson(value as Map<String, dynamic>),
        ),
      ),
      seededDefaults: json['seededDefaults'] as bool? ?? false,
    );
  }
}
