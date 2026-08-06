# quark-verifier-service

Servicio NestJS de prueba para el rol **Verifier** del stack QuarkID 2.0.

Consume `@quarkid/identity-core` para inicializar un agente Credo-TS con capacidades de verificación: invitaciones OOB, proof requests DIDComm v1 (DIF PEX), authorization requests OID4VP (DCQL/PEX para wallets EUDI), y verificación de revocación vía Token Status List.

> Este servicio es un entorno de prueba/integración para validar `@quarkid/identity-core`. No forma parte del SCI productivo (Gateway, Auth, Web, Index, Resolver).

---

## Responsabilidades

- Inicializar el agente Credo-TS como verifier (DID `did:web` + wallet + KMS).
- **DIDComm**: invitaciones OOB, proof requests DIF PEX, gestión de conexiones.
- **OID4VP**: authorization requests (DCQL o PEX) para wallets EUDI; consulta de sesión.
- **Verifiers**: alta y listado de verifiers multi-tenant (`POST /verifiers`, `GET /verifiers`).
- **Records**: consulta de solo lectura de records Credo del tenant (`/records`).
- **Revocación** (ruta global `/revocation/*`): consulta de StatusList, status check por índice, verificación de credencial contra StatusList firmada.
- **Metadata OID4VP**: merge de `OpenId4VcVerifierRecord` por tenant (`PATCH /:walletId/metadata`).
- **Domain key**: importación de clave privada JWK para OID4VP x5c (`POST /domain-key`).
- **Publicación de eventos**: a RabbitMQ (exchanges `quarkid.index` y `quarkid.audit`).

## Stack

- NestJS 10 + TypeScript
- `@quarkid/identity-core` (wrapper Credo-TS)
- KMS: interno (Postgres) o externo (HTTP)
- Records Credo: `PostgresRecordStorage` vía `RecordStorageModule` (`DATABASE_URL`)
- Transporte DIDComm: WebSocket + HTTP
- Mensajería: RabbitMQ (`amqplib`)

> Este servicio **no** persiste en Postgres propio: el módulo de revocation en el verifier es de solo lectura (consulta la StatusList por HTTP y la decodifica). No hay `TypeOrmModule` en `app.module.ts`.

## Estructura

```
source/src/
├── agent/                  # Inicialización del agente Credo (DID gestionado internamente)
├── common/                 # Health, DID Document, logger, interceptors, exception filter
├── config/                 # env.config.ts, index.ts, verifier-config.mock.ts
├── didcomm/                # POST request + GET request/:id + GET /oob/:id (espejo de openid4vc/)
├── openid4vc/              # POST /:walletId/openid4vc/request, GET /session/:id
├── verifiers/
│   ├── dto/                # create-verifier.dto, patch-verifier-metadata.dto
│   ├── verifiers.controller.ts        # GET/POST /verifiers
│   ├── verifiers.service.ts
│   ├── verifiers.module.ts
│   ├── verifier-wallet.controller.ts  # PATCH /:walletId/metadata
│   └── verifier-wallet.module.ts
├── records/
│   ├── list-records-query.dto.ts
│   ├── records.controller.ts        # /:walletId/records/*
│   ├── records.service.ts
│   └── records.module.ts
├── storage/                # RecordStorageModule — ver source/src/storage/README.md
├── revocation/             # Módulo @Global() — rutas /revocation/* (no por walletId)
│   ├── dto/                # revocation.dto.ts
│   ├── revocation.controller.ts     # status, status-check, status/:uri/:idx, verify
│   ├── revocation.service.ts        # getStatusList, getStatus, verifyCredential (sin DB propia)
│   └── revocation.module.ts         # expone StatusListService del core
├── domain-key/             # POST /domain-key (global)
│   ├── dto/                # import-domain-key.dto.ts
│   ├── domain-key.controller.ts
│   ├── domain-key.service.ts
│   └── domain-key.module.ts
├── messaging/
│   ├── messaging.service.ts              # publish a quarkid.index
│   ├── messaging.client.ts
│   ├── messaging.constants.ts            # routing keys y payload types
│   ├── messaging.module.ts
│   ├── audit-messaging.service.ts        # publish a quarkid.audit
│   ├── audit-messaging.module.ts
│   └── audit.interceptor.ts              # APP_INTERCEPTOR global
├── app.module.ts           # RouterModule monta /verifiers y /:walletId/*
└── main.ts
```

## Variables de entorno

Copiar `source/.env.example` a `source/.env` y completar.

Las variables se consumen en `source/src/config/env.config.ts`. Toda variable no listada aquí es ignorada por el código actual.

### HTTP y agente

| Variable | Default | Descripción |
|---|---|---|
| `PORT` | `9004` | Puerto HTTP del servicio. |
| `BASE_URL` | `http://quark-verifier-service:9002` | URL base pública. Se usa para `didcommEndpoint`, `invitationUrlPrefix`, `oid4vcBaseUrl` y el cálculo del `didWebDomain`. |
| `SERVICE_HOST` | `localhost` | Host lógico del servicio. |
| `LOG_LEVEL` | `INFO` | Nivel de log: `DEBUG` \| `INFO` \| `WARN` \| `ERROR`. |
| `WALLET_ID` | — | ID del wallet/tenant default al iniciar el agente raíz. |
| `WALLET_KEY` | — | Clave de encriptación del wallet (mínimo 32 chars recomendado). |
| `NODE_ENV` | — | Si **no** es `production`, activa `useHttpForWebDid` en el DID web. |

### Persistencia / KMS

| Variable | Default | Descripción |
|---|---|---|
| `DATABASE_URL` | — | **Obligatoria.** Postgres (Askar store, BBS, domain-key). |
| `ASKAR_STORE_KEY` | — | Passphrase Askar (obligatoria). |
| `ASKAR_STORE_ID` | — | ID store Askar; default = nombre de DB en `DATABASE_URL`. |

### OID4VP (firma con cadena X.509)

| Variable | Default | Descripción |
|---|---|---|
| `OID4VP_X5C_CERTIFICATES_BASE64` | `[]` | Lista separada por coma de certificados X.509 en base64. Habilita `client_id_scheme=x509_*`. |
| `OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID` | `''` | Key ID del leaf certificate para firma x5c. |
| `OID4VP_X5C_CLIENT_ID_PREFIX` | `x509_hash` | Prefijo de `client_id`: `x509_hash` \| `x509_san_dns`. |

### Otros

| Variable | Default | Descripción |
|---|---|---|
| `VDR_SERVICE_URL` | `http://localhost:4003` | URL del VDR service (registro DID). |
| `RABBITMQ_URL` | `amqp://localhost:5672` | URL del broker RabbitMQ usado por `MessagingService` y `AuditMessagingService`. |

## Levantar en local

El código y el `package.json` viven en `source/`. Ejecutar desde ese subdirectorio:

```bash
cd source
cp .env.example .env
npm install
npm run start:dev
```

El servicio expone HTTP en `PORT` (default `9004`) y comparte el mismo puerto para el WebSocket DIDComm (registrado en `main.ts:31`).

## Endpoints

Los módulos se montan vía `RouterModule` en `app.module.ts:25-31`. Adicionalmente hay **módulos globales** que exponen rutas fuera del router (ver sección "Rutas globales" más abajo).

### Raíz

| Método | Path | Descripción |
|---|---|---|
| `GET` | `/verifiers` | Lista verifiers disponibles para pruebas en este proceso. |
| `POST` | `/verifiers` | Da de alta un verifier (tenant + DID web + `OpenId4VcVerifierRecord` opcional). Body: `{ verifierId, oid4vp? }` (ver `CreateVerifierDto`). |

### Por wallet (`/:walletId`)

| Método | Path | Descripción |
|---|---|---|
| `PATCH` | `/:walletId/metadata` | Merge de metadata OID4VP en el `OpenId4VcVerifierRecord` (campo `clientMetadata`). Body: `PatchVerifierMetadataDto`. |

### DIDComm (`/:walletId/didcomm`)

| Método | Path | Descripción |
|---|---|---|
| `POST` | `/:walletId/didcomm/request` | Flujo integrado: OOB + pending; al conectar envía `request-presentation`. `invitation` = short URL `/oob/:id`. |
| `GET` | `/:walletId/didcomm/request/:pendingRequestId` | Estado / resultado del QR (análogo a sesión OID4VP). |
| `GET` | `/:walletId/didcomm/proofs/:proofExchangeRecordId` | Detalle Credo de un proof exchange. |
| `GET` | `/oob/:pendingRequestId` (sin `/v1`) | Short URL pública: mensaje OOB en JSON (RFC 0434). |

### OID4VP — NestJS (`/:walletId/openid4vc`)

| Método | Path | Descripción |
|---|---|---|
| `POST` | `/:walletId/openid4vc/request` | Crea authorization request OID4VP (DCQL o PEX). Body: `CreatePresentationRequestDto` (campos `presentationDefinition?` \| `dcqlQuery?`, `responseMode?`, `requestSignerMethod?`, `authorizationResponseRedirectUri?`). |
| `GET` | `/:walletId/openid4vc/session/:id` | Estado de una sesión de verificación. |

### Records (`/:walletId/records`)

| Método | Path | Descripción |
|---|---|---|
| `GET` | `/:walletId/records/types` | Lista los tipos de record consultables para el rol verifier (catálogo `record-type-catalog.ts` en `identity-core`). |
| `GET` | `/:walletId/records?type=&query=&page=&limit=` | Lista records paginados filtrados por tipo Credo. `type` obligatorio, `page` default 1, `limit` default 20 (máx 100). |
| `GET` | `/:walletId/records/:recordType/:recordId` | Obtiene un record específico por tipo y UUID. |

### Rutas globales

Los siguientes módulos están declarados con `@Global()` o como providers directos en `app.module.ts` y **no** aparecen en `RouterModule.register`. Sus rutas se sirven en el raíz del servicio.

| Método | Path | Descripción |
|---|---|---|
| `GET` | `/health` | Health check (`CommonController.health`). |
| `GET` | `/:walletId/did.json` | DID Document (`did:web`) de la wallet del verifier. |
| `POST` | `/domain-key` | Importa una clave privada JWK al KMS (usado para OID4VP con `requestSignerMethod=x5c`). Body: `{ keyId, privateJwk }` (ver `ImportDomainKeyDto`). |
| `GET` | `/revocation/status?uri=...` | Descarga y decodifica la StatusList firmada del URI indicado. Retorna `{ jwt, cached, expiresAt }`. |
| `GET` | `/revocation/status-check?uri=...&idx=N` | Devuelve `{ revoked, status, updatedAt }` para un índice concreto. |
| `GET` | `/revocation/status/:uri/:idx` | Igual que `status-check` pero con URI/idx en path. |
| `POST` | `/revocation/verify` | Verifica una credencial SD-JWT contra su StatusList. Body: `{ credentialJwt }`. Retorna `{ valid, errors[], payload? }`. |

> **Nota sobre `/revocation/*`**: a diferencia de los módulos bajo `RouterModule`, las rutas de revocation **no se colgan** de `/:walletId` y **no están segmentadas por tenant**. En el futuro se añadirá un sistema de permisos/autorización para estas rutas. Por ahora se sirven en el raíz.

### Endpoints OID4VP manejados por Credo-TS (no pasan por NestJS)

Registrados por `OpenId4VcVerifierModule` de Credo bajo el prefijo configurado en `env.config.oid4vcBaseUrl` = `${BASE_URL}/openid4vc-flow/{verifierId}/`:

| Método | Path | Descripción |
|---|---|---|
| `GET` | `/{verifierId}/.well-known/oauth-authorization-server` | Metadata OAuth AS (RFC 8414). |
| `GET` | `/{verifierId}/authorization-requests/{requestId}` | Resolve del request object JWT. |
| `POST` | `/{verifierId}/authorize` | Callback de la wallet con `vp_token` (response_mode `direct_post` \| `direct_post.jwt`). |

> Los consumers de estos endpoints son wallets OID4VP; no exponen lógica propia del servicio.

## Eventos publicados (RabbitMQ)

Dos exchanges y dos `MessagingService` separados, definidos en `source/src/messaging/messaging.constants.ts`.

### Exchange `quarkid.index` (vía `MessagingService`)

| Routing Key | Payload (`type`) | Origen |
|---|---|---|
| `did.created` | `DidEventPayload` | Creación de DID web. |
| `did.resolved` | `DidEventPayload` | Resolución de DID. |
| `did.reported` | `DidEventPayload` | Reporte de DID. |

> El verifier **no** publica eventos de revocation (no es emisor de StatusList). A diferencia del issuer, `RevocationVerifierService` opera en modo solo lectura.

### Exchange `quarkid.audit` (vía `AuditMessagingService`)

| Routing Key | Payload (`type`) | Origen |
|---|---|---|
| `audit.operation` | `AuditEventPayload` | `AuditInterceptor` global (`APP_INTERCEPTOR` en `app.module.ts:33`) — emite un evento por cada request HTTP con `correlationId`, `operation`, `status`, `durationMs`. |

## Errores relevantes

- `POST /revocation/verify` no lanza excepciones: cualquier fallo (decode, status no válido, issuer mismatch) se captura en `RevocationVerifierService.verifyCredential` (`revocation.service.ts:95-105`) y se retorna como `{ valid: false, errors: [{ code: 'VERIFICATION_ERROR', message }] }`. Posibles `code` en `errors[]`:
  - `ISSUER_MISMATCH` — el `iss` del JWT no coincide con el `expectedIssuer` provisto.
  - `STATUS_INVALID` — el índice de la credencial está marcado como no válido.
  - `VERIFICATION_ERROR` — cualquier otra excepción.
- Los errores de validación de DTOs propagan al `GlobalExceptionFilter` (`common/http-exception.filter.ts`) como `400 Bad Request`.
