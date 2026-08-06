import 'dart:convert';
import 'dart:io';

import 'models/wallet_ux_data.dart';
import 'wallet_ux_paths.dart';

/// Acceso a disco del JSON de preferencias del wallet.
///
/// Encapsula lectura, escritura y borrado del archivo apuntado por
/// [WalletUxPaths.uxFilePath]. No contiene lógica de negocio: las mutaciones
/// (CRUD de categorías, favoritas, asignaciones) las orquesta [WalletUxNotifier].
///
/// Cada [save] reescribe el archivo completo con indentación legible y
/// `flush: true` para reducir pérdida de datos si la app se cierra de golpe.
class WalletUxRepository {
  WalletUxRepository(this._paths);

  final WalletUxPaths _paths;

  /// Elimina el archivo de preferencias si existe.
  ///
  /// Se invoca desde [WalletNotifier.reset] para dejar el dispositivo sin
  /// categorías ni favoritas tras reiniciar la wallet.
  static Future<void> clear(WalletUxPaths paths) async {
    final file = File(paths.uxFilePath);
    if (await file.exists()) await file.delete();
  }

  /// Carga el documento desde disco.
  ///
  /// Retorna [WalletUxData.empty] si el archivo no existe o está vacío.
  Future<WalletUxData> load() async {
    final file = File(_paths.uxFilePath);
    if (!await file.exists()) return WalletUxData.empty;

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return WalletUxData.empty;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return WalletUxData.fromJson(decoded);
  }

  /// Persiste el documento completo sobrescribiendo el archivo anterior.
  Future<void> save(WalletUxData data) async {
    final file = File(_paths.uxFilePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
      flush: true,
    );
  }
}
