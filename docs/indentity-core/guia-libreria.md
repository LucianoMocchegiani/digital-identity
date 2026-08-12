# Guía de integración — `@quarkid/identity-core`

Cómo integrar la **librería TypeScript** en tu servicio Node (issuer, holder o verifier): bootstrap del agente Credo, tenants, DID, protocolos OID4VCI/OID4VP, DIDComm y consulta de records.

> Esta guía describe la **API del paquete**. Los servicios de identidad Quark (`quark-*-service`) son una capa HTTP encima; ver [api-tenants-y-records.md](./api-tenants-y-records.md) solo si consumís esos REST.

---

## Instalación y requisitos

```bash
npm install @quarkid/identity-core
```

- **Node.js** 20+, **TypeScript** 5+
- **PostgreSQL** para KMS (`internal`) y para records Credo vía `PostgresRecordStorage` (recomendado en QuarkID 2.0)
- **Express** + **ws** (issuer/verifier con OID4VC y DIDComm WebSocket)

Peer dependencies implícitas: Credo 0.6 (`@credo-ts/core`, `@credo-ts/tenants`, `@credo-ts/openid4vc`, `@credo-ts/didcomm`, …).

---

## Arquitectura

```text
                    ┌─────────────────────────────────────┐
                    │  rootAgent (createRoot*Agent)      │
                    │  TenantsModule + listeners globales │
                    └──────────────┬──────────────────────┘
                                   │
           ┌───────────────────────┼───────────────────────┐
           │                       │                       │
    withTenant(tenantId A)   withTenant(tenantId B)   ...
           │                       │
    agent A (storage/KMS       agent B
     aislado por tenant)        ...
           │
    ensureWebDid / createSdJwtOffer / listTenantRecords
```

- **Single-wallet:** un solo `Agent` = una wallet; no hay `TenantsModule` en el camino de negocio (el agente ya es el tenant).
- **Multi-tenant:** un `rootAgent` + N tenants; cada operación de negocio usa `withTenant(rootAgent, tenantId, callback)` y recibe un **`Agent` del tenant**.

---

## Configuración del agente

### `CredoAgentBaseConfig`

```typescript
import type { CredoAgentBaseConfig } from '@quarkid/identity-core'

const config: CredoAgentBaseConfig = {
  vdrServiceUrl: 'http://localhost:4003',
  didcommEndpoint: 'https://issuer.example.com',  // también define host del did:web
  useHttpForWebDid: true,   // dev local sin TLS
  oid4vcBaseUrl: 'https://issuer.example.com/openid4vc-flow', // issuer: OID4VCI
  // verifier: oid4vcBaseUrl → .../openid4vc-auth (según tu env)
}
```

| Campo | Descripción |
|-------|-------------|
| `didcommEndpoint` | URL pública del servicio (invitaciones OOB, endpoint DIDComm en DID Document) |
| `oid4vcBaseUrl` | Base donde Credo monta rutas OID4VCI (issuer) u OID4VP (verifier). Sin esto + `expressApp` no hay HTTP OID4VC |
| `useHttpForWebDid` | Permite `did:web` con resolución HTTP en desarrollo |

### Record storage y KMS (inyección)

Los records y el KMS **no** van en `CredoAgentBaseConfig`. Se inyectan en las opciones del agente:

```typescript
import {
  PostgresRecordStorage,
  PostgresKeyManagementService,
  ROOT_STORAGE_SCOPE,
  type RecordStorage,
  type KeyManagementService,
} from '@quarkid/identity-core'
import { Pool } from 'pg'

const pool = new Pool({ connectionString: process.env.POSTGRES_RECORD_DATABASE_URL })
const recordStorage: RecordStorage = new PostgresRecordStorage(pool, ROOT_STORAGE_SCOPE)
const keyManagementService: KeyManagementService = new PostgresKeyManagementService(pool, ROOT_STORAGE_SCOPE)
```

En servicios Nest, el patrón de referencia es `RecordStorageModule` + `KeyManagementModule` (`source/src/storage/`).

### `buildCredoConfigFromEnv`

Adaptador para variables de entorno del estilo Quark (VDR, DIDComm, OID4VC). El KMS no va acá:

```typescript
import { buildCredoConfigFromEnv } from '@quarkid/identity-core'

const config = buildCredoConfigFromEnv({
  vdrServiceUrl: env.VDR_SERVICE_URL,
  didcommEndpoint: env.BASE_URL,
  useHttpForWebDid: env.NODE_ENV !== 'production',
  oid4vcBaseUrl: `${env.BASE_URL}/openid4vc-flow`,
})

// recordStorage + keyManagementService: obligatorios en createRoot*Agent
```

---

## Modo single-wallet (un agente = una wallet)

Para un **único** issuer/holder/verifier por proceso (integración embebida, sin Credo Tenants en tu capa de aplicación).

### Issuer

```typescript
import { createIssuerAgent, createSdJwtOffer } from '@quarkid/identity-core'
import express from 'express'
import { WebSocketServer } from 'ws'

const app = express()
const wsServer = new WebSocketServer({ server: httpServer })

const agent = await createIssuerAgent(
  {
    ...config,
    wallet: { id: 'issuer-wallet', key: process.env.WALLET_KEY! },
    oid4vcOptions: { /* OpenId4VcIssuerRecord inicial */ },
  },
  { expressApp: app, wsServer, logger },
)

// Protocolo: el mismo `agent`
const { offerUri } = await createSdJwtOffer(agent, {
  configurationId: 'quarkid_demo',
  vct: 'QuarkCredential',
  claims: { name: 'Juan' },
})
```

- Crea DID `did:web:{host}` (sin sufijo `:walletId` en el método single-wallet clásico; el dominio depende de `ensureWebDid` interno al init).
- Registra listeners DIDComm y OID4VCI una vez.

### Holder

```typescript
import { createHolderAgent, receiveCredentialOffer, submitPresentation } from '@quarkid/identity-core'

const agent = await createHolderAgent(
  { ...config, wallet: { id: 'holder-wallet', key: process.env.WALLET_KEY! } },
  { wsServer, logger },
)

await receiveCredentialOffer(agent, offerUri)
await submitPresentation(agent, requestUri)
```

- Crea `did:key` al inicializar.
- No requiere `expressApp` (holder es cliente OID4VC).

### Verifier

```typescript
import { createVerifierAgent, createVerificationRequest } from '@quarkid/identity-core'

const agent = await createVerifierAgent(
  {
    ...config,
    wallet: { id: 'verifier-wallet', key: process.env.WALLET_KEY! },
    verifierOptions: { clientMetadata: { client_name: 'Verifier' } },
  },
  { expressApp: app, wsServer, logger },
)

const { requestUri } = await createVerificationRequest(agent, { dcqlQuery: { ... } })
```

---

## Modo multi-tenant (recomendado QuarkID 2.0)

Un **root agent** por rol; muchas wallets con storage y KMS aislados.

### 1. Bootstrap

```typescript
import {
  createRootIssuerAgent,
  loadTenantMap,
  createIssuerWallet,
  withTenant,
  type Agent,
} from '@quarkid/identity-core'

const rootAgent = await createRootIssuerAgent(config, {
  expressApp: app,
  wsServer,
  recordStorage,
  keyManagementService,
  logger,
  listenerLabel: 'Issuer',
})

// Mapa walletId → tenantId (Credo); persistido en DB de tenants
const tenantMap = await loadTenantMap(rootAgent)
```

Equivalentes:

| Rol | Factory root |
|-----|----------------|
| Issuer | `createRootIssuerAgent` |
| Holder | `createRootHolderAgent` |
| Verifier | `createRootVerifierAgent` |

El root agent **no** debe usarse directamente para emitir/verificar; siempre entrá por `withTenant`.

### 2. Identificadores

| Id | Quién lo genera | Uso en tu código |
|----|-----------------|----------------|
| `walletId` | Tu app (`issuerId`, `verifierId`, `holderId`) | `ensureTenant`, `create*Wallet`, mapa en memoria |
| `tenantId` | Credo (`TenantRecord.id`, UUID) | Primer argumento de `withTenant` |

```typescript
// Patrón típico en servicio Nest (simplificado)
const tenantId = await createIssuerWallet(rootAgent, walletId, '', {
  didcommEndpoint: config.didcommEndpoint,
  oid4vcOptions,
})
tenantMap.set(walletId, tenantId)

async function withWallet<T>(walletId: string, fn: (agent: Agent) => Promise<T>): Promise<T> {
  const tenantId = tenantMap.get(walletId)
  if (!tenantId) throw new Error(`Wallet not found: ${walletId}`)
  return withTenant(rootAgent, tenantId, fn)
}
```

### 3. Alta de wallet (`create*Wallet`)

| Función | DID | OID4VC opcional |
|---------|-----|-----------------|
| `createIssuerWallet(root, walletId, walletKey, opts)` | `did:web:{host}:{walletId}` | `opts.oid4vcOptions` → `OpenId4VcIssuerRecord` |
| `createVerifierWallet(root, walletId, walletKey, opts)` | `did:web:{host}:{walletId}` | `opts.oid4vpOptions` → `OpenId4VcVerifierRecord` |
| `createHolderWallet(root, walletId, walletKey)` | `did:key` | — |

`walletKey` está reservado para compatibilidad; con KMS `internal` no se usa por wallet.

**Dominio del `did:web`:** se deriva de `opts.didcommEndpoint` / `BASE_URL`:

```typescript
// identity-core (wallet.ts): host + ':' + walletId
// BASE_URL https://verifier.example.com → did:web:verifier.example.com:my-verifier-id
```

**Records creados en alta** (no exhaustivo):

- Siempre: tenant Credo, `DidRecord`, `StorageVersionRecord`
- Issuer + `oid4vcOptions`: `OpenId4VcIssuerRecord`
- Verifier + `oid4vpOptions`: `OpenId4VcVerifierRecord`

### 4. Leer DIDs del tenant

Dentro de `withTenant`:

```typescript
import { getTenantWebDid, getTenantKeyDid } from '@quarkid/identity-core'

const did = await withWallet(walletId, (agent) => getTenantWebDid(agent))   // issuer/verifier
const did = await withWallet(walletId, (agent) => getTenantKeyDid(agent))   // holder
```

### 5. Tenants — API bajo nivel

Si no usás `create*Wallet`:

```typescript
import { ensureTenant, withTenant } from '@quarkid/identity-core'

const tenantId = await ensureTenant(rootAgent, 'mi-issuer', '')
await withTenant(rootAgent, tenantId, async (agent) => {
  // operar con agent del tenant
})
```

`ensureTenant` devuelve el `tenantId` existente si el `label` / `walletConfig.id` ya coincide.

`loadTenantMap(rootAgent)` reconstruye el mapa tras reinicio del proceso.

---

## Protocolos OID4VC

Todas las funciones reciben un **`Agent` del tenant** (en multi-tenant: dentro del callback de `withTenant`).

### Issuer (OID4VCI)

| Función | Descripción |
|---------|-------------|
| `initializeIssuerOid4vc(agent, options, issuerId?)` | Crea/actualiza `OpenId4VcIssuerRecord` |
| `patchIssuerOid4vcMetadata(agent, issuerId, patch)` | Merge metadata (configs, display, DPoP); crea el record si falta |
| `createSdJwtOffer(agent, options)` | Offer pre-authorized + `offerUri` |
| `createCredentialOffer` / `getIssuanceSession` | Bajo nivel |
| `ensureIssuer` | Registro de configuraciones soportadas |

```typescript
import {
  createSdJwtOffer,
  patchIssuerOid4vcMetadata,
} from '@quarkid/identity-core'

await withWallet('issuer-wallet-oid4vc', async (agent) => {
  await patchIssuerOid4vcMetadata(agent, 'issuer-wallet-oid4vc', {
    credentialConfigurationsSupported: { /* merge por clave */ },
  })

  return createSdJwtOffer(agent, {
    issuerId: 'issuer-wallet-oid4vc',
    configurationId: 'quarkid_demo',
    vct: 'QuarkCredential',
    claims: { name: 'Juan', email: 'juan@example.com' },
    disclosureFrame: { _sd: ['email'] },
  })
})
```

Credo expone HTTP en `oid4vcBaseUrl` (issuer: `/openid4vc-flow/{issuerId}/...`). Requiere `expressApp` en `createRootIssuerAgent`.

### Holder (cliente)

| Función | Descripción |
|---------|-------------|
| `receiveCredentialOffer(agent, offerUri)` | Flujo OID4VCI completo |
| `submitPresentation(agent, requestUri)` | OID4VP; selección automática de credencial |

```typescript
await withWallet('holder-wallet', (agent) =>
  receiveCredentialOffer(agent, offerUri),
)
```

### Verifier (OID4VP)

| Función | Descripción |
|---------|-------------|
| `initializeVerifierOid4vc(agent, options, verifierId?)` | Crea `OpenId4VcVerifierRecord` |
| `patchVerifierOid4vpMetadata(agent, verifierId, patch)` | Merge `clientMetadata` |
| `createVerificationRequest(agent, options)` | `requestUri` + `verificationSessionId` |
| `getVerificationSession(agent, sessionId)` | Estado y payload de respuesta |

```typescript
import { createVerificationRequest, getVerificationSession } from '@quarkid/identity-core'

const { requestUri, verificationSessionId } = await withWallet('verifier-wallet', (agent) =>
  createVerificationRequest(agent, {
    verifierId: 'verifier-wallet',
    dcqlQuery: { credentials: [{ id: 'c1', format: 'dc+sd-jwt', meta: { vct_values: ['QuarkCredential'] } }] },
  }),
)
```

---

## DIDComm

| Función | Rol |
|---------|-----|
| `createInvitation` / `receiveInvitation` | OOB |
| `offerCredential` / `proposeCredential` | Issuance JSON-LD |
| `requestProof` / … | Presentation |

Mismo contrato: `Agent` del tenant. Ver exports en `@quarkid/identity-core` → `protocol/didcomm/*`.

El root agent registra **listeners** globales (`setupDidCommIssuerListeners`, etc.) que enrutan eventos por tenant.

---

## Consulta de records (solo lectura)

API en `record/tenant-records.ts` — no modifica protocolo; inspección operativa/debug.

### Catálogo de tipos

```typescript
import { getRecordTypeDescriptors, type QuarkAgentRole } from '@quarkid/identity-core'

const types = getRecordTypeDescriptors('issuer')
// { className, storageType, category, description, roles }[]
```

### Listar paginado

```typescript
import { listTenantRecords, UnknownRecordTypeError } from '@quarkid/identity-core'

const page = await withWallet(walletId, (agent) =>
  listTenantRecords(agent, 'issuer', 'ConnectionRecord', {
    page: 1,
    limit: 20,
    query: { state: 'completed' }, // opcional; filtro Credo por tags
  }),
)
// page: { type, pagination: { page, limit, total, totalPages, hasNextPage, ... }, records: [...] }
```

| Opción | Default | Máximo |
|--------|---------|--------|
| `page` | 1 | — |
| `limit` | 20 | 100 (`MAX_RECORDS_PAGE_SIZE`) |

Sin `query`: paginación en SQL. Con `query`: filtra en memoria y pagina.

`recordType` acepta **nombre de clase** (`DidCommConnectionRecord`) o **tipo en storage** (`ConnectionRecord`).

### Obtener uno por id

```typescript
import { getTenantRecord } from '@quarkid/identity-core'

const one = await withWallet(walletId, (agent) =>
  getTenantRecord(agent, 'issuer', 'OpenId4VcIssuerRecord', recordUuid),
)
// { type, id, record }
```

### Tipos permitidos por rol

Resumen (detalle en `getRecordTypeDescriptors`):

- **Común:** `StorageVersionRecord`, `DidRecord`
- **Issuer:** + conexiones DIDComm, `OpenId4VcIssuerRecord`, `OpenId4VcIssuanceSessionRecord`, …
- **Holder:** + `W3cCredentialRecord`, `SdJwtVcRecord`, proof exchanges, …
- **Verifier:** + `OpenId4VcVerifierRecord`, `OpenId4VcVerificationSessionRecord`, …

`UnknownRecordTypeError` si el tipo no aplica al rol.

---

## DID (`did/web-did`, `did/key-did`)

| Función | Uso |
|---------|-----|
| `ensureWebDid(agent, { domain, didcommEndpoint, addDidCommKey?, ... })` | Crear/recuperar `did:web` en el tenant |
| `ensureKeyDid(agent, { keyType })` | `did:key` (holder) |

En multi-tenant, `create*Wallet` ya invoca `ensureWebDid` / `ensureKeyDid` con el dominio correcto.

---

## Listeners y logging

Al crear root o single agent se registran listeners OID4VC y DIDComm (estado de sesiones, credenciales, proofs).

Pasá un logger compatible con `CredoLogger`:

```typescript
createRootIssuerAgent(config, {
  recordStorage,
  keyManagementService,
  logger: {
    log: (msg, ctx) => console.log(msg, ctx),
    warn: (msg, ctx) => console.warn(msg, ctx),
    error: (msg, err, ctx) => console.error(msg, err, ctx),
  },
})
```

`fetchOverride` en opciones reescribe URLs antes de cada `fetch` (útil Docker sin TLS).

---

## Flujo completo (multi-tenant, código)

```typescript
// 1. Bootstrap (una vez)
const rootAgent = await createRootIssuerAgent(config, { expressApp, wsServer, recordStorage, keyManagementService })
const tenantMap = await loadTenantMap(rootAgent)

// 2. Alta wallet
const tenantId = await createIssuerWallet(rootAgent, 'issuer-demo', '', {
  didcommEndpoint: config.didcommEndpoint,
  oid4vcOptions: { credentialConfigurationsSupported: { /* ... */ } },
})
tenantMap.set('issuer-demo', tenantId)

// 3. Offer
const { offerUri } = await withTenant(rootAgent, tenantId, (agent) =>
  createSdJwtOffer(agent, { issuerId: 'issuer-demo', configurationId: 'quarkid_demo', vct: 'QuarkCredential', claims: {} }),
)

// 4. Inspección
const sessions = await withTenant(rootAgent, tenantId, (agent) =>
  listTenantRecords(agent, 'issuer', 'OpenId4VcIssuanceSessionRecord', { page: 1, limit: 10 }),
)
```

---

## Errores frecuentes (librería)

| Error | Causa |
|-------|--------|
| `UnknownRecordTypeError` | `recordType` inválido para el rol |
| `Error al crear did:web:...` | Dominio inválido (ej. `:` o plantillas en `walletId`) |
| OID4VC HTTP 404 | Falta `oid4vcBaseUrl` o `expressApp` en root agent |

---

## Referencia de exports

Punto de entrada: `packages/identity-core/src/index.ts`.

| Área | Módulos |
|------|---------|
| Agent | `agent/issuer.agent`, `holder.agent`, `verifier.agent`, `wallet.ts`, `tenant.ts`, `config.ts` |
| OID4VC | `protocol/openid4vc/*.ts` |
| DIDComm | `protocol/didcomm/*.ts` |
| Records | `record/tenant-records.ts`, `record/record-type-catalog.ts` |
| DID | `did/web-did.ts`, `did/key-did.ts` |

---

## Documentación relacionada

| Doc | Contenido |
|-----|-----------|
| [guia-integracion.md](./guia-integracion.md) | Índice y flujos E2E (resumen) |
| [api-tenants-y-records.md](./api-tenants-y-records.md) | REST de servicios de identidad |
| [postman-bodies.md](./postman-bodies.md) | Bodies JSON |
| [guia-integracion-mobile.md](./guia-integracion-mobile.md) | Holder en Dart (`identity_core_dart`) |

Implementación de referencia: `quark-issuer-service/source/src/agent/`, `issuers/`, `records/`.
