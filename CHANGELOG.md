# Changelog

Feed único de cambios relevantes para **integradores** del monorepo (Kuatia / identity-*): API (`/v1`), documentación del sitio y producto (consola / planes).

Formato: más reciente arriba. Las fechas son aproximadas de publicación interna.

Sitio público: https://kuatia.xyz/docs/changelog

---

## 2026-08 — API v1 estable · docs · planes

### API

- Prefijo público **`/v1`** en issuer, verifier y billing (sin `/v2`).
- Endpoints documentados: health, DID, metadata, branding, offer, request/session, errores HTTP.
- Rate limit por IP en rutas públicas (health / discovery / OID4VC+DIDComm); cupos de plan siguen en traffic con API key.

### Documentación

- Sitio `/docs` (introducción, glosario, flujos, recomendaciones, referencia API).
- Política de [versionado](https://kuatia.xyz/docs/versionado) y este changelog.

### Producto

- Planes: Free · Pro · **Pro Double** (×2 Pro) · Business (a medida).
- Login consola: email/contraseña + **OAuth Google/GitHub** (si hay client id/secret en billing).
- Wallet Flutter: tema Kuatia (charcoal + teal), light/dark e ícono de marca.
- Tema claro/oscuro, SEO técnico (sitemap, robots, OG), config de sitio vía env.

---

## Convenciones

- **Added** — capacidad nueva compatible.
- **Changed** — comportamiento distinto pero en la misma versión mayor (no breaking de contrato).
- **Deprecated** — se anuncia retiro; sigue funcionando hasta la fecha indicada.
- **Removed / Breaking** — solo con nueva versión mayor de API (`/v2`, etc.).
