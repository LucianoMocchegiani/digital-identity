# EUDI Reference Implementation — Issuer & Verifier

Documentación técnica de la implementación de referencia europea (`issuer.eudiw.dev` / `verifier.eudiw.dev`) y cómo QuarkID 2.0 se alineó con ella.

---

## 1. Contexto: qué son estos sitios

La Comisión Europea publica implementaciones de referencia open source del ecosistema EUDI Wallet:

| Sitio | Repo | Propósito |
|-------|------|-----------|
| `https://issuer.eudiw.dev` | [eudi-srv-web-issuing-eudiw-py](https://github.com/eu-digital-identity-wallet/eudi-srv-web-issuing-eudiw-py) | Issuer de prueba que emite PID, mDL y otras credenciales EU |
| `https://verifier.eudiw.dev/home` | Angular SPA | Verifier de prueba que solicita presentaciones a la EUDI Wallet |

Estas implementaciones definen **el piso de compatibilidad** que cualquier issuer/verifier debe cumplir para interoperar con la EUDI Wallet oficial.

---

## 2. EUDI Issuer (`issuer.eudiw.dev`)

### 2.1 Credenciales soportadas

37 tipos de credenciales en dos formatos:

**SD-JWT VC (`dc+sd-jwt`):**
- `eu.europa.ec.eudi.pid_vc_sd_jwt` — Person Identification Data (PID)
- `eu.europa.ec.eudi.mdl_mdoc` → también disponible como SD-JWT
- `eu.europa.ec.eudi.diploma_vc_sd_jwt` — Diploma
- `eu.europa.ec.eudi.ehic_sd_jwt_vc` — Tarjeta sanitaria europea
- `eu.europa.ec.eudi.iban_sd_jwt_vc` — IBAN
- `eu.europa.ec.eudi.tax_sd_jwt_vc` — Número fiscal
- Entre otros (15+ tipos SD-JWT)

**mDoc / mso_mdoc (ISO 18013-5):**
- `eu.europa.ec.eudi.pid_mdoc` — PID en formato CBOR
- `eu.europa.ec.eudi.mdl_mdoc` — Licencia de conducir móvil
- Entre otros (16+ tipos mDoc)

> QuarkID implementa únicamente **`dc+sd-jwt`**. mDoc requiere soporte CBOR/COSE que no está en el scope actual.

### 2.2 Endpoints

| Endpoint | URL |
|----------|-----|
| Metadata OID4VCI | `https://issuer.eudiw.dev/.well-known/openid-credential-issuer` |
| Token endpoint | `https://issuer.eudiw.dev/oidc/token` |
| Credential endpoint | `https://backend.issuer.eudiw.dev/credential` |
| Deferred credential | `https://backend.issuer.eudiw.dev/deferred_credential` |
| Nonce endpoint | `https://backend.issuer.eudiw.dev/nonce` |
| Notification | `https://backend.issuer.eudiw.dev/notification` |

### 2.3 Metadata de credencial (`credential_configurations_supported`)

Para un credential SD-JWT tipo PID:

```json
{
  "eu.europa.ec.eudi.pid_vc_sd_jwt": {
    "format": "dc+sd-jwt",
    "vct": "eu.europa.ec.eudi.pid_vc_sd_jwt",
    "cryptographic_binding_methods_supported": ["jwk", "cose_key"],
    "credential_signing_alg_values_supported": ["ES256"],
    "proof_types_supported": {
      "jwt": {
        "proof_signing_alg_values_supported": ["ES256"]
      },
      "cwt": {
        "proof_signing_alg_values_supported": ["ES256"]
      }
    },
    "display": [...]
  }
}
```

Puntos clave:
- **`credential_signing_alg_values_supported: ["ES256"]`** — el issuer firma con P-256, no con Ed25519
- **`proof_types_supported.jwt.proof_signing_alg_values_supported: ["ES256"]`** — la wallet envía el proof con P-256
- **EdDSA no aparece en ningún lado** — el ecosistema EUDI es ES256-exclusivo
- Soporta CWT (CBOR Web Token) además de JWT, relevante para mDoc

### 2.4 OAuth Authorization Server metadata

```json
{
  "issuer": "https://issuer.eudiw.dev",
  "token_endpoint": "https://issuer.eudiw.dev/oidc/token",
  "grant_types_supported": [
    "authorization_code",
    "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "refresh_token"
  ],
  "token_endpoint_auth_methods_supported": ["public", "attest_jwt_client_auth"],
  "request_object_signing_alg_values_supported": ["ES256", "RS256", ...],
  "code_challenge_methods_supported": ["S256"],
  "dpop_signing_alg_values_supported": ["ES256", "RS256", ...]
}
```

Notas:
- El issuer EUDI también soporta **authorization code flow** (autenticación completa con OIDC), no solo pre-authorized code
- QuarkID implementa únicamente **pre-authorized code flow**, que es el flujo relevante para demos QR (suficiente para interoperabilidad básica)

### 2.5 Flujo de emisión (pre-authorized code)

```
1. Issuer genera credential offer URI
   openid-credential-offer://?credential_offer_uri=https://...

2. Wallet escanea QR → decodifica el URI → hace GET al credential_offer_uri

3. Wallet hace POST /token con grant_type=pre-authorized_code

4. Wallet construye holder proof JWT (alg: ES256, P-256 key)

5. Wallet hace POST /credential con { proof: { jwt: ... }, format: "dc+sd-jwt" }

6. Issuer verifica proof, firma SD-JWT con su P-256 key (#key-p256)

7. Wallet recibe SD-JWT, lo guarda vinculado a su clave P-256
```

---

## 3. EUDI Verifier (`verifier.eudiw.dev`)

### 3.1 Qué hace

SPA Angular que permite:
- Seleccionar qué atributos de qué credencial solicitar
- Generar un QR con la URI del authorization request OID4VP
- El usuario escanea con la EUDI Wallet
- La wallet presenta solo los atributos solicitados
- El verifier muestra los claims verificados

### 3.2 Flujo OID4VP

```
1. Verifier genera authorization request JWT
   - Firmado con su clave P-256 (#key-p256)
   - Contiene presentation_definition (qué credenciales y atributos pedir)
   - response_mode: direct_post

2. Wallet escanea QR → obtiene el request → verifica firma

3. Wallet selecciona credencial, genera VP Token (SD-JWT presentado)

4. Wallet hace POST al response_uri con:
   - vp_token: <sd-jwt~disclosure1~disclosure2>
   - presentation_submission: {...}   (JSON string URL-encoded)

5. Verifier valida:
   - Firma del issuer en el SD-JWT
   - Binding holder (cnf claim)
   - Cumplimiento del presentation_definition

6. Verifier retorna redirect_uri al wallet
```

### 3.3 Algoritmo de firma del request object

El verifier firma el JWT del authorization request con **ES256** (P-256). La EUDI Wallet espera este algoritmo para verificar que el request proviene de un verifier legítimo que controla el DID declarado en `client_id`.

---

## 4. Por qué ES256 y no EdDSA

| Algoritmo | Curva | Usado por |
|-----------|-------|-----------|
| **ES256** | P-256 | EUDI Wallet, ISO 18013-5, OpenID Foundation, hardware seguro móvil (SE/TEE) |
| **EdDSA** | Ed25519 | Hyperledger Aries, DIDComm, ecosistema open source SSI |

El estándar EUDI se basa en **ISO 18013-5** (mDL) que define P-256 como la curva estándar. Los chips de seguridad en iOS y Android tienen P-256 integrado a nivel hardware. EdDSA es más eficiente matemáticamente pero no está en el scope del EU ARF (Architecture Reference Framework).

---

## 5. Implementación en QuarkID 2.0

### 5.1 Cambios en `identity-core`

#### Estructura de claves DID Document (`web.registrar.ts`)

Antes:
```
did:web:issuer.quarkid.com
  #key-auth      → P-256 (JsonWebKey2020)    [authentication, assertionMethod]
  #key-oid4vc    → Ed25519 (JsonWebKey2020)  [authentication, assertionMethod]
  #key-didcomm   → Ed25519 (Ed25519VerificationKey2018) [assertionMethod]
```

Después:
```
did:web:issuer.quarkid.com
  #key-p256      → P-256 (JsonWebKey2020)    [authentication, assertionMethod]
  #key-ed25519   → Ed25519 (JsonWebKey2020)  [authentication, assertionMethod] (opcional, addEd25519Key)
  #key-didcomm   → Ed25519 (Ed25519VerificationKey2018) [assertionMethod]
```

En producción los agentes issuer y verifier solo tienen `#key-p256` + `#key-didcomm`.

#### Metadata OID4VCI (`issuer.oid4vc.ts`)

Se agrega `credential_signing_alg_values_supported` a cada `credential_configuration`:

```typescript
{
  format: 'dc+sd-jwt',
  vct,
  cryptographic_binding_methods_supported: ['jwk'],
  credential_signing_alg_values_supported: supportedAlgorithms ?? ['ES256'],
  proof_types_supported: {
    jwt: { proof_signing_alg_values_supported: supportedAlgorithms ?? ['ES256'] },
  },
}
```

#### Mapper algorithm-aware (`issuer.oid4vc.ts`)

`buildSdJwtCredentialMapper` ahora detecta el algoritmo que usó el holder en su proof JWT y selecciona la clave de firma del issuer correspondiente:

```typescript
// extractProofAlg: infiere 'ES256' o 'EdDSA' del holderBinding
const alg = extractProofAlg(holderBinding)
// getSigningDidUrl(alg): retorna did:web:...#key-p256 para ES256
const didUrl = getSigningDidUrl(alg)
```

#### Holder binding resolver (`binding.resolver.ts`)

Usa `algorithms[0]` (primer algoritmo declarado por el issuer) para seleccionar el tipo de clave:

```typescript
const keyType = algorithms[0] === 'EdDSA'
  ? { kty: 'OKP', crv: 'Ed25519' }
  : { kty: 'EC', crv: 'P-256' }
```

Con `proof_signing_alg_values_supported: ['ES256']`, la wallet crea una clave P-256.

#### Prioridad de firma OID4VP (`did.ts`)

`getOid4VpSigningDidUrl` ahora busca primero `#key-p256`:

```typescript
// #key-p256 (ES256) → primero
// #key-ed25519 (EdDSA) → fallback
// #key-didcomm (EdDSA) → fallback
```

### 5.2 Cambios en `quark-issuer-service`

| Cambio | Detalle |
|--------|---------|
| `OID4VC_SUPPORTED_ALGS` | Nueva env var, default `ES256`. Soporta lista separada por coma: `ES256,EdDSA` |
| Callback `buildSdJwtCredentialMapper` | Recibe `(alg) => getOid4VcSigningDidUrlForAlg(didDoc, alg)` |
| DID Document | Sin `#key-ed25519` por defecto (se eliminó `addEd25519Key: true`) |

### 5.3 Cambios en `quark-verifier-service`

| Cambio | Detalle |
|--------|---------|
| Request object signing | Firma con `#key-p256` (ES256) automáticamente |
| DID Document | Sin `#key-ed25519` por defecto |

---

## 6. Comparación QuarkID vs. EUDI (estado actual)

| Campo | EUDI referencia | QuarkID 2.0 | Estado |
|-------|-----------------|-------------|--------|
| Formato credencial | `dc+sd-jwt`, `mso_mdoc` | `dc+sd-jwt` | ✅ (mDoc fuera de scope) |
| Firma issuer | ES256 (P-256) | ES256 (P-256) | ✅ |
| Proof holder | ES256 | ES256 | ✅ |
| `credential_signing_alg_values_supported` | `['ES256']` | `['ES256']` | ✅ |
| `cryptographic_binding_methods_supported` | `['jwk', 'cose_key']` | `['jwk']` | ✅ (subset; `cose_key` solo aplica a mDoc) |
| Request object OID4VP | ES256 | ES256 | ✅ |
| Authorization code flow | Sí | No (solo pre-authorized) | ⚠️ fuera de scope |
| CWT proof type | Sí | No | ⚠️ solo relevante para mDoc |
| `did:web` público | Sí | Requiere deployment HTTPS | ⚠️ concern de deployment |

---

## 6.1 Diagnóstico: EUDI Wallet muestra error al emitir (tras "Add")

Si la wallet llega a **ISSUANCE REQUEST** (oferta leída) pero luego muestra *Something went wrong issuing your document(s)*, el fallo **no** está en `POST /openid4vc/offer` (ahí solo se crea la sesión; en logs suele verse `OfferUriRetrieved`). Ocurre en pasos posteriores que la app no detalla en UI.

**Qué revisar en orden**

1. **Logs del issuer** después de pulsar Add: deben aparecer llamadas a los endpoints OID4VCI de Credo (típicamente bajo `BASE_URL` + `/openid4vc-auth/...`), en particular **token** y **credential**. Si no hay ningún `POST` nuevo, suele ser red/TLS o la wallet abortó antes de hablar con tu servidor.
2. **`BASE_URL` con HTTPS y certificado confiable** en el dispositivo. La build de producción de EUDI Wallet suele ser estricta con TLS y con URLs del issuer en el offer.
3. **Metadata** accesible desde el teléfono: abrir en el navegador del móvil (o con `curl` desde una red similar) las URLs `/.well-known/openid-credential-issuer` que reescribe `main.ts` hacia el path nativo de Credo.
4. **`cryptographic_binding_methods_supported`**: la referencia EUDI para SD-JWT usa **`jwk`** (y `cose_key` para perfiles mDoc). QuarkID anuncia solo `['jwk']` para alinear con esa expectativa.

Si tras token/credential el listener registra `errorMessage` en la sesión, ese texto suele ser la pista exacta (proof inválido, formato, etc.).

---

## 7. Configuración necesaria para producción

### Variables de entorno (issuer)

```env
# URL pública del issuer (debe ser HTTPS para que did:web sea resolvible)
BASE_URL=https://issuer.quarkid.com

# Algoritmos soportados — ES256 para EUDI, ES256,EdDSA para ecosistemas mixtos
OID4VC_SUPPORTED_ALGS=ES256

# Dominio del did:web (se deriva de BASE_URL automáticamente)
# did:web:issuer.quarkid.com
```

### Variables de entorno (verifier)

```env
BASE_URL=https://verifier.quarkid.com
```

### DID Document resultante (issuer)

```json
{
  "@context": ["https://www.w3.org/ns/did/v1", "https://w3id.org/security/suites/jws-2020/v1", "..."],
  "id": "did:web:issuer.quarkid.com",
  "verificationMethod": [
    {
      "id": "did:web:issuer.quarkid.com#key-p256",
      "type": "JsonWebKey2020",
      "controller": "did:web:issuer.quarkid.com",
      "publicKeyJwk": { "kty": "EC", "crv": "P-256", "x": "...", "y": "..." }
    },
    {
      "id": "did:web:issuer.quarkid.com#key-didcomm",
      "type": "Ed25519VerificationKey2018",
      "controller": "did:web:issuer.quarkid.com",
      "publicKeyBase58": "..."
    }
  ],
  "authentication": ["did:web:issuer.quarkid.com#key-p256"],
  "assertionMethod": ["did:web:issuer.quarkid.com#key-p256", "did:web:issuer.quarkid.com#key-didcomm"],
  "keyAgreement": ["did:web:issuer.quarkid.com#key-p256"]
}
```

---

## 8. Flujo completo QuarkID + EUDI Wallet (post-integración)

```
[EUDI Wallet]           [QuarkID Issuer]
     |                        |
     |  1. Escanea QR          |
     |  (openid-credential-offer://...) |
     |-----GET credential offer URI---->|
     |<----{ credential_offer: {...} }--|
     |                        |
     |--POST /token ---------->|
     |  { pre-authorized_code }|
     |<--{ access_token } -----|
     |                        |
     |  2. Crea P-256 key pair |
     |  3. Genera proof JWT    |
     |     (alg: ES256)        |
     |                        |
     |--POST /credential ------>|
     |  { proof: { jwt: ... }} |
     |                        |
     |  4. Verifica proof ES256|
     |  5. Firma SD-JWT con    |
     |     did:web:...#key-p256|
     |                        |
     |<--{ credential: "eyJ...~..." }--|
     |                        |
     | 6. Guarda SD-JWT en wallet      |
```

---

## 9. Fuentes

- [EU Digital Identity Wallet Architecture Reference Framework](https://digital-strategy.ec.europa.eu/en/library/european-digital-identity-wallet-architecture-and-reference-framework)
- [OpenID for Verifiable Credential Issuance (OID4VCI)](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html)
- [OpenID for Verifiable Presentations (OID4VP)](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html)
- [SD-JWT VC (IETF draft-ietf-oauth-sd-jwt-vc)](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/)
- [issuer.eudiw.dev metadata](https://issuer.eudiw.dev/.well-known/openid-credential-issuer)
- [Repositorio issuer EUDI](https://github.com/eu-digital-identity-wallet/eudi-srv-web-issuing-eudiw-py)
