# QuarkID 2.0 

**Propósito, responsabilidades, entradas/salidas, dependencias y ejemplos de endpoints**

> Documento orientado al MVP (DID:web). En futuras fases se activan módulos de credenciales, vault y operaciones avanzadas.

---

## 0) Visión rápida del flujo DID:web (MVP)

**Wallet → Gateway → Auth → (Web / Index / Resolver) → Explorer**

1. La **Wallet** solicita token a **Auth** y luego publica un DID en **Web**.
2. **Index** persiste DID + metadata; **Web** sirve `/.well-known/did.json`.
3. Al **resolver** un DID: **Resolver** usa **Cache/Index → Web**, valida y responde.
4. Todo se traza con **`correlationId`** y es consultable en **Explorer**.

---

## 1) Capa Gateway & Seguridad

### 1.1 Quark-API (Gateway)
**Para qué sirve**  
Puerta de entrada única del SCI. Gestiona rutas **versionadas** (`/v1`), **rate limit**, validación de **auth** (junto con Auth) y **propagación de `correlationId`**. Aísla a los microservicios internos del acceso directo.

**Responsabilidades**
- Enrutamiento a servicios internos (Auth, Web, Index, Resolver, Explorer).
- Validar y **propagar** headers transversales (p. ej., `x-correlation-id`).
- Aplicar **rate limiting** por API key/JWT.
- CORS y versionado.

**Entradas / Salidas**
- **IN**: Requests HTTP de Wallet/apps (API Key o JWT).
- **OUT**: Forward interno + headers de control; respuesta normalizada al cliente.

**Endpoints (ejemplos a través del Gateway)**
```http
GET  /v1/health
POST /v1/auth/token
POST /v1/dids/web/publish
GET  /v1/dids/resolve/{did}
GET  /v1/explorer/events?correlationId=...
```

**Errores típicos**: `401/403` (auth/scopes), `429` (rate limit), `5xx` (downstream).

**Dependencias**: Quark-Auth; canalización de logs/eventos hacia Explorer.

---

### 1.2 Quark-Auth
**Para qué sirve**  
Administra **Apps**, **API Keys**, **emite/verifica JWT** y **RBAC por scopes** (p. ej., `dids:create`, `dids:resolve`, `web:publish`). Persiste en **Postgres** y cachea en **Redis**.

**Responsabilidades**
- Crear/rotar/revocar **API Keys**.
- **Login/app auth** → **JWT** con `exp`, `iss`, `aud`, `scopes`.
- Validación de tokens y **enforcement** de scopes.
- **Cache** de firmas/tokens (Redis) para performance.

**Entradas / Salidas**
- **IN**: Credenciales de apps/API Keys.
- **OUT**: JWT firmados; veredictos 200/401/403 para Gateway.

**Endpoints**
```http
POST   /v1/auth/token            // emitir JWT
POST   /v1/auth/keys             // crear API Key
DELETE /v1/auth/keys/{id}        // revocar API Key
GET    /v1/auth/introspect       // validar token/scopes (interno)
```

**Errores típicos**: `401` credenciales inválidas; `403` scopes insuficientes.

**Dependencias**: Postgres (apps/keys/tokens revocados), Redis (caché).

---

### 1.3 Quark-Vault *(futuro cercano)*
**Para qué sirve**  
Custodia **claves criptográficas** (DIDs, VCs, firmas). Centraliza políticas y operaciones de firma.

**Responsabilidades**
- Generación/rotación segura de claves.
- Firmado/verificación como servicio (HSM/softHSM).
- Políticas de acceso por servicio/scope.

**Entradas / Salidas**: solicitudes de firma/generación → firmas/material criptográfico.

**Dependencias**: Integración futura con Emitter/Verifier y Web/Resolver.

---

## 2) Capa de Identidad (DID Domain)

### 2.1 Quark-Web
**Para qué sirve**  
Publica y **sirve** el **DID Document** en **`/.well-known/did.json`** (y paths compatibles) para `did:web`. Gestiona **creación/actualización** y **versionado simple**.

**Responsabilidades**
- **Publicar** documento DID (desde Wallet vía Gateway/Auth).
- Servir el documento con **TLS** y headers correctos.
- Mantener **versionado** lógico (`versionId`, `updatedAt`).
- Checklist de seguridad: **TLS/DNS/CORS**.

**Entradas / Salidas**
- **IN**: `POST /publish` con DID Document válido (JSON/JSON-LD).
- **OUT**: `200/201` con metadata (ubicación del recurso). `GET /.well-known/did.json` devuelve documento.

**Endpoints**
```http
POST /v1/dids/web/publish
PUT  /v1/dids/web/update
GET  /.well-known/did.json
```

**Errores típicos**: `400` documento inválido o `didDocument.id` ≠ `did`; `409` conflicto de versión; `5xx` almacenamiento/hosting.

**Dependencias**: Index (persistencia), Auth (scopes `web:publish`), infra de hosting.

---

### 2.2 Quark-Index
**Para qué sirve**  
Base interna de DIDs publicados + **metadata** (estado, versión, timestamps, owner). Optimiza **lookup** y **caché**.

**Responsabilidades**
- Persistir **DID**, **DID Document** y **estado** (p. ej., `published`).
- Exponer **búsqueda/lookup** de alta velocidad.
- Integrar **Redis** para **caché** de resoluciones.

**Entradas / Salidas**
- **IN**: eventos/requests desde **Web** (publish/update).
- **OUT**: `getByDid(did)` + metadata para **Resolver**.

**Endpoints (internos)**
```http
POST /v1/index/dids            // persistir/actualizar
GET  /v1/index/dids/{did}      // lookup por DID
GET  /v1/index/dids?owner=...  // filtros básicos
```

**Errores típicos**: `404` DID no registrado; `409` duplicados; posibles **drifts** con Web (reconciliar en fases futuras).

**Dependencias**: Postgres (JSONB para documento/metadata), Redis (cache TTL + métricas).

---

### 2.3 Quark-DIDs-Resolver (Resolver)
**Para qué sirve**  
**Resuelve** un DID (`did:web:...`) y devuelve el **DID Document**. Implementa el pipeline **Cache → Index → Web → Persist/Cache → Responder**.

**Responsabilidades**
- Parsear/validar formato de `did:web`.
- Negociar **`Accept` / `content-type`** (JSON/JSON-LD).
- Validar `didDocument.id === did`.
- Gestionar **errores estándar** (`invalidDid`, `notFound`, `notAcceptable`).

**Entradas / Salidas**
- **IN**: `GET /resolve/:did` vía Gateway.
- **OUT**: DID Document + **metadata** (content-type, timestamps).

**Endpoint**
```http
GET /v1/dids/resolve/{did}
```

**Errores típicos**: `400` `invalidDid`; `404` `notFound`; `406` `notAcceptable`.

**Dependencias**: Index (lookup), Web (fuente si miss), Redis (caché), Auth (scope `dids:resolve`).

---

### 2.4 Quark-Recovery *(no MVP)*
**Para qué sirve**  
Permite **recuperar** la identidad si se pierde la clave del DID (rotación, guardianes, políticas).

**Responsabilidades**: verificación reforzada; coordinación con Vault; actualización de claves/documento.

**Dependencias**: Vault, Index, Web.

---

## 3) Capa de Credenciales *(post-MVP, para contexto)*

### 3.1 Quark-VCs-Emitter (Issuer)
**Para qué sirve**  
**Emite** (crea y **firma**) **Verifiable Credentials** (W3C).

**Responsabilidades**: construir payload, seleccionar key (Vault), firmar, registrar eventos.

**Errores**: `400` schema inválido; `409` duplicidad; `5xx` firma/Vault.

---

### 3.2 Quark-VCs-Verifier
**Para qué sirve**  
**Verifica** integridad, firma y vigencia de una VC.

**Responsabilidades**: obtener **public keys** (Resolver → DID Document), validar firma, chequear **estado** en Credential-Status.

---

### 3.3 Quark-VCs-Manager
**Para qué sirve**  
Orquesta el **ciclo de vida**: emisión, actualización, revocación, expiración, notificaciones.

**Responsabilidades**: reglas de negocio, auditoría, políticas de expiración, integración con Explorer.

---

### 3.4 Quark-Credential-Status
**Para qué sirve**  
Publica y mantiene el **estado** (activo/revocado) de cada VC.

**Responsabilidades**: endpoints de **status list** o por-ID; consistencia con Manager/Emitter.

---

## 4) Capa de Operaciones

### 4.1 Quark-Operations (Bus de eventos)
**Para qué sirve**  
Centraliza **eventos** del SCI (`did.published`, `did.resolved`, `auth.login`, `error.*`). Alimenta **Explorer** y automatizaciones.

**Responsabilidades**: esquema de eventos, entrega a storage, reintentos, backpressure.

**Entradas / Salidas**: IN desde Gateway/Auth/Web/Resolver/Index → OUT hacia storage/Explorer.

---

### 4.2 Quark-Batcher
**Para qué sirve**  
Agrupa operaciones para **blockchain/IPFS** eficientemente.

**Responsabilidades**: batching, ventanas, reintentos, `batchId`.

---

### 4.3 Quark-Observer
**Para qué sirve**  
Observa blockchain/IPFS y **sincroniza** estado local (Index/Status).

**Responsabilidades**: detectar cambios, reconciliar, emitir eventos de “drift”.

---

### 4.4 Quark-Block
**Para qué sirve**  
**Escribe** en blockchain.

**Responsabilidades**: formateo de transacciones, firma (Vault), confirmaciones.

---

### 4.5 Quark-IPFS
**Para qué sirve**  
Publica/busca contenidos en **IPFS** (documentos grandes, evidencia).

**Responsabilidades**: pinning, gateways, tracking de hashes.

---

## 5) Capa de Observabilidad

### 5.1 Quark-Explorer 2.0
**Para qué sirve**  
Provee **auditoría y trazabilidad** completa. Búsqueda por **`correlationId`** y **timeline** entre servicios (Gateway → Auth → Resolver → Web) con **latencias** y **status**.

**Responsabilidades**
- Modelo de eventos/logs (JSON) con `service`, `endpoint`, `status`, `latency`, `correlationId`.
- Ingesta (push/pull), persistencia y consultas rápidas (≈30 días).
- UI de timeline y filtros.

**Endpoints**
```http
GET /v1/explorer/events?correlationId=abc-123
GET /v1/explorer/timeline?correlationId=abc-123
```

---

## 6) Capa de Cliente

### 6.1 Quark SDK 2.0
**Para qué sirve**  
Librerías para que apps GCBA consuman el SCI **sin implementar SSI**. Incluye **HTTP client**, **auth wrapper** y utilidades para DID/web.

**Responsabilidades**
- Manejar **tokens** (obtener/renovar).
- Exponer métodos: `publishDidWeb()`, `resolveDid()`, etc.
- Estandarizar **errores** y **reintentos**.

**Uso típico (pseudocódigo)**
```js
const sdk = new QuarkSDK({ baseUrl, apiKey });
await sdk.auth.login(); // obtiene JWT
const did = await sdk.didweb.publish(doc);
const resolved = await sdk.dids.resolve(did);
```

---

### 6.2 Wallet Quark 2.0
**Para qué sirve**  
App de usuario para **crear/publicar/resolver** un **DID:web** y visualizar el **DID Document**. Futuro: gestionar **VCs**.

**Flujos clave (MVP)**
1) **Login** (Auth → JWT).  
2) **Crear** DID Document.  
3) **Publicar** (Web) y ver estado.  
4) **Resolver** y **mostrar** documento.

---

## 7) Contratos transversales y buenas prácticas
- **CorrelationId** obligatorio y propagado (Gateway → todos).  
- **Logging estructurado** (JSON): `service`, `endpoint`, `status`, `latency`, `correlationId`.  
- **Seguridad**: RBAC por **scopes mínimos** (`dids:create`, `dids:resolve`, `web:publish`), **no** loguear tokens/JWT, **TLS/CORS** correctos en Web.  
- **Errores estándar**: `invalidDid`, `notFound`, `conflict`, `notAcceptable`, `unauthorized`, `forbidden`.  
- **Versionado**: APIs bajo `/v1`; DID Document con versión lógica.

---

## 8) Secuencia E2E (DID:web)
```text
[Wallet] --(POST /v1/auth/token)--> [Gateway] --(Auth)--> [Auth] --(200 JWT)--> [Wallet]

[Wallet] --(POST /v1/dids/web/publish + JWT + correlationId)--> [Gateway]
[Gateway] --(forward)--> [Web]
[Web] --(persist metadata)--> [Index]
[Web] --(200 + location + version)--> [Gateway] --(→ Wallet)
(Explorer registra: auth.login, web.publish, index.persist)

[Wallet] --(GET /v1/dids/resolve/{did})--> [Gateway] --> [Resolver]
[Resolver] --(cache/index lookup)--> [Index] (hit? si no, va a Web)
[Resolver] --(GET /.well-known/did.json)--> [Web] (si miss)
[Resolver] --(validate id)--> ok --(200 DID Doc)--> [Gateway] --(→ Wallet)
(Explorer registra: resolver.lookup, web.fetch, resolver.validate, resolver.success)
```

---

## 9) Checklist mínimo por servicio (MVP)
- **Gateway**: `/v1`, rate limit, auth middleware, `correlationId`.
- **Auth**: Apps/API Keys, JWT, scopes mínimos, Redis cache.
- **Web**: publish/update, `/.well-known/did.json`, versionado, TLS/CORS.
- **Index**: tabla DID + JSONB + estado, lookup < X ms, cache Redis.
- **Resolver**: `GET /resolve/:did`, negociación `Accept`, validar `didDocument.id`.
- **Explorer**: ingesta + query por `correlationId`, timeline básico.
- **SDK**: cliente HTTP + auth wrapper, helpers de DID/web.
- **Wallet**: login, publicar/resolver DID, UI de estado/errores.

---

*QuarkID 2.0 — Servicios del SCI (MVP DID:web)*
*Marzo 2026*
