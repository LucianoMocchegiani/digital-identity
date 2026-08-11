# identity-kuatia

Web de **Kuatia** (`kuatia.xyz`): marketing + consola self-serve cableada a `identity-billing-service`.

## Arranque (dev)

```bash
cd identity-kuatia/source
cp .env.example .env.local
npm install
npm run dev
```

- Web: http://localhost:3000  
- Billing (API): http://localhost:9000 (vía rewrite `/api/billing/*` → `/v1/*`)
- Issuer / verifier: `:9001` / `:9002` (rewrites `/api/issuer/*` y `/api/verifier/*` para Credenciales)

## Docker / Contabo

Incluido en el compose del monorepo:

```bash
# desde la raíz
docker compose up -d --build identity-kuatia
```

- Imagen: `identity-kuatia/source/Dockerfile` (`output: 'standalone'`)
- Puerto: `3000`
- Build args: `BILLING_URL`, `ISSUER_URL`, `VERIFIER_URL` (hostnames Docker)

Detalle de proxy TLS: [`docs/deploy-contabo-phase1.md`](../docs/deploy-contabo-phase1.md).

## Arquitectura

```
source/src/
├── app/                 # Rutas Next (App Router) — finas, delegan a modules
├── design-system/       # Tokens + primitivos UI reutilizables (Button, Input…)
├── modules/             # Dominio por feature (marketing, auth, products…)
│   └── credentials/     # Emitir / verificar OpenID4VC (offer, request, QR, poll)
└── shared/              # API client, sesión JWT, types, utils
```

- **design-system**: única fuente de look (paleta long-1 dark). Las features no inventan botones sueltos.
- **modules**: cada feature exporta UI + llamadas; se pueden sumar sin romper el shell.
- **credentials**: consola `/app/credenciales` (API key en sessionStorage; proxy same-origin).

Docs internas del monorepo: [`docs/kuatia/`](../docs/kuatia/) (backlog, mockups).  
Docs para clientes: rutas `/docs` en la app.
