import 'dart:typed_data';

import '../record/models/key_record.dart';

/// Interfaz de gestión de claves criptográficas del wallet.
///
/// Abstrae la generación y firma de claves, permitiendo dos implementaciones:
/// - [SoftwareKms]: claves software en memoria, protegidas por el cifrado de isar.
/// - HardwareKmsService (Fase 8): firma via platform channel hacia Android Keystore
///   o iOS Secure Enclave.
///
/// La persistencia de los [KeyRecord] generados es responsabilidad del caller
/// (normalmente a través de [KeyRecordStore]).
abstract class KmsService {
  /// Genera un nuevo par de claves del tipo [keyType].
  ///
  /// Retorna el [KeyRecord] con [KeyRecord.privateJwk] incluido.
  /// El caller debe persistir el record en [KeyRecordStore] antes de usarlo.
  ///
  /// Lanza [UnsupportedError] si el [keyType] no está soportado por esta implementación.
  Future<KeyRecord> generateKey(KeyType keyType);

  /// Firma [payload] con la clave privada de [key].
  ///
  /// Para Ed25519: retorna firma raw de 64 bytes (RFC 8032).
  /// Para P-256 (ES256): retorna r||s (IEEE P1363, 64 bytes), compatible con JWT.
  ///
  /// Lanza [UnsupportedError] si [key.isHardwareBacked] es true (usar HardwareKmsService).
  /// Lanza [ArgumentError] si [key.privateJwk] es null.
  Future<Uint8List> sign({required KeyRecord key, required Uint8List payload});
}
