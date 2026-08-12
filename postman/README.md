# Colecciones Postman — servicios de identidad

Colecciones para billing / issuer / holder / verifier.

## Archivos

| Archivo | Uso |
|---------|-----|
| `Identity-Billing.postman_collection.json` | Auth JWT, productos (+keys), cupos, admin, validate-and-meter |
| `Identity-Issuer.postman_collection.json` | API issuer |
| `Identity-Holder.postman_collection.json` | API holder |
| `Identity-Verifier.postman_collection.json` | API verifier |
| `Kuatia-Demo-Club-Recital.postman_collection.json` | Demo Kuatia: Club Norte + Recital Live + Constructora Andes (metadata visual + QR) |
| `Kuatia-Local-Docker.postman_environment.json` | Kuatia local / tunnel: consola + billing/issuer/verifier; defaults Club Norte |
| `Kuatia-Prod.postman_environment.json` | Kuatia prod (`kuatia.xyz` / `billing` / `issuer` / `verifier`); keys vacías — completar a mano |
| `assets/demo-credentials/` | Logos/fondos de referencia para el demo |
| `scripts/generate-kuatia-club-recital-collection.mjs` | Regenerar demo Club + Recital + Andes |

## Uso rápido

1. Importar colecciones + environment en Postman.
2. Seleccionar **Kuatia Local Docker** o **Kuatia Prod**.
3. **Billing primero**: register/login → `POST /products` issuer → `POST /products` verifier (provision + activate automáticos; guarda keys en el environment). Issuer/verifier deben estar levantados.
4. **Issuer / Verifier collections**: ya mandan header `X-API-Key: {{issuerApiKey}}` / `{{verifierApiKey}}`. Completá esas vars en el environment activo (o copiá del log de Billing / consola Kuatia).
5. Holder **no** usa API key de billing (fuera del perímetro).
6. En offers/requests con QR: tras **Send**, abrir la pestaña **Visualize**.

### Environments Kuatia

Defaults útiles para Club Norte / membresía (alineados a la consola):

| Variable | Valor tipico |
|----------|----------------|
| `credentialConfigurationId` | `membership_card` |
| `vct` | `MembershipCredential` |
| `issuerDisplayName` | `Club Norte` |
| `credentialDisplayName` | `Membresía` |
| `issuerLogoUri` / `credentialLogoUri` | URLs de logo (local trae placeholders) |

Para que la wallet muestre nombre/logo (no “Credencial” / “Emisor desconocido”), tras provisionar el producto hay que publicar branding en el well-known (`PATCH /v1/issuers/{{issuerId}}/records/metadata` con `display` + `credentialConfigurationsSupported.{{credentialConfigurationId}}.display`). Usá las vars `issuerDisplayName`, `credentialDisplayName`, colores y logos del environment.

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

### Demo Club + Recital + Constructora Andes (Kuatia)

1. Environment **Kuatia Local Docker**.
2. Correr colección `Kuatia-Demo-Club-Recital`: `00` auth → `01` productos (plan **pro_double**, 6 keys) → `02` PATCH metadata + well-known → `03` Club / `04` Recital / `05` Andes (offer QR → wallet → request QR).
3. **Constructora Andes** emite `HeavyMachineryOperatorCredential` (habilitación interna; claim `validity_scope`). Display = marca + sede, no maquinaria.
4. Tras el PATCH, la wallet debe mostrar nombre/logo/fondo (no “Credencial” / “Emisor desconocido”).

Regenerar demo:

```bash
node postman/scripts/generate-kuatia-club-recital-collection.mjs
```
