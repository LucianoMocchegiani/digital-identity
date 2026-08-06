# API HTTP — Alta de tenants y consulta de records

Referencia de los endpoints **admin** y **records** en los servicios de identidad multi-tenant.

| Servicio | Puerto (Docker) | Prefijo admin |
|----------|-----------------|---------------|
| `quark-issuer-service` | 9001 | `/issuers` |
| `quark-holder-service` | 9005 | `/holders` |
| `quark-verifier-service` | 9002 | `/verifiers` |

Bodies JSON de ejemplo: [postman-bodies.md](./postman-bodies.md).  
Integración de la librería: [guia-libreria.md](./guia-libreria.md).

---

## Identificadores

| Campo en API | Ejemplo | Uso |
|--------------|---------|-----|
| `issuerId` / `holderId` / `verifierId` | `verifier-wallet` | Path `/:walletId/...`, DID, OID4VC |
| `tenantId` | UUID Credo | Solo en respuesta de alta; interno al servicio |
| `recordId` | UUID del record | `GET .../records/:recordType/:recordId` |

El **tenant de Credo** no aparece como fila en `GET /records` (no es un `*Record` en storage). Se crea con `POST /issuers|holders|verifiers`.

---

## Alta y listado de tenants

### `GET /issuers` | `GET /holders` | `GET /verifiers`

Lista wallets registradas en el proceso (mapa en memoria + tenants cargados al arranque desde Postgres).

**Respuesta 200**

```json
{
  "issuers": [
    {
      "issuerId": "issuer-wallet-oid4vc",
      "tenantId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "did": "did:web:localhost%3A9001:issuer-wallet-oid4vc"
    }
  ]
}
```

(`holders` / `verifiers` con la misma forma, cambiando el nombre del array y del id.)

| Campo | Descripción |
|-------|-------------|
| `issuerId` | Id lógico para rutas y protocolo |
| `tenantId` | Id interno Credo (`withTenant`) |
| `did` | `did:web` (issuer/verifier) o `did:key` (holder); `null` si no se pudo resolver |

**Cuándo usarlo:** antes de probar, para ver qué wallets existen sin repetir el `POST` de alta.

---

### `POST /issuers`

Crea tenant + `DidRecord` + `StorageVersionRecord`. Con body `oid4vc`, además `OpenId4VcIssuerRecord`.

**Body** — ver [postman-bodies.md § Alta de tenants](./postman-bodies.md#alta-de-tenants-admin).

**Respuesta 201**

```json
{
  "issuerId": "issuer-wallet-oid4vc",
  "tenantId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "did": "did:web:localhost%3A9001:issuer-wallet-oid4vc",
  "recordsCreated": [
    "DidRecord",
    "StorageVersionRecord",
    "OpenId4VcIssuerRecord"
  ]
}
```

| HTTP | Motivo |
|------|--------|
| `409 Conflict` | El `issuerId` ya existe en el mapa |
| `400 Bad Request` | `issuerId` inválido (ej. literal `{{issuerId}}` sin resolver en Postman) |

**Efectos en Credo**

- Tenant nuevo con `label` = `issuerId`
- DID `did:web:{host}:{issuerId}` donde `{host}` sale de `BASE_URL`
- Metadata OID4VCI si vino `oid4vc` en el body

---

### `POST /holders`

**Body**

```json
{ "holderId": "holder-wallet" }
```

**Respuesta 201**

```json
{
  "holderId": "holder-wallet",
  "tenantId": "...",
  "did": "did:key:z6Mk...",
  "recordsCreated": ["DidRecord", "StorageVersionRecord"]
}
```

No acepta metadata OID4VCI/OID4VP. El holder actúa como cliente OID4VC.

---

### `POST /verifiers`

**Body** — `verifierId` + opcional `oid4vp.clientMetadata`.

**Respuesta 201**

```json
{
  "verifierId": "verifier-wallet",
  "tenantId": "...",
  "did": "did:web:localhost%3A9002:verifier-wallet",
  "recordsCreated": [
    "DidRecord",
    "StorageVersionRecord",
    "OpenId4VcVerifierRecord"
  ]
}
```

Sin `oid4vp` en el body, `recordsCreated` no incluye `OpenId4VcVerifierRecord` (OID4VP no inicializado hasta tener metadata).

---

### `PATCH /:walletId/metadata` (solo issuer y verifier)

Actualiza metadata OID4VC **sin** tocar otros records por HTTP genérico.

| Rol | Record Credo | Campos típicos en body |
|-----|--------------|------------------------|
| Issuer | `OpenId4VcIssuerRecord` | `credentialConfigurationsSupported`, `display`, `dpopSigningAlgValuesSupported`, … |
| Verifier | `OpenId4VcVerifierRecord` | `clientMetadata` |

`credentialConfigurationsSupported` se **mergea por clave** de configuration id.

**Respuesta 200**

```json
{
  "issuerId": "issuer-wallet-oid4vc",
  "recordType": "OpenId4VcIssuerRecord",
  "record": { }
}
```

(`record` = JSON del record tras el merge.)

| HTTP | Motivo |
|------|--------|
| `404` | Wallet inexistente o sin record OID4VC del rol |

---

## Consulta de records (solo lectura)

Base path (mismo `walletId` que en el alta):

```http
GET /{walletId}/records/types
GET /{walletId}/records?type=...&page=...&limit=...&query=...
GET /{walletId}/records/{recordType}/{recordId}
```

No hay `POST`, `PUT` ni `DELETE` en `/records`. La creación de datos de protocolo ocurre vía DIDComm/OID4VC o en el alta del tenant.

### `GET /:walletId/records/types`

Catálogo de tipos consultables **para el rol del servicio** (issuer, holder o verifier).

**Ejemplo**

```http
GET /issuer-wallet-oid4vc/records/types
```

**Respuesta 200**

```json
{
  "role": "issuer",
  "types": [
    {
      "className": "DidCommConnectionRecord",
      "storageType": "ConnectionRecord",
      "category": "didcomm",
      "description": "Conexión DIDComm con otro agente...",
      "roles": ["issuer", "holder", "verifier"]
    },
    {
      "className": "OpenId4VcIssuerRecord",
      "storageType": "OpenId4VcIssuerRecord",
      "category": "oid4vc",
      "description": "Metadata OID4VCI del emisor...",
      "roles": ["issuer"]
    }
  ]
}
```

| Campo | Descripción |
|-------|-------------|
| `className` | Nombre de clase Credo; válido en query `type` |
| `storageType` | Tipo en tabla Postgres; también válido en `type` |
| `category` | `infra` \| `identity` \| `didcomm` \| `oid4vc` \| `credential` |
| `description` | Texto funcional para operadores / Postman |

---

### `GET /:walletId/records`

Lista paginada de records de un tipo.

**Query params**

| Param | Obligatorio | Default | Descripción |
|-------|-------------|---------|-------------|
| `type` | Sí | — | `ConnectionRecord` o `DidCommConnectionRecord` (equivalentes si el rol lo permite) |
| `page` | No | `1` | Página 1-based |
| `limit` | No | `20` | Máximo `100` |
| `query` | No | — | JSON string con filtro por tags Credo (`findByQuery`), ej. `{"state":"completed"}` |

**Ejemplos**

```http
GET /issuer-wallet-oid4vc/records?type=ConnectionRecord&page=1&limit=20

GET /verifier-wallet/records?type=OpenId4VcVerificationSessionRecord&page=1&limit=10

GET /holder-wallet/records?type=W3cCredentialRecord&query=%7B%22%22%3A%7D
```

**Respuesta 200**

```json
{
  "type": "ConnectionRecord",
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 3,
    "totalPages": 1,
    "hasNextPage": false,
    "hasPreviousPage": false
  },
  "records": [
    {
      "id": "a1b2c3d4-...",
      "_tags": { "connectionId": "...", "state": "completed" },
      "state": "completed"
    }
  ]
}
```

Cada elemento de `records` es el record Credo serializado (`JsonTransformer.toJSON`).

**Paginación**

- Sin `query`: paginación en SQL (eficiente).
- Con `query`: filtro en memoria sobre todos los matches, luego slice por página.

**Errores**

| HTTP | Motivo |
|------|--------|
| `400` | `type` no permitido para el rol, o `query` no es JSON válido |
| `404` | `walletId` no registrado |

---

### `GET /:walletId/records/:recordType/:recordId`

Un record por tipo e id (UUID).

**Ejemplo**

```http
GET /issuer-wallet-oid4vc/records/OpenId4VcIssuerRecord/550e8400-e29b-41d4-a716-446655440000
```

**Respuesta 200**

```json
{
  "type": "OpenId4VcIssuerRecord",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "record": { }
}
```

| HTTP | Motivo |
|------|--------|
| `404` | Wallet, tipo o id inexistente |
| `400` | `recordType` inválido para el rol |

---

## Tipos de record por rol (resumen)

| storageType / clase | Issuer | Holder | Verifier |
|---------------------|:------:|:------:|:--------:|
| `StorageVersionRecord` | x | x | x |
| `DidRecord` | x | x | x |
| `ConnectionRecord` | x | x | x |
| `CredentialExchangeRecord` | x | x | |
| `ProofExchangeRecord` | | x | x |
| `OutOfBandRecord` | x | x | x |
| `OpenId4VcIssuerRecord` | x | | |
| `OpenId4VcIssuanceSessionRecord` | x | | |
| `OpenId4VcVerifierRecord` | | | x |
| `OpenId4VcVerificationSessionRecord` | | | x |
| `W3cCredentialRecord` / `SdJwtVcRecord` / … | | x | |

Detalle y descripciones: respuesta de `GET /records/types` o código en `packages/identity-core/src/record/record-type-catalog.ts`.

---

## Flujo típico de operador

```text
1. GET  /issuers                    → ver wallets existentes
2. POST /issuers                    → crear si hace falta (body oid4vc según mock)
3. POST /{issuerId}/openid4vc/offer → emitir (crea IssuanceSessionRecord)
4. GET  /{issuerId}/records/types   → qué puedo inspeccionar
5. GET  /{issuerId}/records?type=OpenId4VcIssuanceSessionRecord
6. GET  /{issuerId}/records/OpenId4VcIssuanceSessionRecord/{id}
```

Mismo patrón para verifier (`/verifiers`, sesiones `OpenId4VcVerificationSessionRecord`) y holder (credenciales `W3cCredentialRecord` / `SdJwtVcRecord` tras recibir offer).

---

## Postman

Colecciones en `postman/`:

| Colección | Carpeta |
|-----------|---------|
| `Quark-Issuer.postman_collection.json` | `00 - Admin`, `02 - Records` |
| `Quark-Holder.postman_collection.json` | idem |
| `Quark-Verifier.postman_collection.json` | idem |
| `Quark-Flujos-DIDComm-OID4VC.postman_collection.json` | `00.A` provision + flujos |

Variables: `issuerId`, `holderId`, `verifierId`, `recordType`, `recordId`.

---

## identity-core (uso programático)

Equivalente detrás de Nest:

```typescript
import {
  createIssuerWallet,
  listTenantRecords,
  getTenantRecord,
  getRecordTypeDescriptors,
} from '@quarkid/identity-core'

// Tras createRootIssuerAgent + withWallet(agent, ...):
await listTenantRecords(agent, 'issuer', 'ConnectionRecord', { page: 1, limit: 20 })
await getTenantRecord(agent, 'issuer', 'OpenId4VcIssuerRecord', recordId)
getRecordTypeDescriptors('issuer')
```

Ver [guia-integracion.md § Modo multi-tenant](./guia-integracion.md#modo-multi-tenant).
