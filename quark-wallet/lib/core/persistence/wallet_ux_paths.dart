import 'dart:io';

import '../wallet_constants.dart';

/// Resuelve rutas de archivos de preferencias locales del wallet.
///
/// Usa el mismo [directory] que [WalletNotifier] (`getApplicationDocumentsDirectory`)
/// y el mismo [walletId] que el archivo Isar del SDK (`default.isar`).
///
/// En Android la ruta típica es:
/// `/data/data/<package>/app_flutter/default_ux.json`
class WalletUxPaths {
  const WalletUxPaths({
    required this.directory,
    this.walletId = kWalletId,
  });

  /// Directorio de documentos privados de la app.
  final String directory;

  /// Identificador del wallet; forma parte del nombre del archivo.
  final String walletId;

  /// Ruta absoluta del JSON de categorías, favoritas y asignaciones.
  ///
  /// Patrón: `{directory}/{walletId}_ux.json`
  String get uxFilePath {
    final separator = Platform.pathSeparator;
    if (directory.endsWith(separator)) {
      return '$directory${walletId}_ux.json';
    }
    return '$directory$separator${walletId}_ux.json';
  }
}
