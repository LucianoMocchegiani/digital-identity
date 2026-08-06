# Revocación de Credenciales con Token Status List (TSL)

## Visión General

Implementación de revocación de credenciales SD-JWT VC basada en [IETF Token Status List (TSL)](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) usando la librería `@sd-jwt/jwt-status-list`.

**Granularidad**: Un StatusList por VCT (Verifiable Credential Type) por tenant (walletId).

## Conceptos

- **StatusList**: Bitstring comprimido que representa el estado de N credenciales
- **StatusListToken**: JWT que contiene y firma la StatusList
- **Índice**: Posición única dentro del StatusList para cada credencial emitida
- **Estado**: 0 = válido, 1 = revocado, 2 = suspendido (según bits configurados)

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                      packages/identity-core                      │
│  revocation/                                                     │
│  ├── revocation.service.ts     # create, allocate, revoke       │
│  ├── status-list.service.ts    # compress/decompress/sign       │
│  └── types/                    # StatusList, StatusType         │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                   ▼
┌────────────────────────┐         ┌────────────────────────┐
│  quark-issuer-service  │         │ quark-verifier-service │
│                        │         │                        │
│  POST /:walletId/      │         │  GET /revocation/status │
│    revocation/status-list│         │  POST /revocation/verify│
│                        │         │                        │
│  DB: quarkid_issuer    │         │  (cache planeado)      │
│  ┌─────────────────┐   │         │                        │
│  │ status_lists    │   │         │                        │
│  │ status_list_    │   │         │                        │
│  │  revocations    │   │         │                        │
│  └─────────────────┘   │         │                        │
└────────────────────────┘         └────────────────────────┘
            │                                   ▲
            │  publish (planeado)               │ fetch
            ▼                                   │
┌────────────────────────┐                     │
│      RabbitMQ         │─────────────────────┘
│  credential.revoked   │
└────────────────────────┘
```

> El diagrama muestra el estado objetivo. En el MVP actual (ver "Deuda técnica"): la tabla `status_list_cache` del verifier y la publicación a RabbitMQ **no están implementadas**.

## Estructura de datos

### Formato de la URI del StatusList

Conviven **dos definiciones** de URI en el código actual, lo cual es una inconsistencia a resolver:

- **`identity-core` / `RevocationService.buildStatusListUri`** (`packages/identity-core/src/revocation/revocation.service.ts:277`): produce `${cleanDid}/statuslist/${vct}` donde `cleanDid` es el `did:web` o `did:key` sin prefijo. Ejemplo: `issuer-1.example.com/statuslist/UniversityDegree`.
- **`quark-issuer-service` controller** (`quark-issuer-service/source/src/revocation/revocation.service.ts:15-16`): sobreescribe la URI con `${envConfig.didcommEndpoint}/v1/issuers/${walletId}/revocation/status-list/${vct}`. Ejemplo: `https://api.example.com/v1/issuers/issuer-1/revocation/status-list/UniversityDegree`. Esta URL **coincide exactamente** con el path del controller NestJS (`@Controller('issuers/:walletId/revocation')` + `setGlobalPrefix('v1')`).

**URI efectiva en runtime**: la del controller del issuer (segunda), porque es la que se retorna en las respuestas HTTP (`createStatusList`, `allocateIndex`, `getStatusListJwt`). La del core queda como valor de fallback interno.

Decisión pendiente: unificar a un solo formato. Recomendación: la del controller, porque coincide con el path real del endpoint `GET /:walletId/revocation/status-list/:vct` y permite que el Verifier (y el Holder) la resuelvan por HTTP sin ambigüedad.

### Tabla: status_lists (en quarkid_issuer)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID PK | Identificador único |
| wallet_id | VARCHAR(128) | Tenant (walletId) - parte del índice único |
| vct | VARCHAR(256) | Verifiable Credential Type - parte del índice único |
| bits | INT | Bits por entrada (1, 2, 4, 8) - default 1 |
| capacity | INT | Capacidad total - default 16384 |
| compressed_bitstring | TEXT | Base64url(DEFLATE+ZLIB) |
| next_index | INT | Próximo índice libre (contador atómico) |
| revoked_count | INT | Contador de revocaciones |
| last_updated_at | TIMESTAMPTZ | Última actualización |
| created_at | TIMESTAMPTZ | Fecha de creación |
| updated_at | TIMESTAMPTZ | Fecha de última modificación |

### Tabla: status_list_revocations (en quarkid_issuer)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID PK | Identificador único |
| status_list_id | UUID FK | Referencia a status_lists |
| index | INT | Índice revocado (único con status_list_id) |
| credential_id | VARCHAR(256) | ID opcional de la credencial |
| reason | VARCHAR(256) | Razón de revocación |
| revoked_by | VARCHAR(128) | Actor que revocó |
| revoked_at | TIMESTAMPTZ | Timestamp de revocación |

### Tabla: status_list_cache (en quarkid_verifier) — PLANEADA, NO IMPLEMENTADA

> **Estado actual**: el servicio `RevocationVerifierService` (`quark-verifier-service/source/src/revocation/revocation.service.ts`) hace `fetch(uri)` en cada request y retorna `cached: false` hardcodeado. No existe entity, repository ni migración para esta tabla. Ver "Deuda técnica" más abajo.

Esquema objetivo cuando se implemente:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| uri | VARCHAR(512) PK | URI única del StatusList |
| status_list_jwt | TEXT | JWT completo firmado |
| issuer_did | VARCHAR(512) | DID del issuer para validación |
| fetched_at | TIMESTAMPTZ | Cuando se fetcheó |
| expires_at | TIMESTAMPTZ | Cuándo expira (iat + ttl) |

## API REST

### Endpoints del Issuer

> Todas las rutas están bajo el prefijo global `v1` configurado en `main.ts` (`app.setGlobalPrefix('v1', { exclude: GLOBAL_PREFIX_EXCLUDE })`).

| Método | Path | Descripción |
|--------|------|-------------|
| POST | `/v1/issuers/:walletId/revocation/status-list` | Crear StatusList para un VCT |
| GET | `/v1/issuers/:walletId/revocation/status-list/:vct` | Obtener StatusList JWT firmado |
| POST | `/v1/issuers/:walletId/revocation/status-list/:vct/allocate` | Asignar índice libre |
| POST | `/v1/issuers/:walletId/revocation/status-list/:vct/revoke` | Revocar índice |
| GET | `/v1/issuers/:walletId/revocation/status-list/:vct/:idx` | Consultar estado de índice |

### Endpoints del Verifier

| Método | Path | Descripción |
|--------|------|-------------|
| GET | `/revocation/status?uri={uri}` | Fetch StatusList JWT (responde siempre `cached: false` en MVP — ver Deuda técnica) |
| GET | `/revocation/status-check?uri={uri}&idx={idx}` | Consultar estado de un índice vía query string (forma recomendada cuando la URI contiene `/`) |
| GET | `/revocation/status/:uri/:idx` | Consultar estado de un índice vía path params (legacy, conflictivo con URIs que contienen `/`) |
| POST | `/revocation/verify` | Verificar credencial SD-JWT VC completa |

Respuesta de `GET /revocation/status`:

```json
{
  "jwt": "eyJhbGci...",
  "cached": false,
  "expiresAt": "2026-06-10T13:00:00Z"
}
```

Respuesta de `GET /revocation/status-check` o `GET /revocation/status/:uri/:idx`:

```json
{
  "revoked": false,
  "status": 0,
  "updatedAt": "2026-06-10T12:00:00Z"
}
```

> Nota: la respuesta del Verifier incluye el campo booleano `revoked` (`true` si `status !== 0`). El endpoint equivalente del Issuer (`GET /:walletId/revocation/status-list/:vct/:idx`) sólo retorna `{ status, updatedAt }`.

## Flujo de operación

### 1. Crear StatusList

```
POST /issuer-1/revocation/status-list
Body: { "vct": "UniversityDegree" }

Response: {
  "listId": "uuid-xxx",
  "uri": "https://domain/issuer-1/statuslist/UniversityDegree"
}
```

### 2. Asignar índice al emitir credencial

```
POST /issuer-1/revocation/status-list/UniversityDegree/allocate
Body: { "credentialId": "cred-123" }

Response: {
  "index": 0,
  "uri": "https://domain/issuer-1/statuslist/UniversityDegree"
}
```

La credencial SD-JWT VC se emite con:

```json
{
  "vct": "UniversityDegree",
  "iss": "did:web:issuer-1.example.com",
  "status": {
    "status_list": {
      "idx": 0,
      "uri": "https://domain/issuer-1/statuslist/UniversityDegree"
    }
  },
  ...
}
```

### 3. Revocar credencial

```
POST /issuer-1/revocation/status-list/UniversityDegree/revoke
Body: { "index": 0, "reason": "Credencial vencida" }

Response: {
  "revokedAt": "2026-06-05T12:00:00Z"
}
```

### 4. Verificar credencial (Verifier)

```
POST /revocation/verify
Body: { "credentialJwt": "eyJhbGci..." }

Response: {
  "valid": true,
  "errors": []
}
```

O si está revocada:

```
Response: {
  "valid": false,
  "errors": [
    { "code": "STATUS_INVALID", "message": "Credential status is 1 (revoked/suspended)", "details": { "status": 1, "idx": 0 } }
  ]
}
```

## Eventos RabbitMQ

> **Estado actual (MVP)**: el `RevocationService` del core publica eventos si recibe un `MessagingService` por constructor, pero el `RevocationIssuerModule` lo instancia con `messaging = undefined` (`quark-issuer-service/source/src/revocation/revocation.module.ts:26`). **No se emite ningún evento en producción hoy**. Ver "Deuda técnica".

Contrato de eventos definidos en `identity-core` (`packages/identity-core/src/revocation/revocation.service.ts`):

| Routing Key | Cuándo se emite | Origen |
|-------------|-----------------|--------|
| `revocation.status-list.created` | Al crear una nueva StatusList | `RevocationService.createStatusList` |
| `revocation.status-list.allocated` | Al asignar un índice a una credencial | `RevocationService.allocateIndex` |
| `credential.revoked` | Al marcar un índice como revocado | `RevocationService.revoke` |

### Payload: credential.revoked

```json
{
  "walletId": "issuer-1",
  "vct": "UniversityDegree",
  "listId": "uuid-xxx",
  "index": 0,
  "credentialId": "cred-123",
  "reason": "Credencial vencida",
  "revokedBy": "admin-1",
  "timestamp": "2026-06-05T12:00:00Z"
}
```

> Los payloads de `revocation.status-list.created` y `revocation.status-list.allocated` siguen el mismo esquema: `walletId`, `vct`, `listId`, `timestamp` (+ `bits`, `capacity`, `uri` para el primero; `index`, `credentialId` para el segundo).

### Brecha de wiring detectada

Para que estos eventos se publiquen faltan dos cosas:

1. `RevocationIssuerModule` debe inyectar un `MessagingService` que implemente la interfaz `MessagingService` de `@quarkid/identity-core` (firma `publish(routingKey, payload): Promise<void>`).
2. El `MessagingService` actual del issuer (`quark-issuer-service/source/src/messaging/messaging.service.ts:20`) expone `publish(...): void` (no `Promise<void>`) y no está registrado bajo el token `MESSAGING_SERVICE` exportado por `identity-core`. Hay que adaptar la firma y registrar el provider con el token correcto.

## Decisiones técnicas

### Paquete elegido

Se usa `@sd-jwt/jwt-status-list@0.19.0` en lugar de su sucesor `@owf/token-status-list` porque:

- El original está más maduro (12K descargas/semana, 102 versiones)
- Solo necesitamos soporte JWT (no CWT/CBOR)
- API core idéntica al sucesor → migración futura trivial

### Firma de StatusList JWTs

Se firma con la misma clave del issuer que emite las credenciales (ES256).

### Persistencia

- **Issuer**: DB local `quarkid_issuer` (Postgres)
- **Verifier**: DB local `quarkid_verifier` (Postgres) para cache
- No se usa VDR service para StatusLists (está dedicado a resolución DIDs)

## Dependencias

```json
{
  "@sd-jwt/jwt-status-list": "^0.19.0",
  "@sd-jwt/core": "^0.19.0",
  "@sd-jwt/sd-jwt-vc": "^0.19.0"
}
```

## Estado de implementación

- [x] Fase 1: Core en identity-core (StatusListService, RevocationService)
- [x] Fase 2: Entities y endpoints en issuer
- [ ] Fase 3: Integración con emisión de credenciales (buildSdJwtCredentialMapper)
- [x] Fase 4: Endpoints en verifier (sin cache — ver Deuda técnica)
- [ ] Fase 5: Eventos RabbitMQ (wiring incompleto — ver Deuda técnica)
- [ ] Fase 6: Tests y documentación

## Deuda técnica

Consolidado de gaps entre el código y este documento. Tickets a abrir para cerrar cada uno:

1. **Cache del Verifier no implementado**
   - Falta: `StatusListCacheEntity`, `TypeormStatusListCacheRepository`, registro en `TypeOrmModule.forFeature` y `AppModule`, lógica de `get-or-set` con `expires_at` en `RevocationVerifierService.getStatusList`.
   - Impacto: cada verificación hace un `fetch` HTTP al issuer, sin TTL ni offline-cache.

2. **Eventos RabbitMQ no se emiten**
   - Falta: provider de `MessagingService` registrado bajo el token `MESSAGING_SERVICE` (exportado de `@quarkid/identity-core`), con firma `publish(routingKey, payload): Promise<void>`. El `MessagingService` actual del issuer tiene firma sync.
   - Impacto: el `observer` y otros consumidores no reciben `credential.revoked`, `revocation.status-list.created`, `revocation.status-list.allocated`.

3. **URI del StatusList duplicada**
   - `identity-core` define `${cleanDid}/statuslist/${vct}` y el controller del issuer sobreescribe a `${didcommEndpoint}/${walletId}/revocation/status-list/${vct}`. Decidir cuál es la canónica y deprecar la otra.

4. **Doc desactualizada en este commit**
   - Este archivo quedó sincronizado con el código al 2026-06-10. Mantener esta sección "Estado de implementación" viva ante cualquier cambio.

## Fecha de última actualización

2026-06-10