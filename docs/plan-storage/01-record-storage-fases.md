# Fases: Record storage (Credo wallet)

## Objetivo

Desacoplar el almacenamiento de **records Credo** (`DidRecord`, `OpenId4VcIssuanceSessionRecord`, conexiones DIDComm, etc.) de la librería `@quarkid/identity-core`, de modo que:

- **identity-core** define el contrato (`RecordStorage`) y toda la lógica de consulta por tenant (`tenant-records`, catálogo por rol, paginación, `matchesQuery`).
- **issuer / verifier / holder** son dueños de la conexión (pool, env, health, shutdown, migraciones) y eligen el backend concreto.

La idea explícita es que el integrador pueda enchufar **PostgreSQL, MongoDB o SQLite** (u otro motor) implementando el mismo port, sin cambiar OID4VCI, DIDComm ni las APIs de records.

## Situación actual (post-implementación, julio 2026)

```
RecordStorageModule (Nest)  →  Pool pg + PostgresRecordStorage
       ↓
main.ts  →  app.get(RECORD_STORAGE)
       ↓
createRoot*Agent(config, { recordStorage })
       ↓
registerRecordConfig(dm, recordStorage)  →  Credo StorageService
```

- **identity-core**: port `RecordStorage`, `PostgresRecordStorage`, `tenant-records` vía `resolveRecordStorage`.
- **issuer / holder / verifier**: `POSTGRES_RECORD_DATABASE_URL`, lifecycle del pool en Nest.
- **Modelo**: inyección obligatoria; sin modos `internal`/`external` ni URL remota de records.

## Situación anterior (referencia histórica)

```
environment.config.ts  →  INTERNAL_RECORD_DATABASE_URL  (hoy: POSTGRES_RECORD_DATABASE_URL)
       ↓
buildCredoConfigFromEnv()  →  record: { mode, databaseUrl }
       ↓
createRoot*Agent()  →  registerRecordConfig()
       ↓
new InternalRecordStorageService(databaseUrl)   ← Pool pg creado DENTRO del core
```

Problemas que motivaron el refactor:

- El servicio solo pasaba una URL; no controlaba lifecycle del pool ni migraciones.
- `tenant-records.ts` acoplado a la implementación Postgres concreta.
- Cambiar de motor implicaba tocar el core, no un adapter en el servicio.

## Arquitectura objetivo

```mermaid
flowchart TB
  subgraph core ["@quarkid/identity-core"]
    Port["RecordStorage"]
    Logic["tenant-records · record-type-catalog · matchesQuery"]
    Agent["createRoot*Agent({ recordStorage })"]
    Logic --> Port
    Agent --> Port
  end

  subgraph issuer ["quark-issuer-service"]
    Mod["StorageModule (Nest)"]
    PG["PostgresRecordStorage"]
    Mongo["MongoRecordStorage (futuro)"]
    SQL["SqliteRecordStorage (futuro)"]
    Mod --> PG
    Mod -.-> Mongo
    Mod -.-> SQL
  end

  PG -.->|implements| Port
  Mongo -.->|implements| Port
  SQL -.->|implements| Port
```

## Contrato: `RecordStorage`

Ubicación propuesta: `packages/identity-core/src/record/record-storage.interface.ts`

### Operaciones por ID (CRUD)

Requeridas por Credo y por las APIs Quark (`getTenantRecord`, protocolo OID4VC/DIDComm):

- `save`, `update`, `delete`, `deleteById`, `getById`

### Listados — **solo paginados**

`listTenantRecords` y `GET /:walletId/records` **no deben** usar `getAll` ni `findByQuery` sin paginar. El port Quark exige únicamente:

- `getAllPaginated(ctx, recordClass, { page, limit })`
- `findByQueryPaginated(ctx, recordClass, query, { page, limit })`

Ambos devuelven `PaginatedRecords<T>` (`items` + `pagination` con `total`, `hasNextPage`, etc.).

**Fuera del port Quark (no implementar / no llamar desde servicios):**

- `getAll` — carga ilimitada; inaceptable en multi-tenant.
- `findByQuery` — hoy hace scan completo del tipo en memoria; mismo problema.

> **Nota Credo:** el adapter concreto registrado en `InjectionSymbols.StorageService` puede seguir cumpliendo la API completa de Credo (incluye `getAll` / `findByQuery`) para uso **interno del agente** en protocolos. Eso queda encapsulado en el adapter, no en el contrato `RecordStorage` que consumen issuer/verifier/holder ni en `tenant-records`.

### Scope de tenant

Cada implementación recibe el scope vía `AgentContext.contextCorrelationId` (= `wallet_id`), igual que hoy.

### Requisito para todos los backends

| Método | Postgres | Mongo | SQLite |
|--------|----------|-------|--------|
| `getAllPaginated` | `LIMIT`/`OFFSET` en SQL (ya parcialmente) | Índice + skip/limit | Igual |
| `findByQueryPaginated` | Filtro por tags en SQL/JSONB o índices | Query con índices en `tags.*` | Igual |

Hoy `findByQueryPaginated` en Postgres usa **paginación en SQL** (`record-query.sql.ts`).

### Backends previstos

| Backend | Caso de uso | Notas |
|---------|-------------|-------|
| **PostgreSQL** | Producción multi-tenant (issuer, verifier, holder en servidor) | Implementación inicial; mover SQL desde `internal.record.ts` |
| **MongoDB** | Alto volumen de documentos, tags indexados en colección | `findByQueryPaginated` con índices compuestos en `tags` |
| **SQLite** | Dev local, tests, agente embebido single-tenant | Un archivo por servicio o por tenant; sin red |

El core **no importa** drivers (`pg`, `mongodb`, `better-sqlite3`). Esos viven en el servicio o en un paquete opcional `@quarkid/identity-core-storage-*`.

## Fases

| Fase | Título | Estado |
|------|--------|--------|
| 0 | Inventario | Hecho |
| 1 | Port `RecordStorage` | Hecho |
| 2 | Inyección desde bootstrap | Hecho |
| 3 | `PostgresRecordStorage` en servicios | Hecho |
| 4 | Issuer / verifier / holder | Hecho |
| 5 | MongoDB | Pendiente |
| 6 | SQLite | Pendiente |

### Fase 0 — Inventario y criterios de aceptación ✅

**Entregables**

- Inventario de call sites legacy completado (código eliminado en julio 2026).
- Documentar métodos obligatorios del port (tabla anterior).
- Definir variables de entorno objetivo por servicio (ej. `RECORD_STORAGE_DRIVER=postgres|mongo|sqlite`).

**Criterio de done**

- Matriz método × backend (qué debe implementar cada adapter).

---

### Fase 1 — Port en identity-core ✅

**Cambios en `identity-core`**

1. Crear `RecordStorage` con: CRUD por ID + **solo** `getAllPaginated` y `findByQueryPaginated` para listados.
2. Hacer que `InternalRecordStorageService` implemente `RecordStorage` (y, por separado, la API Credo completa donde el agente lo requiera).
3. Refactorizar `tenant-records.ts`:
   - `resolveStorage(agent): RecordStorage`.
   - Eliminar cualquier camino que llame `getAll` / `findByQuery` sin paginar.
   - Si el storage no implementa paginación → `RecordStorageCapabilityError`.
4. Exportar `RecordStorage` desde `src/index.ts`.

**Compat**

- `registerRecordConfig(dm, config)` sigue creando `InternalRecordStorageService` si no se pasa instancia.

**Criterio de done**

- Tests unitarios del port con mock in-memory.
- `GET /records` sigue funcionando en issuer con config actual.

---

### Fase 2 — Inyección desde el agente bootstrap ✅

**Cambios en `identity-core`**

1. Extender `CreateRootIssuerAgentOptions` / holder / verifier:

   ```typescript
   recordStorage: RecordStorage  // obligatorio
   ```

2. `registerRecordConfig(dm, recordStorage)` registra la instancia en Credo.

**Cambios en servicios (issuer primero)**

1. `StorageModule` Nest:
   - Provee `Pool` o cliente según driver.
   - Provee `RecordStorage` → `PostgresRecordStorage`.
2. `agent-issuer.ts` recibe `RecordStorage` por DI y lo pasa a `createRootIssuerAgent`.

**Criterio de done**

- Issuer arranca con storage inyectado desde Nest.
- Verifier y holder pueden seguir en fallback hasta Fase 4.

---

### Fase 3 — Implementación Postgres en identity-core + Nest ✅

**Opción A (recomendada MVP):** `quark-*-service/source/src/storage/postgres-record.storage.ts`  
**Opción B:** paquete `packages/identity-core-storage-pg` compartido entre los tres servicios.

**Contenido**

- Mover SQL y lógica de `internal.record.ts` al adapter Postgres.
- `identity-core` conserva solo: interfaz, `matchesQuery`, `tenant-records`, tipos.
- **Reimplementar `findByQueryPaginated` con paginación en DB** (no scan + slice en memoria).
- Deprecar o hacer `private` `getAll` / `findByQuery` en el adapter Quark; mantener solo si Credo los invoca vía `StorageService`.

**Mejoras incluidas**

- Columna `data` como `JSONB` (ya se usa `data::jsonb` en paginación).
- Índices: `(wallet_id, type)`, `(wallet_id, type, id)`.
- `onModuleDestroy` → `pool.end()` en Nest.

**Criterio de done**

- `InternalRecordStorageService` marcado `@deprecated` o eliminado tras migrar los tres servicios.
- Sin import de `pg` en el barrel principal de identity-core (opcional: peer dependency en paquete pg).

---

### Fase 4 — Replicar en verifier y holder ✅

Mismo `StorageModule` (o módulo compartido copiado) en:

- `quark-verifier-service`
- `quark-holder-service`

Cada uno con su propia `POSTGRES_RECORD_DATABASE_URL` (bases `quarkid_verifier`, `quarkid_holder` en compose).

**Criterio de done**

- Los tres servicios inyectan `RecordStorage`; ninguno depende de `record.databaseUrl` en `buildCredoConfigFromEnv`.

---

### Fase 5 — Adapter MongoDB (opcional)

**Ubicación:** `packages/identity-core-storage-mongo` o `*/storage/mongo-record.storage.ts`

**Modelo de documento sugerido**

```json
{
  "_id": "<wallet_id>::<type>::<id>",
  "walletId": "...",
  "type": "OpenId4VcIssuanceSessionRecord",
  "id": "...",
  "tags": { "state": "...", "role": "..." },
  "data": { ... },
  "createdAt": "..."
}
```

**Índices**

- `{ walletId: 1, type: 1 }`
- Tags usados en `findByQueryPaginated`: índices compuestos según catálogo DIDComm/OID4VC.

**Ventaja vs Postgres actual**

- `findByQueryPaginated` con filtros en índices Mongo, sin cargar el tenant entero en RAM.

**Criterio de done**

- Issuer (o holder) puede arrancar con `RECORD_STORAGE_DRIVER=mongo` en entorno de prueba.
- Suite de contrato: CRUD + **solo** métodos paginados para listados; ningún test depende de `getAll` / `findByQuery` sin paginar.

---

### Fase 6 — Adapter SQLite (opcional)

**Casos**

- Tests de integración sin Docker Postgres.
- Desarrollo local ligero.
- Prototipo agente single-tenant (sin `TenantsModule`).

**Ubicación:** `packages/identity-core-storage-sqlite`

**Notas**

- Un archivo `.db` por proceso o por `wallet_id` según aislamiento requerido.
- Misma interfaz `RecordStorage`; SQL adaptado o capa ORM mínima.

**Criterio de done**

- `docker-compose` profile `lite` con issuer + SQLite file volume.
- Documentado que no es target de producción multi-tenant.

---

## Configuración objetivo (issuer ejemplo)

```env
# Driver elegido por el servicio (no por identity-core)
RECORD_STORAGE_DRIVER=postgres   # postgres | mongo | sqlite

# Postgres (vigente)
POSTGRES_RECORD_DATABASE_URL=postgresql://user:pass@postgres:5432/quarkid_issuer

# Mongo (fase 5)
# RECORD_MONGO_URI=mongodb://mongo:27017/quarkid_issuer_records

# SQLite (fase 6)
# RECORD_SQLITE_PATH=/data/issuer-records.db
```

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Regresión en OID4VCI (sesiones en records) | Tests E2E offer + credential tras cada fase |
| `findByQuery` / `getAll` sin límite | Fuera del port; solo paginados en APIs y `tenant-records` |
| `findByQueryPaginated` distinto entre backends | Suite de contrato compartida por adapter |
| Migración de datos Postgres → Mongo | Fuera de scope MVP; script ETL solo si hay demanda |
| Duplicar código SQL en 3 servicios | Paquete `identity-core-storage-pg` compartido |

## Relación con otros planes

- **Status list:** tabla propia del issuer; no mezclar con `records` de Credo. Ver [02-status-list-storage-fases.md](./02-status-list-storage-fases.md).
- **KMS:** claves separadas del record storage. Ver [03-kms-storage-fases.md](./03-kms-storage-fases.md). No compartir el mismo port.

## Referencias en código actual

| Archivo | Rol |
|---------|-----|
| `packages/identity-core/src/record/postgres-record.storage.ts` | Adapter Postgres (`PostgresRecordStorage`) |
| `packages/identity-core/src/record/record-storage.interface.ts` | Port `RecordStorage` |
| `packages/identity-core/src/record/tenant-records.ts` | Listado por tenant |
| `packages/identity-core/src/agent/record.module.ts` | Wiring en bootstrap |
| `quark-*-service/source/src/storage/record-storage.module.ts` | Pool + inyección Nest |
