# Plan de desacoplamiento de persistencia

Documentos de fases para mover la **conexión y el adapter de base de datos** a cada servicio (issuer, verifier, holder), manteniendo la **lógica SSI** en `@quarkid/identity-core`.

Patrón común: **port en core + implementación inyectada en el servicio**.

Convención de nombres: interfaces sin prefijo `I` (`RecordStorage`, `StatusListStorage`, `KeyManagementService`).

## Layout Nest (issuer de referencia)

Toda la infra de persistencia vive en `quark-*-service/source/src/storage/`. Los módulos de dominio (`revocation/`, `openid4vc/`, …) solo consumen tokens.

| Módulo Nest | Port | Estado |
|-------------|------|--------|
| `RecordStorageModule` | `RecordStorage` | Hecho (issuer / verifier / holder) |
| `StatusListStorageModule` | `StatusListStorage` | Hecho (issuer; verifier/holder leen por HTTP) |
| `KeyManagementModule` | `KeyManagementService` | Hecho — producto Quark fija Askar + `BbsKeyManagementService`; verifier añade domain-key Askar. La librería sigue aceptando Postgres u otros adapters inyectados. |

| Documento | Dominio | Backends objetivo |
|-----------|---------|-------------------|
| [01-record-storage-fases.md](./01-record-storage-fases.md) | Records Credo (wallet) | Askar (producto Quark); PostgreSQL (adapter disponible) |
| [02-status-list-storage-fases.md](./02-status-list-storage-fases.md) | Token Status List (revocación) | PostgreSQL (issuer); lectura HTTP en verifier/holder |
| [03-kms-storage-fases.md](./03-kms-storage-fases.md) | Claves del agente | Contrato `KeyManagementService`; Nest inyecta Askar (+ additional backends) |

## Estado (agosto 2026)

| Fase | Record storage | Estado |
|------|----------------|--------|
| 1–2 | Port `RecordStorage` + inyección en agente | Hecho |
| 3 | `PostgresRecordStorage`, pool en Nest, paginación SQL | Hecho |
| 4 | Issuer / holder / verifier con `RecordStorageModule` | Hecho (AskarRecordStorage en producto) |
| 5–6 | Mongo, SQLite (adapters locales) | Pendiente |

| Dominio | Estado inyección Nest |
|---------|----------------------|
| Records | Hecho (`AskarRecordStorage` en producto Quark) |
| Status list | Hecho en issuer (`src/storage/`; dominio en `revocation/`) |
| KMS | Hecho — Askar primario + `BbsKeyManagementService` (+ domain-key Askar en verifier) |


El modelo vigente es **inyección en el mismo proceso**. Askar cifra claves/records; Postgres queda como sidecar BLS / StatusList (y como adapter completo si un integrador no usa Askar).
