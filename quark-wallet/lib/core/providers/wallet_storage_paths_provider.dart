import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../persistence/wallet_ux_paths.dart';

/// Resuelve [WalletUxPaths] con el directorio de documentos de la app.
///
/// Usa [getApplicationDocumentsDirectory] (mismo origen que [WalletNotifier])
/// para que el JSON de preferencias quede junto al archivo Isar del SDK.
///
/// Consumido por [walletUxNotifierProvider] al cargar preferencias tras
/// desbloquear la wallet.
final walletStoragePathsProvider = FutureProvider<WalletUxPaths>((ref) async {
  final directory = (await getApplicationDocumentsDirectory()).path;
  return WalletUxPaths(directory: directory);
});
