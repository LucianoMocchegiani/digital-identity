# EUDI Android Wallet — Análisis de Restricciones a Emisores Privados

## Resumen

La EUDI Android Wallet UI **no implementa un sistema dinámico de trusted list** (LOTL/TSL/IACA). Las restricciones son estáticas: una allowlist hardcodeada de URLs de emisores por build flavor. Como emisor privado, estás bloqueado a menos que tu URL sea agregada y el wallet recompilado.

---

## 1. Allowlist de Emisores (OID4VCI)

**Archivo:** `core-logic/src/demo/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`

El wallet solo acepta ofertas de credenciales de URLs explícitamente configuradas:

```kotlin
issuersConfig = listOf(
    "https://issuer.eudiw.dev",
    "https://issuer-backend.eudiw.dev",
    "https://issuer.pruebasaproduccunon.uno/openid4vc-auth/issuer-wallet-oid4vc"
)
```

La validación es por **matching exacto de URL** en `WalletCoreDocumentsController.kt`:

```kotlin
.firstOrNull { (vciConfig, _) -> vciConfig.config.issuerUrl == issuerId }
```

Si el issuer no está en la lista, la oferta se rechaza. No hay fallback dinámico.

---

## 2. Certificados de Reader/Verifier (OID4VP)

**Archivos:** `resources-logic/src/main/res/raw/*.pem`

Para presentaciones (OpenID4VP), el wallet valida los certificados del verifier contra CAs bundleadas:

| Archivo PEM | País/Entidad |
|---|---|
| `pidissuerca02_cz.pem` | República Checa |
| `pidissuerca02_ee.pem` | Estonia |
| `pidissuerca02_eu.pem` | Unión Europea |
| `pidissuerca02_lu.pem` | Luxemburgo |
| `pidissuerca02_nl.pem` | Países Bajos |
| `pidissuerca02_pt.pem` | Portugal |
| `pidissuerca02_ut.pem` | Desarrollo/UT |
| `dc4eu.pem` | DC4EU |
| `r45_staging.pem` | R45 Staging |

La verificación se realiza vía `readerAuth?.isVerified` delegado a la librería core con validación X.509 estándar.

---

## 3. Trust Status en UI — Hardcodeado

**Archivo:** `issuance-feature/src/main/java/eu/europa/ec/issuancefeature/interactor/DocumentIssuanceSuccessInteractor.kt:72`

```kotlin
val issuerIsTrusted = false  // hardcodeado
```

El estado de confianza del emisor en la UI **siempre muestra "no verificado"**, independientemente de si el emisor está en la allowlist. No hay lógica dinámica de determinación de confianza.

---

## 4. Resumen de Barreras

| Barrera | Tipo | Bloquea a emisor privado |
|---|---|---|
| Allowlist de URLs de emisores | Estática (hardcode por build flavor) | **Sí** |
| Validación de certificados de reader | X.509 contra CAs bundleadas | Solo afecta verifiers |
| Sistema dinámico LOTL/TSL/IACA | No existe | N/A |

---

## 5. Cómo Agregar un Emisor Privado

Para integrar un emisor privado en este wallet se debe:

1. Agregar la URL del issuer al array `issuersConfig` en `WalletCoreConfigImpl.kt` del flavor correspondiente (`demo` o `dev`).
2. Recompilar y redistribuir el wallet.

No existe mecanismo runtime para registrar emisores dinámicamente sin modificar el código fuente.

---

## 6. Notas sobre la Arquitectura de Confianza EUDI

La EUDI Wallet Reference Implementation usa una arquitectura de confianza **centralizada y estática** en esta versión. En producción, el modelo europeo prevé:

- **LOTL (List of Trusted Lists)**: lista de listas de confianza nacionales.
- **IACA (Issuing Authority Certificate Authority)**: para credenciales mDL/ISO 18013.
- **TSL (Trusted Service Lists)**: para certificados cualificados.

Ninguno de estos mecanismos está implementado en el wallet de referencia analizado. La integración con estos sistemas requeriría un cambio arquitectónico significativo.
