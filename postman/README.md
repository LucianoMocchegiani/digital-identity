# Colecciones Postman — servicios de identidad

Colecciones para billing / issuer / holder / verifier.

## Archivos

| Archivo | Uso |
|---------|-----|
| `Identity-Billing.postman_collection.json` | Auth JWT, productos (+keys), cupos, admin, validate-and-meter |
| `Identity-Issuer.postman_collection.json` | API issuer |
| `Identity-Holder.postman_collection.json` | API holder |
| `Identity-Verifier.postman_collection.json` | API verifier |
| `Identity-Demo-Multi-tenant.postman_collection.json` | Demo multi-tenant (emisión/verificación + QR) |
| `Identity-Local-Docker.postman_environment.json` | `localhost:9000/9001/9002/9005` |
| `Identity-Tunnel-Dominios.postman_environment.json` | HTTPS vía tunnel |
| `assets/demo-credentials/` | Logos/fondos de referencia para el demo |
| `scripts/generate-multi-tenant-collection.mjs` | Regenerar la colección multi-tenant |

## Uso rápido

1. Importar colecciones + environment en Postman.
2. Seleccionar **Identity Local Docker**.
3. **Billing primero**: register/login → `POST /products` issuer → `POST /products` verifier (provision + activate automáticos; guarda keys en el environment). Issuer/verifier deben estar levantados.
4. **Issuer / Verifier collections**: ya mandan header `X-API-Key: {{issuerApiKey}}` / `{{verifierApiKey}}`. Completá esas vars en **Identity Local Docker** (o copiá del log de Billing).
5. Holder **no** usa API key de billing (fuera del perímetro).
6. En offers/requests con QR: tras **Send**, abrir la pestaña **Visualize**.

## URLs (Docker Compose)

| Servicio | URL |
|----------|-----|
| Billing | `http://localhost:9000` |
| Issuer | `http://localhost:9001` |
| Verifier | `http://localhost:9002` |
| Holder | `http://localhost:9005` (comentado en compose) |

| Header | Dónde | Valor |
|--------|-------|--------|
| `X-Admin-Key` | Billing admin | `ADMIN_API_KEY` (default `dev-admin-change-me`) |
| `Authorization: Bearer` | Billing `/me`, `/products` | JWT del register/login |
| `X-API-Key` | Issuer / Verifier APIs | `iss_live_…` / `ver_live_…` del producto |

Regenerar demo multi-tenant:

```bash
node postman/scripts/generate-multi-tenant-collection.mjs
```
