# quark-verifier-x5c — Certificado de dominio para verificación con EUDI Wallet

## Por qué es necesario

La EUDI Wallet Android solo acepta verifiers que se identifiquen con uno de estos esquemas:

```kotlin
withClientIdSchemes(listOf(
    ClientIdScheme.X509SanDns,
    ClientIdScheme.X509Hash
))
```

El `quark-verifier-service` por defecto firma los authorization requests OID4VP con `did`, que la EUDI wallet rechaza. Para que la wallet acepte el request, el verifier debe firmar con un certificado X.509 (`requestSignerMethod: "x5c"`).

El certificado identifica al **dominio del servicio** (no a un tenant individual), por eso es compartido entre todos los tenants via el scope `domain-key` del KMS.

En multi-tenant (`gcba-verifier`, `renaper-verifier`, etc.) **no hace falta un certificado ni una entrada de trust store por tenant**: todos los verifiers del mismo `quark-verifier-service` usan el mismo leaf cert de `verifier.pruebasaproduccunon.uno`. La wallet EUDI solo necesita `quark_ca.pem` en `configureReaderTrustStore` (ya configurado en `dev` y `demo`).

Los certificados viven en `local/certs/` (carpeta ignorada por git; ver `.gitignore`).

---

## Arquitectura — domain-key (Askar)

El verifier Quark registra `AskarDomainKeyManagementService` (`backend = askar-domain-key`)
con un perfil Askar fijo `domain-key`. Credo, al firmar OID4VP x5c desde un tenant,
busca la `keyId` en Askar del tenant y, si no está, en el backend domain-key.

Una sola copia cifrada en el store Askar; no hace falta reimportar por tenant.

(Quien use Postgres como KMS primario sin Askar puede seguir el fallback SQL
`wallet_id = domain-key` de `PostgresKeyManagementService`.)

---

## Setup manual — paso a paso

### Prerequisitos

- OpenSSL instalado
- Node.js disponible
- `quark-verifier-service` desplegado y accesible

---

### Paso 1 — Generar los certificados P-256

> **Importante:** usar P-256 (no RSA). El KMS interno solo soporta ES256/P-256 y EdDSA/Ed25519.

```bash
# Crear directorio de certs (local/ está en .gitignore del repo padre)
mkdir -p local/certs && cd local/certs

# 1. CA (Quark Local CA)
MSYS_NO_PATHCONV=1 openssl ecparam -name prime256v1 -genkey -noout -out quark-ca.key
MSYS_NO_PATHCONV=1 openssl req -new -x509 -key quark-ca.key -out quark-ca.pem -days 3650 \
  -subj "/CN=Quark Local CA"

# 2. Leaf cert del verifier (CN = dominio real del servicio)
MSYS_NO_PATHCONV=1 openssl ecparam -name prime256v1 -genkey -noout -out quark-verifier.key
MSYS_NO_PATHCONV=1 openssl req -new -key quark-verifier.key -out quark-verifier.csr \
  -subj "/CN=verifier.pruebasaproduccunon.uno"

echo "subjectAltName=DNS:verifier.pruebasaproduccunon.uno" > san.cnf

MSYS_NO_PATHCONV=1 openssl x509 -req \
  -in quark-verifier.csr \
  -CA quark-ca.pem -CAkey quark-ca.key -CAcreateserial \
  -out quark-verifier.pem \
  -days 3650 \
  -extfile san.cnf
```

> `MSYS_NO_PATHCONV=1` es necesario en Git Bash para Windows para evitar que interprete `/CN=...` como una ruta.

---

### Paso 2 — Obtener el base64 DER y el JWK

```bash
# Base64 del DER crudo (NO usar openssl base64 -in cert.pem — eso encodea el PEM entero)
LEAF_B64=$(openssl x509 -in quark-verifier.pem -outform DER | base64 -w 0)
CA_B64=$(openssl x509 -in quark-ca.pem -outform DER | base64 -w 0)

echo "${LEAF_B64},${CA_B64}"

# JWK de la clave privada del verifier
node -e "
const crypto = require('crypto');
const fs = require('fs');
const pem = fs.readFileSync('quark-verifier.key', 'utf8');
console.log(JSON.stringify(crypto.createPrivateKey(pem).export({ format: 'jwk' })));
"
```

---

### Paso 3 — Configurar el .env del verifier

```env
OID4VP_X5C_CLIENT_ID_PREFIX=x509_san_dns
OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID=quark-verifier-key-1
OID4VP_X5C_CERTIFICATES_BASE64=<LEAF_B64>,<CA_B64>
```

> El orden es **leaf primero, CA después**.

---

### Paso 4 — Importar la clave privada al KMS (Askar domain-key)

Con el servicio corriendo (composición Askar; sin `KMS_DRIVER`):

```bash
curl -X POST https://verifier.pruebasaproduccunon.uno/v1/domain-key \
  -H "Content-Type: application/json" \
  -d '{
    "keyId": "quark-verifier-key-1",
    "privateJwk": {
      "kty": "EC",
      "crv": "P-256",
      "x": "<x del JWK>",
      "y": "<y del JWK>",
      "d": "<d del JWK>"
    }
  }'
```

Respuesta esperada: `{ "keyId": "quark-verifier-key-1" }`

> Este paso se debe repetir si se rota el certificado o se levanta una nueva instancia con store Askar limpio.

---

### Paso 5 — Agregar la CA al trust store de la EUDI Wallet

1. Copiar `local/certs/quark-ca.pem` a:
   ```
   local/repos-externos/eudi-app-android-wallet-ui/resources-logic/src/main/res/raw/quark_ca.pem
   ```

2. Agregar `R.raw.quark_ca` en `configureReaderTrustStore()` en ambos flavors:
   - `core-logic/src/dev/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`
   - `core-logic/src/demo/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`

   ```kotlin
   configureReaderTrustStore(
       context,
       // ... otros certs ...
       R.raw.quark_ca
   )
   ```

3. Recompilar e instalar la wallet:
   ```powershell
   cd local\repos-externos\eudi-app-android-wallet-ui
   .\gradlew.bat :app:installDevDebug
   ```

---

### Paso 6 — Crear un verification request x5c

El servicio toma la cadena x5c del `.env` (`OID4VP_X5C_*`); en el body solo hace falta `"requestSignerMethod": "x5c"`.

Ejemplo multi-tenant RENAPER (vía gateway):

```bash
POST https://gateway.../v1/verifiers/renaper-verifier/openid4vc/request
# o directo: POST https://verifier.pruebasaproduccunon.uno/v1/verifiers/renaper-verifier/openid4vc/request
Content-Type: application/json
Authorization: Bearer <token>

{
  "requestSignerMethod": "x5c",
  "responseMode": "direct_post",
  "dcqlQuery": {
    "credentials": [
      {
        "id": "pasaporte_ciudadano_renaper",
        "format": "dc+sd-jwt",
        "meta": {
          "vct_values": ["PasaporteCiudadanoCardRENAPER"]
        },
        "claims": [
          { "path": ["nombre"] },
          { "path": ["apellido"] },
          { "path": ["dni"] }
        ]
      }
    ]
  }
}
```

El `requestUri` devuelto se escanea con la EUDI wallet (QR o deep link).

> **Emisión (OID4VCI):** además del x5c en verificación, la EUDI wallet exige que el issuer esté en `issuersConfig`. Para RENAPER: `https://issuer.pruebasaproduccunon.uno/openid4vc-flow/renaper-issuer` en `WalletCoreConfigImpl.kt` (`dev` / `demo`).

---

## Archivos relevantes

| Archivo | Descripción |
|---|---|
| `local/certs/quark-ca.pem` | Cert de la CA — copiar a `quark_ca.pem` en la EUDI wallet |
| `local/certs/quark-verifier.pem` | Cert leaf del verifier (SAN = dominio del servicio) |
| `local/certs/quark-ca.key` | Clave privada CA (en `local/`, no versionada) |
| `local/certs/quark-verifier.key` | Clave privada verifier (en `local/`, no versionada) |
| `packages/identity-core/src/kms/domain-key.ts` | Función `importDomainKey(agent, …)` |
| `packages/identity-core/src/kms/askar-domain-key-management.service.ts` | Backend Askar perfil `domain-key` |
| `quark-verifier-service/source/src/domain-key/` | Endpoint `POST /domain-key` |
| `quark-verifier-service/source/.env` | Variables `OID4VP_X5C_*` |

---

## Error frecuente — "Constructed encoding used for primitive type"

**Causa:** el base64 del certificado fue generado con `openssl base64 -in cert.pem` en lugar de extraer el DER primero.

**Fix:**
```bash
# MAL — encodea el PEM completo (headers incluidos)
openssl base64 -in quark-verifier.pem -A

# BIEN — extrae el DER y lo encodea
openssl x509 -in quark-verifier.pem -outform DER | base64 -w 0
```
