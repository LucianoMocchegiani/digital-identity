# Refactor pendiente

## quark-api-gateway

- **Health duplicado**  `AppController` y `HealthController` ambos responden `GET /v1/health`. Eliminar el endpoint de `AppController` + borrar `AppService` (queda vaci­o).
- **`AllExceptionsFilter` codigo muerto**  existe en `common/filters/` pero no esta registrado en ningun lado. Se usa `GlobalExceptionFilter`. Eliminar.
- **Eliminar spec files sin uso**  solo `quark-api-gateway` los tiene (6 archivos): `api-version.interceptor.spec.ts`, `correlation-id.middleware.spec.ts`, `api-version.config.spec.ts`, `circuit-breaker.spec.ts`, `metrics.spec.ts`, `routes.config.spec.ts`.
- **Bug: `routes.config.ts`  `observer` y `operations` teng­an el mismo puerto 3005.** Observer movido a 3006 en `docker-compose.yml` y `routes.config.ts`.
- **`routes.config.ts` usa `process.env` directo** en `resolveRoute()`  `ConfigService`.
- **`MetricsRegistry` custom  `prom-client`**  `gateway/metrics.ts` es una implementacion in-memory ad-hoc. Migrar a `prom-client` (Counter/Histogram/Gauge reales) y extraer a `src/metrics/metrics.module.ts` como en `quark-holder-service`. Agregar `collectDefaultMetrics()` para metricas de proceso Node.js. El gateway mantiene sus metricas especi­ficas (circuit breaker, active connections, retries).
- **`MessagingModule` sin cablear**  esta importado en `app.module.ts` pero `AuditInterceptor` no esta registrado como `APP_INTERCEPTOR`. El gateway nunca publica auditori­a. Decidir: wirearlo o eliminarlo.
- **Dos conexiones Redis independientes**  `HealthController` y `TenantRateLimitInterceptor` crean cada uno su propio `new Redis(url)`. Crear `src/redis/redis.module.ts` con `@Global()` + `useFactory(ConfigService)` igual al de `quark-index`, exponer token `REDIS_CLIENT`. Inyectar en ambas clases. No hace falta `RedisService` de dominio, solo el cliente compartido.
- **`console.log` / `console.warn`** en `gateway.service.ts` (li­neas 56 y 185)  reemplazar con NestJS `Logger`.

## Logger estructurado JSON (todos los servicios)

- **Agregar `JsonLoggerService` + `LoggingInterceptor`** a los 6 servicios que les falta: `quark-api-gateway`, `quark-auth`, `quark-index`, `quark-observer`, `quark-operations`, `quark-resolver`.
  - Copiar `src/common/logger.ts` y `src/common/logging.interceptor.ts` desde `quark-issuer-service`.
  - Ajustar `service` hardcodeado por nombre del servicio en cada `logger.ts`.
  - Registrar en `main.ts`: `app.useLogger(new JsonLoggerService())` + `app.useGlobalInterceptors(new LoggingInterceptor())`.
- **`console.log` / `console.warn`** en `gateway.service.ts` (li­neas 56 y 185)  NestJS `Logger`.
- **`new JsonLoggerService()` directo en servicios de dominio**  `openid4vc.service`, `credentials.service`, `metrics.service` (issuer/holder/verifier) instancian `JsonLoggerService` directamente. Reemplazar por `new Logger(ClassName.name)`: ya estan cubiertas por `app.useLogger()` en `main.ts`.

## quark-index
- **Tipo `DidDocument` definido como `any`**  definir interfaz propia `DidDocumentJson` basada en el spec W3C (sin importar `@credo-ts/core`  es una clase con metodos que arrastra todo Credo). Candidato a vivir en `packages/@quarkid/types` cuando se cree. Por ahora definirla localmente en `src/dids/types/did-document.type.ts` y reutilizarla en los 5 archivos que hoy usan `any`. y repetido en 5 archivos**  `did-index.entity.ts`, `did-history.entity.ts`, `upsert-did.dto.ts`, `did-record.response.dto.ts`, `resolver-client.service.ts`. Extraer a `src/dids/types/did-document.type.ts` con la interfaz tipada y reutilizarla en todos.

## Estandarizacion entidades TypeORM (auth, operations, index)

- **`quark-auth` eliminar `PersistenceModule` y `src/entities/` centralizado.** Mover cada entidad a `entities/` dentro de su modulo de dominio (`tenants/entities/`, `api-keys/entities/`, etc.). Cambiar `forRoot` a `autoLoadEntities: true`.
- **`quark-index` mover entidades a subcarpeta `entities/`.** `did-index.entity.ts` y `did-history.entity.ts` estan sueltas en `src/dids/`  mover a `src/dids/entities/`.
- **`quark-operations` extraer consumer RabbitMQ de `EventsService`.** La conexion AMQP, channel y consume estan embebidos en el mismo servicio que persiste en DB. Crear `src/messaging/messaging.consumer.ts` que maneje solo la conexion y delegue a `EventsService.handleAuditEvent()`. Igual al patron de `quark-index` (`MessagingConsumer` + `MessagingModule`). Tambien migrar `process.env.RABBITMQ_URL`  `ConfigService`.
- **`quark-operations` cambiar `synchronize: true` en `forRoot`** a `synchronize: process.env.NODE_ENV !== 'production'` para evitar migraciones automaticas en prod. Agregar `autoLoadEntities: true`.

**Estandar:** entidad directo en `<modulo>/` si es una sola, subcarpeta `entities/` si hay 2+. `TypeOrmModule.forFeature([...])` en el modulo de dominio, `autoLoadEntities: true` en `app.module.ts`.

## quark-issuer-service / quark-holder-service / quark-verifier-service

- **`CommonController` mezcla concerns**  `GET /health` y `GET /:walletId/did.json` conviven en `common/common.controller.ts`. Separar: mover `health` a `app.controller.ts` (consistente con el resto del stack), mover `did.json` a un modulo de dominio (`dids/` o dentro del modulo principal del servicio). Eliminar `CommonController` si queda vaci­o.

## quark-auth

- **`validate` e `introspect` son modulos de un solo endpoint**  `ValidateController` y `IntrospectController` cada uno tiene un unico endpoint y ambos usan `TokensService` directamente. Colapsar en `TokensController` / `TokensModule`. Eliminar `validate.module.ts`, `validate.controller.ts`, `introspect.module.ts`, `introspect.controller.ts`.

## quark-holder-service

- **Mongoose muerto**  `@nestjs/mongoose` y `mongoose` estan en `package.json` pero no se usan en ningun lado del codigo. `MetricsService` los inyecta con `@Optional()` y el `dbState` siempre devuelve `-1`. Eliminar dependencias y sacar `@InjectConnection()` + metrica de DB de `MetricsService`.

## Health checks (todos los servicios)

- **Agregar `GET /health/ready` (readiness)** a todos los servicios que solo tienen liveness. El gateway ya lo tiene. Dependencias a verificar por servicio:
  - `quark-auth`  PostgreSQL + Redis
  - `quark-index`  PostgreSQL + Redis + RabbitMQ
  - `quark-operations`  PostgreSQL + RabbitMQ
  - `quark-resolver`  quark-index
  - `quark-issuer-service` / `quark-holder-service` / `quark-verifier-service`  PostgreSQL (KMS DB)
  - `quark-observer`  RabbitMQ + quark-index

## Analisis: libreri­as compartidas

- **Analizar extraccion de codigo comun a paquetes compartidos**  hay codigo duplicado en `src/common/` y `src/messaging/` en todos los servicios. Evaluar crear:
  - `@quarkid/common`  filtros de excepcion, interceptores de correlacion-id, guards genericos, decoradores, logger JSON
  - `@quarkid/messaging`  `MessagingClient`, `AuditMessagingService`, `AuditInterceptor`, `messaging.constants.ts` (exchanges, routing keys, `AuditEventPayload`)
  - Como paquetes internos en `packages/` (igual que `identity-core`) o como npm privado
  - **Prerequisito:** terminar estandarizacion de estructura y config primero  no vale la pena extraer codigo inconsistente

## Estandarizacion config (todos los servicios)

- **Eliminar `config.module.ts`** en `quark-api-gateway`, `quark-auth`, `quark-operations`, `quark-resolver`, `quark-observer`  `AppConfigModule` es redundante si `app.module.ts` ya tiene `ConfigModule.forRoot({ isGlobal: true })`. Dejar solo `environment.config.ts` con la factory.
- **Migrar `env.config.ts` plain object `ConfigService`** en `quark-issuer-service`, `quark-holder-service`, `quark-verifier-service`  actualmente leen `process.env` en un objeto exportado al importar el modulo. Convertir a factory function y registrar en `ConfigModule.forRoot`.
- **Nombre de archivo consistente** ” algunos usan `env.config.ts`, otros `environment.config.ts`. Unificar en `environment.config.ts`.

## Estandarizacion mensajeri­a (todos los servicios)

- **Directorio** ” `quark-api-gateway` y `quark-auth` usan `src/common/messaging/`, el resto usa `src/messaging/`. Unificar en `src/messaging/`.
- **`process.env.RABBITMQ_URL`**  `ConfigService` en todos los servicios.
- **`AuditInterceptor` de `quark-auth`** esta en `src/common/interceptors/`  mover a `src/messaging/`.
