# QuarkID 2.0 — Roadmap retrospectivo

Documento informativo del avance del roadmap técnico. Resume qué se hizo en cada punto según commits, merges (PRs del repo padre) y estado actual de los submódulos.

**Última actualización:** junio 2026 (revisado contra código y docs de limitaciones)

> **Nota sobre DIDComm:** La implementación inicial quedó **rota e inconclusa** en wallet/SDK. En backend (Credo) DIDComm v1 funciona entre agentes servidor Quark, pero **no es interoperable** con `identity-core-dart` (envelope JWE v2 vs NaCl v1). No usar DIDComm para flujos productivos wallet↔Quark; usar OID4VCI/OID4VP.

---

## 1 — Investigación de compatibilidad con sistemas OpenID4VC (wallet / emisión / verificación)

- Análisis comparativo **DIDComm vs OpenID4VC** y métodos DID (`did:quark`, `did:key`, `did:web`, `did:jwk`) en `docs/soporte-eu-wallet/` — para entender qué protocolos usa el ecosistema europeo (EUDI) frente a los de Quark y decidir qué adaptar sin reescribir todo.
- Documentación de brechas de interoperabilidad con **EUDI Wallet** (16 docs): requisitos del holder, trusted list, attestation-based, soporte dual ES256/EdDSA, gaps de `identity-core` — mapa priorizado de lo que falta antes de que una wallet europea hable con Quark (y viceversa).
- **Resultado verificado:** emisión (`quark-issuer-service` → EUDI Wallet) y verificación (`quark-verifier-service` → EUDI Wallet) con OID4VCI/OID4VP y verifier en modo **x5c** (`docs/plan-verificacion-eudi-wallet.md`) — demuestra que la infra Quark opera con wallets reales del estándar europeo, no solo en flujos internos.
- Matriz de compatibilidad: EUDI Wallet → servicios Quark **OK**; `quark-wallet` → infra EUDI pública **E2E no verificado** (código auth code + TrustConfig ya implementados) — separa lo resuelto en servidor de lo pendiente en pruebas reales contra `issuer.eudiw.dev` / `verifier.eudiw.dev`.
- Implementación en código: **PR #10** `feat/openid4vc` y commit `51a5531` (x5c + verificación EUDI) — pasa el análisis teórico a código funcional en issuer, verifier e identity-core.
- Deuda técnica en `docs/deuda-tecnica/compatibilidad-quark-wallet-eudi-issuer-verifier.md` y `compatibilidad-verifier-con-eudi-wallet.md` — registra pendientes para no perder contexto entre sprints.

**Estado actual**
- **Qué hace:** Corpus documental EUDI/OpenID4VC; Quark→EUDI Wallet verificado en emisión y verificación servidor; wallet con auth code OID4VCI y TrustConfig OID4VP ya en código.
- **Falta:** E2E `quark-wallet` ↔ infra EUDI pública (no probado en campo); trusted list / LOTL dinámico; attestation-based (`attest_jwt_client_auth`); validación en producción documentada.

---

## 2 — Creación de repos y scaffold

- Commit inicial `6e2e5d3` — scaffold monorepo QuarkID 2.0 como punto de partida con estructura, compose y convenciones compartidas.
- Migración a **submódulos Bitbucket** (`5e351b4`) — cada servicio versiona y despliega independiente sin bloquear al resto.
- Infraestructura transversal: `docker-compose.yml`, `postgres-init`, colecciones **Postman** — levantar el stack local con un comando y probar flujos E2E.
- Documentación MVP en `docs/acercamiento-quark-demo-1/` y `AGENTS.md` — onboarding de devs y guía para agentes de IA.
- Skills de flujo de trabajo IA (action-plan, pr-description, code-cleanup, session-memory) — automatizar planes, PRs y continuidad entre sesiones.
- Submódulos incorporados progresivamente (identidad, wallet, explorer, operations) — ensamblar el ecosistema sin crear los 14 repos de una vez.
- Estandarización de 9 servicios NestJS: **PR #27** `refactor/standardize` — misma config, logging JSON y health en servicios de identidad y observer.
- Sync docs/Postman/compose con rutas `/v1`: **PR #29** — alinear documentación y pruebas con el versionado real de las APIs.
- Eliminación de `quark-web`: **PR #13** — cada issuer/verifier publica su propio `did.json`; ya no hace falta un servicio web central.

**Estado actual**
- **Qué hace:** Repo padre coordina 14 submódulos; `docker compose up` levanta stack local; Postman y docs alineados a `/v1`; issuer/holder/verifier/observer con logging JSON (PR #27).
- **Falta:** CI/CD productivo por repo; Helm/K8s; alta disponibilidad; Vault centralizado; logging JSON pendiente en gateway, auth, index, resolver y operations (`docs/deuda-tecnica/funcionalidades-pendientes.md`).

---

## 3 — quark-api-gateway

- Scaffold NestJS 10 + Express como **entrada única del SCI** (puerto 3000) — los clientes hablan solo con el gateway; los microservicios no se exponen a internet.
- Routing versionado bajo `/v1` hacia Auth, Index, Resolver y servicios de identidad — URL base estable y evolución de APIs sin romper clientes viejos.
- **Rate limiting** por API key/JWT — protege el SCI de abuso; devuelve 429 si una app supera su cuota.
- Propagación obligatoria de `x-correlation-id` — seguir una operación en los logs a través de gateway → auth → issuer → operations.
- Middleware de auth vía introspección delegada a `quark-auth` — el gateway pregunta a auth si el token es válido y qué scopes tiene antes de reenviar.
- Helmet, CORS centralizado, health endpoints — seguridad HTTP y probes de Kubernetes en un solo lugar.
- Refactor de estandarización: **PR #27** — mismo patrón operativo que el resto de servicios NestJS.
- Routing explícito de identidad bajo `/v1`: post-**PR #29** — enruta correctamente a issuer/verifier/holder/operations con el prefijo versionado.

**Estado actual**
- **Qué hace:** Proxy reverso único del SCI; valida auth vía introspección; rate limit y `x-correlation-id` downstream.
- **Falta:** Forwardear `tenantId`/`appId` como headers; cablear auditoría RabbitMQ (`MessagingModule` importado pero sin `AuditInterceptor`); métricas `prom-client`; Redis unificado; health duplicado; `JsonLoggerService` pendiente.

---

## 4 — quark-auth

- Scaffold NestJS con **Apps + API Keys + JWT** (puerto 3001) — registrar aplicaciones del ecosistema (wallet, backoffice, GCBA) y emitir credenciales de acceso.
- RBAC por **scopes** (`dids:create`, `dids:resolve`, emisión, verificación, etc.) — cada app solo hace lo que su rol permite; el gateway rechaza 403 si el JWT no trae el scope del endpoint.
- Persistencia en **Postgres** (apps, keys, audit) — guardar apps, API keys hasheadas y registro de acciones (crear key, revocar, login).
- **Redis** (cache de tokens/keys) — introspección rápida en el gateway sin ir a Postgres en cada request.
- Emisión y verificación de JWT con `exp`, `iss` y scopes — tokens con vida limitada y permisos embebidos para decisiones de autorización.
- Endpoint de introspección para el gateway — validar Bearer token y scopes antes de proxyar al servicio destino.
- Interceptors de messaging y auditoría (RabbitMQ) — publicar logins y cambios de keys al bus para operations y explorer.
- Estandarización config/logging/health: **PR #27** — logs JSON con `correlationId` y health check estándar.
- Actualización gateway/auth: **PR #18** — alinear contrato de scopes e introspección entre gateway y auth.

**Estado actual**
- **Qué hace:** Apps, API keys, JWT con scopes, introspección, cache Redis; publica eventos al bus RabbitMQ.
- **Falta:** Simplificar modelo (eliminar entidad `App` → `Tenant` directo); clarificar `dids:write` vs `dids:create`; seed como script independiente; colapsar `validate`/`introspect` en `TokensModule`; `JsonLoggerService` pendiente.

---

## 5 — quark-explorer

- UI **Next.js 15** (App Router + TypeScript + Tailwind), puerto 3011 — interfaz tipo "block explorer" para inspeccionar DIDs, eventos y credenciales.
- **Dashboard** (KPIs DIDs totales/activos) — vista ejecutiva del tamaño y salud del registro de identidades.
- **DID Browser** (listado paginado, filtros) — buscar DIDs por owner o estado sin curl/Postman.
- **DID Viewer** (JSON con highlighting) — ver el DID Document completo para soporte y debugging.
- **Event Log** (eventos del Observer, polling) — timeline de publicaciones, resoluciones y errores correlacionados por DID.
- **Credential Activity** (emisiones OID4VCI y verificaciones OID4VP) — auditar quién emitió, quién verificó y cuándo.
- Capa `src/services/` con stubs para BFF futuro (`NEXT_PUBLIC_USE_MOCKS`) — UI desacoplada; al existir el BFF solo se cambia la implementación.
- Agregado como submódulo: **PR #11**, **PR #12** — integrado al repo padre y compose local.

**Estado actual**
- **Qué hace:** Frontend Next.js con dashboard, browser/viewer de DIDs, event log y actividad de credenciales; capa services con mocks.
- **Falta:** BFF NestJS conectado a index/operations/observer; datos reales; Trust Registry; historial de versiones de DID Document.

---

## 6 — quark-index

- Índice de DIDs registrados (puerto 3003) — fuente de verdad local de qué DIDs existen en Quark y su documento, sin resolver por HTTP cada vez.
- Persistencia **Postgres** (tabla DID + JSONB) — almacenar el documento completo con consultas rápidas y metadata de publicación.
- Caché **Redis** (TTL + métricas hit/miss) — respuestas rápidas para DIDs frecuentes sin golpear Postgres en cada request.
- Consumer **RabbitMQ** — registrar en el bus cuando se indexa o actualiza un DID para trazabilidad.
- Health endpoints y estandarización NestJS — monitoreo operativo y consistencia con el SCI.
- Habilitado en `docker-compose.yml`: **PR #22** — parte del stack local junto con resolver y gateway.
- Colección Postman dedicada — probar CRUD de DIDs sin escribir requests a mano.

**Estado actual**
- **Qué hace:** Índice operativo Postgres + Redis; consumer RabbitMQ; integrado al compose y al flujo did:web.
- **Falta:** Tipar `DidDocument` (hoy `any`); `source` enum + `tenantId`/`appId`; reorganizar entidades; `JsonLoggerService` pendiente.

---

## 7 — quark-resolver

- Resolución universal de DIDs (puerto 3004) — dado un DID, devolver su DID Document para que wallets y servicios obtengan claves públicas.
- Estrategias: `did:web` (index + HTTP), `did:key`, `did:jwk` — web busca primero en index y luego HTTP; key/jwk se resuelven localmente.
- Negociación de `Accept`/`contentType`, errores estándar (`notFound`, `invalidDid`) — responder en el formato pedido con errores predecibles.
- Validación `didDocument.id == did` — rechazar documentos mal formados o suplantados.
- Integración RabbitMQ — auditar cada resolución (éxito/fallo) en el bus de eventos.
- Renombre web-node → `did:web` — alinear nomenclatura W3C tras eliminar quark-web.
- Agregado al ecosistema: **PR #8** `ft-resolver` + Postman — cierra el flujo MVP did:web (publicar → resolver → verificar).

**Estado actual**
- **Qué hace:** Resuelve `did:web`, `did:key` y `did:jwk`; flujo MVP did:web end-to-end operativo.
- **Falta:** Más métodos DID; `JsonLoggerService`; métricas Prometheus; `routes.config` vía `ConfigService`.

---

## 8 — quark-holder (quark-holder-service)

- Servicio NestJS holder para pruebas E2E (puerto 9005) — simular titular en servidor para Postman, integraciones sin móvil y tests automatizados.
- Integración `@quarkid/identity-core` (KMS internal + wallet Postgres) — reutilizar lógica SSI de issuer/verifier sin duplicar protocolos.
- Flujos **DIDComm** (conexiones, RFC 0036/0037) vía Credo v1 — recibir credenciales y proofs entre agentes servidor Quark (no interoperable con wallet móvil).
- Flujos **OID4VCI** (receive-offer) y **OID4VP** (present) vía HTTP — emisión y presentación con protocolo web estándar (compatible EUDI).
- Soporte `did:key` P-256: **PR #4** `QUARK-516-524-525-526-527` — claves P-256 para holder binding como exige EUDI.
- OpenID4VC end-to-end: **PR #7**, **PR #10** — completar circuito holder junto con issuer y verifier.
- **Multitenant**: wallets aisladas por tenant (**PR #17**) — varios holders en un proceso con datos separados (demo multi-tenant).
- Rutas `/v1`, estandarización y RabbitMQ — API consistente con el SCI y eventos auditables.
- Métricas Prometheus en `/metrics` — observabilidad de requests, latencia y errores.

**Estado actual**
- **Qué hace:** Holder de prueba servidor; OID4VCI/OID4VP operativos; DIDComm v1 Credo entre agentes backend; multitenant; logging JSON (PR #27).
- **Falta:** Servicio de test, no productivo; DIDComm no usable con `quark-wallet` (incompatibilidad de envelope); deps Mongoose muertas; `CommonController` a separar; KMS internal solo dev.

---

## 9 — quark-issuer (quark-issuer-service)

- Servicio NestJS emisor (puerto 9001) — firma y entrega VCs; rol central de emisión institucional GCBA.
- Emisión **DIDComm** (W3C JSON-LD VC) vía Credo v1 — oferta por conexión DIDComm entre agentes servidor (no wallet móvil).
- Emisión **OID4VCI** (SD-JWT VC) — QR/offer → token → SD-JWT; compatible con EUDI Wallet.
- `did:web` para el issuer — identidad institucional en `/.well-known/did.json` resoluble por cualquier wallet.
- Status list de revocación opcional — invalidar credenciales emitidas sin borrarlas del dispositivo del usuario.
- Compatibilidad emisores externos (Paradyn): `665a200` — validar recepción de credenciales de issuers no-Quark.
- Soporte EUDI: `dc+sd-jwt`, DPoP, `supportedAlgorithms` (**PR #7**) — que EUDI Wallet entienda formatos y haga binding criptográfico correcto.
- Endpoints OID4VC Credo (`/openid4vc-flow/*`, `/openid4vc-auth/*`) — protocolo estándar sin rutas propietarias.
- Multitenant, RabbitMQ, estandarización, rutas `/v1` — varios issuers en un proceso con auditoría de emisiones.
- Publicación `/.well-known/did.json` — wallets resuelven claves públicas del emisor desde su dominio.

**Estado actual**
- **Qué hace:** Emite OID4VCI (SD-JWT) y DIDComm v1 servidor; EUDI Wallet verificada; revocación vía status list; multitenant; logging JSON.
- **Falta:** KMS externo/Vault para prod; verificación cripto completa en status list JWT; CA real para x5c (hoy self-signed dev); `CommonController` a refactorizar.

---

## 10 — quark-verifier (quark-verifier-service)

- Servicio NestJS verificador (puerto 9002) — pide y valida que el holder demuestre credenciales (ej. mayor de edad).
- Verificación **DIDComm** (DIF PEX) vía Credo v1 — proof request entre agentes servidor (no wallet móvil).
- Verificación **OID4VP** (DCQL/PEX) — pedir presentación vía URL/QR HTTPS; la wallet responde con VP token.
- `did:web` para el verifier — identidad verificable del servicio que solicita la credencial.
- Modo **x5c** (`OID4VP_X5C_*`, `client_id` X509SanDns/X509Hash) — EUDI Wallet solo confía en verifiers con certificado X.509; sin x5c rechaza el request.
- Verificación Quark → EUDI Wallet documentada y funcional — demo real: EUDI Wallet escanea QR del verifier Quark y completa.
- Multitenant, RabbitMQ, estandarización, rutas `/v1` — varios verifiers, trazabilidad y API alineada al gateway.
- KMS domain-key scope compartido: **PR #25** `QUARK-867` — reutilizar certificados x5c entre tenants sin duplicar material criptográfico.

**Estado actual**
- **Qué hace:** OID4VP operativo con EUDI Wallet (x5c); DIDComm v1 entre agentes servidor; multitenant; domain-key compartida.
- **Falta:** Certificados de producción; DCQL auto-selección en holder backend (`identity-core` devuelve `null` con DCQL); trusted list EUDI; KMS seguro prod.

---

## 11 — quark-operations

- Hub de **trazabilidad y event bus** (puerto 3005) — punto central de auditoría de todo el ecosistema SSI.
- Consumer **RabbitMQ** — escuchar eventos del gateway, auth y demás sin que cada servicio escriba directo en la DB.
- Persistencia Postgres (`quarkid_operations`) — historial durable para consultas, dashboards y cumplimiento.
- Endpoints `/v1/events` (timeline) y `/v1/usage/dashboard` — API para explorer y operadores: qué pasó y uso por tenant.
- Submódulo independiente: **PR #21**, **PR #22** — ciclo de release propio desacoplado del repo padre.
- Integración traceability + event bus: `334ef8d` — cablear RabbitMQ en compose y emitir eventos reales.
- Estandarización NestJS — mismo estándar operativo que gateway, auth, index, etc.

**Estado actual**
- **Qué hace:** Consumer RabbitMQ activo; persiste timeline y métricas de uso; API de consulta operativa.
- **Falta:** Extraer consumer AMQP a módulo dedicado; `synchronize: false` en prod; `JsonLoggerService`; correlación `tenantId` completa (bloqueada por gateway); dashboard enriquecido.

---

## 12 — quark-wallet

- App móvil **Flutter** (Material 3 + Riverpod) — producto usuario final que recibe, guarda y presenta credenciales.
- Integración `identity_core_dart` (Dart puro, sin Credo nativo) — lógica SSI embebida sin Node ni bridges a Credo.
- **OID4VCI**: QR/deep link, pre-auth, auth code (`AuthCodeBrowserSlide` + WebView), credenciales diferidas — modos de emisión implementados en código.
- **OID4VP**: selective disclosure SD-JWT + `EudiTrustConfigLoader` — presentación y trust config para verifiers europeos cargada en `wallet_notifier`.
- **DIDComm**: UI de conexión OOB existe, pero el protocolo quedó **roto e inconcluso** — handshake unidireccional, sin intercambio real de credenciales/proofs con backend Quark.
- Desbloqueo **biometría + PIN** — proteger claves y credenciales; autenticación antes de firmar.
- Historial de actividad — emisiones y presentaciones pasadas visibles para el usuario.
- UI renovada: home, categorías, favoritas, búsqueda — UX usable para demo y piloto.
- Onboarding persistente y estilos display OID4VCI — guía al usuario nuevo; credenciales legibles por tipo.
- Repo padre: **PR #2**; actualización **PR #16** — wallet como componente de primera clase del ecosistema.

**Estado actual**
- **Qué hace:** Wallet Flutter con OID4VCI/OID4VP operativos contra infra Quark local; auth code y TrustConfig EUDI en código; biometría/PIN; UI de demo.
- **Falta:** E2E contra `issuer.eudiw.dev` / `verifier.eudiw.dev` (no verificado); **DIDComm a rehacer** (implementación inicial rota: envelope incompatible con Credo, handshake incompleto, UI muestra éxito sin protocolo terminado); backup/recovery; publicación en stores.

---

## 13 — Librería identity-core (@quarkid/identity-core)

- Wrapper TypeScript sobre **Credo-TS 0.7** (issuer, holder, verifier) — un paquete npm compartido; evita configurar Credo en cada servicio.
- Protocolos: **DIDComm v1** (Credo/NaCl, agente↔agente servidor), **OID4VCI**, **OID4VP**, **SD-JWT VC**, W3C JSON-LD — OID4VC es el camino productivo; DIDComm v1 solo entre backends Quark.
- DIDs: `did:web` (issuer/verifier), `did:key` (holder), `did:jwk` — identidad institucional en web; holders locales en dispositivo o servidor.
- KMS: `internal` (Postgres), `external` (HTTP); P-256 + Ed25519 — dev en Postgres; producción con custodio externo; algoritmos EUDI y Quark.
- **Multi-tenant** por `contextCorrelationId` — un proceso Node aloja N agentes sin mezclar claves ni credenciales.
- Records: credenciales, conexiones, metadata OID4VC, DID documents — estado del agente fuera del KMS.
- **Revocación** status list (`src/revocation/`: `RevocationService`, `StatusListService`) — módulo implementado; requiere `IStatusListRepository` en el consumidor.
- **EUDI**: inferencia algoritmo holder, x5c verifier, KMS domain-key — Ed25519 vs P-256 automático; verifier con certificado; claves de dominio compartidas.
- OpenID4VC completo: **PR #10** — módulos Credo de emisión y verificación web en los tres roles.
- Documentación en `packages/identity-core/docs/` — guía para integradores del paquete npm.

**Estado actual**
- **Qué hace:** Librería central backend; OID4VC + SD-JWT + multitenant + revocación; DIDComm v1 Credo entre agentes servidor; base de issuer/holder/verifier.
- **Falta:** KMS Vault no cableado (`mode: 'vault'` cae a internal); claves sin cifrar en reposo; `allowInsecureUrls` siempre activo; verificación cripto en status list JWT; DCQL auto-selección holder; deferred credentials sin procesar; DIDComm no interoperable con wallet Dart.

---

## 14 — Librería identity-core-dart

- SDK holder SSI **100% Dart** (sin Credo) — corre en Flutter sin Node; control total del stack móvil.
- **OID4VCI** (pre-auth, tx_code, auth code, deferred) — modos de emisión implementados (`prepareAuthCodeFlow`, `acquireCredentialsWithAuthCode`).
- **OID4VP** (PEX, DCQL, holder binding) — matching DCQL en `match_credentials.dart`; presentación con selective disclosure.
- **DIDComm** — implementación inicial **rota e inconclusa**: handshake unidireccional (`ConnectionState` nunca llega a `complete`), sin transporte inbound, envelope JWE v2 incompatible con Credo v1 NaCl del backend Quark.
- DIDs locales (`did:key`, `did:jwk`, `did:peer`) + resolución `did:web` — identidad en dispositivo; validar entidades externas.
- Isar con cifrado AES-256-GCM por campo (`enc:v1:`) + PIN Argon2id — **implementado** (`field_cipher.dart`, `pin_verifier.dart`, `wallet_secure_storage.dart`).
- KMS software (Ed25519, P-256, X25519) + interfaz hardware (Keystore/Secure Enclave) — firmar en dev; claves no exportables en dispositivo real (limitado).
- Framework de confianza (DID, X.509, EUDI Relying Party) — `TrustConfig` inyectable vía `WalletService`; verificación cripto X.509/JWT aún MVP.
- Documentación en `packages/identity-core-dart/docs/` — onboarding para devs Flutter.

**Estado actual**
- **Qué hace:** SDK holder con OID4VCI/VP/DCQL operativos; cifrado por campo y PIN implementados; trust framework DID/X.509/EUDI RP; base de `quark-wallet`.
- **Falta:** **Rehacer DIDComm** (protocolo roto, sin interop con backend Quark); verificación cripto cadenas X.509 y JWT EUDI RP; archivo Isar completo sin cifrar (metadatos en claro); migración registros legacy; mDoc; backup/recovery; `retryDeferred` retorna `null`; no en pub.dev.

---

## PRs clave del repo padre (referencia)

| PR | Tema |
|----|------|
| #1 | Logging test + informe QUARK-435 |
| #2 | Submódulo quark-wallet |
| #4 | QUARK-516-524-525-526-527 (did:web, P-256, did:key) |
| #6 | Rename OneDid → QuarkDid |
| #7–#10 | OpenID4VC end-to-end |
| #11–#12 | quark-explorer + identity-core-dart |
| #13 | Eliminar quark-web |
| #14 | Simplificar rutas didcomm / uso de agentes |
| #17 | Multitenant (docs + refs) |
| #18 | Actualización gateway + auth |
| #19 | RabbitMQ messaging |
| #21–#22 | quark-operations traceability |
| #25 | QUARK-867 (KMS domain-key) |
| #27 | Estandarización 9 servicios NestJS |
| #29 | Sync docs/Postman/compose `/v1` |

---

## Síntesis

| # | Componente | Estado |
|---|------------|--------|
| 1 | Investigación OpenID4VC/EUDI | Documentado; Quark↔EUDI Wallet OK en servidor; wallet E2E EUDI público sin verificar |
| 2 | Repos + scaffold | Operativo local; CI/CD prod y logging JSON en SCI pendientes |
| 3 | quark-api-gateway | Operativo; deuda técnica en headers tenant, audit y métricas |
| 4 | quark-auth | Operativo; refactor modelo Tenant y JsonLogger pendientes |
| 5 | quark-explorer | MVP frontend mocks; BFF y datos reales pendientes |
| 6 | quark-index | Operativo; tipado y trazabilidad mejorables |
| 7 | quark-resolver | Operativo did:web/key/jwk |
| 8 | quark-holder | Test server; OID4VC OK; DIDComm solo backend↔backend |
| 9 | quark-issuer | OID4VCI + EUDI OK; DIDComm solo backend; KMS prod pendiente |
| 10 | quark-verifier | OID4VP + EUDI x5c OK; DIDComm solo backend |
| 11 | quark-operations | Consumer RabbitMQ operativo; correlación tenant incompleta |
| 12 | quark-wallet | OID4VC OK con Quark; auth code + TrustConfig en código; **DIDComm roto**; E2E EUDI público sin verificar |
| 13 | identity-core | OID4VC maduro; DIDComm v1 Credo servidor; seguridad prod pendiente |
| 14 | identity-core-dart | OID4VCI/VP/DCQL + cifrado OK; **DIDComm roto/incompleto**; trust crypto MVP |
