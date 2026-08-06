# Auth + API Gateway — MVP local

## Tenants precargados (seed)

| Slug | Tipo | clientId | clientSecret (dev) |
|------|------|----------|-------------------|
| `admin` | admin | `admin` | `admin-dev-secret` |
| `wallet_01` | wallet | `wallet_01` | `wallet_01-dev-secret` |
| `negocio_01` | business | `negocio_01` | `negocio_01-dev-secret` |

El seed corre al arrancar `quark-auth` si la tabla `tenants` está vacía (`AUTH_SEED_ENABLED=true`).

## Flujo de prueba (Postman)

Environment: **Quark Auth (Local Docker)** + colección **Quark Auth**.

1. `POST /v1/auth/token` — `clientId=admin`, `clientSecret=admin-dev-secret`
2. `POST /v1/auth/tenants` — Bearer admin, crear `wallet_02` (devuelve nuevo `clientSecret`)
3. `POST /v1/auth/token` — credenciales `wallet_01`
4. `POST /v1/auth/keys` — Bearer wallet → guardar `apiKey` en el environment
5. `POST /v1/auth/token` — body `{ "apiKey": "{{apiKey}}" }`
6. `POST /v1/auth/validate` — mismo JWT que usa el gateway

Gateway (colección **Quark API Gateway**):

1. `POST {{gatewayBaseUrl}}/v1/auth/token` — proxy a auth
2. Rutas protegidas con `Authorization: Bearer {{accessToken}}` — el guard llama a `POST /v1/auth/validate`

## Correlation ID

- Gateway: middleware genera/propaga `x-correlation-id` y `traceparent`.
- Auth: interceptor refleja `x-correlation-id` en la respuesta.
- Enviar el header en Postman (pre-request script de las colecciones).

## Reset DB (si migrás desde schema viejo)

```powershell
docker compose down
docker volume rm quark_postgres_data
docker compose up -d --build quark-auth quark-api-gateway postgres redis
```

## Rebuild servicios

```powershell
docker compose up -d --build quark-auth quark-api-gateway
```
