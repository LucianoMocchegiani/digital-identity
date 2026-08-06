# Guía de integración — índice general

Resumen E2E y enlaces. La **documentación de la librería** (`@quarkid/identity-core`) está en:

**[guia-libreria.md](./guia-libreria.md)** — configuración, `createRoot*Agent`, `create*Wallet`, `withTenant`, protocolos, records.

| Necesitás… | Documento |
|------------|-----------|
| Integrar el paquete npm en tu servicio Node | [guia-libreria.md](./guia-libreria.md) |
| Consumir REST de `quark-*-service` | [api-tenants-y-records.md](./api-tenants-y-records.md) |
| Bodies Postman | [postman-bodies.md](./postman-bodies.md) |
| Holder móvil (Dart) | [guia-integracion-mobile.md](./guia-integracion-mobile.md) |

> Flujo OID4VC puro sin VDR obligatorio. Producto Quark: Askar + sidecar BBS Postgres. La librería acepta cualquier adapter inyectado (Askar, Postgres, …).

---

## Dos modos de uso

| | **Single-wallet** | **Multi-tenant** (QuarkID 2.0 servicios de identidad) |
|---|-------------------|-----------------------------------------------|
| **Factory del agente** | `createIssuerAgent`, `createHolderAgent`, `createVerifierAgent` | `createRootIssuerAgent`, `createRootHolderAgent`, `createRootVerifierAgent` |
| **Cuántas wallets** | Una por proceso (fija en config) | Muchas por proceso (una por tenant Credo) |
| **Alta de wallet** | Al crear el agente (implícita) | `POST /issuers`, `POST /holders`, `POST /verifiers` |
| **Rutas HTTP Nest** | `/didcomm/...`, `/openid4vc/...` (legacy) | `/:walletId/didcomm/...`, `/:walletId/openid4vc/...` |
| **DID issuer/verifier** | `did:web:{host}` (un solo tenant) | `did:web:{host}:{walletId}` |
| **DID holder** | `did:key` | `did:key` (por tenant) |
| **Consulta de records** | Directo en Credo | `GET /:walletId/records` (solo lectura) |
| **Referencia en repo** | Integración embebida custom | `quark-issuer-service`, `quark-holder-service`, `quark-verifier-service` |

Las funciones de protocolo (`createSdJwtOffer`, `receiveCredentialOffer`, `createVerificationRequest`, etc.) reciben siempre un **`Agent` del tenant** (single-wallet: el único agente; multi-tenant: agente obtenido con `withTenant`).

---

## Modo multi-tenant (resumen)

Detalle de API: [guia-libreria.md § Modo multi-tenant](./guia-libreria.md#modo-multi-tenant-recomendado-quarkid-20).

Un **agente root** por servicio (sin wallet de negocio propia) coordina tenants aislados vía **Credo Tenants**. Cada tenant tiene:

| ID | Origen | Uso |
|----|--------|-----|
| **`issuerId` / `verifierId` / `holderId`** | Lo define el cliente en `POST` (id lógico / wallet id) | Rutas HTTP, `did:web:...:{walletId}`, OID4VCI/OID4VP (`issuerId` en URLs Credo) |
| **`tenantId`** | UUID que devuelve Credo al crear el tenant | Solo interno: `withTenant(rootAgent, tenantId, ...)` |

No uses el `tenantId` en URLs públicas; usa el id lógico (`verifier-wallet`, etc.).

### 1. Bootstrap del servicio (identity-core)

```typescript
import {
  createRootIssuerAgent,
  buildCredoConfigFromEnv,
  loadTenantMap,
  createIssuerWallet,
  withTenant,
} from '@quarkid/identity-core'

// En quark-issuer-service (simplificado)
const config = buildCredoConfigFromEnv(envConfig)
const rootAgent = await createRootIssuerAgent(config, {
  expressApp: app,
  wsServer: wss,
  logger,
})

// Tenants persistidos se cargan al arranque
const tenantMap = await loadTenantMap(rootAgent)
// tenantMap: walletId → tenantId (Credo)
```

Equivalente por rol:

| Rol | Root agent | Crear tenant | DID |
|-----|------------|--------------|-----|
| Issuer | `createRootIssuerAgent` | `createIssuerWallet` | `did:web:{host}:{walletId}` |
| Verifier | `createRootVerifierAgent` | `createVerifierWallet` | `did:web:{host}:{walletId}` |
| Holder | `createRootHolderAgent` | `createHolderWallet` | `did:key` |

`create*Wallet` hace internamente: `ensureTenant` → `withTenant` → `ensureWebDid` / `ensureKeyDid` → opcional `initializeIssuerOid4vc` / `initializeVerifierOid4vc`.

### 2. API HTTP (servicios de identidad)

Prefijo **`walletId`** = `issuerId` | `verifierId` | `holderId` del body de alta.

#### Admin (colección raíz)

| Método | Issuer | Holder | Verifier |
|--------|--------|--------|----------|
| `GET` | `/issuers` | `/holders` | `/verifiers` |
| `POST` | `/issuers` | `/holders` | `/verifiers` |
| `PATCH` | `/:walletId/metadata` | — | `/:walletId/metadata` |

`POST` devuelve `{ issuerId, tenantId, did, recordsCreated }` (o `holderId` / `verifierId`).

`GET` lista wallets registradas en el proceso (memoria + tenants cargados al bootstrap).

#### Por tenant

| Área | Issuer / Verifier | Holder |
|------|-------------------|--------|
| Health | `GET /health` | igual |
| DID Document | `GET /:walletId/did.json` | `did:web` issuer/verifier; holder usa `did:key` (sin did.json web) |
| DIDComm | `/:walletId/didcomm/*` | igual |
| OID4VC | `/:walletId/openid4vc/*` | igual |
| Records (lectura) | `/:walletId/records`, `.../types`, `.../:type/:id` | igual |

Credo sigue registrando OID4VC en rutas fijas del proceso:

| Rol | Prefijo Credo | Ejemplo |
|-----|---------------|---------|
| Issuer OID4VCI | `/openid4vc-flow/{issuerId}/` | `.../token`, `.../credential` |
| Verifier OID4VP | `/openid4vc-auth/{verifierId}/` | `.../authorize/{requestId}` |

`BASE_URL` del `.env` debe ser la URL pública (tunnel o localhost) **sin** plantillas Postman (`{{verifierId}}`).

### 3. Ejecutar protocolo en un tenant (desde Nest)

Los servicios guardan `walletId → tenantId` y delegan a identity-core:

```typescript
// Patrón en quark-*-service (agent-store)
export function withWallet<T>(walletId: string, fn: (agent: Agent) => Promise<T>): Promise<T> {
  const tenantId = tenantMap.get(walletId)
  if (!tenantId) throw new NotFoundException(`Wallet '${walletId}' not found`)
  return withTenant(rootAgent, tenantId, fn)
}

// Ejemplo: offer OID4VCI
await withWallet(issuerId, (agent) =>
  createSdJwtOffer(agent, { configurationId: 'quarkid_demo', vct: 'QuarkCredential', claims: { ... } })
)
```

Tras `POST /issuers`, hay que **`registerTenant(walletId, tenantId)`** en el mapa en memoria (ya lo hace el servicio).

### 4. Alta y listado de tenants (HTTP)

Referencia detallada: [api-tenants-y-records.md](./api-tenants-y-records.md) (`GET/POST /issuers|holders|verifiers`, respuestas, errores).

Bodies JSON: [postman-bodies.md](./postman-bodies.md). Resumen issuer con metadata OID4VCI (`issuer-config.mock.ts`):

```json
POST /issuers
{
  "issuerId": "issuer-wallet-oid4vc",
  "oid4vc": {
    "display": [{ "name": "Issuer", "locale": "es" }],
    "dpopSigningAlgValuesSupported": ["ES256"],
    "credentialConfigurationsSupported": {
      "quarkid_demo": {
        "format": "dc+sd-jwt",
        "vct": "QuarkCredential",
        "cryptographic_binding_methods_supported": ["did:jwk", "jwk"],
        "credential_signing_alg_values_supported": ["ES256"],
        "proof_types_supported": {
          "jwt": { "proof_signing_alg_values_supported": ["ES256"] }
        },
        "display": [{
          "name": "QuarkCredential",
          "locale": "en",
          "background_color": "#1a1a2e",
          "text_color": "#ffffff"
        }]
      }
    }
  }
}
```

Luego las operaciones usan ese id:

```http
POST /issuer-wallet-oid4vc/openid4vc/offer
GET  /issuer-wallet-oid4vc/records/types
```

### 5. Records (solo lectura)

| Endpoint | Descripción |
|----------|-------------|
| `GET /:walletId/records/types` | Catálogo por rol (`className`, `storageType`, `description`) |
| `GET /:walletId/records?type=...&page=1&limit=20` | Listado paginado; `query` opcional (JSON por tags) |
| `GET /:walletId/records/:recordType/:recordId` | Detalle por UUID |

No hay `POST/PUT/DELETE` en `/records`. Metadata OID4VCI/OID4VP: `PATCH /:walletId/metadata`.

Documentación completa: [api-tenants-y-records.md](./api-tenants-y-records.md).

### 6. Flujo E2E recomendado (Postman)

1. `00.A` — `GET` + `POST` `/issuers`, `/holders`, `/verifiers` (o reutilizar ids listados).
2. `01` / `02` — DIDComm y OID4VC con `{{issuerId}}`, `{{holderId}}`, `{{verifierId}}` en la URL.
3. Environment activo (`Quark Local Docker` o `Quark Tunnel Dominios`).

---

## Modo single-wallet (resumen)

Detalle de API: [guia-libreria.md § Modo single-wallet](./guia-libreria.md#modo-single-wallet-un-agente--una-wallet).

Integración **directa** con `createIssuerAgent` / `createHolderAgent` / `createVerifierAgent`: un agente ya incluye KMS, wallet y DID.

### Issuer — crear el agente

```typescript
import { createIssuerAgent } from '@quarkid/identity-core'
import express from 'express'
import http from 'http'
import { WebSocketServer } from 'ws'

const app = express()
const server = http.createServer(app)
const wsServer = new WebSocketServer({ server })

const agent = await createIssuerAgent(
  {
    label: 'Mi Issuer',
    walletId: 'issuer-wallet',
    walletKey: process.env.WALLET_KEY!,
    didcommEndpoint: process.env.BASE_URL ?? 'http://localhost:9001',
    oid4vcBaseUrl: process.env.BASE_URL ?? 'http://localhost:9001',
    useHttpForWebDid: true,
    vdrServiceUrl: process.env.VDR_SERVICE_URL ?? 'http://localhost:4003',
  },
  { expressApp: app, wsServer, recordStorage, keyManagementService }
)

server.listen(9001)
```

Credo registra OID4VCI bajo `/openid4vc-flow/{issuerId}/` (en single-wallet el `issuerId` suele coincidir con `walletId` de la config).

| Endpoint | Descripción |
|----------|-------------|
| `GET /.well-known/openid-credential-issuer` | Metadata del issuer |
| `GET /.well-known/oauth-authorization-server` | Metadata OAuth AS |
| `POST /token` | Pre-authorized code → access token |
| `POST /credential` | Emisión de la credencial firmada |

### Issuer — credential offer

```typescript
import { createSdJwtOffer } from '@quarkid/identity-core'

const { offerUri, issuanceSessionId } = await createSdJwtOffer(agent, {
  configurationId: 'quarkid_demo',
  vct: 'QuarkCredential',
  claims: { name: 'Juan Perez', email: 'juan@example.com', role: 'member' },
  disclosureFrame: { _sd: ['email', 'role'] },
  claimsDisplay: {
    name:  { name: 'Nombre completo', locale: 'es' },
    email: { name: 'Correo electrónico', locale: 'es' },
    role:  { name: 'Rol', locale: 'es' },
  },
})
```

`createSdJwtOffer` ejecuta `ensureIssuer` + `createCredentialOffer` sobre el **mismo** `agent` (no hace falta `withTenant`).

### Holder — crear el agente

```typescript
import { createHolderAgent } from '@quarkid/identity-core'

const agent = await createHolderAgent(
  {
    label: 'Mi Holder',
    walletId: 'holder-wallet',
    walletKey: process.env.WALLET_KEY!,
    didcommEndpoint: process.env.BASE_URL ?? 'http://localhost:9005',
    useHttpForWebDid: true,
    vdrServiceUrl: process.env.VDR_SERVICE_URL ?? 'http://localhost:4003',
  },
  { wsServer, recordStorage, keyManagementService }
)
```

`did:key` se crea al inicializar. El holder no expone OID4VCI/OID4VP propios (solo cliente HTTP).

### Holder — recibir y presentar

```typescript
import { receiveCredentialOffer, submitPresentation } from '@quarkid/identity-core'

const result = await receiveCredentialOffer(agent, offerUri)
const response = await submitPresentation(agent, requestUri)
```

### Verifier — crear el agente

```typescript
import { createVerifierAgent } from '@quarkid/identity-core'

const agent = await createVerifierAgent(
  {
    label: 'Mi Verifier',
    walletId: 'verifier-wallet',
    walletKey: process.env.WALLET_KEY!,
    didcommEndpoint: process.env.BASE_URL ?? 'http://localhost:9002',
    oid4vcBaseUrl: process.env.BASE_URL ?? 'http://localhost:9002',
    useHttpForWebDid: true,
    vdrServiceUrl: process.env.VDR_SERVICE_URL ?? 'http://localhost:4003',
  },
  { expressApp: app, wsServer, recordStorage, keyManagementService }
)
```

OID4VP bajo `/openid4vc-auth/{verifierId}/`.

### Verifier — authorization request y sesión

```typescript
import { createVerificationRequest, getVerificationSession } from '@quarkid/identity-core'

const { requestUri, verificationSessionId } = await createVerificationRequest(agent, {
  dcqlQuery: {
    credentials: [{ id: 'quark-credential', format: 'dc+sd-jwt', meta: { vct_values: ['QuarkCredential'] } }],
  },
})

const session = await getVerificationSession(agent, verificationSessionId)
```

---

## Flujo OID4VC (ambos modos)

La secuencia de mensajes es la misma; cambia **cómo** se obtiene el `agent` y las **URLs**:

```
Issuer (tenant A)              Holder (tenant H)           Verifier (tenant V)
  │                               │                               │
  │  offer (Nest o createSdJwtOffer)                             │
  │──────────────────→ offerUri   │                               │
  │                               │ receive-offer / receiveCredentialOffer
  │◀──────── OID4VCI ────────────│                               │
  │                               │                               │
  │                               │◀──── requestUri ──────────────│
  │                               │ present / submitPresentation │
  │                               │──────── vp_token ────────────▶│
```

En multi-tenant, las llamadas Nest usan `POST /{issuerId}/openid4vc/offer`, `POST /{holderId}/openid4vc/receive-offer`, etc.

---

## API identity-core

Tablas completas, ejemplos y errores: **[guia-libreria.md](./guia-libreria.md)**.

---

## Variables de entorno

### Issuer / Verifier (públicos, DID web)

| Variable | Ejemplo | Descripción |
|----------|---------|-------------|
| `BASE_URL` | `https://issuer.example.com` | URL pública. Define host del `did:web` y base OID4VC. **Sin** `{{variables}}`. |
| `DATABASE_URL` | `postgres://...` | Postgres del servicio (Askar store, BBS, StatusList) |
| `ASKAR_STORE_KEY` | (passphrase) | Passphrase del store Askar (obligatoria en producto Quark) |
| `ASKAR_STORE_ID` | (opcional) | Default: nombre de DB en `DATABASE_URL` |

En multi-tenant, el segmento `:walletId` del DID se toma del `issuerId`/`verifierId` del `POST`, no del `BASE_URL`.

### Holder

| Variable | Ejemplo | Descripción |
|----------|---------|-------------|
| `BASE_URL` | `http://localhost:9005` | DIDComm / invitaciones (sin OID4VC servidor) |
| `WALLET_KEY` | (legacy single-wallet) | En multi-tenant el KMS no usa clave por wallet en el POST |

---

## Errores comunes

| Error | Causa | Solución |
|-------|--------|----------|
| `Wallet 'x' not found` | `walletId` no está en `tenantMap` | Ejecutar `POST /issuers` (o holder/verifier); tras reinicio de contenedor, repetir alta o confiar en tenants persistidos + `loadTenantMap` |
| `did:web:...:{{verifierId}}` inválido | Postman envió literal `{{verifierId}}` | Activar environment; body con id real (`verifier-wallet`) |
| `No did:web DID document found` | Falta `oid4vcBaseUrl` o `expressApp` en root agent | Pasar `expressApp` a `createRoot*Agent` |
| `Cannot resolve credential offer` | Holder no alcanza `BASE_URL` del issuer | Misma red / tunnel; URLs HTTPS en wallet de producción |
| `No credential satisfies the request` | Holder sin credencial que cumpla DCQL/PEX | Emitir antes con OID4VCI; revisar `vct` |
| Validation 400 en `POST /issuers` | `issuerId` con caracteres inválidos | Solo alfanumérico, `.`, `_`, `-` |

---

## Documentación relacionada

- **[guia-libreria.md](./guia-libreria.md)** — integración del paquete npm (principal)
- [api-tenants-y-records.md](./api-tenants-y-records.md) — REST servicios de identidad
- [postman-bodies.md](./postman-bodies.md) — bodies HTTP
- [guia-integracion-mobile.md](./guia-integracion-mobile.md) — holder Dart
- [packages/identity-core/README.md](../../packages/identity-core/README.md) — entrada del paquete
