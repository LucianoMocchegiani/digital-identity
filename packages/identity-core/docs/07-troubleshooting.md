---
id: troubleshooting
title: Troubleshooting
sidebar_position: 7
---

# Troubleshooting

Esta guía recopila los problemas operativos más comunes al integrar `@quarkid/identity-core` (TypeScript sobre Credo-TS 0.7), con el formato **Síntoma → Causa → Solución**. Cada causa y solución se verificó contra el código fuente del paquete.

La mayoría de estos problemas derivan de [limitaciones conocidas](./08-limitations.md); cuando aplica, se enlaza la limitación correspondiente para el detalle de evidencia (`archivo:línea`).

---

## 1. TLS / `fetch` falla en Docker (URLs `https` que no resuelven)

- **Síntoma:** Errores de conexión o de TLS al resolver un `did:web` o durante peticiones OID4VC entre servicios dentro de Docker (p. ej. `fetch failed`, `ECONNREFUSED`, errores de certificado / handshake TLS). Las URLs que la capa `@openid4vc` construye internamente son `https://`, pero los servicios internos solo escuchan en HTTP plano.
- **Causa:** Los endpoints OID4VC y los documentos `did:web` se direccionan con `https://`, pero en una red Docker interna los servicios suelen no terminar TLS (lo hace un reverse proxy / ingress por fuera). El `fetch` por defecto (de `@credo-ts/node`) intenta el `https://` literal y falla.
- **Solución:** Combinar tres mecanismos:
  1. Pasar un **`fetchOverride`** en las options del agente (es una opción base de `CreateAgentOptions`, disponible en las seis funciones de creación: `createIssuerAgent` / `createHolderAgent` / `createVerifierAgent` y sus variantes `createRoot*Agent`) que reescriba `https://` → `http://` para los hosts internos antes de realizar la petición. El override reemplaza `agentDependencies.fetch` y afecta a todas las peticiones del agente, incluida la verificación de tokens en el issuer.
  2. Configurar **`useHttpForWebDid: true`** en la config del agente, para que la resolución de `did:web` use HTTP en lugar de HTTPS en entornos sin TLS.
  3. Tener presente que **`allowInsecureUrls` ya está habilitado de forma incondicional** por el core (en las funciones de creación de agente y en el `InitConfig` de Credo), por lo que no hay que activarlo manualmente — pero tampoco se puede desactivar (ver [limitación 2](./08-limitations.md)).

  Ejemplo del `fetchOverride`:

  ```ts
  const reescribirHttp: typeof fetch = (input, init) => {
    // Reescribe https→http solo para hosts internos de Docker
    const url = typeof input === 'string' ? input : input.toString()
    const interno = url.replace('https://issuer.interno', 'http://issuer.interno')
    return fetch(interno, init)
  }

  const agent = await createHolderAgent(config, { fetchOverride: reescribirHttp })
  ```

  Verificado en `src/agent/create-agent-options.types.ts:37` (`fetchOverride?: typeof fetch`), `src/agent/holder.agent.ts:112-113` (aplicación del override sobre `agentDependencies.fetch`) y `src/types/config.types.ts:28` (`useHttpForWebDid?`).

> Detalle de la activación y wiring del agente en [Bootstrap del agente](./03-agent-bootstrap.md).

---

## 2. `RecordStorageBootstrapError` al arrancar el agente

- **Síntoma:** El bootstrap lanza `RecordStorageBootstrapError` (`RECORD_STORAGE_INJECTION_REQUIRED`).
- **Causa:** `createRoot*Agent` se invocó sin `recordStorage` en las opciones.
- **Solución:** Crear un adapter que implemente `RecordStorage` (p. ej. `PostgresRecordStorage` con un `Pool` de `pg`) e inyectarlo: `createRootIssuerAgent(config, { recordStorage, expressApp, ... })`. En servicios Quark, usar `RecordStorageModule` de Nest.

## 3. `RecordStorageCapabilityError` al listar records

- **Síntoma:** `listTenantRecords` lanza `RecordStorageCapabilityError`.
- **Causa:** El objeto registrado como `StorageService` no implementa `getAllPaginated` / `findByQueryPaginated`.
- **Solución:** Usar `PostgresRecordStorage` o un adapter propio que cumpla el port `RecordStorage`.

## 4. Cómo activar Askar

- **Síntoma:** Querés KMS + records cifrados en Askar.
- **Solución (librería):** inyectar `AskarKeyManagementService`, `AskarRecordStorage`, `askarStore` y, si usás BBS, `BbsKeyManagementService(pool)` en `additionalKeyManagementServices`.
- **Producto Quark:** los tres servicios ya fijan esa composición; bastan `ASKAR_STORE_KEY` y `DATABASE_URL`.

## 4b. Integrador sin Askar (Postgres full)

- **Solución:** inyectar `PostgresKeyManagementService(pool, scope)` como primario y `PostgresRecordStorage`. Las claves Ed25519/P-256 quedan en tabla `keys` en texto plano.

> Ver [Referencia · KMS](./06-reference/02-kms.md) y [limitación 1](./08-limitations.md).

---

## 5. Tenant no encontrado / operaciones fuera de contexto

- **Síntoma:** Errores al operar sobre un tenant (tenant inexistente, operaciones que no encuentran wallet, o resultados que no corresponden al tenant esperado).
- **Causa:** Se invoca `withTenant` sin haber creado/cargado antes el tenant (faltó `ensureTenant` o `loadTenantMap`), o se usa un `tenantId` equivocado.
- **Solución:**
  1. Crear el tenant primero con `ensureTenant(rootAgent, walletId, ...)` (o cargar el mapa de tenants con `loadTenantMap`).
  2. Usar el **`tenantId` devuelto** por la creación — no asumir un id.
  3. Ejecutar todas las operaciones del tenant **dentro de `withTenant`**, pasando ese mismo `tenantId`.

  > Nota: el parámetro `walletKey` de `ensureTenant` no protege nada (ver [limitación 3](./08-limitations.md)); no lo trates como mecanismo de seguridad.

> Ver [Tenants](./04-tenants.md).

---

## 6. `did:web` no resoluble

- **Síntoma:** La resolución del `did:web` del issuer o del verifier falla (el DID no resuelve, o resuelve a un documento vacío/erróneo).
- **Causa:** Alguna de estas tres:
  - `useHttpForWebDid` está mal configurado para el entorno (HTTP en producción o HTTPS en un entorno de dev sin TLS).
  - El endpoint `.well-known` del DID no es accesible públicamente (red interna, firewall, DNS).
  - El documento DID nunca se publicó.
- **Solución:**
  1. Ajustar **`useHttpForWebDid`** según el entorno: `true` (HTTP) en desarrollo / Docker sin TLS, `false` (HTTPS) en producción.
  2. Confirmar que el documento DID está accesible en la URL `.well-known` correspondiente (`https://<host>/.well-known/did.json` o `https://<host>/<path>/did.json`).
  3. Verificar que el DID efectivamente se publicó (las funciones `ensure*` pueden recrearlo de forma destructiva si la clave KMS no se encuentra — ver [limitación 13](./08-limitations.md)).

  Verificado en `src/agent/dids.module.ts:40` (`buildWebDidResolver(config.useHttpForWebDid)`).

---

## 7. OID4VC no se activa (endpoints no registrados)

- **Síntoma:** Los endpoints OID4VCI / OID4VP no responden (404), o el agente arranca pero nunca expone las rutas de emisión/verificación.
- **Causa:** La activación de OID4VC requiere **AMBOS** valores presentes: `config.oid4vcBaseUrl` **y** `options.expressApp`. Si falta cualquiera de los dos, el bloque de configuración OID4VC se omite por completo (es un spread condicional `config.oid4vcBaseUrl && options.expressApp && { ... }`).
- **Solución:** Proveer **los dos**: definir `config.oid4vcBaseUrl` con la URL base pública y pasar la instancia de Express como `options.expressApp` al crear el agente. Atención: la JSDoc de `createVerifierAgent` menciona un parámetro `options.openId4Vc` que **no existe**; la activación real depende de `oid4vcBaseUrl` + `expressApp` (ver [limitación 18](./08-limitations.md)).

  Verificado en `src/agent/issuer.agent.ts:80` y `src/agent/verifier.agent.ts:80` (spread condicional con ambas condiciones).

> Ver [Bootstrap del agente](./03-agent-bootstrap.md).

---

## 8. Falta PostgreSQL (Askar store, BBS o records)

- **Síntoma:** Error al inicializar Askar, el sidecar BBS o un adapter Postgres de records.
- **Causa:** `DATABASE_URL` ausente o pool inaccesible; o falta `ASKAR_STORE_KEY` cuando se usa Askar.
- **Solución:** Definir `DATABASE_URL` válida y, en producto Quark, `ASKAR_STORE_KEY`. Verificar que Nest inyecta `askarStore` + adapters.

---

## 9. El issuer / verifier toma el registro equivocado en multi-tenant

- **Síntoma:** En un despliegue multi-tenant o multi-issuer se opera sobre un issuer/verifier distinto al esperado, de forma no determinista.
- **Causa:** `ensureIssuer` / `ensureVerifier` invocados **sin** `issuerId` / `verifierId` toman "el primer registro en DB" (`getAllIssuers()[0]` / `getAllVerifiers()[0]`). El orden lo decide la base, por lo que el resultado es impredecible cuando hay más de un registro.
- **Solución:** Pasar siempre el **`issuerId` / `verifierId` explícito** en cualquier escenario con más de un issuer o verifier.

> Ver [limitación 16](./08-limitations.md).

---

## 10. El holder presenta más credenciales de las pedidas

- **Síntoma:** En flujos DIDComm (W3C JSON-LD / Presentation Exchange), el holder revela credenciales adicionales a las solicitadas por el verifier, degradando la minimización de divulgación.
- **Causa:** Los listeners del holder **auto-aceptan** conexiones, ofertas y solicitudes de prueba sin confirmación del usuario (`acceptOffer`, `acceptCredential`, `acceptRequest`), y `expandPexSelection` rellena descriptores no asignados con credenciales adicionales del wallet que "matchean" (log `Expanded PEX: added N extra credential(s)`).
- **Solución:** **No** usar `setupHolderListeners` tal cual en producción. Implementar un flujo con **confirmación explícita del usuario** antes de presentar, y construir manualmente la selección de credenciales (presentar exactamente las pedidas, sin `expandPexSelection`). Esto afecta solo al camino DIDComm W3C, no al SD-JWT VC sobre OID4VP.

> Ver [limitación 12](./08-limitations.md).

---

## Ver también

- [Bootstrap del agente](./03-agent-bootstrap.md)
- [Tenants](./04-tenants.md)
- [Referencia · KMS](./06-reference/02-kms.md)
- [Referencia · Records](./06-reference/03-records.md)
- [Limitaciones](./08-limitations.md)
