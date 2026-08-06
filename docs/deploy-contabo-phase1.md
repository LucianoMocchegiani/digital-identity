# Deploy Contabo — phase 1

Stack: **Postgres + billing + issuer + verifier** (no holder, no RabbitMQ).

## 1. VPS prep

- Ubuntu 22.04/24.04
- Docker + Docker Compose plugin
- Open only 80/443 (or Cloudflare Tunnel). Prefer not exposing 9000/9001/9002 publicly without TLS/proxy.

## 2. Configure secrets

```bash
cp identity-billing-service/source/.env.example identity-billing-service/source/.env
cp identity-issuer-service/source/.env.example identity-issuer-service/source/.env
cp identity-verifier-service/source/.env.example identity-verifier-service/source/.env
```

Set at least:

| Variable | Where |
|----------|--------|
| `POSTGRES_PASSWORD` | host env / compose |
| `ADMIN_API_KEY` | billing `.env` |
| `BILLING_INTERNAL_TOKEN` | billing + issuer + verifier `.env` (same value) |
| `ASKAR_STORE_KEY` | issuer + verifier (strong random) |
| `BASE_URL` | public HTTPS URL per service |
| `API_KEY_AUTH_ENABLED=true` | issuer + verifier |

## 3. Start

```bash
# Opcional en Contabo: password fuerte (default local: identity)
export POSTGRES_PASSWORD='...'
export BILLING_INTERNAL_TOKEN='...'
export ADMIN_API_KEY='...'
export ASKAR_STORE_KEY='...'

docker compose up -d --build
```

## 4. Onboard a customer

**Alta de cuentas:** solo `POST /v1/auth/register` (sin productos).  
**Productos:** `POST /v1/products` crea issuer|verifier + key, **provisiona el tenant** y **activa** el resource (issuer/verifier deben estar arriba).

```bash
cd identity-billing-service/source
npm install
BILLING_URL=http://localhost:9000 \
ADMIN_API_KEY=... \
ISSUER_URL=http://localhost:9001 \
VERIFIER_URL=http://localhost:9002 \
npm run onboard -- --name "ACME" --email billing@acme.com --password secret123 \
  --plan free --issuer acme --verifier acme
```

Planes pagados (después del register): `--plan pro` o `--plan business` (alias `--plan paid` → pro).

Store the printed API keys securely (shown once). Cupos: `maxProducts` (free=2) · `rateLimitRpm` · `monthlyTxQuota`.

## 5. Call issuer / verifier APIs

```http
X-API-Key: iss_live_xxx
POST /v1/issuers/acme/openid4vc/offer
```

```http
X-API-Key: ver_live_xxx
POST /v1/verifiers/acme/openid4vc/request
```

## 6. Plan changes

- Upgrade manual: `POST /v1/admin/accounts/:id/activate-paid` → plan `pro`
- Set plan: `POST /v1/admin/accounts/:id/plan` `{ "plan":"pro"|"business"|"free" }`
- Override cupos: `POST /v1/admin/accounts/:id/quota`
- Downgrade a free: archiva productos extras (deja 1 activo)
- Suspend: `POST /v1/admin/accounts/:id/status` `{ "status":"suspended" }`

## Public vs admin

| Public (no API key) | Admin (API key per resource) |
|---------------------|------------------------------|
| `/health`, `/health/ready` | `POST /v1/issuers`, offers, records, revoke, … |
| `/:walletId/did.json` | `POST /v1/verifiers`, OID4VP request, domain-key, … |
| `/oob/:id` | |
| Status list GET | |

## Phase 2 (not in this drop)

- Mercado Pago / Stripe `PaymentProvider`
- Dashboard UI (products menu)
- Edge rate limiting by plan
- Holder + RabbitMQ
