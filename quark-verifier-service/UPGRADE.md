# UPGRADE — quark-verifier-service

## A v0.1.0 (multi-tenant + rutas /v1)

1. **Prefijo global `/v1`.** Todas las rutas pasan a `/v1`. Actualizar clientes.
2. **Modelo multi-tenant.** Los verifiers se crean con `POST /v1/verifiers` (body `{ verifierId }`).
   Variables de wallet único (`AGENT_LABEL`, `WALLET_ID`, etc.) **ya no se usan**.
3. **OID4VP x5c (opcional).** Variables `OID4VP_X5C_*` para firma con certificado X.509.

## A "Flujo OID4VC" (13/04/2026) — BREAKING

Renombrar variable de entorno de wallet a record:

| Antes | Ahora |
|---|---|
| `INTERNAL_WALLET_DATABASE_URL` | `POSTGRES_RECORD_DATABASE_URL` (antes `INTERNAL_RECORD_DATABASE_URL`) |

Records: `RecordStorageModule` + `PostgresRecordStorage` (inyección en proceso, Postgres local).
