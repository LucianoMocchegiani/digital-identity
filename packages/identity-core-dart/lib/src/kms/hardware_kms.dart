import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../record/models/key_record.dart';
import 'kms_service.dart';

/// Implementación de [KmsService] que delega a Android Keystore / iOS Secure Enclave
/// a través de un Flutter MethodChannel.
///
/// Solo soporta P-256 (ES256); Ed25519 y X25519 no tienen soporte hardware en esta fase.
/// Para claves hardware-backed: [KeyRecord.privateJwk] == null, [KeyRecord.isHardwareBacked] == true.
/// La firma retorna directamente IEEE P1363 (r||s, 64 bytes); la conversión DER→P1363
/// se realiza en el código nativo.
class HardwareKmsService implements KmsService {
  static const _channel = MethodChannel('identity_core_dart/hardware_kms');
  static const _uuid = Uuid();

  /// Retorna true si el dispositivo tiene hardware seguro disponible (Android ≥ 6 / iOS Secure Enclave).
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<KeyRecord> generateKey(KeyType keyType) async {
    if (keyType != KeyType.p256) {
      throw UnsupportedError(
        'HardwareKmsService solo soporta P-256. '
        'Para Ed25519 / X25519 usar SoftwareKms.',
      );
    }

    final keyId = _uuid.v4();
    final Map<Object?, Object?> raw = await _channel.invokeMethod('createKey', {'keyId': keyId});

    final publicJwk = <String, dynamic>{
      'kty': 'EC',
      'crv': 'P-256',
      'x': raw['x'] as String,
      'y': raw['y'] as String,
    };

    return KeyRecord(
      keyId: keyId,
      keyType: KeyType.p256,
      publicJwk: publicJwk,
      privateJwk: null,
      isHardwareBacked: true,
      createdAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<Uint8List> sign({required KeyRecord key, required Uint8List payload}) async {
    if (!key.isHardwareBacked) {
      throw ArgumentError('HardwareKmsService solo puede firmar claves hardware-backed.', 'key');
    }
    if (key.keyType != KeyType.p256) {
      throw UnsupportedError('HardwareKmsService solo soporta firma con P-256.');
    }

    final result = await _channel.invokeMethod<Uint8List>('sign', {
      'keyId': key.keyId,
      'payload': payload,
    });
    return result!;
  }

  /// Elimina la clave del keystore nativo. Llamar al borrar un [KeyRecord] hardware-backed.
  Future<void> deleteKey(String keyId) async {
    await _channel.invokeMethod<void>('deleteKey', {'keyId': keyId});
  }
}
