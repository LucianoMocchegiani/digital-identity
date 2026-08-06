# Revocación EUDI — Cómo funciona

Dos repos involucrados:
- **`eudi-srv-web-issuing-eudiw-py`** — el issuer (emite credentials)
- **`eudi-srv-statuslist-py`** — el servicio de status lists (maneja la revocación)

---

## Especificación

**IETF Token Status List** — bitstring de 1 bit por credential (0 = válida, 1 = revocada).

---

## Arquitectura

```
Issuer ──POST /take──► Status List Service ──GET lista──► Verifier
       ──POST /set──►
```

- El issuer **no almacena** las status lists, todo va al servicio externo.
- El verifier consulta directamente al Status List Service via URI embebida en la credential.

---

## Flujo de emisión

1. El issuer llama `POST /token_status_list/take` con `country`, `doctype`, `expiry_date`
2. El servicio reserva un slot aleatorio y responde:

```json
{
  "status_list":     { "uri": "https://.../token_status_list/FC/pid.1/{uuid}", "idx": 42 },
  "identifier_list": { "uri": "https://.../identifier_list/FC/pid.1/{uuid}",   "id": "42" }
}
```

3. Ese objeto se embebe como claim `status` en la credential (SD-JWT o mDoc).

> `identifier_list` solo se usa en mDoc. SD-JWT solo usa `status_list`.

---

## Flujo de revocación

1. El operador inicia el proceso — el holder presenta su credential vía **OID4VP** (QR o deeplink)
2. El issuer extrae el claim `status` de la credential presentada
3. Llama `POST /token_status_list/set`:

```
uri=<uri>&idx=42&status=1
```

4. El servicio setea el bit en la posición 42 → credential revocada.

> **No es reversible.** `status=0` es rechazado con 400.

---

## Cómo verifica un Verifier

1. Extrae `status.uri` y `status.idx` de la credential
2. `GET` a esa URI → recibe un JWT firmado con la bitstring
3. Verifica la firma (ES256, cert en header `x5c`)
4. Descomprime el campo `lst`
5. Lee el bit en posición `idx` → `0` válida, `1` revocada

---

## Status List Service — internals

| Aspecto | Detalle |
|---------|---------|
| Framework | Flask 2.3 + Gunicorn |
| Storage | File-based en `/var/opt/status_lists/` |
| Formato | JWT (`statuslist+jwt`) + CWT (COSE_Sign1 CBOR) |
| Firma | ES256 (ECDSA P-256 SHA-256), clave por país |
| Slots por lista | 10.000 (aleatorios) |
| Autenticación API | `X-API-Key` header |
| Países soportados | FC, PT, EE, CZ, NL, LU, EU, AV, AV2 |
| Renovación | Thread diario que re-firma los JWT/CWT |

**Estructura en disco:**
```
/var/opt/status_lists/token_status_list/{country}/{doctype}/{uuid}/
├── full_list.json
├── token_status_list.jwt
└── token_status_list.cwt
```

Cuando una lista se llena (10.000 slots), se crea una nueva con nuevo UUID.

---

## Configuración (issuer)

```yaml
revocation:
  take_url: "https://issuer.eudiw.dev/token_status_list/take"
  set_url:  "https://issuer.eudiw.dev/token_status_list/set"
  api_key:  "secret"
  enabled:  true
```

---

## Cómo maneja el status la wallet Android

### Stack de librerías

```
eudi-app-android-wallet-ui
  └── eudi-lib-android-wallet-core 0.26.1
        ├── Nimbus-JOSE 11.20.1      (verificación firma JWT)
        ├── BouncyCastle 1.78.1      (crypto EC/RSA)
        ├── cose-java 1.1.0          (COSE Sign1 para mDoc)
        └── eudi-lib-kmp-statium 0.5.1
              ├── Ktor 3.3.3         (HTTP GET del status list)
              └── java.util.zip      (DEFLATE — JVM builtin)
```

### Background worker

`RevocationWorkManager` es un `CoroutineWorker` que corre periódicamente:

1. Llama `resolveDocumentStatus()` para cada documento almacenado
2. Detecta `Status.Invalid` o `Status.Suspended` → credential revocada
3. Persiste los IDs en Room DB (tabla `revokedDocuments`)
4. Emite un broadcast intent a la UI

### Estados posibles de una credential

| Estado | Valor de bit | Descripción |
|--------|-------------|-------------|
| `Status.Valid` | `0x00` | Credential válida |
| `Status.Invalid` | `0x01` | Revocada |
| `Status.Suspended` | `0x02` | Suspendida (solo si bits > 1) |

Con la config EUDI de 1 bit por credential solo existen `Valid` e `Invalid`.

### Qué ve el usuario

| Lugar | Comportamiento |
|-------|---------------|
| Lista de documentos | Ícono rojo + label "Revoked" |
| Filtros | Puede filtrar por Valid / Expired / Revoked |
| Detalle del documento | "Document revoked" en rojo + "This document cannot be used for verification." |
| Bottom sheet | Modal que lista los documentos recién revocados con navegación al detalle |

### Flujo interno de resolución de estado

```
RevocationWorkManager
  └── WalletCoreDocumentsController.resolveDocumentStatus()
        └── SdJwtStatusReferenceExtractor.extractStatusReference()
              → extrae uri + idx del claim "status" del SD-JWT
        └── GetStatus(getStatusListToken).currentStatus()
              → HTTP GET uri
              → verifica firma JWT (x5c, ES256)
              → descomprime bitstring (DEFLATE/ZLIB)
              → lee bit en posición idx
              → retorna Status.Valid / Status.Invalid
```

---

## Dónde está el uri y el idx en una credential SD-JWT

### Estructura del payload JWT

```json
{
  "iss": "https://issuer.eudiw.dev",
  "sub": "...",
  "iat": 1234567890,
  "exp": 1234567890,
  "vct": "eu.europa.ec.eudi.pid.1",

  "status": {
    "status_list": {
      "uri": "https://issuer.eudiw.dev/token_status_list/FC/eu.europa.ec.eudi.pid.1/a1b2c3d4-...",
      "idx": 42
    }
  },

  "given_name": "...",
  "family_name": "..."
}
```

### Ruta exacta

```
JWT payload
  └── status                    (objeto raíz)
        └── status_list         (objeto anidado)
              ├── uri           (string) → URL del JWT firmado con la bitstring
              └── idx           (int)   → posición del bit de esta credential
```

El extractor en código (`SdJwtStatusReferenceExtractor.kt`):

```kotlin
val statusList = claims["status"]
    ?.jsonObject
    ?.get("status_list")
    ?.jsonObject

val uri = statusList["uri"]?.jsonPrimitive?.content
val idx = statusList["idx"]?.jsonPrimitive?.intOrNull
```

### Cómo decodear el JWT para verlo

El SD-JWT tiene el formato:

```
<header_b64>.<payload_b64>.<signature_b64>~<disclosure1>~<disclosure2>~...
```

El payload es la segunda parte, decodeable con base64url sin padding. El claim `status` **no está en los disclosures** — siempre está en el payload base del JWT y no es selectivamente divulgable.
