---
id: records
title: Records
sidebar_position: 3
---

# Records

El **record storage** es la capa de persistencia de `@quarkid/identity-core`. Sobre ella Credo-TS guarda el estado de la wallet: credenciales (W3C, SD-JWT VC), DIDs, conexiones DIDComm, intercambios y sesiones OID4VCI / OID4VP.

## Arquitectura (julio 2026)

- **Port** `RecordStorage` en identity-core (`record-storage.interface.ts`).
- **Adapter de referencia** `PostgresRecordStorage` (`postgres-record.storage.ts`).
- **Conexión** (`Pool` pg): la crea y cierra el **servicio Nest** (issuer / holder / verifier).
- **Bootstrap**: `createRoot*Agent(config, { recordStorage, ... })` — `recordStorage` es **obligatorio**.

```ts
import { Pool } from 'pg'
import {
  PostgresRecordStorage,
  PostgresKeyManagementService,
  ROOT_STORAGE_SCOPE,
} from '@quarkid/identity-core'

const pool = new Pool({ connectionString: process.env.DATABASE_URL })
const recordStorage = new PostgresRecordStorage(pool, ROOT_STORAGE_SCOPE)
const keyManagementService = new PostgresKeyManagementService(pool, ROOT_STORAGE_SCOPE)

const agent = await createRootIssuerAgent(config, {
  expressApp,
  recordStorage,
  keyManagementService,
})
```

`registerRecordConfig(dm, recordStorage)` registra la instancia en `InjectionSymbols.StorageService`. Si falta → `RecordStorageBootstrapError`. El KMS se inyecta igual (`keyManagementService` obligatorio); ver [KMS](./02-kms.md).

No hay modos de configuración: el integrador siempre provee un `RecordStorage` en proceso (típicamente `PostgresRecordStorage`).

## Port `RecordStorage`

Operaciones expuestas a Quark (`tenant-records`, APIs HTTP):

| Método | Descripción |
| --- | --- |
| `save` / `update` / `delete` / `deleteById` | CRUD por id |
| `getById` | Lectura puntual |
| `getAllPaginated` | Listado paginado por tipo (SQL en Postgres) |
| `findByQueryPaginated` | Filtro por tags Credo + paginación (SQL JSONB en Postgres) |

`PostgresRecordStorage` además implementa `getAll` y `findByQuery` para uso **interno de Credo** en protocolos; no forman parte del port Quark.

## Modelo de datos

Cada record se persiste como `StoredRecord`:

| Campo | Descripción |
| --- | --- |
| `id` | Identificador del record |
| `type` | Tipo en storage (`ConnectionRecord`, etc.) |
| `tags` | Resultado de `getTags()` — usado para filtrar |
| `data` | `toJSON()` del record |

Tabla Postgres: `records (type, id, wallet_id, data)` con `data` JSON serializado.

El tipo `QuarkWalletRecord` enumera los records concretos de QuarkID (ver `quark-wallet-record.types.ts`).

## Consulta por tenant

Funciones en `tenant-records.ts`:

- `listTenantRecords(agent, role, recordType, { page, limit, query? })`
- `getTenantRecord(agent, role, recordType, recordId)`

El storage se resuelve con `resolveRecordStorage(agent)` y debe implementar `RecordStorage` (`isRecordStorage` en `record-storage.guards.ts`). Si no → `RecordStorageCapabilityError`.

Catálogo de tipos por rol: `record-type-catalog.ts` / `getRecordTypeDescriptors(role)`.

## Adapter propio

Podés implementar `RecordStorage` (y los métodos extra que Credo requiera en runtime) e inyectarlo en lugar de `PostgresRecordStorage`. Ver plan en `docs/plan-storage/01-record-storage-fases.md` (Mongo, SQLite).

## Ver también

- [Agent bootstrap](../03-agent-bootstrap.md) — `recordStorage` en opciones del agente.
- [Tenants](../04-tenants.md) — scope `wallet_id` / `contextCorrelationId`.
- [Limitaciones](../08-limitations.md).
