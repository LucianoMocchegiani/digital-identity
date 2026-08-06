# Refactor pendiente

## quark-api-gateway

- [ ] **Health duplicado** — `AppController` y `HealthController` ambos responden `GET /v1/health`. Eliminar el endpoint de `AppController` + borrar `AppService` (queda vacío).
- [ ] **`AllExceptionsFilter` código muerto** — existe en `common/filters/` pero no está registrado en ningún lado. Se usa `GlobalExceptionFilter`. Eliminar.
- [ ] **Eliminar spec files sin uso** — solo `quark-api-gateway` los tiene (6 archivos): `api-version.interceptor.spec.ts`, `correlation-id.middleware.spec.ts`, `api-version.config.spec.ts`, `circuit-breaker.spec.ts`, `metrics.spec.ts`, `routes.config.spec.ts`.
- [x] **Bug: `routes.config.ts` — `observer` y `operations` tenían el mismo puerto 3005.** Observer movido a 3006 en `docker-compose.yml` y `routes.config.ts`.
- [ ] **`routes.config.ts` usa `process.env` directo** en `resolveRoute()` → `ConfigService`.
- [ ] **Gateway no forwardea contexto de auth a servicios downstream** *(no prioritario — el `correlationId` permite cruzar eventos del gateway con los de servicios downstream en `quark-operations` para recuperar el `tenantId`)* — `AuthGuard` valida el JWT y pone `tenantId/appId/apiKeyId` en `request.user`, pero `GatewayService` no inyecta esos valores como headers al hacer proxy. Los servicios downstream publican eventos de auditoría sin `tenantId` ni `appId`. Solución: en `AuthGuard` (o `GatewayService`) agregar headers `X-Tenant-Id`, `X-App-Id`, `X-Api-Key-Id` al request forwardeado. Los `AuditInterceptor` de cada servicio los leen y los incluyen en el `AuditEventPayload`.
- [ ] **`MetricsRegistry` custom → `prom-client`** — `gateway/metrics.ts` es una implementación in-memory ad-hoc. Migrar a `prom-client` (Counter/Histogram/Gauge reales) y extraer a `src/metrics/metrics.module.ts` como en `quark-holder-service`. Agregar `collectDefaultMetrics()` para métricas de proceso Node.js. El gateway mantiene sus métricas específicas (circuit breaker, active connections, retries).
- [ ] **`MessagingModule` sin cablear** — está importado en `app.module.ts` pero `AuditInterceptor` no está registrado como `APP_INTERCEPTOR`. El gateway nunca publica auditoría. Decidir: wirearlo o eliminarlo.
- [ ] **Dos conexiones Redis independientes** — `HealthController` y `TenantRateLimitInterceptor` crean cada uno su propio `new Redis(url)`. Crear `src/redis/redis.module.ts` con `@Global()` + `useFactory(ConfigService)` igual al de `quark-index`, exponer token `REDIS_CLIENT`. Inyectar en ambas clases. No hace falta `RedisService` de dominio, solo el cliente compartido.
- [ ] **`console.log` / `console.warn`** en `gateway.service.ts` (líneas 56 y 185) → reemplazar con NestJS `Logger`.

## Logger estructurado JSON (todos los servicios)

- [ ] **Agregar `JsonLoggerService` + `LoggingInterceptor`** a los 6 servicios que les falta: `quark-api-gateway`, `quark-auth`, `quark-index`, `quark-observer`, `quark-operations`, `quark-resolver`.
  - Copiar `src/common/logger.ts` y `src/common/logging.interceptor.ts` desde `quark-issuer-service`.
  - Ajustar `service` hardcodeado por nombre del servicio en cada `logger.ts`.
  - Registrar en `main.ts`: `app.useLogger(new JsonLoggerService())` + `app.useGlobalInterceptors(new LoggingInterceptor())`.
- [ ] **`console.log` / `console.warn`** en `gateway.service.ts` (líneas 56 y 185) → NestJS `Logger`.
- [ ] **`new JsonLoggerService()` directo en servicios de dominio** — `openid4vc.service`, `credentials.service`, `metrics.service` (issuer/holder/verifier) instancian `JsonLoggerService` directamente. Reemplazar por `new Logger(ClassName.name)`: ya están cubiertas por `app.useLogger()` en `main.ts`.

## quark-index

- [ ] **Mejorar trazabilidad de DIDs en el index** — el campo `source` es un string libre. Mejorar con:
  - `source` → enum: `'issuer' | 'verifier' | 'holder' | 'wallet' | 'resolver'`
  - Agregar `tenantId?: string` — identifica a quién pertenece el DID (issuer, verifier, holder)
  - Agregar `appId?: string` — opcional, para mayor precisión si se mantiene la entidad App
  - **Caso especial resolver**: cuando `source = 'resolver'` no hay tenant asociado (resuelve DIDs de cualquier origen) — `tenantId` y `appId` quedan `null`. Manejar en `dids.service.ts` sin romper el upsert.
  - Actualizar `UpsertDidDto`, `DidIndexEntity`, `DidHistoryEntity`, `AuditEventPayload` del consumer.
- [ ] **Tipo `DidDocument` definido como `any`** — definir interfaz propia `DidDocumentJson` basada en el spec W3C (sin importar `@credo-ts/core` — es una clase con métodos que arrastra todo Credo). Candidato a vivir en `packages/@quarkid/types` cuando se cree. Por ahora definirla localmente en `src/dids/types/did-document.type.ts` y reutilizarla en los 5 archivos que hoy usan `any`. y repetido en 5 archivos** — `did-index.entity.ts`, `did-history.entity.ts`, `upsert-did.dto.ts`, `did-record.response.dto.ts`, `resolver-client.service.ts`. Extraer a `src/dids/types/did-document.type.ts` con la interfaz tipada y reutilizarla en todos.

## Estandarización entidades TypeORM (auth, operations, index)

- [ ] **`quark-auth` — eliminar `PersistenceModule` y `src/entities/` centralizado.** Mover cada entidad a `entities/` dentro de su módulo de dominio (`tenants/entities/`, `api-keys/entities/`, etc.). Cambiar `forRoot` a `autoLoadEntities: true`.
- [ ] **`quark-index` — mover entidades a subcarpeta `entities/`.** `did-index.entity.ts` y `did-history.entity.ts` están sueltas en `src/dids/` → mover a `src/dids/entities/`.
- [ ] **`quark-operations` — extraer consumer RabbitMQ de `EventsService`.** La conexión AMQP, channel y consume están embebidos en el mismo servicio que persiste en DB. Crear `src/messaging/messaging.consumer.ts` que maneje solo la conexión y delegue a `EventsService.handleAuditEvent()`. Igual al patrón de `quark-index` (`MessagingConsumer` + `MessagingModule`). También migrar `process.env.RABBITMQ_URL` → `ConfigService`.
- [ ] **`quark-operations` — cambiar `synchronize: true` en `forRoot`** a `synchronize: process.env.NODE_ENV !== 'production'` para evitar migraciones automáticas en prod. Agregar `autoLoadEntities: true`.

**Estándar:** entidad directo en `<modulo>/` si es una sola, subcarpeta `entities/` si hay 2+. `TypeOrmModule.forFeature([...])` en el módulo de dominio, `autoLoadEntities: true` en `app.module.ts`.

## quark-issuer-service / quark-holder-service / quark-verifier-service

- [ ] **`CommonController` mezcla concerns** — `GET /health` y `GET /:walletId/did.json` conviven en `common/common.controller.ts`. Separar: mover `health` a `app.controller.ts` (consistente con el resto del stack), mover `did.json` a un módulo de dominio (`dids/` o dentro del módulo principal del servicio). Eliminar `CommonController` si queda vacío.

## quark-auth

- [ ] **Clarificar diferencia entre `dids:write` y `dids:create`** en `tenants.service.ts` — `business` tiene `dids:write` pero no `dids:create`, `admin` tiene ambos. No está claro qué operación específica protege cada uno.
- [ ] **Eliminar entidad `App` — modelo simplificado** — un tenant es directamente el cliente que consume la API. `App` es una capa innecesaria. Mover `clientId`, `clientSecretHash`, `allowedScopes`, `isActive` a `Tenant`. Relacionar `ApiKey` directamente con `Tenant`. Eliminar `apps.module.ts`, `apps.controller.ts`, `apps.service.ts`, `app.entity.ts`. Actualizar `TokensService` y `ApiKeysService`.
- [ ] **`SeedModule` → script independiente** — el seed corre en `OnModuleInit` mezclado con el ciclo de vida del servicio. Convertir a script separado (`npm run seed`) ejecutable una sola vez, invocable desde el entrypoint Docker o pipeline de deploy. Eliminar `seed.module.ts` y `seed.service.ts` del árbol de módulos NestJS.
- [ ] **`validate` e `introspect` son módulos de un solo endpoint** — `ValidateController` y `IntrospectController` cada uno tiene un único endpoint y ambos usan `TokensService` directamente. Colapsar en `TokensController` / `TokensModule`. Eliminar `validate.module.ts`, `validate.controller.ts`, `introspect.module.ts`, `introspect.controller.ts`.

## quark-holder-service

- [ ] **Mongoose muerto** — `@nestjs/mongoose` y `mongoose` están en `package.json` pero no se usan en ningún lado del código. `MetricsService` los inyecta con `@Optional()` y el `dbState` siempre devuelve `-1`. Eliminar dependencias y sacar `@InjectConnection()` + métrica de DB de `MetricsService`.

## Health checks (todos los servicios)

- [ ] **Agregar `GET /health/ready` (readiness)** a todos los servicios que solo tienen liveness. El gateway ya lo tiene. Dependencias a verificar por servicio:
  - `quark-auth` — PostgreSQL + Redis
  - `quark-index` — PostgreSQL + Redis + RabbitMQ
  - `quark-operations` — PostgreSQL + RabbitMQ
  - `quark-resolver` — quark-index
  - `quark-issuer-service` / `quark-holder-service` / `quark-verifier-service` — PostgreSQL (KMS DB)
  - `quark-observer` — RabbitMQ + quark-index

## Análisis: librerías compartidas

- [ ] **Analizar extracción de código común a paquetes compartidos** — hay código duplicado en `src/common/` y `src/messaging/` en todos los servicios. Evaluar crear:
  - `@quarkid/common` — filtros de excepción, interceptores de correlación-id, guards genéricos, decoradores, logger JSON
  - `@quarkid/messaging` — `MessagingClient`, `AuditMessagingService`, `AuditInterceptor`, `messaging.constants.ts` (exchanges, routing keys, `AuditEventPayload`)
  - Como paquetes internos en `packages/` (igual que `identity-core`) o como npm privado
  - **Prerequisito:** terminar estandarización de estructura y config primero — no vale la pena extraer código inconsistente

## Estandarización config (todos los servicios)

- [ ] **Eliminar `config.module.ts`** en `quark-api-gateway`, `quark-auth`, `quark-operations`, `quark-resolver`, `quark-observer` — `AppConfigModule` es redundante si `app.module.ts` ya tiene `ConfigModule.forRoot({ isGlobal: true })`. Dejar solo `environment.config.ts` con la factory.
- [ ] **Migrar `env.config.ts` plain object → `ConfigService`** en `quark-issuer-service`, `quark-holder-service`, `quark-verifier-service` — actualmente leen `process.env` en un objeto exportado al importar el módulo. Convertir a factory function y registrar en `ConfigModule.forRoot`.
- [ ] **Nombre de archivo consistente** — algunos usan `env.config.ts`, otros `environment.config.ts`. Unificar en `environment.config.ts`.

## Estandarización mensajería (todos los servicios)

- [ ] **Directorio** — `quark-api-gateway` y `quark-auth` usan `src/common/messaging/`, el resto usa `src/messaging/`. Unificar en `src/messaging/`.
- [ ] **`process.env.RABBITMQ_URL`** → `ConfigService` en todos los servicios.
- [ ] **`AuditInterceptor` de `quark-auth`** está en `src/common/interceptors/` → mover a `src/messaging/`.
- [ ] **`||` vs `??`** para fallback de URL — `quark-api-gateway` y `quark-auth` usan `||`, el resto `??`. Unificar en `??`.

