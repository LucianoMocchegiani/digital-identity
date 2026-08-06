import 'dart:typed_data';

import '../record/models/key_record.dart';
import 'hardware_kms.dart';
import 'kms_service.dart';
import 'software_kms.dart';

/// Selecciona automáticamente el backend KMS correcto para cada operación.
///
/// - [preferHardware] == true: usa [HardwareKmsService] para P-256 (si disponible),
///   y [SoftwareKms] para Ed25519 / X25519.
/// - Firma: siempre delega al backend según [KeyRecord.isHardwareBacked].
class KmsBackendSelector implements KmsService {
  KmsBackendSelector({
    required this.preferHardware,
    SoftwareKms? softwareKms,
    HardwareKmsService? hardwareKms,
  })  : _soft = softwareKms ?? SoftwareKms(),
        _hard = hardwareKms ?? HardwareKmsService();

  final bool preferHardware;
  final SoftwareKms _soft;
  final HardwareKmsService _hard;

  @override
  Future<KeyRecord> generateKey(KeyType keyType) async {
    if (preferHardware && keyType == KeyType.p256) {
      final available = await HardwareKmsService.isAvailable();
      if (available) return _hard.generateKey(keyType);
    }
    return _soft.generateKey(keyType);
  }

  @override
  Future<Uint8List> sign({required KeyRecord key, required Uint8List payload}) {
    if (key.isHardwareBacked) return _hard.sign(key: key, payload: payload);
    return _soft.sign(key: key, payload: payload);
  }
}
