---
id: limitations
title: Limitaciones conocidas
sidebar_position: 7
---

# Limitaciones conocidas

Este documento describe el estado honesto del SDK a la fecha de **última verificación: julio 2026**. El objetivo es que el integrador pueda tomar decisiones de diseño e informar a los usuarios finales sin sorpresas. Cada limitación incluye su evidencia en el código fuente, su implicación práctica y, cuando existe, un workaround.

---

## Tabla resumen

| # | Limitación | Grupo | Severidad | Estado |
|---|-----------|-------|-----------|--------|
| 1 | Cifrado en reposo parcial (archivo Isar completo sin cifrar) | Seguridad | **Media** | Cifrado por campo `enc:v1:` implementado; metadatos en claro |
| 2 | X.509: sin verificación de firmas | Seguridad | **Alta** | TODO pendiente |
| 3 | EUDI RP: JWT sin verificación de firma | Seguridad | **Alta** | MVP |
| 4 | Backup/recovery no implementado | Funcionalidad | **Alta** | Sin fecha |
| 5 | Hardware KMS parcial | Funcionalidad | **Media** | Fase 8 |
| 6 | mDoc ISO 18013-5 parcial | Funcionalidad | **Media** | Fase 4 |
| 7 | DIDComm — exchanges no persistidos / inbound ad-hoc | Funcionalidad | **Media** | Handshake + WS funcionales; ver §7 |
| 8 | ~~Interop DIDComm SDK ↔ Quark (envelope)~~ | Funcionalidad | — | **Resuelto** (Envelope V1) |
| 9 | `retryDeferred` siempre retorna `null` | Funcionalidad | **Media** | Sin fecha |
| 10 | ~~`TrustConfig` no inyectable vía `WalletService`~~ | Funcionalidad | **Baja** | Resuelto — ver `WalletService.trustConfig` |
| 11 | `Dio` custom no inyectable | Funcionalidad | **Baja** | Por diseño |
| 12 | `did:peer` no integrado al resolver universal | Funcionalidad | **Baja** | Por diseño |
| 13 | No publicado en pub.dev | Distribución | **Alta** | Repo privado |
| 14 | JARM: solo ECDH-ES + A128GCM + P-256 | Funcionalidad | **Baja** | MVP EUDI |
| 15 | BBS+ selective disclosure (holder) | Funcionalidad | **Baja** | Mobile: Dart LD + `libbbs` FFI; desktop/CI: Node MATTR bridge |

---

## Seguridad

Estas tres limitaciones son las más críticas. Afectan directamente la confidencialidad de las credenciales y las claves privadas en reposo, y la autenticidad de las cadenas de confianza con issuers y verifiers.

---

### 1. Cifrado en reposo parcial (archivo Isar completo sin cifrar)

**Qué pasa.** `RecordStore.open()` recibe un parámetro `encryptionKey` (32 bytes, derivado con Argon2id del PIN) pero **Isar 3.1.0+1 no lo aplica** a nivel de motor. El archivo `.isar` —índices, metadatos de actividad, conexiones, DIDs, fechas, `vct`, etc.— queda **sin cifrar como base de datos completa**.

**Mitigación implementada.** Cuando la sesión se abre vía `WalletService.create()` / `unlock()`, los stores sensibles cifran valores críticos con [FieldCipher](../lib/src/crypto/field_cipher.dart) (formato `enc:v1:` + AES-256-GCM) usando [WalletCryptoContext](../lib/src/crypto/wallet_crypto_context.dart):

| Store | Campos cifrados en disco |
|---|---|
| `KeyRecordStore` | `privateJwkJson` (null en claves hardware-backed) |
| `CredentialRecordStore` | SD-JWT: `compactSdJwt`, `prettyClaimsJson`, metadata opcional; W3C: `credentialJson`; mDoc: `issuerSignedBase64`, `namespacesJson` |
| `DeferredCredentialRecordStore` | `accessTokenJson`, `responseJson` |

**Evidencia (motor Isar).** `lib/src/record/record_store.dart`:
```
// encryptionKey ignored: isar 3.1.0+1 open() doesn't expose encryptionKey parameter.
```

**Causa.** Limitación del motor Isar 3.x. El SDK mitiga con **cifrado AES-256-GCM por campo** en lugar de depender de Isar 4 prerelease.

**Implicación para bax.** Con acceso al filesystem (root, extracción forense, backup inseguro) pueden leerse **metadatos** y registros legacy aún en texto plano. Los campos sensibles escritos con `WalletService` quedan ilegibles sin el PIN correcto. El sandbox de Android/iOS mitiga en dispositivos no comprometidos.

**Estado.** Implementado: validación de PIN (hash Argon2id en secure storage), derivación de clave y cifrado por campo en los stores anteriores. **Pendiente:** migración automática de registros legacy en claro (PR3); stores no sensibles (`activity`, `connection`, `did`) sin cifrar.

**Wallets legacy.** Registros guardados antes de esta versión pueden seguir en texto plano hasta que se reescriban o corra el migrador. Wallets sin `wallet_pin_hash_*` no validan PIN en `unlock()` hasta un `reset` + onboarding nuevo.

**Mitigaciones.** `android:allowBackup="false"`; no afirmar protección total del archivo `.isar`. Ver [análisis de opciones](../../../docs/deuda-tecnica/wallet-persistencia-cifrado-analisis.md).

**Ver también.** [Ciclo de vida del wallet](03-wallet-lifecycle.md), [Stores](05-reference/01-stores.md), `lib/src/crypto/README.md`.

---

### 2. X.509: sin verificación criptográfica de firmas de la cadena

**Qué pasa.** `X509Trust.validate()` realiza cuatro verificaciones sobre la cadena de certificados del header `x5c`: validez temporal del leaf, coincidencia de `clientId` con el SAN, continuidad estructural (el campo `issuer` de cada cert coincide con el `subject` del siguiente) y root pinning (comparación byte a byte del DER). Sin embargo, **no verifica que cada certificado haya sido firmado criptográficamente por la clave privada de la CA anterior**.

**Evidencia.** `lib/src/trust/x509_trust.dart`, método `_validChain`, líneas 289–291:
```
// TODO: agregar verificación criptográfica de firma cuando sea necesario:
//   signer.init(false, PublicKeyParameter(certs[i+1].publicKey))
//   signer.verifySignature(certs[i].tbsBytes, certs[i].signature)
```

**Implicación para bax.** Un atacante podría presentar una cadena X.509 estructuralmente coherente pero con certificados fabricados. El riesgo es reducido cuando se usa root pinning (la CA raíz se compara byte a byte), pero **si no se configuran `trustedRootCertificates`, la validación de confianza X.509 no tiene respaldo criptográfico**.

**Workaround.** Siempre configurar `TrustConfig` con una lista no vacía de `trustedRootCertificates` al usar X.509. Ver [Trust](05-reference/05-trust.md) para la configuración de trust registries.

---

### 3. EUDI RP: JWT del entity statement sin verificación de firma

**Qué pasa.** `EudiRpTrust.validate()` descarga el entity statement del verifier EUDI desde `/.well-known/openid-federation` y extrae la metadata del payload JWT. El JWT **no se verifica criptográficamente**: no se valida la firma, ni se recorre la cadena de confianza OpenID Federation hasta el trust anchor.

**Evidencia.** `lib/src/trust/eudi_rp_trust.dart`, línea 58:
```
// Decodificar payload del JWT (sin verificar firma — MVP)
```

**Implicación para bax.** Un verifier malicioso podría servir un JWT con metadata falsificada (por ejemplo, declarar un `client_id` legítimo). La implementación actual es adecuada para un MVP o entorno controlado, pero **no debe usarse como control de seguridad en producción frente a verifiers no confiables**.

**Workaround.** Combinado con `trustedRootCertificates` en X.509 (limitación #2) ofrece una mitigación parcial. Para producción con EUDI, la verificación completa de firma JWT y la resolución de cadena de federación deben estar implementadas en el SDK antes de habilitar este flujo.

**Ver también.** [Trust](05-reference/05-trust.md).

---

## Funcionalidad

---

### 4. Backup y recovery no implementados

**Qué pasa.** El SDK no ofrece ningún mecanismo de exportación de material de clave (seed, mnemónico BIP-39 ni ningún equivalente). Si el usuario pierde el dispositivo, lo resetea o desinstala la app, **todas las credenciales y claves privadas se pierden de forma irrecuperable**. No hay restauración posible desde otro dispositivo.

**Evidencia.** Ausencia de cualquier método `exportSeed`, `exportMnemonic` o equivalente en `WalletService` y en `KmsService`/`SoftwareKms`. La funcionalidad no está planificada en ninguna fase documentada del roadmap actual.

**Implicación para bax.** bax debe comunicar explícitamente esta limitación en su UX —por ejemplo, en el onboarding y en pantallas de gestión del dispositivo— para que el usuario no espere poder recuperar su wallet desde otro teléfono. No mostrar opciones de backup que el SDK no puede cumplir.

**Workaround.** Ninguno dentro del SDK. Si la app necesita portabilidad de credenciales, debe implementar su propia lógica de exportación cifrada fuera del SDK (exportar el JSON de credenciales, no el material de clave).

**Ver también.** [Ciclo de vida del wallet](03-wallet-lifecycle.md).

---

### 5. Hardware KMS parcial

**Qué pasa.** El SDK expone un `MethodChannel` real (`identity_core_dart/hardware_kms`) para delegar operaciones criptográficas al hardware del dispositivo (Android Keystore / iOS Secure Enclave). Sin embargo:

- Solo la curva **P-256** tiene soporte en hardware.
- **Ed25519 y X25519** siempre ejecutan en `SoftwareKms`, independientemente de la disponibilidad del hardware.
- Si el canal nativo no está presente (el plugin nativo no fue integrado en la app host), el SDK **falla silenciosamente** a `SoftwareKms` sin emitir advertencia.
- La integración del lado nativo (Kotlin/Swift) es responsabilidad de la app host — corresponde a la **Fase 8** del roadmap.

**Evidencia.** `lib/src/crypto/hardware_kms.dart` — el fallback silencioso a `SoftwareKms` ocurre en el `catch` de la invocación del channel; `lib/src/crypto/software_kms.dart` — las operaciones Ed25519/X25519 nunca intentan el channel de hardware.

**Implicación para bax.** Si bax necesita que las claves nunca salgan del hardware del dispositivo (por requisitos de certificación o compliance), debe verificar qué operaciones terminan en hardware y cuáles en software. Actualmente, las claves Ed25519 —las más usadas en DIDs— siempre están en software.

**Workaround.** Para operaciones P-256 en hardware, integrar el plugin nativo en la Fase 8. Para Ed25519, no hay alternativa dentro del SDK hoy.

**Ver también.** [KMS](05-reference/04-kms.md).

---

### 6. mDoc ISO 18013-5 parcial

**Qué pasa.** El modelo `MdocRecord` existe y persiste credenciales mDoc con `namespaces` pre-decodificados. Sin embargo, el parser CBOR completo (`MdocParser`) que debería decodificar el CBOR raw de un issuer signed document **no está implementado**. Esta funcionalidad corresponde a la **Fase 4** del roadmap.

**Evidencia.** `lib/src/record/models/mdoc_record.dart` — el campo `namespaces` es un `Map<String, dynamic>` pero no hay lógica de parsing CBOR en ningún archivo del árbol de `lib/src/`.

**Implicación para bax.** No es posible recibir ni procesar credenciales mDoc (documentos de identidad digitales como el mDL) usando solo este SDK hoy. El almacenamiento del modelo está listo para cuando el parser esté disponible.

**Workaround.** Posponer la integración de flujos mDoc hasta que la Fase 4 esté completa.

**Ver también.** [Credenciales](05-reference/02-credentials.md).

---

### 7. DIDComm — persistencia de exchanges y canales ad-hoc

**Qué pasa.** El handshake DID Exchange, el envelope Credo V1 y `DidCommFlowSession` (WS) cubren emisión y verificación con Quark. Quedan pendientes:

- Persistencia durable de `CredentialExchangeRecord` / `ProofExchangeRecord` (hoy en memoria de sesión).
- Canales inbound fuera de la sesión WS (push/polling) vía `handleIncomingMessage`.

**Workaround.** Mantener la pantalla de flujo abierta hasta completar offer/request. Para OID4VCI/OID4VP usar esos protocolos.

**Ver también.** [DIDComm](04-flows/04-didcomm.md).

---

### 8. ~~Interoperabilidad DIDComm SDK ↔ Quark (envelope)~~ (resuelto)

**Qué pasa.** Antes el SDK usaba JWE XC20P (DIDComm v2) incompatible con Credo. Ahora `DidCommEnvelopeV1` habla el mismo Authcrypt/Anoncrypt v1 que issuer/verifier.

**Ver también.** [DIDComm](04-flows/04-didcomm.md).

---

### 9. `retryDeferred` siempre retorna `null`

**Qué pasa.** El método `Oid4VciService.retryDeferred()` consulta el deferred credential endpoint del issuer con el `transaction_id` guardado. Si el issuer ya emitió la credencial, actualiza el `DeferredCredentialRecord` con la respuesta, pero **siempre retorna `null`** en lugar de retornar el `CredentialRecord` resultante. El comentario en el código es explícito: `// El caller debe parsear e insertar con parseAndStore`.

**Evidencia.** `lib/src/protocol/openid4vc/oid4vci/oid4vci_service.dart`, línea 136:
```dart
return null; // El caller debe parsear e insertar con parseAndStore
```

**Implicación para bax.** Al llamar a `retryDeferred()` y recibir `null`, bax no puede distinguir entre "la credencial todavía no está lista" y "la credencial está lista pero tenés que parsearla vos". Debe leer el `DeferredCredentialRecord` actualizado, verificar si el campo `response` contiene un `credential`, parsearlo manualmente e insertarlo en el store de credenciales usando `parseAndStore`.

**Workaround.** Después de llamar a `retryDeferred()`, releer el `DeferredCredentialRecord` del store. Si `record.response['credential'] != null`, invocar el método de parsing correspondiente (SD-JWT VC, W3C JWT) e insertar el resultado manualmente.

**Ver también.** [OID4VCI](04-flows/02-oid4vci.md).

---

### 10. ~~`TrustConfig` no inyectable vía `WalletService`~~ (resuelto)

`WalletService` acepta `TrustConfig` en el constructor y en `create()` / `unlock()`. Ver [Trust](05-reference/05-trust.md).

---

### 11. `Dio` custom no inyectable

**Qué pasa.** No es posible configurar un `Dio` custom (por ejemplo, con un `HttpClientAdapter` para certificados TLS autofirmados o un proxy de debugging) a través de la API pública del SDK. Los constructores de `Oid4VciService` y `Oid4VpService` sí declaran un parámetro `Dio? dio`, pero no son alcanzables por la vía pública: `WalletSession.fromRecordStore()` los instancia internamente sin exponer ese parámetro, y `WalletService` tampoco lo acepta.

**Evidencia.** `lib/src/wallet/wallet_service.dart` y `lib/src/wallet/wallet_session.dart` — ninguno de los dos expone un parámetro `Dio` en sus firmas públicas. Los constructores de `Oid4VciService` y `Oid4VpService` en `lib/src/protocol/` tienen el parámetro pero son de uso interno.

**Implicación para bax.** Durante el desarrollo con servidores locales o staging que usen TLS autofirmado, la integración fallará con errores de certificado sin posibilidad de bypass desde el SDK. En producción, no es posible auditar el tráfico del SDK desde un proxy como Charles o mitmproxy sin modificar el código fuente.

**Workaround.** Ver [Troubleshooting → "Errores TLS con servidores locales"](06-troubleshooting.md) para la alternativa actual (configuración a nivel del sistema operativo del dispositivo).

---

### 12. `did:peer` no integrado al resolver universal

**Qué pasa.** `session.dids.resolve('did:peer:...')` retorna `null`. El resolver universal del SDK no incluye soporte para el método `did:peer`. La resolución de DIDs peer sí está disponible mediante la API de bajo nivel `DidPeer.resolve()`, pero no a través del resolver unificado.

**Evidencia.** `lib/src/did/did_service.dart` — el método `resolve()` delega en los resolvers registrados; `did:peer` no está registrado. `lib/src/did/did_peer.dart` — expone `DidPeer.resolve()` de forma independiente.

**Implicación para bax.** Si bax usa `did:peer` en flujos DIDComm (los DIDs peer son la forma estándar de identificar agentes en DIDComm), debe llamar a `DidPeer.resolve()` directamente en lugar de usar el resolver central. Esto requiere conocer cuándo el DID a resolver es de tipo `did:peer` y bifurcar el código.

**Workaround.** Verificar el prefijo del DID antes de resolver: si comienza con `did:peer:`, llamar a `DidPeer.resolve()`; en caso contrario, usar `session.dids.resolve()`.

**Ver también.** [DIDs](05-reference/03-dids.md).

---

## Distribución

---

### 13. No publicado en pub.dev — solo git dependency privada

**Qué pasa.** El paquete `identity_core_dart` no está publicado en [pub.dev](https://pub.dev). La única forma de incluirlo como dependencia es mediante una git dependency apuntando al repositorio privado Bitbucket `fleetstudio/quarkid-identity-core-dart`.

**Evidencia.** Ausencia del paquete en pub.dev; instrucciones de instalación en `pubspec.yaml` vía `git:` en [Instalación](02-installation.md).

**Implicación para bax.** bax necesita que el equipo de Phinx Lab otorgue acceso de lectura al repositorio privado de Bitbucket para cada desarrollador y para el entorno de CI/CD. Las actualizaciones del SDK no llegan automáticamente via `pub upgrade`; requieren actualizar el `ref` o el `path` en el `pubspec.yaml`. Las herramientas de análisis de dependencias de pub.dev (auditorías de seguridad, compatibilidad de versiones) no están disponibles para este paquete.

**Workaround.** Solicitar acceso al repositorio a través del equipo de Phinx Lab. Para CI/CD, configurar las credenciales SSH o HTTPS de Bitbucket en el pipeline. No hay workaround para la ausencia en pub.dev; es una decisión de distribución del equipo.

**Ver también.** [Instalación](02-installation.md).

---

### 14. JARM: algoritmos de respuesta cifrada limitados

**Qué pasa.** Para `response_mode: direct_post.jwt`, el SDK cifra la respuesta con JWE usando
`JarmEncrypt` (`lib/src/protocol/openid4vc/oid4vp/jarm_encrypt.dart`). Solo se soporta
`ECDH-ES` como `alg`, `A128GCM` como `enc` y claves del receptor con `crv: P-256`.

**Implicación para bax.** Verifiers EUDI estándar (`verifier.eudiw.dev`) usan exactamente este
perfil. Si un verifier futuro exigiera otra curva o `enc`, el envío fallará con
`SubmitPresentationResult(success: false)` antes del POST HTTP.

**Workaround.** Ninguno dentro del SDK hasta ampliar `JarmEncrypt`.

**Ver también.** [OID4VP — Perfil EUDI](04-flows/03-oid4vp.md#perfil-eudi-dcql--jarm).

---

### 15. BBS+ selective disclosure — límites del MVP holder

**Qué hay.** Derive/verify de `BbsBlsSignatureProof2020` en mobile usa `DartBbsLdSuite`
+ `libbbs` (`dart:ffi`). En desktop/CI el oracle es `tool/bbs_mattr_bridge.mjs` (MATTR).

**Límites.** Reveal materializado sin `jsonld.frame` completo: VCs con blank nodes anidados
en el subject pueden diferir de MATTR. Emisión BLS no está en el KMS de la wallet (solo holder).

**Workaround / detalle.** Ver `docs/spikes/bbs-dart-wallet-spike.md` y
`docs/spikes/bbs-dart-native-design.md` en el repo padre.

---

## Ver también

- [Ciclo de vida del wallet](03-wallet-lifecycle.md) — modelo de seguridad y derivación de clave con Argon2id.
- [OID4VCI — Recepción de credenciales](04-flows/02-oid4vci.md) — flujo de credenciales diferidas y uso de `retryDeferred`.
- [DIDComm](04-flows/04-didcomm.md) — flujo con Quark Credo y limitaciones restantes.
- [KMS](05-reference/04-kms.md) — Hardware KMS vs. Software KMS: cuándo se usa cada uno.
- [Trust](05-reference/05-trust.md) — configuración de `TrustConfig` y uso de `WalletSession.fromRecordStore()`.
- [Errores](05-reference/06-errors.md) — catálogo de excepciones, incluyendo `WrongPinError`.
- [Troubleshooting](06-troubleshooting.md) — soluciones concretas para los síntomas derivados de estas limitaciones.
