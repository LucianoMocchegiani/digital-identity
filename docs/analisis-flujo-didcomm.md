# Análisis del flujo DIDComm — QuarkID 2.0

> **Estado:** Borrador para revisión
> **Fecha:** 2026-06-23
> **Rama analizada:** `revocation-flow`
> **Alcance:** `packages/identity-core` + `quark-issuer-service` + `quark-holder-service` + `quark-verifier-service`
> **Convención de severidad:** 🔴 P0 bloqueante · 🟠 P1 importante · 🟡 P2 deuda técnica

---

## 1. Resumen ejecutivo

La funcionalidad core del flujo DIDComm (issue-credential v2 / present-proof v2 con JSON-LD y DIF PEX) está **correcta para el happy path**. Los tres agentes montan el mismo stack Credo-TS, los listeners responden al estado de los records, y el multi-tenancy está bien modelado con `withWallet` + `tenantMap` + `withTenant`.

**Sin embargo, el sistema no es seguro en producción tal como está.** Cinco hallazgos P0 combinados:

1. **Sin autenticación HTTP** en los endpoints DIDComm (issuer, holder, verifier).
2. **Fuga de DIDs entre tenants** en el flujo de firma del issuer.
3. **El verifier NO consulta revocación en DIDComm** — acepta credenciales revocadas.
4. **El verifier NO valida issuer ni schema** en la Presentation Definition.
5. **Default `https://example.org`** en invitaciones OOB si no se pasa `domain`.

La rama `revocation-flow` actual resuelve (parcialmente) el punto #3 desde el lado issuer, pero el listener del verifier sigue sin consultar el status list — ese trabajo es previo a cerrar la historia de revocación E2E.

---

## 2. Cómo funciona el flujo

### 2.1 Stack por rol

Los tres agentes montan el mismo conjunto Credo:

- `DidCommModule` con `DidCommCredentialV2Protocol` + `DidCommJsonLdCredentialFormatService`.
- Holder y verifier suman `DidCommProofV2Protocol` + `DidCommDifPresentationExchangeProofFormatService`.
- Transporte de salida: `DidCommWsOutboundTransportDelayedClose` con `closeDelayMs = 10000` (workaround para un bug de Credo donde el socket se cierra antes de que el receptor reciba el mensaje).

### 2.2 Issue-Credential v2 (JSON-LD)

```
HOLDER                                   ISSUER
──────                                   ──────
1. POST /receive-invitation ───────────► (auto-accept WS handshake)
                                          connection-request/response vía WS
                                          
2. ◄─────── offer-credential (v2, JSON-LD)
   listener: OfferReceived
     └─► acceptOffer (auto) ──────────► request-credential
                                          listener: RequestReceived
                                            └─► acceptRequest ─────► issue-credential
   listener: CredentialReceived
     └─► acceptCredential ─────────────► ack
   listener: Done
```

### 2.3 Present-Proof v2 (DIF PEX)

```
VERIFIER                                 HOLDER
────────                                 ──────
1. POST /request-proof ─────────────────► request-presentation (PEX)
                                          listener: RequestReceived
                                            ├─► selectCredentialsForRequest
                                            ├─► expandPexSelection (heurístico)
                                            └─► acceptRequest ────────► presentation
   listener: PresentationReceived
     └─► acceptPresentation (sin validar revocación)
```

El routing por `thid`/`pthid` y la serialización del envelope están 100% delegados a Credo. QuarkID no manipula el envelope manualmente — diseño correcto.

### 2.4 Reutilización de conexiones

- `receiveInvitationFromUrl` se invoca con `reuseConnection: true` (`packages/identity-core/src/protocol/didcomm/invitation.ts:84-90`).
- `autoAcceptConnections: true` está habilitado en los tres roles (`issuer.agent.ts:124`, `holder.agent.ts:124`, `verifier.agent.ts:124`).
- Si el agente se reinicia, Credo recrea la conexión desde cero.

### 2.5 Out-of-Band Invitations

- `createInvitation` usa `oob.createInvitation()` y serializa con `toUrl({ domain })` con `domain` por defecto `https://example.org` (ver §6.5).
- `receiveInvitation` normaliza `_oob=` → `oob=` y delega a Credo.

---

## 3. Lo que funciona bien

1. **Aislamiento multi-tenant en el path feliz** — `withWallet` (en `agent-store.ts` de cada servicio) + `tenantMap` + `withTenant` (de Credo Tenants) aísla storage y KMS por walletId. Cada request entra y sale del tenant scope.

2. **`ensureKeyDid` / `ensureWebDid` robustos** — detectan `KeyManagementKeyNotFoundError` y validan el DID Document al rehidratar (chequean que existan `addEd25519Key`, `addDidCommKey` y `service: did-communication`). Si falta algo, recrean el DID.

3. **`DidCommWsOutboundTransportDelayedClose`** (`packages/identity-core/src/protocol/didcomm/transport.ts:30-77`) — workaround acotado, configurable vía `transportCloseDelayMs`, con comentario explicativo del bug que mitiga.

4. **`negotiateProposal` en `issuer.listener.ts:36-66`** — filtra tipos custom de VerifiableCredential, preserva `@context` si tiene más de un elemento, y rellena `issuer` e `id`. Es el único punto de transformación de payload y está contenido.

5. **`expandPexSelection` heurística razonable** (`holder.listener.ts:46-118`) — cuando un Presentation Definition deja descriptores sin asignar, busca en el wallet credenciales que cumplan los `constraints.fields` y las asigna automáticamente. Tiene fallback con `try/catch` que evita propagar crashes.

6. **`RevocationIssuerService`** en el issuer — implementa correctamente `allocateIndex` antes del offer (`openid4vc.service.ts:40-58`), asegurando que cada SD-JWT tenga `status_list` revocable desde el día uno. Cumple W3C VC-bitstring-status-list.

7. **Try/catch en listeners** — un error en un record no detiene el event loop de Credo. Los errores se loguean y el flujo continúa.

8. **Logging estructurado JSON + `AuditInterceptor` global** con `correlationId` propagado vía header `x-correlation-id`. Cumple con la guía de `logging-best-practices` y queda listo para ingest en Elasticsearch/Loki.

9. **`HttpExceptionFilter` con分级 de severidad** (`common/http-exception.filter.ts:50-58`) — 5xx ERROR con stack, 4xx WARN. Convención correcta.

10. **`ValidationPipe` global con `whitelist: true, transform: true`** en los 3 servicios — rechaza campos no declarados y transforma tipos.

11. **`AuditInterceptor` con `correlationId`** (`messaging/audit.interceptor.ts:10-44`) — publica cada request a `quarkid.audit` con duración y status.

12. **DTOs validados con `class-validator`** — intención correcta, aunque la ejecución tiene huecos (ver §6).

---

## 4. Hallazgos por gravedad

### 🔴 P0 — Bloqueantes para producción

#### 4.1 Sin autenticación HTTP en endpoints DIDComm (seguridad crítica)

**Servicios afectados:** issuer, holder, verifier.

`JwtAuthGuard` solo se aplica a 2 endpoints del issuer (`revocation.controller.ts:107, 121`). En holder y verifier **no hay ningún guard activo**. Todos los siguientes endpoints están públicos:

- `GET /issuers`, `GET /holders`, `GET /verifiers` — listan todos los tenants con su `issuerId`, `tenantId` y `did` (enumeración trivial).
- `GET /:walletId/did.json` — expone el DID Document completo de cualquier tenant.
- `POST /didcomm/create-invitation`, `POST /didcomm/offer-credential`, `POST /didcomm/request-proof` — cualquier actor puede operar sobre cualquier wallet.
- `GET /:walletId/records/*` — devuelve `CredentialRecord` emitidos, incluyendo claims.

`JwtAuthGuard` no está registrado como global en ninguno de los tres `app.module.ts`. `IssuerScopesGuard` existe pero solo se aplica a 2 rutas.

#### 4.2 Fuga de DIDs entre tenants (multi-tenant)

**Archivos:** `packages/identity-core/src/protocol/didcomm/issuer.listener.ts:31-32` y `packages/identity-core/src/protocol/didcomm/issuance.ts:62-64`.

```ts
const didRecords = await agent.dids.getCreatedDids({ method: 'web' });
const issuerDid = didRecords[0]?.did ?? '';
```

`getCreatedDids` sin filtro de tenant **devuelve todos los DIDs web de todos los tenants**. Si hay 2 tenants, `didRecords[0]` puede ser el DID de otro tenant → **el issuer de un tenant firma credenciales con el DID de otro tenant**.

Adicionalmente, `getCreatedDids` no filtra por `role: DidDocumentRole.Created`, así que un DID web importado (resolución entrante) también podría usarse como firmante.

#### 4.3 Verifier NO consulta revocación en DIDComm (agujero crítico)

**Archivo:** `packages/identity-core/src/protocol/didcomm/verifier.listener.ts:38-55`.

El listener llama `acceptPresentation` directamente, sin pasar por `RevocationVerifierService`. **Una credencial revocada será aceptada por el listener.**

La revocación existe como feature en el issuer y como servicio HTTP en el verifier, pero **no está enchufada al flujo DIDComm**. Esto invalida toda la rama `revocation-flow` actual en su objetivo declarado: hacer que el flujo completo emitir → custodiar → presentar → **rechazar si está revocada** funcione.

#### 4.4 Verifier NO valida issuer ni schema en la Presentation Definition

**Archivo:** `packages/identity-core/src/credential/presentation.builder.ts:22-58`.

El builder genera PEX con un único filtro:

```ts
constraints.fields: [{ path: '$.type', filter: { contains: 'GenericCredential' } }]
```

Sin `issuer`, sin `credentialSchema`, sin `subject_is_issuer: true`, sin predicate. **Cualquier credencial con el type string "GenericCredential" pasa**, sea del issuer que sea. Combinado con `autoAcceptConnections: true` y `acceptPresentation` automático, **el modelo de seguridad es fail-open en TODOS los puntos críticos**.

#### 4.5 Default `https://example.org` en invitaciones OOB

**Archivo:** `packages/identity-core/src/protocol/didcomm/invitation.ts:28`.

```ts
const domain = options?.domain ?? 'https://example.org';
```

Si un servicio upstream olvida pasar `domain`, las invitaciones OOB apuntan a `example.org`. El holder intentará resolver `did:web:example.org` y conectar contra `wss://example.org` — fallo silencioso o, peor, exfiltración si el dominio se vendió.

---

### 🟠 P1 — Importantes

#### 4.6 Listeners no se desregistran — memory leak

Búsqueda exhaustiva: **0 ocurrencias de `agent.events.off` / `removeListener` en el paquete**. Si se llama `createRootHolderAgent` dos veces en el mismo proceso (test suite, hot-reload, reinicio), Credo **duplica los listeners** porque no deduplica. Cada reinicio acumula handlers zombies.

#### 4.7 Listeners globales sin scope de tenant

Todos los listeners (`holder.listener.ts`, `issuer.listener.ts`, `verifier.listener.ts`) se registran en el **root agent** y procesan eventos de **todos los tenants**. Combinado con §4.2, un `ProposalReceived` del tenant A puede ser manejado por el listener que firmaría con un DID del tenant B. No hay `correlationId` por tenant en los logs — la correlación en troubleshooting es imposible.

#### 4.8 Race conditions en creación de tenants

`POST /issuers`, `POST /holders`, `POST /verifiers` no son atómicos. `hasWallet` + `createWallet` ejecutan TOCTOU — dos requests concurrentes con el mismo `issuerId` pasan el check `hasWallet` antes de que el primero registre el tenant. No hay mutex.

- Issuer: `issuers.service.ts:71-82`
- Holder: `holders.service.ts:60-65`

#### 4.9 Race condition en `MessagingService.publish`

`messaging.service.ts:23-25` (en los 3 servicios) descarta la promesa de `channel.publish` con `.catch()`. El emisor nunca sabe si RabbitMQ aceptó el mensaje. Además, `onModuleInit` no es `async` (`messaging.service.ts:14-17`) — el primer `publish` puede ejecutarse antes de que `assertExchange` complete.

#### 4.10 Validación de input laxa

- `walletId` se valida con `WALLET_ID_REGEX` solo en `CreateIssuerDto` / `CreateHolderDto`, **nunca en runtime** en los controllers. `withWallet` rechaza si no existe en el mapa, pero no sanitiza.
- `CredentialSubjectDto` tiene index signature `[key: string]: unknown` — desactiva validación efectiva. Un atacante puede meter cualquier claim (incluido `id` del holder, que se usa para firmar la credencial).
- `connectionId`, `issuerDid`, `proofType`, `@context`, `id` (path) — todos sin validación semántica.
- `RequestProofDto.presentationDefinition` es `@IsObject()` plano, sin `@ValidateNested` ni cap de descriptores. DoS posible (1M descriptores).

#### 4.11 Errores silenciados → sin observabilidad

- `connections.service.ts:25-27` (holder): si `didcomm.connections` no existe, devuelve `[]` sin loggear.
- `credentials.service.ts:38-43` (verifier): `getProofs` traga todos los errores con `catch {}`.
- `issuance.ts:85-88`, `presentation.ts:60-63`: convierten cualquier excepción a `{ error: message }` — se pierde stack trace y tipo.
- `verifiers.service.ts:43-48`, `issuers.service.ts:50-58`: tragan errores de `getTenantWebDid` con `try { ... } catch { did = null }`.
- `connections.service.ts:51-58` (verifier): `findById` que devuelve `null` se traduce a `NotFoundException` sin log previo del intento fallido.

#### 4.12 HTTP 200 con `{ error: string }` en el cuerpo

**Archivo:** `quark-holder-service/source/src/didcomm/credentials/credentials.service.ts:67`.

`proposeCredential` devuelve `{ error }` con HTTP 200 cuando la conexión no existe. El cliente recibe 200 con error embebido en lugar de 404. Rompe el contrato REST y hace fallar silenciosamente a clientes tipados.

#### 4.13 Doble path paralelo DIDComm vs OID4VCI sin endpoint unificado

El holder tiene **dos caminos para recibir credenciales** con shapes incompatibles:

| Aspecto | DIDComm | OID4VCI |
|---|---|---|
| Endpoint de recepción | `POST /didcomm/receive-invitation` + listener automático | `POST /openid4vc/receive-offer` (síncrono) |
| Almacenamiento | Automático vía listener `acceptCredential` | Explícito en `holder.oid4vc.ts:87-95` |
| DTO de respuesta | Lista plana con shape Credo crudo | `ReceivedCredentialDto[]` con envelope estable |
| Presentación | Listener automático al recibir `presentation-request` con `expandPexSelection` heurístico | `POST /openid4vc/present` síncrono con `errorCode: NO_MATCHING_CREDENTIAL` |
| Errores | Se loguean y se pierden; el cliente no se entera en tiempo real | Se devuelven como `UnprocessableEntityException` |

**Riesgos concretos:**

1. Una credencial recibida por DIDComm aparece en `/didcomm/credentials` pero **NO** en la respuesta de `/openid4vc/receive-offer`. No hay endpoint unificado `/credentials` que combine ambos.
2. El listener DIDComm acepta ofertas automáticamente — **no hay forma de rechazar** una oferta recibida por este canal.
3. Si un issuer publica dos QR (uno por cada protocolo) para la misma credencial, el holder termina con 2 records distintos.
4. `credential-status` solo se chequea en el path DIDComm contra el VDR; el path OID4VCI no expone endpoint análogo.

#### 4.14 Tipado débil contra Credo

Uso extensivo de `as unknown as ...` y shapes locales (`CredentialsAgent`, `ProofsAgent`, `ConnectionLike`, `DidcommConnectionsApi`, `AgentModulesLike`) en `issuance.ts`, `presentation.ts`, `connections.service.ts`, `credentials.service.ts` de los 3 servicios. Si Credo renombra o mueve una API, **no hay validación estática** — el cast sigue "funcionando" hasta el primer crash en runtime.

#### 4.15 `getSignerOptions` no determinístico

**Archivo:** `quark-issuer-service/source/src/revocation/revocation.service.ts:27-49`.

En cada request de `revoke`/`allocate`/`getStatus` se hace `agent.dids.getCreatedDids({method:'web'})` y se toma `records[0]`. Si el tenant tiene varios DIDs, el firmante puede cambiar entre requests. Combinado con §4.2, el firmante puede ser el DID de otro tenant.

#### 4.16 `getStatusList` nunca cachea

**Archivo:** `quark-verifier-service/source/src/revocation/revocation.service.ts:10-30`.

La firma dice `cached: false` siempre. Si el issuer publica cada 5 minutos, este endpoint golpea al issuer en cada verificación.

#### 4.17 Sin teardown del agente Credo en SIGTERM

`messaging.service.ts:19` cierra el cliente RabbitMQ en `OnModuleDestroy`, pero `rootAgent` nunca se hace `agent.shutdown()`. En `SIGTERM` los procesos pueden perder estado sin liberar transporte WS ni credenciales en memoria. Sockets WS y handles SQLite pueden quedar colgados.

---

### 🟡 P2 — Deuda técnica

| # | Issue | Ubicación |
|---|---|---|
| 4.18 | `DidCommWsOutboundTransportDelayedClose` sin allowlist de endpoint outbound | `packages/identity-core/src/protocol/didcomm/transport.ts:39-76` |
| 4.19 | Middleware WebSocket no-op disfrazado de feature | `quark-issuer-service/source/src/main.ts:30-35` |
| 4.20 | `autoAcceptConnections: true` + `autoAccept` de presentaciones + sin allowlist = fail-open total | `verifier.agent.ts:124, 242` |
| 4.21 | Endpoints duplicados: `GET /connections` vs `GET /records?type=ConnectionRecord` | issuer/verifier/holder |
| 4.22 | `invitation.service.ts` loguea `oob=` con `recipientKeys` y `serviceEndpoint` | holder, issuer |
| 4.23 | `MAX_DESCRIPTORS = 20` magic number en `presentation.builder.ts:5` | identity-core |
| 4.24 | Detección de "revoked" por `errorMessage.includes('revoked')` — frágil, depende del idioma | `holder.listener.ts:181-189` |
| 4.25 | `MessagingService.publish` no es async + `messaging.client.ts:46` pierde stack en `console.error`-like | todos |
| 4.26 | `@context` declarado como `'@context'` en DTO (frágil ante transpiler) | `credential-exchange.dto.ts:23` |
| 4.27 | `Buffer.from(undefined, 'base64')` en `invitation.service.ts:22-24` si la URL no tiene `oob=` | issuer |
| 4.28 | `proofType` declarado en DTO pero nunca usado | holder, issuer |
| 4.29 | ASCII art (`VERIFIED_ASCII`, `NOT_VERIFIED_ASCII`) contamina el log JSON estructurado | `verifier.listener.ts:8-24` |
| 4.30 | Duplicación de `CredentialsAgent`/`ProofsAgent` entre `issuance.ts` y `presentation.ts` | identity-core |
| 4.31 | Acoplamiento al shape interno de Credo: `firstCredential` no es API pública | `holder.listener.ts:82` |
| 4.32 | Sin rate limiting — `app.module.ts` no importa `@nestjs/throttler` | todos |
| 4.33 | `RecordsController` no expone `GET /proof/:id` — para inspeccionar un proof record hay que ir a SQLite | verifier |

---

## 5. Hallazgos por archivo (referencia rápida)

### `packages/identity-core/src/`
- `agent/issuer.agent.ts:127-134` — registro correcto de módulos DIDComm
- `agent/holder.agent.ts:127-141` — idem + `OpenId4VcHolderModule`
- `agent/verifier.agent.ts:127-134` — idem
- `agent/tenant.ts:40-47` — `withTenant` aísla storage por tenant
- `agent/wallet.ts:98` — `createIssuerWallet` / `createHolderWallet` / `createVerifierWallet`
- `protocol/didcomm/issuer.listener.ts:15-91` — listener issuer (⚠️ §4.2, §4.7)
- `protocol/didcomm/holder.listener.ts:46-118` — `expandPexSelection` (heurística OK)
- `protocol/didcomm/holder.listener.ts:120-197` — listener holder (⚠️ §4.6, §4.7)
- `protocol/didcomm/verifier.listener.ts:31-55` — listener verifier (⚠️ §4.3, §4.7)
- `protocol/didcomm/issuance.ts:52-89` — `offerCredential` (⚠️ §4.2)
- `protocol/didcomm/presentation.ts:31-64` — `requestProof`
- `protocol/didcomm/invitation.ts:24-39` — `createInvitation` (⚠️ §4.5)
- `protocol/didcomm/transport.ts:39-76` — WS outbound (⚠️ §4.18)
- `credential/credential.builder.ts:35-57` — payload JSON-LD
- `credential/presentation.builder.ts:22-58` — PEX (⚠️ §4.4)

### `quark-issuer-service/source/src/`
- `didcomm/didcomm.module.ts` — wiring del módulo
- `didcomm/invitation/invitation.controller.ts:14-18` — `POST /create-invitation` (⚠️ §4.1)
- `didcomm/credentials/credentials.controller.ts:16-19` — `POST /offer-credential` (⚠️ §4.1, §4.10)
- `didcomm/credentials/credential-exchange.dto.ts:11-17` — `CredentialSubjectDto` (⚠️ §4.10)
- `issuers/issuers.controller.ts:24-37` — sin auth (⚠️ §4.1)
- `issuers/issuers.service.ts:50-58` — traga errores (⚠️ §4.11)
- `issuers/issuers.service.ts:71-82` — race en creación (⚠️ §4.8)
- `revocation/revocation.controller.ts:107, 121` — único endpoint con `JwtAuthGuard`
- `revocation/revocation.service.ts:27-49` — `getSignerOptions` no determinístico (⚠️ §4.15)
- `messaging/messaging.service.ts:14-25` — race en `publish` (⚠️ §4.9)
- `app.module.ts:17-30` — sin `APP_GUARD` global (⚠️ §4.1)
- `main.ts:30-35` — middleware no-op (⚠️ §4.19)

### `quark-holder-service/source/src/`
- `didcomm/invitation/invitation.controller.ts:9-12` — sin auth (⚠️ §4.1)
- `didcomm/credentials/credentials.controller.ts:9-12` — sin auth (⚠️ §4.1)
- `didcomm/credentials/credentials.service.ts:67` — `proposeCredential` devuelve `{ error }` con 200 (⚠️ §4.12)
- `didcomm/credentials/credentials.service.ts:82-141` — listar credenciales (⚠️ §4.11)
- `holders/holders.service.ts:41-44` — traga errores de `getTenantKeyDid` (⚠️ §4.11)
- `holders/holders.service.ts:60-65` — race en creación (⚠️ §4.8)
- `app.controller.ts:18-26` — `GET /:walletId/did.json` sin auth (⚠️ §4.1)
- `openid4vc/openid4vc.service.ts` — endpoint paralelo (⚠️ §4.13)

### `quark-verifier-service/source/src/`
- `didcomm/invitation/invitation.controller.ts:8-12` — sin auth (⚠️ §4.1)
- `didcomm/credentials/credentials.controller.ts:9-12` — sin auth (⚠️ §4.1)
- `didcomm/credentials/credentials.service.ts:19-26` — `requestProof`
- `didcomm/credentials/credentials.service.ts:38-43` — `getProofs` traga errores (⚠️ §4.11)
- `didcomm/credentials/request-proof.dto.ts:18-21` — PD sin validar (⚠️ §4.10)
- `revocation/revocation.controller.ts:28-52` — handlers duplicados (⚠️ §4.21)
- `revocation/revocation.service.ts:10-30` — sin cache (⚠️ §4.16)
- `verifiers/verifiers.service.ts:43-48` — traga errores (⚠️ §4.11)
- `app.module.ts:15-29` — sin `APP_GUARD` (⚠️ §4.1)
- `main.ts:16-21` — shutdown básico, no hace `agent.shutdown()` (⚠️ §4.17)

---

## 6. Recomendaciones priorizadas

### 🔴 P0 — Esta semana, antes de producción

1. **Filtrar DIDs por tenant** — `issuer.listener.ts:31` y `issuance.ts:63`. Resolver tenant desde `connectionRecord` antes de elegir DID firmante. Sin esto, se filtran credenciales firmadas con el DID equivocado entre tenants.

2. **Conectar `RevocationVerifierService` al listener DIDComm del verifier** — en `verifier.listener.ts:44-51`, antes de `acceptPresentation`, decodificar la presentación, extraer `credentialStatus`, llamar al servicio de revocación, **NO aceptar si está revocada** (devolver `problem-report`). Este es el punto bloqueante de la rama `revocation-flow`.

3. **Endurecer la Presentation Definition** — añadir `issuerDid` allowlist, `schemaId`, `subjectIsIssuer: true`, cap de descriptores, y rechazar PDs sin `field.filter` que mencionen `issuer` o `credentialSchema`.

4. **Aplicar `JwtAuthGuard` global** vía `APP_GUARD` en los 3 `app.module.ts`, más verificar `req.user.walletId === params.walletId` en cada controller. El patrón `getAuthContext` ya existe en `revocation.controller.ts:76-82` (issuer) pero no se invoca.

5. **Hacer `domain` requerido en `createInvitation`** — eliminar el default `https://example.org` en `invitation.ts:28`.

### 🟠 P1 — Próximo hito

6. **Implementar `removeListeners(agent)`** y exponerlo desde `identity-core/index.ts`. Cada `setup*Listeners` debe retornar un disposer.

7. **Serializar creación de tenants** con `async-mutex` por `walletId` (en los 3 servicios).

8. ~~**Scoping de listener por tenant** — resolver `tenantId` desde `connectionRecord` en cada handler y rechazar si no coincide con el `walletId` esperado.~~ **Hecho (2026-06-25)** — implementado en `shared.listener.ts` vía `findTenantIdForRecord(rootAgent, recordId, 'credentials' | 'proofs')` + `api.withTenantAgent` en los handlers de `issuer.listener.ts`, `holder.listener.ts` y `verifier.listener.ts`. E2E DIDComm issuance + presentation pasando con `VERIFIED: true`.

9. **Tipar contra tipos exportados de Credo** — eliminar todos los `as unknown as` reescribiendo con `import type` desde `@credo-ts/core`. Definir `VerifiablePresentationAgent`, `ConnectionApi`, etc. en `packages/identity-core/src/types` y reexportar.

10. **Mapear errores tipificados a HTTP** — `ConnectionNotFoundError` → 404, `ConnectionStateInvalid` → 409, etc. Eliminar `{ error }` con HTTP 200.

11. **Hacer `MessagingService.publish` async** o propagar el `Promise` al caller (en los 3 servicios).

12. **Cachear `getStatusList` en el verifier** con TTL configurable.

13. **Quitar index signature `[key: string]: unknown`** de `CredentialSubjectDto` y declarar claims explícitamente.

### 🟡 P2 — Deuda técnica

14. Cerrar `rootAgent.shutdown()` en `OnApplicationShutdown` (los 3 servicios).
15. Eliminar endpoints duplicados (`connections`/`records`, `revocation.controller` handler doble).
16. Reemplazar `errorMessage.includes('revoked')` por `ProblemReportMessage` codes tipificados.
17. Exponer endpoint unificado `GET /:walletId/credentials` que combine DIDComm + OID4VCI con discriminador de formato.
18. ~~Eliminar el middleware WebSocket no-op (`issuer/main.ts:30-35`).~~ **Hecho (2026-06-25)** — borrado de los 3 `main.ts` (issuer, verifier, holder) y del import muerto `import type { Request, Response, NextFunction } from 'express'`. Era un no-op (ambos branches del if llamaban `next()`).
19. Quitar ASCII art del log estructurado JSON.
20. Eliminar `MessagingService.publish` no awaited + log con stack preservado.
21. Rate limiting con `@nestjs/throttler` en controllers admin.
22. Métricas: counters para `proof.requested`, `proof.accepted`, `proof.rejected`, `proof.revocation_check_failed`.
23. Validar `connectionId` con regex UUID en runtime.
24. `ParseIntPipe` en `idx` de `revocation.controller.ts:42` (verifier).
25. No loguear `recipientKeys`/`serviceEndpoint` a menos que `LOG_LEVEL=DEBUG` y entorno dev.

---

## 7. Métricas de calidad observadas

| Dimensión | Calificación | Observaciones |
|---|---|---|
| Manejo de errores | 5/10 | Hay `try/catch` pero se silencia con `log.warn` o `String(err)`. Stack traces se pierden. |
| Logging | 5/10 | JSON estructurado en el http layer OK. Faltan `correlationId` por tenant en listeners. ASCII art distrae. |
| Tipado | 4/10 | Uso extensivo de `as unknown` sobre APIs de Credo. Shapes locales incompletas. |
| Cobertura de edge cases | 6/10 | Buena en DIDs efímeros, faltante en transporte y multi-tenant. |
| Concurrencia | 5/10 | Sin `AbortController`, sin mutex, sin serialización explícita en `expandPexSelection`. |
| **Seguridad** | **3/10** | **Sin auth HTTP. Sin allowlist de endpoint. Sin scope de tenant en listeners. Fail-open en revocation check y issuer validation.** |
| Documentación | 7/10 | JSDoc detallado en funciones públicas; faltan invariantes multi-tenant. |

---

## 8. Próximos pasos sugeridos

1. **Revisar este documento en el equipo** y validar la priorización.
2. **Empezar por P0 #2** (conectar revocación al listener del verifier) — es el punto bloqueante de la rama actual y tiene tests E2E listos en Postman folder 03.
3. **Crear tickets** para cada P0 con criterios de aceptación:
   - Test E2E: credencial revocada → verifier devuelve `problem-report` con código `cred-revoked`.
   - Test E2E: credencial sin filtro de issuer en PD → controller rechaza 400.
   - Test E2E: request sin JWT → 401.
   - Test E2E: dos tenants, oferta de A firmada con DID de B → assertion falla.
4. **Estimar sprint** — los 5 P0 son ~3-5 días de trabajo集中 (2 con Credo, 1-2 de hardening, 1 de tests E2E).
5. **Cerrar el documento** cuando todos los P0 estén resueltos y migrar a `docs/historical/` o marcar como `archived`.

---

## Anexo A — Archivos analizados

**Paquete `identity-core`** (45 archivos TS):

```
src/agent/{config,create-agent-options.types,credo-init-config,dids.module,kms.module,record.module,tenant,wallet,issuer.agent,holder.agent,verifier.agent,index}.ts
src/credential/{credential.builder,presentation.builder}.ts
src/did/{did,key-did,web-did}.ts + src/did/registrar/{quark,web}.registrar.ts + src/did/resolver/{quark,web-http,web.factory}.{ts,resolver.ts}
src/protocol/didcomm/{holder,issuer,verifier,shared}.listener.ts
src/protocol/didcomm/{issuance,presentation,invitation,transport}.ts
src/protocol/openid4vc/{binding.resolver,holder.oid4vc,issuer.oid4vc,issuer.oid4vc.listener,verifier.oid4vc,verifier.oid4vc.listener}.ts
src/record/{external,internal,record-type-catalog,tenant-records}.ts
src/revocation/{index,revocation.service,status-list.service}.ts + src/revocation/{errors/revocation.errors,interfaces/status-list-repository.interface,types/status-list.types}.ts
src/kms/{domain-key,external,external.vault,internal}.kms.ts
src/types/{config,logger}.types.ts
src/utils/retry.ts
```

**Servicios** — controllers, services, dtos, modules en `didcomm/`, `agent/`, `common/`, `config/`, `holders/`, `issuers/`, `verifiers/`, `records/`, `messaging/`, `revocation/`, `openid4vc/`, `metrics/`, `domain-key/`, `app.{controller,module}`, `main.ts`.

Total: ~80 archivos TS analizados en profundidad.

---

## Anexo B — Glosario

- **DIDComm v2**: protocolo de mensajería peer-to-peer sobre cifrado authenticated encryption (libsodium/PEC). Mensajes con `id`, `type`, `thid`, `pthid`.
- **issue-credential v2**: protocolo para emitir credenciales, mensajes `propose/offer/request/issue/ack`.
- **present-proof v2**: protocolo para presentar credenciales, mensajes `propose/request/presentation/ack`.
- **DIF PEX** (Presentation Exchange): formato de proof request basado en `input_descriptors` con `constraints.fields` (filtros JSONPath).
- **OOB** (Out-of-Band): invitation de bootstrap que arranca una conexión.
- **OID4VCI / OID4VP**: estándares OpenID for VC Issuance / Presentation. Alternativa a DIDComm, basada en HTTP + OAuth2.
- **Tenants** (Credo): mecanismo de Credo-TS para aislar storage, KMS y DIDs por contexto.
- **StatusList** (W3C VC-bitstring-status-list): bitstring firmado por el issuer que marca credenciales revocadas.
