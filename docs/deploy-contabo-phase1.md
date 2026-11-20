# Deploy Contabo — phase 1

Stack: **Postgres + billing + issuer + verifier + Kuatia web + wallet web** (no holder, no RabbitMQ). La wallet web es una SPA estática servida por Nginx; no agrega un backend ni depende de los otros servicios del compose.

## 1. VPS prep

- Ubuntu 22.04/24.04
- Docker + Docker Compose plugin
- Open only **80/443** (o Cloudflare Tunnel). No expongas los puertos internos de los servicios directamente al público.

## 2. Configure secrets and browser origins

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
| `JWT_SECRET` | billing `.env` |
| `ASKAR_STORE_KEY` | issuer + verifier (strong random) |
| `BASE_URL` | public HTTPS URL per service (issuer/verifier) |
| `API_KEY_AUTH_ENABLED=true` | issuer + verifier |
| `CORS_ORIGINS` | issuer and verifier `.env`: exact public wallet origin, e.g. `https://wallet.example.com` |

The wallet calls the public issuer and verifier endpoints directly from the browser. Replace the example `CORS_ORIGINS=http://localhost:5173` in **both** service env files with the wallet's HTTPS origin (no path or trailing slash); if multiple origins are needed, separate them with commas. Keep the web wallet hostname consistent with the URLs used by your QR/deep links.

## 3. Start

```bash
export POSTGRES_PASSWORD='...'
export BILLING_INTERNAL_TOKEN='...'
export ADMIN_API_KEY='...'
export JWT_SECRET='...'
export ASKAR_STORE_KEY='...'

docker compose up -d --build
```

Servicios locales (sin proxy):

| Servicio | URL |
|----------|-----|
| Kuatia (web) | http://localhost:3000 |
| Wallet web | http://localhost:3005 |
| Billing | http://localhost:9000 |
| Issuer | http://localhost:9001 |
| Verifier | http://localhost:9002 |

La wallet es solo de navegador; en producción debe servirse por HTTPS para habilitar las APIs criptográficas del navegador. Nginx devuelve `index.html` para rutas SPA, por lo que `/issue` y `/present` también funcionan al abrirlas directamente o recargar.

## 4. Publicar la wallet con TLS / Cloudflare Tunnel

Apuntá el dominio público elegido a `identity-wallet-web:80` si el proxy está en la red Docker, o al puerto publicado `http://127.0.0.1:3005` si el proxy/túnel corre directamente en la VPS. Por ejemplo, para `cloudflared` instalado como servicio en el host:

```yaml
ingress:
  - hostname: wallet.example.com
    service: http://127.0.0.1:3005
  - service: http_status:404
```

Usá el hostname real de tu wallet en el ingress y en `CORS_ORIGINS`. Si cambiás los `.env` del issuer/verifier después de haber iniciado Compose, recreá los tres contenedores para que tomen la configuración y reconstruí la SPA si cambió su código:

```bash
docker compose up -d --build identity-wallet-web identity-issuer-service identity-verifier-service
```

Ejemplo con Caddy / Nginx / Traefik:

| Host público | Upstream |
|--------------|----------|
| `kuatia.xyz` / `www` | `identity-kuatia:3000` |
| `wallet.example.com` | `identity-wallet-web:80` o `127.0.0.1:3005` |
| `api.kuatia.xyz` (opcional) | `identity-billing-service:9000` |
| `issuer.…` / `verifier.…` | issuer:9001 / verifier:9002 |

Solo 80/443 al mundo. Kuatia no necesita exponer billing al browser si usás el rewrite same-origin. Para el túnel en el host, no apuntes al puerto 80 de la VPS: `3005:80` en Compose significa puerto **3005 del host → puerto 80 del contenedor**.

## 5. Onboard a customer

**Alta de cuentas:** `POST /v1/auth/register` o UI Kuatia `/register`.  
**Productos:** `POST /v1/products` (o consola `/app/productos`) crea issuer|verifier + key, **provisiona el tenant** y **activa** el resource.

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

Planes pagados: `--plan pro` o `--plan business` (alias `--plan paid` → pro).

Store the printed API keys securely (shown once). Cupos: `maxProducts` (free=2) · `rateLimitRpm` · `monthlyTxQuota`.

## 6. Call issuer / verifier APIs

```http
X-API-Key: iss_live_xxx
POST /v1/issuers/acme/openid4vc/offer
```

```http
X-API-Key: ver_live_xxx
POST /v1/verifiers/acme/openid4vc/request
```

## 7. Plan changes

- Upgrade manual: `POST /v1/admin/accounts/:id/activate-paid` → plan `pro`
- Set plan: `POST /v1/admin/accounts/:id/plan` `{ "plan":"pro"|"business"|"free" }`
- Override cupos: `POST /v1/admin/accounts/:id/quota`
- Downgrade a free: archiva productos extras (deja 1 activo)
- Suspend: `POST /v1/admin/accounts/:id/status` `{ "status":"suspended" }`

## Public vs admin (issuer/verifier)

| Public (no API key) | Admin (API key per resource) |
|---------------------|------------------------------|
| `/health`, `/health/ready` | `POST /v1/issuers`, offers, records, revoke, … |
| `/:walletId/did.json` | `POST /v1/verifiers`, OID4VP request, domain-key, … |
| `/oob/:id` | |
| Status list GET | |

## Phase 2 (not in this drop)

- Mercado Pago / Stripe `PaymentProvider`
- Módulo Credenciales OpenID4VC en Kuatia (`/app/credenciales`)
- Edge rate limiting by plan
- Holder + RabbitMQ
