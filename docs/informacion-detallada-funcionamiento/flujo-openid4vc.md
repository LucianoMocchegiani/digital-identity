# Flujo OpenID4VC — Emisión y Verificación de Credenciales SD-JWT

Descripción completa del flujo OID4VCI (emisión) + OID4VP (presentación/verificación) implementado en QuarkID 2.0.

---

## Tabla de Contenidos

1. [Visión general](#visión-general)
2. [Actores del sistema](#actores-del-sistema)
3. [Formato de credencial: SD-JWT VC](#formato-de-credencial-sd-jwt-vc)
4. [Flujo 1 — Emisión (OID4VCI)](#flujo-1--emisión-oid4vci)
5. [Flujo 2 — Presentación y Verificación (OID4VP)](#flujo-2--presentación-y-verificación-oid4vp)
6. [Selective Disclosure — cómo funciona](#selective-disclosure--cómo-funciona)
7. [JARM — respuesta encriptada](#jarm--respuesta-encriptada)
8. [Resumen de endpoints](#resumen-de-endpoints)

---

## Visión general

```
Issuer ──[OID4VCI]──► Holder ──[OID4VP]──► Verifier
   emite credencial       almacena          verifica
   SD-JWT VC              y presenta
```

Los protocolos usados:
- **OID4VCI** (OpenID for Verifiable Credential Issuance) — flujo pre-authorized code
- **OID4VP** (OpenID for Verifiable Presentations) — presentación directa con JARM encriptado

---

## Actores del sistema

| Actor | Servicio | Puerto | Rol |
|-------|----------|--------|-----|
| Issuer | `quark-issuer-service` | 9001 | Emite credenciales SD-JWT firmadas con `did:web` |
| Holder | `quark-holder-service` | 9005 | Recibe, almacena y presenta credenciales |
| Verifier | `quark-verifier-service` | 9002 | Crea authorization requests y verifica presentaciones |

---

## Formato de credencial: SD-JWT VC

El formato usado es `dc+sd-jwt` (SD-JWT Verifiable Credential según el spec IETF).

Un SD-JWT VC en formato compacto tiene esta estructura:

```
<header>.<payload>.<signature>~<disclosure1>~<disclosure2>~
```

### Header (decodificado)
```json
{
  "typ": "dc+sd-jwt",
  "alg": "ES256",
  "kid": "#key-1"
}
```

### Payload (decodificado)
```json
{
  "vct": "QuarkCredential",
  "name": "Juan Perez",
  "cnf": {
    "jwk": {
      "kty": "EC",
      "kid": "f570696f-170e-409e-a9b8-f9eb018b4116",
      "crv": "P-256",
      "x": "B1hVz_o4F08j1q4tMVneKM6_k1eVVanUdGKm2IAup8Y",
      "y": "SUz8b7l9PXAwFlr_6dDmI1_RkKIG3_pM9_ZLsr6EBcw"
    }
  },
  "iss": "did:web:quark-issuer-service%3A9001",
  "iat": 1775789948,
  "_sd": [
    "nxtzBZq1IZaL2j1L0MUFqzQT_ayAoPk7YA-uhnopC1I",
    "ygPAh7nYqgObiA-rWD-QXWF2nYJRgt31U_o164S9r_4"
  ],
  "_sd_alg": "sha-256"
}
```

### Campos del payload

- **`vct`** — Verifiable Credential Type: tipo semántico de la credencial (equivalente a `type` en W3C VC)
- **`name`** — claim visible siempre (no está en `_sd`)
- **`cnf.jwk`** — clave pública del holder que hizo el key binding (confirma que el holder es quien dice ser)
- **`iss`** — DID del issuer (`did:web`)
- **`iat`** — timestamp de emisión (Unix)
- **`_sd`** — hashes SHA-256 de los claims con selective disclosure (`email`, `role`)
- **`_sd_alg`** — algoritmo de hash usado para los SD hashes

### Disclosures (decodificadas)

Cada disclosure es `base64url(["salt", "claim_name", "claim_value"])`:

```
WyJyeGN4d0ZCYlVsX2FhSUN0IiwiZW1haWwiLCJqdWFuQGV4YW1wbGUuY29tIl0
→ ["rxcxwFBbUl_aaICt", "email", "juan@example.com"]

WyJkNWpiNmdHWjFzMlpTeFZZIiwicm9sZSIsIm1lbWJlciJd
→ ["d5jb6gGZ1s2ZSxVY", "role", "member"]
```

---

## Flujo 1 — Emisión (OID4VCI)

### Paso 1 — Issuer crea el offer

**Request** `POST http://localhost:9001/openid4vc/offer`
```json
{
  "credentialConfigurationId": "quarkid_demo",
  "vct": "QuarkCredential",
  "claims": {
    "name": "Juan Perez",
    "email": "juan@example.com",
    "role": "member"
  },
  "disclosureFrame": {
    "_sd": ["email", "role"]
  }
}
```

**Campos del body:**

| Campo | Descripción |
|-------|-------------|
| `credentialConfigurationId` | Identificador del tipo de credencial configurado en el issuer. Debe existir en el `OpenId4VcIssuerModule`. |
| `vct` | Verifiable Credential Type — el tipo semántico. Va en el payload del SD-JWT. |
| `claims` | Los atributos de la credencial. Todos van en el payload JWT. |
| `disclosureFrame._sd` | Lista de claim names que se van a ocultar con selective disclosure. Los no listados van siempre visibles. |

En este ejemplo: `name` siempre visible, `email` y `role` ocultos con SD.

**Response**
```json
{
  "offerUri": "openid-credential-offer://?credential_offer_uri=http%3A%2F%2Fquark-issuer-service%3A9001%2Fvc%2F...",
  "issuanceSessionId": "bbfa63cd-c99c-4848-9b33-6d03d9d897e5"
}
```

- **`offerUri`** — URI que el holder debe resolver para iniciar el flujo. Puede ser un deep link (`openid-credential-offer://`) o una URL HTTPS.
- **`issuanceSessionId`** — ID interno de la sesión de issuance en el issuer.

---

### Paso 2 — Holder recibe el offer

**Request** `POST http://localhost:9005/openid4vc/receive-offer`
```json
{
  "offerUri": "openid-credential-offer://?credential_offer_uri=http%3A%2F%2Fquark-issuer-service%3A9001%2Fvc%2F..."
}
```

**Internamente el holder ejecuta (OID4VCI pre-authorized code flow):**

1. `resolveCredentialOffer(offerUri)` — descarga y parsea el metadata del issuer + las credenciales ofrecidas
2. `requestToken()` — solicita el access token (pre-authorized, sin interacción del usuario)
3. `requestCredentials()` — solicita la credencial usando el token + `credentialBindingResolver` (genera key binding con did:key o JWK)
4. `sdJwtVcApi.store({ record })` — persiste el `SdJwtVcRecord` en la wallet PostgreSQL

**Response** (simplificado): la credencial recibida con el compact SD-JWT.

---

### Paso 3 — Holder consulta sus credenciales

**Request** `GET http://localhost:9005/credentials`

**Response**
```json
{
  "credentials": [
    {
      "id": "7311bca0-0102-40dc-9431-fc944e2462ce",
      "format": "dc+sd-jwt",
      "compactSdJwtVc": "eyJ0eXAiOiJkYytzZC1qd3QiLCJhbGciOiJFUzI1NiIsImtpZCI6IiNrZXktMSJ9..."
    }
  ]
}
```

- **`format`** — siempre `dc+sd-jwt` para SD-JWT VCs
- **`compactSdJwtVc`** — el SD-JWT en formato compacto (JWT + disclosures). Es la credencial lista para presentar.

---

## Flujo 2 — Presentación y Verificación (OID4VP)

### Paso 4 — Verifier crea el authorization request

**Request** `POST http://localhost:9002/openid4vc/request`
```json
{
  "presentationDefinition": {
    "id": "quark-pd-1",
    "input_descriptors": [
      {
        "id": "any-credential",
        "constraints": {
          "fields": []
        }
      }
    ]
  }
}
```

- **`presentationDefinition`** — define qué credenciales acepta el verifier (formato DIF Presentation Exchange). `fields: []` acepta cualquier credencial.

**Response**
```json
{
  "requestUri": "openid4vp://?client_id=did%3Aweb%3Aquark-verifier-service%253A9002&request_uri=http%3A%2F%2Fquark-verifier-service%3A9002%2Fvc%2F...%2Fauthorization-requests%2F...",
  "verificationSessionId": "23984441-1a67-4649-997b-8742813ed4b4"
}
```

- **`requestUri`** — URI que el holder debe resolver. Contiene el `client_id` (DID del verifier) y la URL donde está el JWT del authorization request.
- **`verificationSessionId`** — ID interno para consultar el resultado de la verificación.

---

### Paso 5 — Holder presenta la credencial

**Request** `POST http://localhost:9005/openid4vc/present`
```json
{
  "requestUri": "openid4vp://?client_id=did%3Aweb%3Aquark-verifier-service%253A9002&request_uri=http%3A%2F%2F..."
}
```

**Internamente el holder ejecuta:**

1. `resolveOpenId4VpAuthorizationRequest(requestUri)` — descarga y verifica el JWT del request, calcula qué credenciales lo satisfacen
2. Selección automática de credencial: primera que matchea cada `input_descriptor`
3. `acceptOpenId4VpAuthorizationRequest()` — firma el `vp_token` con KB-JWT + encripta la respuesta JARM

**Response**
```json
{
  "ok": true,
  "serverResponse": { "status": 200, "body": {} },
  "authorizationResponsePayload": {
    "vp_token": "eyJ0eXAiOiJkYytzZC1qd3Qi...",
    "presentation_submission": {
      "id": "fVU71ZGZ5g-JCHzlN-dmZ",
      "definition_id": "quark-pd-1",
      "descriptor_map": [
        { "id": "any-credential", "format": "vc+sd-jwt", "path": "$" }
      ]
    }
  }
}
```

- **`vp_token`** — el SD-JWT con KB-JWT (Key Binding JWT) adjunto: `<sd-jwt>~<disclosure1>~<disclosure2>~<kb-jwt>`
- **`presentation_submission`** — mapeo de qué credencial satisface qué `input_descriptor`

---

### Paso 6 — Verifier consulta el resultado de la sesión

**Request** `GET http://localhost:9002/openid4vc/session/:verificationSessionId`

**Response (campos relevantes)**
```json
{
  "id": "23984441-1a67-4649-997b-8742813ed4b4",
  "state": "ResponseVerified",
  "authorizationResponsePayload": {
    "vp_token": "...",
    "presentation_submission": { ... }
  }
}
```

- **`state: "ResponseVerified"`** — la presentación fue verificada exitosamente
- El `vp_token` decodificado contiene los claims de la credencial

---

## Selective Disclosure — cómo funciona

Al emitir con `disclosureFrame._sd: ["email", "role"]`:

```
claims visibles en el JWT:  name = "Juan Perez"
claims ocultos con SD:      email, role  →  aparecen como hashes en _sd
```

Al presentar, el holder elige qué disclosures incluir en el `~disclosure~` del compact SD-JWT:
- Si incluye la disclosure de `email` → el verifier puede leer el email
- Si no la incluye → el verifier solo ve que existe un hash pero no el valor

En este flujo de prueba el holder incluye todas las disclosures. En un wallet real el holder seleccionaría cuáles revelar según lo que pida el verifier.

---

## JARM — respuesta encriptada

El verifier configura `authorization_encrypted_response_alg: ECDH-ES` + `authorization_encrypted_response_enc: A128GCM`.

Esto significa que la respuesta del holder va encriptada como un JWE compacto:

```
<header>..<iv>.<ciphertext>.<tag>
```

El header del JWE:
```json
{
  "kid": "3cc7da56-4efa-412b-b8d4-0962d034e1d8",
  "enc": "A128GCM",
  "alg": "ECDH-ES",
  "epk": {
    "kty": "EC",
    "crv": "P-256",
    "x": "...",
    "y": "..."
  }
}
```

**Proceso de encriptación (en el KMS del holder):**
1. Crea clave efímera EC P-256
2. ECDH entre clave efímera y clave pública del verifier → shared secret
3. ConcatKDF (RFC 7518 §4.6.2) → CEK de 128 bits
4. AES-128-GCM con el CEK → `{ encrypted, iv, tag }`
5. Borra la clave efímera del KMS

El verifier desencripta usando su clave privada EC P-256 + la `epk` del header.

---

## Resumen de endpoints

### Issuer (`quark-issuer-service:9001`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/openid4vc/offer` | Crea un credential offer y devuelve el offer URI |

### Holder (`quark-holder-service:9005`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/openid4vc/receive-offer` | Ejecuta el flujo OID4VCI completo y guarda la credencial |
| POST | `/openid4vc/present` | Presenta credencial al verifier via OID4VP |
| GET | `/credentials` | Lista todas las credenciales almacenadas |
| GET | `/credentials-status` | Lista credenciales con su estado de revocación |

### Verifier (`quark-verifier-service:9002`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/openid4vc/request` | Crea un authorization request (presentation request) |
| GET | `/openid4vc/session/:id` | Consulta el estado y resultado de una sesión de verificación |
