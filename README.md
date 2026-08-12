# Identity monorepo (snapshot)

Copia limpia (sin historial Git de los repos originales) de librerías, servicios de identidad, wallet y material de soporte.

## Contenido

| Ruta | Descripción |
|------|-------------|
| `packages/identity-core` | SDK SSI TypeScript (Credo-TS) |
| `packages/identity-core-dart` | SDK SSI Dart/Flutter |
| `identity-billing-service` | Cuentas, productos, API keys, planes (Free/Pro/Business) — `:9000` |
| `identity-kuatia` | Web Kuatia (landing + consola) — `:3000` → billing |
| `identity-issuer-service` | Emisión (OID4VCI, DIDComm) — `:9001` |
| `identity-verifier-service` | Verificación (OID4VP, DIDComm) — `:9002` |
| `identity-holder-service` | Custodia (lab; fuera del compose) |
| `identity-wallet` | App Flutter |
| `docs/` | Documentación del ecosistema |
| `docs/deploy-contabo-phase1.md` | Deploy Contabo + onboarding |
| `postman/` | Colecciones de identidad |
| `docker-compose.yml` | Stack: postgres + billing + issuer + verifier + kuatia |
| `scripts/postgres-init.sh` | Crea las DBs del compose al primer arranque |

## Arranque

```bash
cp identity-billing-service/source/.env.example identity-billing-service/source/.env
cp identity-issuer-service/source/.env.example identity-issuer-service/source/.env
cp identity-verifier-service/source/.env.example identity-verifier-service/source/.env

docker compose up -d --build
```

- Kuatia (web): http://localhost:3000  
- Billing: http://localhost:9000  
- Issuer: http://localhost:9001  
- Verifier: http://localhost:9002  
- Postgres: `localhost:5432` (`identity` / `identity` por defecto)

Auth por API key **habilitada** (`API_KEY_AUTH_ENABLED=true`). Onboard:

```bash
cd identity-billing-service/source && npm install
npm run onboard -- --name "Demo" --email demo@example.com --password secret123 --issuer demo --verifier demo
```

Deploy Contabo: [`docs/deploy-contabo-phase1.md`](docs/deploy-contabo-phase1.md).

Postman: importar `postman/` y el environment `Kuatia-Local-Docker` (o `Kuatia-Prod`).
