# identity-billing-service

Servicio NestJS de **billing, cuentas y API keys** del stack Identity.

Gestiona cuentas (self-serve + admin), productos (cada uno es **un** issuer **o** un verifier + API key), cupos (`maxProducts`, `rateLimitRpm`, `monthlyTxQuota`) y validación interna para los guards de issuer/verifier.

---

## Modelo

| Límite | Qué controla |
|--------|--------------|
| **maxProducts** | Cuántos productos activos (issuer o verifier) |
| **rateLimitRpm** | Techo de requests/minuto (cuenta) |
| **monthlyTxQuota** | Transacciones/mes (UTC) |

Flujo:
1. **Register** → solo cuenta free (sin issuer ni verifier).
2. **POST /products** → crea producto + API key, **provisiona el tenant** en issuer/verifier y **activa** el resource.

### Planes

| Plan | Productos | Rate limit | Cuota mensual |
|------|-----------|------------|---------------|
| `free` | 2 | 30 rpm | 5_000 |
| `pro` | 5 | 600 rpm | 100_000 |
| `business` | 20 | 3_000 rpm | 1_000_000 |

Alias legacy: `paid` → `pro`.

---

## Responsabilidades

- **Auth self-serve**: register (solo cuenta free) / login (JWT).
- **Cuenta**: perfil, usage, checkout, listado de planes.
- **Productos**: cada uno = issuer **o** verifier + key.
- **API keys**: rotar / revocar (secreto una sola vez).
- **Admin**: ops, cupos manuales, activate-paid.
- **Internal**: `validate-and-meter` (auth + rate limit + cuota).
- **Pagos**: `PaymentProvider` (hoy `manual`).

## Arquitectura

```mermaid
graph LR
    user["Usuario / dashboard<br/>JWT"] --> billing["identity-billing"]
    admin["Admin<br/>X-Admin-Key"] --> billing
    issuer["issuer"] -- "validate + meter<br/>X-Internal-Token" --> billing
    verifier["verifier"] -- "validate + meter<br/>X-Internal-Token" --> billing
    billing --- db[("Postgres<br/>identity_billing")]
```

```mermaid
graph TD
    account["Account<br/>plan · cupos · password"] --> product["Product<br/>status"]
    product --> resource["Resource<br/>issuer|verifier"]
    resource --> apikey["ApiKey"]
    account --> usage["UsagePeriod<br/>YYYY-MM · txCount"]
    account --> sub["Subscription"]
```

## Stack

- NestJS 10 + TypeScript
- TypeORM + Postgres
- `class-validator` / `class-transformer` en **todos** los bodies
- `@nestjs/jwt` para sesión de cuenta
- Sin Credo / Askar

## Estructura

```
source/src/
├── auth/                  # POST /v1/auth/register|login + JwtAuthGuard
│   └── dto/
├── me/                    # GET /v1/me, usage, plans · POST checkout
├── products/              # CRUD /v1/products (+ resources)
│   └── dto/
├── resources/             # rotate / revoke (JWT)
│   └── dto/
├── admin/                 # /v1/admin/* (X-Admin-Key)
│   └── dto/
├── internal/              # validate-and-meter
│   └── dto/
├── billing/               # BillingService · plans · api-key.util
├── entities/
├── payment/
├── webhooks/
├── common/                # password · wallet-id · PlanBodyDto · warnings
├── scripts/onboard-account.ts
├── config/
├── health.controller.ts
├── app.module.ts
└── main.ts
```


## Variables de entorno

| Variable | Default | Descripción |
|---|---|---|
| `PORT` | `9000` | Puerto HTTP |
| `DATABASE_URL` | `postgresql://identity:identity@localhost:5432/identity_billing` | Postgres |
| `ADMIN_API_KEY` | `dev-admin-change-me` | `/v1/admin/*` |
| `BILLING_INTERNAL_TOKEN` | `dev-internal-change-me` | issuer/verifier → billing |
| `JWT_SECRET` | `dev-jwt-change-me` | Firma de access tokens |
| `JWT_EXPIRES_IN` | `7d` | Expiración JWT |
| `PAYMENT_PROVIDER` | `manual` | `manual` \| `mercadopago` \| `stripe` |
| `ISSUER_URL` | `http://localhost:9001` | Para provision al crear producto issuer |
| `VERIFIER_URL` | `http://localhost:9002` | Para provision al crear producto verifier |
| `PROVISION_ON_CREATE` | `true` | Si `false`, no llama a issuer/verifier |

## Endpoints

### Público

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/health` | Health |
| `POST` | `/v1/auth/register` | Alta cuenta free (sin productos) |
| `POST` | `/v1/auth/login` | Login → `accessToken` |
| `POST` | `/v1/webhooks/payments/:provider` | Webhook de pago |

### Cuenta (`Authorization: Bearer <jwt>`)

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/v1/me` | Perfil + cupos |
| `GET` | `/v1/me/usage` | Uso del período |
| `GET` | `/v1/me/plans` | Planes disponibles |
| `POST` | `/v1/me/checkout` | Checkout (`plan`: free\|pro\|business) |
| `GET` | `/v1/products` | Listar productos |
| `POST` | `/v1/products` | Crear issuer\|verifier + key + provision tenant + activate |
| `GET` | `/v1/products/:id` | Detalle |
| `PATCH` | `/v1/products/:id` | Renombrar |
| `DELETE` | `/v1/products/:id` | Archivar (no el último) |
| `GET` | `/v1/products/:id/resources` | Resources del producto |
| `POST` | `/v1/resources/:id/keys/rotate` | Rotar key |
| `POST` | `/v1/api-keys/:id/revoke` | Revocar key |

### Internal (`X-Internal-Token`)

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/v1/internal/validate-and-meter` | Auth + 1 tx (429 rate / 402 cuota) |

Issuer y verifier lo llaman desde el `ApiKeyAuthGuard` (1 round-trip por request autenticado).

### Admin (`X-Admin-Key`)

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/v1/admin/accounts` | Listar |
| `GET` | `/v1/admin/accounts/:id` | Detalle + usage |
| `POST` | `/v1/admin/accounts/:id/plan` | Set plan |
| `POST` | `/v1/admin/accounts/:id/status` | Set status |
| `POST` | `/v1/admin/accounts/:id/quota` | Override cupos |
| `POST` | `/v1/admin/accounts/:id/activate-paid` | Activa `pro` (manual) |
| `POST` | `/v1/admin/accounts/:id/checkout` | Checkout |
| `POST` | `/v1/admin/accounts/:id/products` | Crear producto (issuer\|verifier) + provision + activate |
| `GET` | `/v1/admin/accounts/:id/menu` | Productos |
| `POST` | `/v1/admin/resources/:id/keys/rotate` | Rotar |
| `POST` | `/v1/admin/api-keys/:id/revoke` | Revocar |

## Arranque

```bash
cp source/.env.example source/.env
docker compose up -d --build

# O solo billing
cd source
npm install
npm run start:dev
```

## Onboard (CLI)

Alta siempre vía `/auth/register` (con password). Admin para upgrade de plan / cupos.

```bash
cd source
npm run onboard -- --name "ACME" --email billing@acme.com --password secret123 \
  --product "ACME App" --issuer acme --verifier acme
```

Equivalente HTTP: `POST /v1/auth/register`.

## Postman

Importar `postman/Identity-Billing.postman_collection.json`.

Deploy Contabo: ver [`docs/deploy-contabo-phase1.md`](../docs/deploy-contabo-phase1.md).
