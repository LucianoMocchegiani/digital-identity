# Changelog — identity-holder-service

> Servicio de prueba/integración del rol Holder en QuarkID 2.0. No forma parte del stack productivo.

## DIDComm alineado — [23/07/2026]
- Módulo `didcomm/` plano (como issuer/verifier): solo `POST .../receive-invitation`.
- **Breaking:** eliminados connections, propose-credential y listados de credentials/status bajo didcomm. Usar `GET .../records`. Ver UPGRADE.md.

## v0.1.0 — Integración con identity-wallet — [27/04/2026]
- Integración con identity-wallet.
- Rutas explícitas bajo prefijo global `/v1` (excepto `/metrics`).
- Modelo multi-tenant: alta dinámica de holders vía `POST /v1/holders`.

## Flujo OID4VC — [13/04/2026]
- OID4VCI (`POST /openid4vc/receive-offer`) y OID4VP (`POST /openid4vc/present`).
- **Breaking:** variables `WALLET_*` renombradas a `RECORD_*` (ver UPGRADE.md).

## DID key y Docker — [07/04/2026]
- Soporte de DID `did:key` (actualmente Ed25519).
- `useHttpForWebDid`; fixes de build Docker.
- JSDoc traducido a español.

## Logging estructurado — [01/04/2026]
- Logging JSON estructurado y documentación de logging.

## Scaffold inicial — [26/03/2026]
- Estructura inicial del servicio holder (NestJS 10).
- Migración de `@one/credo` a `@identity/core`.
- Módulo de métricas Prometheus.
