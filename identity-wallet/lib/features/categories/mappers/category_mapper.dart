import 'package:identity_core_dart/identity_core.dart';

import '../../../core/persistence/models/category_data.dart';
import '../../../core/persistence/models/wallet_ux_data.dart';
import '../../credentials/mappers/credential_ui_mapper.dart';
import '../../credentials/models/wallet_credential.dart';
import '../constants/category_catalog.dart';
import '../models/wallet_category.dart';

/// Puente entre datos persistidos ([WalletUxData]) y modelos de UI ([WalletCategory]).
///
/// Resuelve la relación N:M credencial ↔ categoría cruzando:
/// - [WalletUxData.credentialUx] (asignaciones y favoritas)
/// - [credentialsProvider] (credenciales reales del SDK)
class CategoryMapper {
  const CategoryMapper._();

  /// Convierte una [CategoryData] en [WalletCategory] con credenciales asignadas.
  ///
  /// Filtra [credentials] por los IDs presentes en `credentialUx.categoryIds`
  /// y las mapea a [WalletCredential] vía [CredentialUiMapper].
  static WalletCategory toWalletCategory({
    required CategoryData category,
    required WalletUxData uxData,
    required List<CredentialRecord> credentials,
  }) {
    final isSystem = isSystemCategoryId(category.id);
    final List<WalletCredential> assignedCredentials;
    if (isSystem) {
      assignedCredentials = credentials
          .map(CredentialUiMapper.toWalletCredential)
          .toList(growable: false);
    } else {
      final assignedIds = uxData.credentialUx.entries
          .where((entry) => entry.value.categoryIds.contains(category.id))
          .map((entry) => entry.key)
          .toSet();

      assignedCredentials = credentials
          .where((record) => assignedIds.contains(record.id))
          .map(CredentialUiMapper.toWalletCredential)
          .toList(growable: false);
    }

    return WalletCategory(
      id: category.id,
      label: category.label,
      iconAsset: categoryIconAssetForIndex(category.iconIndex),
      rowColor: categoryRowColor(category.colorArgb),
      iconIndex: category.iconIndex,
      colorArgb: category.colorArgb,
      credentials: assignedCredentials,
      isSystem: isSystem,
    );
  }

  /// Convierte todas las categorías persistidas a modelos UI ordenados por [CategoryData.sortOrder].
  static List<WalletCategory> toWalletCategories({
    required WalletUxData uxData,
    required List<CredentialRecord> credentials,
  }) {
    final sorted = [...uxData.categories]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return sorted
        .map(
          (category) => toWalletCategory(
            category: category,
            uxData: uxData,
            credentials: credentials,
          ),
        )
        .toList(growable: false);
  }

  /// Indica si [credentialId] está marcada como favorita en [uxData].
  static bool isFavorite(WalletUxData uxData, String credentialId) {
    return uxData.credentialUx[credentialId]?.isFavorite ?? false;
  }
}
