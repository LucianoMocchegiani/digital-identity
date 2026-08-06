---
id: kms
title: Referencia del KMS
sidebar_position: 4
---

# Referencia del KMS

El KMS (*Key Management Service*) es la capa del SDK responsable de generar pares de claves criptográficas y producir firmas. Se expone como la interfaz abstracta `KmsService`, con dos implementaciones concretas: `SoftwareKms` y `HardwareKmsService`.

El integrador **raramente interactúa con el KMS directamente**. Los servicios de protocolo (OID4VCI, OID4VP, DIDComm) firman internamente a través de `session.kms`. Solo en casos avanzados —migración de claves, diagnóstico o integración con hardware personalizado— es necesario acceder al KMS de forma explícita.

---

## Interfaz `KmsService`

```dart
abstract class KmsService {
  Future<KeyRecord> generateKey(KeyType keyType);

  Future<Uint8List> sign({
    required KeyRecord key,
    required Uint8List payload,
  });
}
```

### `generateKey`

Genera un nuevo par de claves del tipo indicado. Retorna un `KeyRecord` con `privateJwk` incluido (excepto para claves hardware-backed, donde `privateJwk` es `null`). **La persistencia del `KeyRecord` es responsabilidad del caller**; normalmente se delega al `KeyRecordStore` a través de `session.keyStore`.

Lanza `UnsupportedError` si el `keyType` no está soportado por la implementación concreta.

### `sign`

Firma `payload` con la clave privada de `key`. El formato de la firma depende del algoritmo:

| Algoritmo | Formato retornado |
|---|---|
| Ed25519 | Firma raw de 64 bytes (RFC 8032) |
| P-256 (ES256) | `r\|\|s` en IEEE P1363, 64 bytes (compatible con JWT) |

Lanza `UnsupportedError` si `key.isHardwareBacked` es `true` (usar `HardwareKmsService` en ese caso). Lanza `ArgumentError` si `key.privateJwk` es `null`.

### Enum `KeyType`

```dart
enum KeyType {
  ed25519,  // EdDSA — DIDComm, ecosistemas Aries
  p256,     // ES256 (secp256r1) — EUDI, hardware seguro (SE/TEE)
  x25519,   // ECDH Curve25519 — key agreement en DIDComm (no es algoritmo de firma)
}
```

> **Nota sobre X25519:** `KeyType.x25519` no puede usarse para firmar. Cualquier llamada a `sign` con una clave de este tipo lanza `UnsupportedError`. Su único uso es el key agreement en DIDComm (anoncrypt/authcrypt).

---

## `SoftwareKms`

Implementación en pure Dart. Soporta los tres `KeyType`:

| `KeyType` | Biblioteca usada | Observación |
|---|---|---|
| `ed25519` | `cryptography` (pure Dart) | Generación y firma |
| `p256` | `pointycastle` | `DartEcdsa` del paquete `cryptography` no implementa `newKeyPair()` ni `sign()` en Android |
| `x25519` | `cryptography` (pure Dart) | Solo generación; no admite firma |

### Persistencia de claves

Las claves software se persisten como `KeyRecord` en la colección Isar `keyRecordIsars`. El campo `privateJwkJson` contiene el JWK privado serializado.

> ⚠️ **Cifrado por campo:** con sesión abierta vía `WalletService`, `privateJwkJson` se persiste con prefijo `enc:v1:` (AES-256-GCM). Claves hardware-backed mantienen `privateJwkJson` null. El archivo `.isar` completo sigue sin cifrar — ver [Limitaciones #1](../07-limitations.md).

---

## `HardwareKmsService`

Implementación que delega a hardware seguro del dispositivo (Android Keystore / iOS Secure Enclave) a través de un Flutter `MethodChannel`.

### Identificador del channel

```dart
static const _channel = MethodChannel('identity_core_dart/hardware_kms');
```

### Métodos nativos invocados

Los siguientes métodos son el contrato que deben implementar los plugins nativos (Kotlin en Android, Swift en iOS). Son invocados internamente por los métodos Dart de `HardwareKmsService`; el integrador no los llama directamente.

| Método nativo | Parámetros | Qué hace |
|---|---|---|
| `isAvailable` | — | Retorna `bool`; detecta si el dispositivo tiene hardware seguro (Android ≥ 6 / iOS Secure Enclave) |
| `createKey` | `keyId: String` | Genera una clave P-256 en el keystore nativo; retorna `x` e `y` (coordenadas públicas en base64url) |
| `sign` | `keyId: String`, `payload: Uint8List` | Firma `payload` con la clave identificada por `keyId`; retorna IEEE P1363 (`r\|\|s`, 64 bytes) |
| `deleteKey` | `keyId: String` | Elimina la clave del keystore nativo |

### `deleteKey`

`HardwareKmsService` expone también el método público `Future<void> deleteKey(String keyId)`, que el integrador puede invocar directamente al eliminar un `KeyRecord` hardware-backed. Tras llamar a `session.keyStore.delete(keyRecord)`, se recomienda llamar a `session.kms.hardwareKms.deleteKey(keyRecord.keyId)` para asegurarse de que la clave quede eliminada también del Android Keystore / iOS Secure Enclave y no deje material criptográfico huérfano en el chip.

### Soporte de algoritmos

`HardwareKmsService` **solo soporta `KeyType.p256`**. Cualquier llamada a `generateKey` con `KeyType.ed25519` o `KeyType.x25519` lanza:

```
UnsupportedError: HardwareKmsService solo soporta P-256.
Para Ed25519 / X25519 usar SoftwareKms.
```

Las claves hardware-backed tienen `KeyRecord.privateJwk == null` e `isHardwareBacked == true`. La clave privada nunca abandona el chip.

Si el `MethodChannel` no tiene un plugin registrado (por ejemplo, en entornos de test o en plataformas no soportadas), `isAvailable()` atrapa `MissingPluginException` y retorna `false`.

---

## `KmsBackendSelector`

El selector es la implementación de `KmsService` que el SDK instancia internamente. Elige el backend correcto según la configuración y el tipo de clave:

```
generateKey(keyType):
  si preferHardware == true Y keyType == p256:
    si HardwareKmsService.isAvailable() == true → usa HardwareKmsService
    si no → usa SoftwareKms (fallback silencioso)
  en cualquier otro caso → usa SoftwareKms

sign(key, payload):
  si key.isHardwareBacked == true → delega a HardwareKmsService
  si no → delega a SoftwareKms
```

**Punto clave del fallback:** si `preferHardwareKms: true` pero el hardware no está disponible en el dispositivo, el selector cae silenciosamente a `SoftwareKms` para P-256. No se lanza ningún error ni se emite ninguna advertencia.

---

## Cómo activar el KMS hardware

El parámetro `preferHardwareKms` se pasa en `WalletService.create()` o `WalletService.unlock()`:

```dart
// Crear wallet con hardware KMS activado
final createSession = await walletService.create(
  walletId: 'mi-wallet',
  pin: '123456',
  directory: appDir,
  preferHardwareKms: true,   // P-256 irá a Android Keystore / iOS Secure Enclave
);
```

```dart
// Desbloquear manteniendo la misma preferencia
final unlockSession = await walletService.unlock(
  walletId: 'mi-wallet',
  pin: '123456',
  directory: appDir,
  preferHardwareKms: true,
);
```

Ver [Ciclo de vida del wallet](../03-wallet-lifecycle.md) para el contexto completo de `create` y `unlock`.

---

## Cuándo lo usa el integrador

En la gran mayoría de los casos, **el integrador no llama al KMS directamente**. Los servicios de protocolo firman internamente:

- OID4VCI: firma el DPoP proof y el JWT de presentación de clave.
- OID4VP: firma la VP Token.
- DIDComm: firma el DID Exchange Request y realiza el key agreement ECDH para el cifrado JWE.

Los únicos casos en que el integrador puede necesitar el KMS de forma explícita son:

- **Generación de claves adicionales** fuera de los flujos de DID (por ejemplo, claves de propósito específico).
- **Firma de payloads ad hoc** que no correspondan a ningún protocolo estándar del SDK.
- **Diagnóstico o migración**: consultar o rotar claves via `session.keyStore`.

---

## Ver también

- [Ciclo de vida del wallet](../03-wallet-lifecycle.md) — parámetro `preferHardwareKms` en `create` y `unlock`
- [DIDs](03-dids.md) — generación de claves asociada a la creación de DIDs
- [Referencia de Stores](01-stores.md) — `KeyRecordStore` y persistencia de `KeyRecord`
- [Limitaciones](../07-limitations.md) — cifrado en reposo y cifrado por campo en stores
