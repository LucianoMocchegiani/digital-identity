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

## Docker / Contabo

Incluido en el compose del monorepo:

```bash
# desde la raíz
docker compose up -d --build identity-kuatia
```

- Imagen: `identity-kuatia/source/Dockerfile` (`output: 'standalone'`)
- Puerto: `3000`
- `BILLING_URL` de build: `http://identity-billing-service:9000`

Detalle de proxy TLS: [`docs/deploy-contabo-phase1.md`](../docs/deploy-contabo-phase1.md).

## Arquitectura

```
source/src/
├── app/                 # Rutas Next (App Router) — finas, delegan a modules
├── design-system/       # Tokens + primitivos UI reutilizables (Button, Input…)
├── modules/             # Dominio por feature (marketing, auth, products…)
│   └── credentials/     # Stub fase 2: emitir/verificar OpenID4VC desde la web
└── shared/              # API client, sesión JWT, types, utils
```

- **design-system**: única fuente de look (paleta long-1 dark). Las features no inventan botones sueltos.
- **modules**: cada feature exporta UI + llamadas; se pueden sumar sin romper el shell.
- **credentials** (futuro): issuer/verifier desde la app; el nav del console ya reserva el hueco.

Docs internas del monorepo: [`docs/kuatia/`](../docs/kuatia/) (backlog, mockups).  
Docs para clientes: rutas `/docs` en la app.
