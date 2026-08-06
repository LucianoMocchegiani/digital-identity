# Resumen de modificaciones: EUDI Wallet vs Quark Issuer

## Contexto

Este documento resume los cambios aplicados para lograr interoperabilidad entre:

- `local/eudi-app-android-wallet-ui` (wallet EUDI Android)
- `quark-issuer-service` (issuer QuarkID)

durante el flujo OID4VCI.

## Cambios en EUDI Wallet

### 1) Ajuste de client authentication para issuer Quark

**Archivos:**

- `local/eudi-app-android-wallet-ui/core-logic/src/dev/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`
- `local/eudi-app-android-wallet-ui/core-logic/src/demo/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`

**Cambio:**

- Se reemplazo `ClientAuthenticationType.AttestationBased` por:
  - `ClientAuthenticationType.None("quark-wallet-dev")`

**Motivo:**

- El issuer Quark no soporta autenticacion de cliente basada en attestation para este flujo.

### 2) Configuracion DPoP para issuer Quark

**Archivos:**

- `local/eudi-app-android-wallet-ui/core-logic/src/dev/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`
- `local/eudi-app-android-wallet-ui/core-logic/src/demo/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`

**Cambio:**

- Se agrego para el issuer Quark:
  - `.withDPopConfig(DPopConfig.Default)`

**Motivo:**

- Evitar rutas internas inconsistentes del SDK durante la emision.

### 3) Fix de crash al convertir Bundle a mapa

**Archivo:**

- `local/eudi-app-android-wallet-ui/business-logic/src/main/java/eu/europa/ec/businesslogic/extension/BundleExtensions.kt`

**Cambio:**

- `toMapOrEmpty()` dejo de usar `getString()` para todas las claves.
- Ahora convierte de forma segura solo tipos serializables a string (`String`, `CharSequence`, `Number`, `Boolean`) e ignora otros (ej.: `Intent`).

**Motivo:**

- Corregir `ClassCastException` (`Intent cannot be cast to String`).

### 4) Logging de errores internos OID4VCI

**Archivo:**

- `local/eudi-app-android-wallet-ui/core-logic/src/main/java/eu/europa/ec/corelogic/controller/WalletCoreDocumentsController.kt`

**Cambio:**

- Se agregaron logs con `cause` (throwable) en puntos de falla del flujo:
  - `OfferResult.Failure`
  - `IssueEvent.Failure`
  - `IssueEvent.DocumentFailed`
  - otros casos de finalizacion sin documentos emitidos

**Motivo:**

- Mejor diagnostico en `adb logcat` para identificar causa real del error.

## Cambios en Quark Issuer

### 1) Normalizacion de metadata de credential issuer

**Archivo:**

- `quark-issuer-service/src/main.ts`

**Cambio:**

- Se mantuvo la normalizacion del metadata para compatibilidad con wallets estrictas.
- Se evita ambiguedad entre bloques legacy y modernos cuando corresponde.

**Motivo:**

- Mejorar interoperabilidad con EUDI (parsing estricto de metadata).

### 2) Eliminacion de bloques de cifrado incompletos

**Archivo:**

- `quark-issuer-service/src/main.ts`

**Cambio:**

- Se eliminan del metadata:
  - `credential_request_encryption`
  - `credential_response_encryption`

**Motivo:**

- Evitar errores de parseo como `MissingFieldException` cuando la wallet exige campos adicionales (por ejemplo `jwks`) al detectar esos objetos.

### 3) Publicacion explicita de soporte DPoP en OAuth AS metadata

**Archivo:**

- `quark-issuer-service/src/main.ts`

**Cambio:**

- Para `/.well-known/oauth-authorization-server/...` se agrega:
  - `dpop_signing_alg_values_supported: ["ES256"]`

**Motivo:**

- Declarar formalmente soporte DPoP para clientes estrictos como EUDI wallet y evitar fallas de estado interno relacionadas con DPoP.

## Resultado esperado

Con estos cambios, el flujo de emision OID4VCI con EUDI wallet queda alineado en:

- metadata de issuer y authorization server
- modo de autenticacion de cliente
- manejo de DPoP
- robustez de cliente Android y observabilidad de errores
