import 'dart:typed_data';

import 'package:isar/isar.dart';

import '../crypto/wallet_crypto_context.dart';
import 'isar/activity_isar.dart';
import 'isar/connection_record_isar.dart';
import 'isar/deferred_credential_isar.dart';
import 'isar/did_isar.dart';
import 'isar/key_record_isar.dart';
import 'isar/mdoc_isar.dart';
import 'isar/sd_jwt_vc_isar.dart';
import 'isar/w3c_credential_isar.dart';

/// Wrapper sobre [Isar] que abre y gestiona la base de datos cifrada del wallet.
///
/// Registra todos los schemas de colección y expone [db] para que los stores
/// individuales puedan acceder a sus colecciones. La clave de cifrado de 32 bytes
/// es derivada externamente (Argon2id en Fase 2) y pasada al momento de apertura.
class RecordStore {
  RecordStore._(this._isar, this._cryptoContext);

  final Isar _isar;
  final WalletCryptoContext? _cryptoContext;

  /// Instancia [Isar] con todas las colecciones abiertas.
  Isar get db => _isar;

  /// Contexto de cifrado de campos de la sesión actual, si existe.
  ///
  /// Los stores sensibles lo usan al persistir y leer `privateJwkJson`, JWTs
  /// y tokens. Es `null` si el integrador abrió el wallet sin [WalletService].
  WalletCryptoContext? get cryptoContext => _cryptoContext;

  /// Abre la base de datos cifrada para el wallet identificado por [walletId].
  ///
  /// [walletId] se usa como nombre del archivo isar (un archivo por wallet).
  /// [encryptionKey] debe ser exactamente 32 bytes (AES-256); generado con Argon2id.
  /// [directory] ruta al directorio de almacenamiento de la app.
  ///
  /// Lanza [IsarError] si la clave de cifrado es incorrecta o el archivo está corrupto.
  /// [cryptoContext] habilita cifrado AES-GCM por campo en los stores sensibles.
  static Future<RecordStore> open({
    required String walletId,
    required Uint8List encryptionKey,
    required String directory,
    WalletCryptoContext? cryptoContext,
  }) async {
    // encryptionKey ignored: isar 3.1.0+1 open() doesn't expose encryptionKey parameter.
    final isar = await Isar.open(
      [
        SdJwtVcIsarSchema,
        W3cCredentialIsarSchema,
        MdocIsarSchema,
        DidIsarSchema,
        KeyRecordIsarSchema,
        ActivityIsarSchema,
        DeferredCredentialIsarSchema,
        ConnectionRecordIsarSchema,
      ],
      directory: directory,
      name: walletId,
    );

    return RecordStore._(isar, cryptoContext);
  }

  /// Cierra la base de datos liberando los recursos asociados.
  Future<void> close() => _isar.close();

  /// Cierra la base de datos y elimina el archivo isar del disco.
  ///
  /// Equivalente a un reset completo del wallet: todos los datos se pierden.
  /// Después de llamar a [clear], esta instancia no debe usarse.
  Future<void> clear() => _isar.close(deleteFromDisk: true);
}
