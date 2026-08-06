import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_record.freezed.dart';

/// Tipo de curva criptográfica de una clave.
enum KeyType {
  /// Ed25519 — EdDSA, usado en DIDComm y ecosistemas Aries.
  ed25519,

  /// P-256 (secp256r1) — ES256, requerido por EUDI y hardware seguro (SE/TEE).
  p256,

  /// X25519 — Diffie-Hellman en Curve25519, usado para key agreement en DIDComm.
  ///
  /// No es un algoritmo de firma; solo se usa para ECDH en anoncrypt/authcrypt.
  x25519,
}

/// Registro de un par de claves criptográficas almacenado en el wallet.
///
/// Las claves software almacenan [privateJwk] (protegido por el cifrado de isar).
/// Las claves hardware-backed (`isHardwareBacked: true`) tienen [privateJwk] nulo
/// porque la clave privada nunca sale del chip (Android Keystore / iOS Secure Enclave).
@freezed
class KeyRecord with _$KeyRecord {
  const factory KeyRecord({
    /// Identificador único de la clave (UUID v4).
    required String keyId,

    /// Tipo de curva criptográfica.
    required KeyType keyType,

    /// JWK público (sin campo `d`), seguro para compartir.
    required Map<String, dynamic> publicJwk,

    /// JWK privado completo (incluye campo `d`).
    ///
    /// `null` para claves hardware-backed, donde la clave privada reside
    /// en el chip y nunca puede ser exportada.
    Map<String, dynamic>? privateJwk,

    /// Indica si la clave privada está protegida por hardware (SE/TEE).
    ///
    /// Cuando es `true`, las operaciones de firma se realizan via platform channel
    /// hacia [HardwareKmsService] (Fase 8).
    required bool isHardwareBacked,

    /// Fecha de generación de la clave.
    required DateTime createdAt,

    /// DID asociado a esta clave, si fue creado como parte de una identidad.
    String? did,
  }) = _KeyRecord;
}
