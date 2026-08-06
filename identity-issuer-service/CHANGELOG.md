# Changelog — identity-issuer-service

> Servicio de prueba/integración del rol Issuer en QuarkID 2.0. No forma parte del stack productivo.

## v0.1.0 — Revocación y rutas explícitas v1 — [29/04/2026]

### Nuevas funcionalidades
- Revocación de credenciales vía StatusList con persistencia TypeORM/Postgres (`/v1/issuers/:walletId/revocation/*`).
- Rutas explícitas bajo el prefijo global `/v1`.
- `BASE_URL` para construir `didcommEndpoint`, `invitationUrlPrefix` y el prefijo OID4VCI; URI pública del status list incluye el prefijo global.
- Compatibilidad de tipos (eliminación de `any`).

### Cambios en base de datos
- Tablas `status_lists` y `status_list_revocations` (índices únicos por walletId+vct y por índice de revocación).

## Flujo OID4VCI — [13/04/2026]
- Oferta de credenciales SD-JWT (`dc+sd-jwt`) vía pre-authorized code (eIDAS 2.0): `POST /v1/issuers/:walletId/openid4vc/offer`.
- **Breaking:** variables de entorno `WALLET_*` renombradas a `RECORD_*` (ver UPGRADE.md).

## DID web y status list opcional — [06/04/2026]
- Soporte `did:web`; bootstrap de status list opcional.
- JSDoc y comentarios traducidos a español.

## Logging estructurado — [01/04/2026]
- Logging JSON estructurado y documentación de logging.

## Scaffold inicial — [26/03/2026]
- Estructura inicial del servicio issuer (NestJS 10).
- Migración de `@one/credo` a `@identity/core`.
- README inicial.
