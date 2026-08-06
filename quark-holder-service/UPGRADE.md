# UPGRADE — quark-holder-service

## A "DIDComm alineado" (feat/alineacion-didcomm-holder) — BREAKING

Misma alineación que issuer/verifier: módulo `didcomm/` plano y un solo entrypoint HTTP.

### Endpoints eliminados

| Antes | Alternativa |
|---|---|
| `GET /v1/holders/:id/didcomm/connections` | `GET /v1/holders/:id/records?type=ConnectionRecord` |
| `GET /v1/holders/:id/didcomm/connection/:id` | `GET /v1/holders/:id/records/ConnectionRecord/:id` |
| `POST /v1/holders/:id/didcomm/propose-credential` | Flujo issuer-initiated: `POST .../issuers/.../didcomm/offer` + `receive-invitation` |
| `GET /v1/holders/:id/didcomm/credentials` | `GET /v1/holders/:id/records?type=W3cCredentialRecord` (u otros tipos en `/records/types`) |
| `GET /v1/holders/:id/didcomm/credentials-status` | — (revocación vía verifier / VDR según flujo) |
| `GET /v1/holders/:id/didcomm/credential-status/:id` | — |

### Endpoint conservado

- `POST /v1/holders/:id/didcomm/receive-invitation` — body `{ invitationUrl }`

### Verificación

1. `npm run build` en `source/`
2. Smoke: offer issuer → `receive-invitation` → `GET .../records?type=W3cCredentialRecord`

## A v0.1.0 (multi-tenant + rutas /v1)

1. **Prefijo global `/v1`.** Todas las rutas pasan a `/v1`, excepto `GET /metrics`
   (Prometheus) que queda en la raíz. Actualizar clientes.
2. **Modelo multi-tenant.** Ya no se configura un único wallet por env. Los holders se
   crean dinámicamente con `POST /v1/holders` (body `{ holderId }`). Las variables
   `AGENT_LABEL`, `WALLET_ID`, `WALLET_KEY`, `DIDCOMM_ENDPOINT`, `WALLET_MODE` e
   `INTERNAL_WALLET_DATABASE_URL` **ya no se usan**; eliminar del `.env`.
3. **CORS.** Configurar `WALLET_ORIGIN` (default `*`).

## A "Flujo OID4VC" (13/04/2026) — BREAKING

Renombrar variable de entorno de wallet a record:

| Antes | Ahora |
|---|---|
| `INTERNAL_WALLET_DATABASE_URL` | `POSTGRES_RECORD_DATABASE_URL` (antes `INTERNAL_RECORD_DATABASE_URL`) |

Los records se inyectan vía `RecordStorageModule` + `PostgresRecordStorage` (mismo proceso, Postgres local).
