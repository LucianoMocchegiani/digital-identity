---
id: trust
title: Referencia de confianza (TrustConfig)
sidebar_position: 5
---

# Referencia de confianza (TrustConfig)

El subsistema de confianza valida la identidad del verifier durante el flujo OID4VP. Cuando la wallet resuelve un presentation request, el SDK analiza el header del request JWT para detectar qué mecanismo de autenticación usa el verifier y ejecuta la validación correspondiente. El resultado queda disponible para que la UI lo muestre al usuario antes de que confirme la presentación.

---

## Configuración

### La clase `TrustConfig`

```dart
class TrustConfig {
  const TrustConfig({
    this.trustedRootCertificates = const [],
    this.eudiTrustAnchorUrl,
  });

  /// Certificados raíz de confianza en base64 DER.
  final List<String> trustedRootCertificates;

  /// URL del trust anchor para OpenID Federation / EUDI.
  final String? eudiTrustAnchorUrl;
}
```

**`trustedRootCertificates`** — lista de certificados CA raíz contra los que se ancla la validación X.509. El formato esperado es base64 DER estándar o base64url, con o sin padding (la comparación normaliza ambas variantes). Si la lista está vacía, no se verifica el root: cualquier cadena X.509 estructuralmente válida se acepta.

**`eudiTrustAnchorUrl`** — URL del trust anchor de la federación EUDI (OpenID Federation). Requerido para que el mecanismo `eudiRpAuthentication` funcione; si es `null` o la cadena está vacía, los requests EUDI no son evaluados (se retorna `null` en lugar de un `TrustedEntity`).

### Cómo inyectar `TrustConfig`

`WalletService.create()` y `WalletService.unlock()` aceptan un parámetro opcional `trustConfig`. También puede definirse por defecto en el constructor de `WalletService`:

```dart
final service = WalletService(
  trustConfig: TrustConfig(trustedRootCertificates: ['MIIBxTCCAW...']),
);

final session = await service.unlock(
  walletId: walletId,
  pin: pin,
  directory: appDocumentsDir,
);
```

Vía alternativa de bajo nivel (sin `WalletService`): `WalletSession.fromRecordStore(...)`. Útil en tests o integraciones que gestionan el salt y la derivación de clave manualmente:

```dart
// 1. Recuperar o generar el salt (16 bytes) guardado en FlutterSecureStorage
//    bajo la clave 'wallet_salt_<walletId>'.
final storage = FlutterSecureStorage();
final saltBase64 = await storage.read(key: 'wallet_salt_$walletId');
final salt = base64Decode(saltBase64!);

// 2. Derivar la clave AES-256 con Argon2id.
//    Parámetros exactos: parallelism=4, memory=64 MB, iterations=8, hashLength=32.
//    El integrador debe replicar estos valores o la clave no coincidirá con la
//    base de datos creada por WalletService.
final derivedKey = await argon2id(
  password: passphrase,
  salt: salt,
  parallelism: 4,
  memory: 64 * 1024, // 64 MB en KB
  iterations: 8,
  hashLength: 32,
);

// 3. Abrir el RecordStore con la clave derivada.
//    Isar 3.1.0 no cifra el archivo .isar completo (encryptionKey ignorado por el motor).
//    Los campos sensibles se cifran por campo (enc:v1:) si la sesión usa WalletService.
//    Ver limitaciones: ../07-limitations.md
final recordStore = await RecordStore.open(
  walletId: walletId,
  encryptionKey: derivedKey,
  directory: appDocumentsDir,
);

// 4. Crear la sesión con TrustConfig inyectado.
final session = WalletSession.fromRecordStore(
  recordStore,
  trustConfig: TrustConfig(
    trustedRootCertificates: ['MIIBxTCCAW...'],
    eudiTrustAnchorUrl: 'https://trust-anchor.example.eu',
  ),
);
```

> **Vía avanzada:** `WalletSession.fromRecordStore` sigue disponible cuando el integrador no usa `WalletService` y debe replicar la derivación Argon2id manualmente. Ver [Limitaciones](../07-limitations.md).

---

## Mecanismos de confianza

El SDK detecta automáticamente el mecanismo según el contenido del request JWT. La lógica de detección es la siguiente (en orden de prioridad):

1. Si se completó una verificación de firma OpenID Federation (`signatureVerified != null`) → **EUDI RP Authentication**.
2. Si el header del JWT contiene la clave `x5c` → **X.509**.
3. Si el `client_id` empieza con `did:` → **DID**.
4. Default → **DID**.

| Mecanismo | Enum | Qué valida |
|---|---|---|
| X.509 | `TrustMechanismType.x509` | Validez temporal del certificado leaf; coincidencia de `client_id` con SAN URI o SAN DNS del leaf; continuidad estructural de la cadena (issuer[i] == subject[i+1]); si `trustedRootCertificates` no está vacío, el root debe estar en la lista (comparación byte a byte). **No verifica firmas criptográficas** de la cadena (limitación de la implementación actual). |
| DID | `TrustMechanismType.did` | Resolución del DID del verifier; si el header del JWT contiene `kid`, verifica que esté presente en el DID Document. Es el mecanismo más débil: solo garantiza que el DID es resolvible, no que el verifier pertenece a ningún trust framework. |
| EUDI RP Authentication | `TrustMechanismType.eudiRpAuthentication` | Descarga el Entity Statement del verifier desde `<clientId>/.well-known/openid-federation`; extrae `organization_name` y `logo_uri` del entity statement. La verificación de la cadena completa de OpenID Federation (multi-hop hasta el trust anchor) **no está implementada** en la versión actual: el JWT del entity statement se decodifica sin verificar la firma. Requiere `eudiTrustAnchorUrl` configurado. |

---

## Comportamiento sin `TrustConfig`

Cuando no se provee `TrustConfig` (el caso por defecto de `WalletService.create()` y `unlock()`):

- **X.509:** la validación procede sin verificar el root. Cualquier cadena estructuralmente válida y no vencida produce `isVerified: true`.
- **DID:** la validación procede normalmente (sin impacto, `TrustConfig` no afecta al mecanismo DID).
- **EUDI RP Authentication:** `eudiTrustAnchorUrl` es `null` → el SDK retorna `null` como `trustedEntity` (no se lanza ningún error; el verifier queda sin información de confianza).

En ningún caso la ausencia de `TrustConfig` bloquea el flujo de presentación ni lanza una excepción. La evaluación de confianza es informativa: la decisión de continuar o cancelar la presentación queda en manos del integrador.

---

## Qué ve el integrador

Después de llamar a `session.openid4vp.resolveRequest(uri)`, el resultado es un `CredentialsForRequest` cuyo campo `trustedEntity` contiene la evaluación de confianza:

**Semántica de `null` vs `isVerified: false`**

Los dos valores indican cosas distintas; no son equivalentes:

- **DID no resolvible o `kid` ausente en el DID Document** → retorna `TrustedEntity` **no-null** con `isVerified: false`. El mecanismo se detectó correctamente pero la validación falló.
- **EUDI — falla en la descarga del Entity Statement** → hay fallback a `client_metadata` inline; retorna `TrustedEntity` **no-null** con `isVerified: false` (no `null`). (Verificado contra `eudi_rp_trust.dart`.)
- **`null`** solo cuando no se pudo determinar ningún mecanismo: request sin JWT (parámetros directos en URI), mecanismo EUDI sin `eudiTrustAnchorUrl` configurado, o error irrecuperable antes de la evaluación.

```dart
final request = await session.openid4vp.resolveRequest(uri);

final entity = request.trustedEntity; // TrustedEntity?

if (entity == null) {
  // No se pudo determinar ningún mecanismo de confianza:
  // — request sin JWT (parámetros directos en URI), o
  // — mecanismo EUDI sin eudiTrustAnchorUrl configurado, o
  // — error irrecuperable antes de la evaluación.
}

if (entity != null) {
  entity.isVerified;                  // bool — true si la validación fue exitosa
  entity.trustMechanism;              // TrustMechanismType — x509 / did / eudiRpAuthentication
  entity.relyingParty.entityId;       // String — client_id del verifier
  entity.relyingParty.organizationName; // String? — nombre de la organización
  entity.relyingParty.logoUri;        // String? — URI del logo
  entity.relyingParty.domain;         // String? — dominio (solo X.509, SAN DNS)
  entity.relyingParty.uri;            // String? — URI de la entidad
  entity.did;                         // String? — DID del verifier (solo mecanismo DID)
  entity.certificateChain;            // List<String>? — cadena x5c (solo X.509)
}
```

`isVerified: false` no bloquea la presentación. Es información que la wallet puede usar para mostrar una advertencia al usuario ("verifier no verificado") antes de confirmar.

---

## Ver también

- [Presentación de credenciales (OID4VP)](../04-flows/03-oid4vp.md) — flujo completo donde se usa la evaluación de confianza.
- [Ciclo de vida del wallet](../03-wallet-lifecycle.md) — vía avanzada de inyección mediante `WalletSession.fromRecordStore`.
- [Limitaciones](../07-limitations.md) — limitaciones de la API de inyección de `TrustConfig` y estado de la verificación criptográfica.
