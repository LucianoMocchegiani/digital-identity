# UPGRADE — identity-issuer-service

## A v0.2.0 (Record + Revocation storage injection) — BREAKING

Misma filosofía que el PR `record-storage-injection` aplicada al módulo de revocación: **port + adapter Postgres en identity-core, módulo Nest que provee el storage y reutiliza el `pg.Pool` de records**.

### Cambios breaking

1. **TypeORM eliminado del issuer.** El módulo `RevocationIssuerModule` ya no usa TypeORM. Las tablas `status_lists` y `status_list_revocations` ahora las crea el adapter `PostgresStatusListStorage` de `@identity/core` con DDL idempotente al primer arranque.
   - Borrar de `.env`: `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE` (si solo se usaban para revocation).
2. **Variables de entorno**:
   - Renombrar: ya no aplica (este PR no renombra nada que no se hubiera renombrado antes).
   - **Nueva opcional**: `POSTGRES_STATUS_LIST_DATABASE_URL`. Si está vacía, `StatusListStorageModule` reusa el pool de records. Definila solo si querés separar la DB de revocation.
3. **Cambios en DI (consumidores de `@identity/core`)**:
   - `IStatusListRepository` → `StatusListStorage`.
   - `MESSAGING_SERVICE` pasa de `string` a `Symbol('MessagingService')`.
   - El nuevo `StatusListStorage` incluye `withTransaction<T>(fn)`. Si mantenés un adapter propio, implementalo.
4. **Eventos `credential.revoked` / `revocation.status-list.*` ahora se publican**. El `MessagingModule` provee el symbol `MESSAGING_SERVICE` del core, que se inyecta al `RevocationService`. Antes quedaban en no-op por wiring manual.

### Verificación post-upgrade

1. `npm run build` en `source/` debe compilar limpio.
2. Arrancar el servicio y verificar en logs:
   - `[PostgresRecordStorage] initialization succeeded after N attempts`
   - `[PostgresStatusListStorage] schema version 1 ready`
3. Smoke test del flow de revocation (Postman carpeta "03 Revocation E2E"): createStatusList → allocate → revoke → getStatusListJwt.
4. Verificar que la DB contiene las dos tablas con los índices correctos.

## A v0.1.0 (Revocación + rutas /v1)

1. **Prefijo global `/v1`.** Todas las rutas (excepto `/:walletId/did.json`) pasan a
   colgar de `/v1`. Actualizar clientes que llamaban rutas sin prefijo.
2. **`BASE_URL`.** Configurar la URL base pública; de ella se derivan el endpoint
   DIDComm, el prefijo de invitación y el prefijo OID4VCI, además de la URI pública
   del status list (`${BASE_URL}/v1/issuers/${walletId}/revocation/status-list/${vct}`).

## A "Flujo OID4VCI" (13/04/2026) — BREAKING

Renombrar variable de entorno de wallet a record:

| Antes | Ahora |
|---|---|
| `INTERNAL_WALLET_DATABASE_URL` | `POSTGRES_RECORD_DATABASE_URL` (antes también `INTERNAL_RECORD_DATABASE_URL`) |

Records: `RecordStorageModule` + `PostgresRecordStorage` (inyección en proceso, Postgres local).

Agregar (si se usa OID4VCI): `OID4VC_SUPPORTED_ALGS` (default `ES256`).
