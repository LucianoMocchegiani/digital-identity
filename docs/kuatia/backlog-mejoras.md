# Kuatia — backlog de mejoras (notas)

Dos listas, cada una ordenada **fácil → difícil**:

1. **Desarrollo** — código, producto, infra técnica  
2. **Tramiterío** — legal, cuentas empresa, ventas, outreach, higiene operativa  

Checkout hoy: `POST /me/checkout` es **manual** (`url: null`).  
Auth hoy: email + password. APIs bajo `/v1`.

---

# A. Desarrollo

## Orden por dificultad

| # | Ítem | Dificultad | Notas |
|---|------|------------|--------|
| D1 | Tema claro (light) | Baja | Tokens CSS + toggle |
| D2 | Revisar / mejorar textos (landing + docs) | Baja | Copy B2B; antes de i18n |
| D3 | SEO técnico | Baja–media | metadata, sitemap, robots, CWV |
| D4 | Calibrar planes + Pro Double | Baja–media | `plans.ts` + UI Pricing/Plan |
| D5 | Versionado API + docs | Baja–media | Política `/v1`, changelog, badge docs |
| D6 | Página docs “Seguridad y confianza” | Baja–media | High-level; refuerza imagen B2B |
| D7 | Rate limits endpoints públicos | Media | Spike wallets |
| D8 | Anti-abuso plan Free (eng) | Media | Email verify, caps, scoring |
| D9 | Login GitHub + Gmail | Media | OAuth → billing |
| D10 | Wallet: estilos Kuatia (`identity-wallet`) | Media | App lista; solo theme/UI |
| D11 | i18n (es / en / pt) | Media | Después de textos ES |
| D12 | Sección Credenciales (UI) | Media | QR / offer / request / poll |
| D13 | MCP docs / API | Media–alta | Tools seguros |
| D14 | Herramienta de cifrado | Media–alta | Spike → lib/API → UI |
| D15 | Pasarela de pagos (integración) | Alta | Stripe/MP + webhooks + portal |
| D16 | Auditorías | Alta | Rabbit → store → UI → docs |
| D17 | Business overrides (admin/código) | Alta | Cupos custom en billing |
| D18 | Seguridad: stress / romper la app | Alta / continua | k6, abuse, fail-closed |

**Primeros candidatos (dev):** D1 → D2 → D3 → D4 → D5/D6 → D7 → D8.

---

## Detalle — Desarrollo

### D1. Tema claro

- [x] Modo **light** (`data-theme` / CSS variables).
- [x] Persistencia + `prefers-color-scheme` (fallback sin preferencia guardada).
- [x] Toggle en header marketing + consola; Atmosphere y bordes vía tokens.
- [ ] Pulido fino de contraste en edge cases (PhoneFrame mock, estados danger).

### D2. Revisar / mejorar textos (landing + docs)

- [x] Copy landing + `/docs/*` (tono B2B, términos unificados).
- [x] Claro para no-SSI; glosario enlazado desde landing y docs.
- [x] Planes: “producto”, solicitudes/min y transacciones sin jerga rpm/tx.
- [ ] Revisión editorial fina si cambia el producto (planes, precios).

### D3. SEO técnico

- [x] Metadata por ruta, OG, canónicas (`metadataBase`, `NEXT_PUBLIC_SITE_URL`).
- [x] `sitemap.xml` + `robots.txt` (disallow `/app/*`, `/api/*`; login/register `noindex`).
- [x] OG image + favicon generados; JSON-LD Organization / WebSite.
- [x] CWV básicos: `next/font` + `display: swap`, `viewport` / theme-color.
- [x] `socialDescription` corta para OG (WhatsApp corta ~70–80 chars).
- [ ] Mejorar preview en plataformas (WhatsApp, Telegram, LinkedIn, X, iMessage): crop/safe-zone OG, títulos, scrapers/cache, asset estático si hace falta.
- [ ] hreflang cuando exista i18n.
- [ ] OG asset estático / brand art si se quiere más control que `ImageResponse`.

### D4. Planes: calibrar + Pro Double

**Catálogo:** Free 2 / 30 RPM / 5k TX · Pro 5 / 600 / 100k · **Pro Double** 10 / 1.2k / 200k · **Business a medida** (baseline interno 20 / 3k / 1M; UI = contactar ventas).

- [x] Escala Free → Pro → Pro Double (×2 Pro) → Business.
- [x] Billing: `pro_double` en `plans.ts` + DTO + onboard.
- [x] Pricing / `PlanPanel` / types Kuatia / README billing.
- [ ] Overrides custom → D17 + tramiterío T7.
- [ ] Recalibrar números si el uso real lo pide (cuentas existentes no se actualizan solas).

### D5. Versionado API + documentación

APIs ya en `/v1`. Docs del sitio con versión y changelog.

| Capa | Enfoque |
|------|---------|
| API | Prefijo `/v1`; política de breaking + deprecación |
| Docs | Badge “API v1”; páginas Versionado + Changelog |
| Changelog | Feed único: API + docs + producto (`CHANGELOG.md` en la raíz + `/docs/changelog`) |

- [x] Página política de versionado en `/docs/versionado`.
- [x] Changelog público (repo + sitio).
- [x] Badge API v1 en sidebar de docs.
- [x] No crear `/v2` vacío.

### D6. Docs: Seguridad y confianza

- [x] Sección pública `/docs/seguridad`: auth (API key), multi-tenant, rate limits, qué guardamos / no.
- [x] Citar Credo / OWF / OpenID4VC con precisión; sin fingir SOC2/eIDAS/ISO.
- [x] Enlazar desde intro, footer y autenticación.

### D7. Rate limits endpoints públicos

- [ ] Defaults en billing + issuer/verifier (health, well-known, did.json, Credo).
- [ ] Spike: no romper wallets.
- [ ] Documentar límites públicos vs por plan.

### D8. Anti-abuso Free (ingeniería)

| Medida | Notas |
|--------|--------|
| Email verificado antes de provisionar / meter | v1 |
| Rate limit + normalizar email en register | v1 |
| Caps lifetime free / trial único | v2 |
| Scoring IP/device (soft) | v2 |
| Free sandbox vs prod | opcional |
| Tarjeta $0 | solo si hace falta (alta fricción) |

- [ ] v1 email verify + rate register.
- [ ] v2 OAuth signal (D9) + scoring + métricas abuso.
- [ ] Reglas reflejadas en ToS (tramiterío T5).

### D9. Login GitHub + Gmail

- [ ] OAuth Google/GitHub; tabla identidades; link a cuenta existente.
- [ ] UI login/register; apps OAuth en cuenta org (tramiterío T1).
- [ ] Una cuenta free por `sub` OAuth.

### D10. Wallet: estilos Kuatia (`identity-wallet`)

App Flutter **ya funcional**. Solo alinear diseño a web (hoy brand púrpura en `AppColors`).

- [ ] Tokens charcoal + teal `#00a89d`; ThemeData; cards OID4VCI display.
- [ ] Light/dark alineado a web; splash/icono Kuatia.
- [ ] No rehacer protocolos.

### D11. i18n (es / en / pt)

- [ ] Default ES; EN y PT.
- [ ] Marketing, auth, consola, docs por fases.

### D12. Credenciales (UI consola)

- [ ] `/app/credenciales`: offer/request, QR, poll sesión.

### D13. MCP docs / API

- [ ] MCP lectura docs; tools API con auth segura.

### D14. Herramienta de cifrado

Alineado a docs → Recomendaciones (cifrar con clave pública del holder).

- [ ] Spike JWE/ECDH; spec; lib o API; UI consola; amenazas.
- [ ] Analizar: quién cifra, qué JWK/DID, offline vs online, responsabilidad.

### D15. Pasarela de pagos (integración)

- [ ] Stripe y/o Mercado Pago; checkout real; webhooks → plan; portal cliente; sandbox.
- [ ] Cuenta business del provider → tramiterío T1 / T6.

### D16. Auditorías

- [ ] Reusar Rabbit `quarkid.audit` → persistencia → UI por producto (API key + walletId) → docs/API.

### D17. Business overrides (código)

- [ ] Admin/API para cupos custom (piezas parciales ya existen).
- [ ] Negociación comercial → T7.

### D18. Seguridad — stress

- [ ] k6 load/burst; auth abuse; payloads; cuota 402/429; billing down → fail closed.
- [ ] Inventario `@Public()`; secretos fuera del repo; isolation tenant.

---

# B. Tramiterío

## Orden por dificultad

| # | Ítem | Dificultad | Notas |
|---|------|------------|--------|
| T1 | Cuentas corporativas / higiene accesos | Baja–media | Org ≠ personal; MFA; 2 owners |
| T2 | Dominio, mails y contacto prod | Baja–media | `@kuatia.xyz`; sacar placeholders footer |
| T3 | Imagen profesional (operativo) | Baja–media | Checklist confianza; tono ventas |
| T4 | SEO cuentas (Search Console, etc.) | Baja | Propiedades en cuenta empresa |
| T5 | Marketing B2B / outreach | Media | Radar de clientes; no es código |
| T6 | Legalidades del producto | Alta | Abogado; ToS; privacidad; impuestos |
| T7 | Business a medida (ventas/contrato) | Alta | Negociación + DPA |
| T8 | Cuentas stores (Apple / Google Play) | Media–alta | Cuando publiquen wallet |
| T9 | Entidad / KYC pasarela de pagos | Alta | Alta en Stripe/MP como business |

**Primeros candidatos (tramiterío):** T1 → T2 → T3 → T4 → T6 (antes de cobrar en serio).

---

## Detalle — Tramiterío

### T1. Cuentas corporativas / higiene

**Persona ≠ empresa.** No operar prod con cuentas personales.

| Qué | Cómo |
|-----|------|
| Email | `hola@`, `soporte@`, `noreply@`, `seguridad@` del dominio |
| GitHub | Organization; 2FA; ≥2 owners; repos bajo la org |
| Cloud / VPS | Facturación y root empresa; MFA; roles |
| DNS / dominio | Cuenta empresa; recuperación documentada |
| OAuth apps | Registradas a nombre de la org |
| Secrets | Password manager de equipo |
| Analytics | Propiedades en cuenta empresa |
| Offboarding | Revocar el mismo día |

- [ ] Inventario personal → migrar a org.
- [ ] MFA en todo lo crítico.
- [ ] Doc interna “quién es owner de qué” (sin secrets en el repo).

### T2. Dominio, mails y contacto en prod

- [ ] Mails reales en footer / docs / soporte.
- [ ] Sacar placeholders (`+595 21 000 000`, etc.) en producción.
- [ ] `noreply@` para transactional cuando haga falta.

### T3. Imagen profesional (operativo / GTM)

Señales que otras techs miran (además del código):

- Docs maduras, versionadas, sin vapor.
- Legal + contacto visibles.
- Límites de plan transparentes.
- No afirmar certificaciones que no existen.
- Tono partner técnico (preciso, honest about limits).

- [ ] Revisar claims de marketing vs capacidad real.
- [ ] Guía corta de tono para ventas/copy (junto a D2).

### T4. SEO — cuentas

- [ ] Google Search Console / Bing en cuenta empresa.
- [ ] Accesos con roles (no un solo Gmail personal).

### T5. Marketing B2B / outreach

Público: empresas, instituciones, orgs (documentos, eventos, membresías).

- [ ] One-pager + posicionamiento.
- [ ] Contenido / comunidades SSI–OWF; LinkedIn; partnerships.
- [ ] Outreach directo; sandbox free fácil; case studies.
- [ ] Alinear mensajes a T3 / D2.

### T6. Legalidades

Validar con abogado (PY + mercados destino):

- [ ] ToS + privacidad (aceptación en register).
- [ ] Roles encargado/responsable; datos en claims/logs.
- [ ] Facturación / impuestos / e-commerce.
- [ ] Cookies/analytics si aplica; DPA Business; SLA.
- [ ] Anti-abuso free reflejado en ToS.
- [ ] Footer con enlaces legales reales.

### T7. Business a medida (ventas)

- [ ] Proceso comercial por encima de Pro Double.
- [ ] Contrato + DPA; cupos negociados (activa D17).

### T8. Stores (wallet)

- [ ] Apple Developer / Google Play a nombre de la org cuando publiquen.

### T9. KYC / entidad pasarela

- [ ] Alta business en Stripe y/o Mercado Pago.
- [ ] Datos fiscales alineados a T6.
- [ ] Desbloquea D15 en producción real.

---

# Dependencias cruzadas

```text
D2 textos ──► D11 i18n
D5 versionado + D6 security page ──► T3 confianza
T1 cuentas org ──► D9 OAuth apps + D15/T9 pagos
T6 legal ──► T9 pagos + footer T2
D8 anti-abuso ──► T6 ToS
D4 planes ──► D15 checkout + T7 business
D10 wallet estilos ──► T8 stores (si publican)
D16 auditorías ──► narrativa enterprise (T3)
D7 rate limits ──► D18 stress
```
