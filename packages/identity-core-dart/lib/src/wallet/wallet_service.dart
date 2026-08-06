import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart' as hex_codec;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../crypto/pin_verifier.dart';
import '../crypto/wallet_crypto_context.dart';
import '../kms/kms_backend_selector.dart';
import '../record/record_store.dart';
import '../trust/trust_config.dart';
import 'wallet_exceptions.dart';
import 'wallet_secure_storage.dart';
import 'wallet_session.dart';

/// Orquesta el ciclo de vida del wallet: creación, desbloqueo, bloqueo y reset.
///
/// Responsabilidades principales:
///
/// - Generar y persistir el salt de derivación en secure storage.
/// - Validar el PIN mediante hash Argon2id antes de abrir la sesión.
/// - Derivar la clave AES de cifrado de campos y exponerla en [WalletCryptoContext].
/// - Abrir y cerrar [RecordStore] (Isar) para cada sesión.
///
/// La validación del PIN **no depende** de que Isar cifre la base de datos:
/// wallets creados con esta versión guardan `wallet_pin_hash_<walletId>` y
/// lanzan [WrongPinError] si el PIN no coincide.
class WalletService {
  /// Crea el servicio con almacenamiento seguro y derivación de PIN configurables.
  ///
  /// [secureStorage] se adapta internamente a [WalletSecureStorage] si no se
  /// pasa [walletSecureStorage] (útil para tests con almacenamiento en memoria).
  ///
  /// [pinVerifier] permite inyectar [PinVerifier] en tests.
  WalletService({
    FlutterSecureStorage? secureStorage,
    WalletSecureStorage? walletSecureStorage,
    PinVerifier? pinVerifier,
    TrustConfig? trustConfig,
  })  : _secureStorage = walletSecureStorage ??
            FlutterWalletSecureStorage(secureStorage),
        _pinVerifier = pinVerifier ?? PinVerifier(),
        _defaultTrustConfig = trustConfig;

  final WalletSecureStorage _secureStorage;
  final PinVerifier _pinVerifier;
  final TrustConfig? _defaultTrustConfig;
  WalletSession? _session;

  static String _saltKey(String walletId) => 'wallet_salt_$walletId';

  static String _pinHashKey(String walletId) => 'wallet_pin_hash_$walletId';

  /// Crea un wallet nuevo para [walletId] protegido por [pin].
  ///
  /// [directory] ruta donde Isar escribe `<walletId>.isar`.
  /// [preferHardwareKms] si es `true`, las claves P-256 pueden residir en
  /// Android Keystore / iOS Secure Enclave.
  /// [trustConfig] configuración de confianza OID4VP; si es null se usa la del
  /// constructor de [WalletService] (si se definió).
  ///
  /// Persiste en secure storage:
  /// - salt de 16 bytes (hex) para Argon2id;
  /// - hash de verificación del PIN (hex).
  ///
  /// Retorna una [WalletSession] desbloqueada con [WalletCryptoContext] listo
  /// para cifrar campos sensibles en los stores.
  ///
  /// Lanza [WalletAlreadyExistsError] si ya existe salt para [walletId].
  Future<WalletSession> create({
    required String walletId,
    required String pin,
    required String directory,
    bool preferHardwareKms = false,
    TrustConfig? trustConfig,
  }) async {
    final existingSalt = await _secureStorage.read(key: _saltKey(walletId));
    if (existingSalt != null) throw WalletAlreadyExistsError(walletId);

    final salt = _generateSalt();
    final encryptionKey = await _pinVerifier.deriveEncryptionKey(
      pin: pin,
      salt: salt,
    );
    final pinHash = await _pinVerifier.derivePinHash(pin: pin, salt: salt);

    await _secureStorage.write(
      key: _saltKey(walletId),
      value: hex_codec.hex.encode(salt),
    );
    await _secureStorage.write(
      key: _pinHashKey(walletId),
      value: hex_codec.hex.encode(pinHash),
    );

    final cryptoContext = WalletCryptoContext(encryptionKey: encryptionKey);

    final recordStore = await RecordStore.open(
      walletId: walletId,
      encryptionKey: encryptionKey,
      directory: directory,
      cryptoContext: cryptoContext,
    );

    return _openSession(
      recordStore: recordStore,
      cryptoContext: cryptoContext,
      preferHardwareKms: preferHardwareKms,
      trustConfig: trustConfig ?? _defaultTrustConfig,
    );
  }

  /// Desbloquea un wallet existente validando [pin] y abre una [WalletSession].
  ///
  /// Flujo:
  /// 1. Lee el salt de secure storage.
  /// 2. Verifica el hash del PIN (lanza [WrongPinError] si falla).
  /// 3. Deriva la clave AES y abre Isar.
  /// 4. Crea la sesión con [WalletCryptoContext].
  ///
  /// Lanza [WalletNotFoundError] si no hay salt para [walletId].
  /// Lanza [WrongPinError] si el hash guardado no coincide con [pin].
  Future<WalletSession> unlock({
    required String walletId,
    required String pin,
    required String directory,
    bool preferHardwareKms = false,
    TrustConfig? trustConfig,
  }) async {
    final saltHex = await _secureStorage.read(key: _saltKey(walletId));
    if (saltHex == null) throw WalletNotFoundError(walletId);

    final salt = Uint8List.fromList(hex_codec.hex.decode(saltHex));

    final pinHashHex = await _secureStorage.read(key: _pinHashKey(walletId));
    if (pinHashHex != null) {
      final expectedHash = Uint8List.fromList(hex_codec.hex.decode(pinHashHex));
      final actualHash = await _pinVerifier.derivePinHash(pin: pin, salt: salt);
      if (!_pinVerifier.verifyPinHash(expected: expectedHash, actual: actualHash)) {
        throw const WrongPinError();
      }
    }

    final encryptionKey = await _pinVerifier.deriveEncryptionKey(
      pin: pin,
      salt: salt,
    );

    final cryptoContext = WalletCryptoContext(encryptionKey: encryptionKey);

    final recordStore = await RecordStore.open(
      walletId: walletId,
      encryptionKey: encryptionKey,
      directory: directory,
      cryptoContext: cryptoContext,
    );

    return _openSession(
      recordStore: recordStore,
      cryptoContext: cryptoContext,
      preferHardwareKms: preferHardwareKms,
      trustConfig: trustConfig ?? _defaultTrustConfig,
    );
  }

  /// Bloquea la sesión activa, cierra Isar y descarta la clave en memoria.
  ///
  /// Después de [lock], los accesos a la sesión previa deben usar [unlock] de nuevo.
  Future<void> lock() async {
    await _session?.lock();
    _session = null;
  }

  /// Elimina por completo el wallet: archivos Isar, salt y hash de PIN.
  ///
  /// [directory] debe ser el mismo usado en [create] o [unlock].
  /// Si hay sesión abierta, la bloquea antes de borrar.
  Future<void> reset({
    required String walletId,
    required String directory,
  }) async {
    await lock();
    await _secureStorage.delete(key: _saltKey(walletId));
    await _secureStorage.delete(key: _pinHashKey(walletId));
    await _deleteIsarFiles(walletId: walletId, directory: directory);
  }

  WalletSession _openSession({
    required RecordStore recordStore,
    required WalletCryptoContext cryptoContext,
    required bool preferHardwareKms,
    TrustConfig? trustConfig,
  }) {
    _session = WalletSession.fromRecordStore(
      recordStore,
      kms: _buildKms(preferHardwareKms),
      cryptoContext: cryptoContext,
      trustConfig: trustConfig,
    );
    return _session!;
  }

  KmsBackendSelector _buildKms(bool preferHardware) =>
      KmsBackendSelector(preferHardware: preferHardware);

  Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  Future<void> _deleteIsarFiles({
    required String walletId,
    required String directory,
  }) async {
    for (final path in [
      '$directory/$walletId.isar',
      '$directory/$walletId.isar.lock',
    ]) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }
}
