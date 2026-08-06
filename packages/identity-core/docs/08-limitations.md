---
id: limitations
title: Limitaciones
sidebar_position: 8
---

# Limitaciones

Este documento consolida las limitaciones conocidas de `@quarkid/identity-core` (TypeScript sobre Credo-TS 0.7) verificadas contra el código fuente. Cada limitación incluye su evidencia `archivo:línea`, la implicación práctica para el integrador y, cuando existe, un workaround.

Las rutas de evidencia son relativas a la raíz del paquete (`packages/identity-core/`). Las líneas se verificaron contra el estado actual del código; aun así pueden desplazarse al evolucionar la base.

## Resumen por severidad

| Severidad | Limitaciones |
|-----------|--------------|
| **Alta** | Claves privadas sin cifrar en reposo (adapter Postgres / BLS sidecar); HTTP plano habilitado siempre; adapter `RecordStorage` incompleto; listeners auto-aceptan todo. |
| **Media** | `walletKey` no protege nada; domain-key compartida sin cifrar; sin verificación cripto en status list; DCQL no implementado en selección; `deferredCredentials` no se procesan; `ensure*` destructivo; `QuarkDidRegistrar` no verifica el VDR; `ensureIssuer`/`ensureVerifier` sin id usan el primer registro; BLS/BBS+ solo en Postgres (Askar no soporta Bls12381G2). |
| **Baja** | PE selecciona solo la primera credencial; `createInvitation` usa dominio dummy; JSDoc desincronizada; repo privado / submódulo. |

---

## Seguridad

### 1. Claves privadas sin cifrar en reposo (KMS Postgres / BLS)

- **Severidad:** Alta
- **Evidencia:** `src/kms/postgres-key-management.service.ts` (schema tabla `keys` / `saveKey`)
- **Implicación práctica:** El adapter `PostgresKeyManagementService` (KMS primario completo) persiste `private_jwk` **en texto plano**. Con composición Askar (producto Quark) solo el material BLS de `BbsKeyManagementService` usa esa tabla; Ed25519/P-256/X25519 viven cifrados en el store Askar. Las claves x5c de dominio usan el perfil Askar `domain-key`.
- **Workaround:** Inyectar Askar como primario (como hacen issuer/verifier/holder). Ver [KMS](./06-reference/02-kms.md).

### 1b. BLS/BBS+ solo vía Postgres (Askar sin Bls12381G2)

- **Severidad:** Media
- **Evidencia:** `src/kms/bbs-kms.ts`; firma en `src/credential/bbs/bbs-credential.ts` (MATTR). Askar 0.7 no expone Bls12381G2.
- **Implicación práctica:** La clave `#key-bbs-ldp` se genera con MATTR y se guarda en Postgres `keys`. Nest inyecta `BbsKeyManagementService` cuando el KMS primario es Askar.
- **Workaround:** Aislar ACL de la tabla `keys`; documentar la excepción BBS si compliance exige “solo Askar”.

### 2. `allowInsecureUrls` / HTTP plano habilitado siempre

- **Severidad:** Alta
- **Evidencia:**
  - `setGlobalConfig({ allowInsecureUrls: true })` en las seis funciones de creación de agente: `src/agent/issuer.agent.ts:47` y `:152`; `src/agent/holder.agent.ts:49` y `:143`; `src/agent/verifier.agent.ts:47` y `:150`.
  - `allowInsecureHttpUrls: true` en `src/agent/credo-init-config.ts:4` (`ROOT_AGENT_INIT_CONFIG`, aplicado a todos los agentes).
- **Implicación práctica:** Tanto la capa OAuth2/OID4VC (`@openid4vc/oauth2`) como el `InitConfig` de Credo aceptan URLs `http://` sin TLS de forma incondicional. No hay forma de desactivarlo por configuración del integrador; queda habilitado en producción. Expone los flujos OID4VCI/OID4VP a intercepción y manipulación si el transporte no está protegido por otra capa.
- **Workaround:** Garantizar TLS a nivel de infraestructura (reverse proxy / service mesh / ingress) de modo que todo el tráfico real viaje cifrado, tratando el flag como restringido a desarrollo local.

### 3. `walletKey` no protege nada

- **Severidad:** Media
- **Evidencia:** `src/agent/tenant.ts:23` (parámetro `_walletKey`), `src/agent/tenant.ts:29` (`createTenant({ config: { label: walletId } })`)
- **Implicación práctica:** `ensureTenant(rootAgent, walletId, _walletKey)` recibe `_walletKey` pero **no lo persiste ni lo usa**: el tenant se crea solo con `{ label: walletId }`. El `key` de un objeto `wallet: { id, key }` tampoco cifra nada (el KMS Postgres almacena en claro, ver limitación 1). El parámetro genera una falsa sensación de protección por contraseña/clave de wallet.
- **Workaround:** No confiar en `walletKey` como mecanismo de seguridad. La protección real debe venir de Askar (`ASKAR_STORE_KEY`) y/o cifrado de la base. BLS sigue en Postgres en claro (limitación 1b).

### 4. domain-key (x5c)

- **Severidad:** Media (operativa / auth del endpoint)
- **Evidencia:** `AskarDomainKeyManagementService` + `importDomainKey(agent, …)`; endpoint Nest sin auth.
- **Implicación práctica:** Con Askar la clave de dominio está cifrada en el store (perfil `domain-key`). Sigue siendo material compartido entre tenants vía resolución multi-backend.
- **Workaround:** Restringir quién puede invocar `POST /domain-key` (auth pendiente).

### 5. Verificación criptográfica ausente al decodificar el JWT de status list

- **Severidad:** Media
- **Evidencia:** `src/revocation/status-list.service.ts:110-123` (`decodeJwt` solo parsea y lanza `InvalidStatusListJwtError`); `src/revocation/revocation.errors.ts:48-56` (`StatusListExpiredError`) y `:58-66` (`StatusListSignatureError`), ambas definidas pero **nunca lanzadas** en el código (confirmado por búsqueda en `src/`).
- **Implicación práctica:** `decodeJwt` decodifica la status list y su payload sin verificar la **firma** del emisor ni la **expiración** (`exp`) del JWT. Las dos clases de error pensadas para esos chequeos están definidas pero no se usan. Un consumidor que se apoye solo en `decodeJwt` podría aceptar una status list manipulada o caducada.
- **Workaround:** El integrador debe verificar firma y expiración por su cuenta antes de confiar en el resultado de `decodeJwt` (resolviendo el DID del emisor y validando la firma del JWT con la clave pública correspondiente).

---

## Funcionalidad

### 6. (Resuelto) Domain-key vía Askar

- Antes el import escribía SQL en claro y exigía KMS Postgres. Ahora el producto Quark usa `askar-domain-key`. El path Postgres `DOMAIN_KEY_SCOPE` queda solo para integradores con KMS Postgres full.
### 7. Adapter `RecordStorage` incompleto

- **Severidad:** Alta
- **Evidencia:** `tenant-records.ts` usa `resolveRecordStorage` + `isRecordStorage`; adapters que no exponen paginación fallan con `RecordStorageCapabilityError`.
- **Implicación práctica:** Un adapter custom debe implementar todo el port `RecordStorage`, no solo CRUD por id.
- **Workaround:** Reutilizar `AskarRecordStorage` o `PostgresRecordStorage`.

### 8. DCQL no implementado en la selección de credenciales del holder

- **Severidad:** Media
- **Evidencia:** `src/protocol/openid4vc/holder.oid4vc.ts:168-174` (`selectCredentialsForRequest` devuelve `null` cuando `resolved.dcql` está presente)
- **Implicación práctica:** La auto-selección de credenciales para una presentación OID4VP solo cubre Presentation Exchange (PE). Si el verifier emite una request **DCQL**, `selectCredentialsForRequest` retorna `null` y el flujo de alto nivel no presenta nada. DCQL solo es manejable a bajo nivel (`selectCredentialsForDcqlRequest` directo de Credo).
- **Workaround:** Para DCQL, procesar manualmente el `queryResult` con la API de bajo nivel de Credo antes de llamar a `acceptOpenId4VpAuthorizationRequest`.

### 9. PE selecciona solo la primera credencial por descriptor

- **Severidad:** Baja
- **Evidencia:** `src/protocol/openid4vc/holder.oid4vc.ts:161` (`credentials[entry.inputDescriptorId] = [entry.verifiableCredentials[0]]`)
- **Implicación práctica:** En modo PE, para cada input descriptor se toma únicamente la **primera** credencial candidata, sin lógica de elección (ni interacción del usuario, ni preferencia por más reciente/válida). Si el wallet tiene varias credenciales que satisfacen el descriptor, puede presentar una distinta a la deseada.
- **Workaround:** Construir manualmente el objeto `presentationExchange.credentials` con la credencial elegida antes de llamar a `acceptPresentationRequest`.

### 10. `deferredCredentials` no se procesan automáticamente

- **Severidad:** Media
- **Evidencia:** `src/protocol/openid4vc/holder.oid4vc.ts:84-97`: `requestCredentials` retorna `{ credentials, deferredCredentials }`, pero el bucle de almacenamiento solo recorre `credentials` (líneas 87-95) y `deferredCredentials` se devuelve sin recuperar ni persistir.
- **Implicación práctica:** Si el issuer responde con credenciales **diferidas** (emisión asíncrona OID4VCI), el core las expone en el retorno pero no las recupera más tarde ni las guarda en el wallet. El integrador queda a cargo de todo el ciclo deferred.
- **Workaround:** El integrador debe implementar el polling/recuperación de las credenciales diferidas y persistirlas usando las APIs de almacenamiento (`sdJwtVcApi.store`, `w3cCredentialsApi.store`, etc.).

### 12. Los listeners auto-aceptan todo y pueden sobre-divulgar

- **Severidad:** Alta
- **Evidencia:**
  - `connections: { autoAcceptConnections: true }` en los tres roles: `src/agent/issuer.agent.ts:96` y `:201`; `src/agent/holder.agent.ts:93` y `:183`; `src/agent/verifier.agent.ts:96` y `:195`.
  - El holder auto-acepta ofertas y credenciales y auto-presenta proofs: `src/protocol/didcomm/holder.listener.ts:136` (`acceptOffer`), `:143` (`acceptCredential`), `:174` (`acceptRequest`).
  - `expandPexSelection` añade credenciales extra a la presentación: `src/protocol/didcomm/holder.listener.ts:46-118` (la asignación ocurre en `:108-112`, con log "Expanded PEX: added N extra credential(s)" en `:114`).
- **Implicación práctica:** En el flujo DIDComm (W3C JSON-LD / PE) el holder acepta conexiones, ofertas y solicitudes de prueba **sin confirmación del usuario**, y `expandPexSelection` rellena descriptores no asignados con credenciales adicionales del wallet — presentando potencialmente **más** de lo solicitado. Esto degrada la minimización de divulgación. (Afecta solo al camino DIDComm W3C; no al SD-JWT VC sobre OID4VP.)
- **Workaround:** Reemplazar los listeners por un flujo con confirmación explícita del usuario, y no usar `expandPexSelection` para producción (seleccionar exactamente las credenciales pedidas).

### 13. Las funciones `ensure*` son destructivas

- **Severidad:** Media
- **Evidencia:**
  - `src/did/web-did.ts:80` y `:88`: `ensureWebDid` borra el `DidRecord` local (`didRepo.deleteById`) y recrea si falta la clave KMS o falta una verification method esperada.
  - `src/did/key-did.ts:38`: `ensureKeyDid` borra el `DidRecord` local y recrea si la clave KMS se perdió.
  - `src/did/did.ts:29-33`: `ensureDid` borra el registro **local** (`deleteById`) **y en el VDR** (`POST /did/delete`) antes de recrear.
- **Implicación práctica:** Si la clave KMS no se encuentra (p. ej. almacenamiento efímero reiniciado, o KMS apuntando a otra base), estas funciones **eliminan** el DID existente —en `ensureDid` también del VDR— y crean uno nuevo, en lugar de fallar. Una mala configuración del KMS puede borrar DIDs publicados.
- **Workaround:** Garantizar persistencia y consistencia del KMS antes de invocar `ensure*`. Verificar que el KMS apunta a la base correcta antes de arrancar el agente en producción.

### 14. `QuarkDidRegistrar` no verifica la respuesta del VDR

- **Severidad:** Media (sería Alta de no ser porque solo se manifiesta cuando el VDR rechaza activamente el registro, no en el flujo normal; el workaround de re-resolver el DID es simple y fiable).
- **Evidencia:** `src/did/registrar/quark.registrar.ts:150-157` (`fetch(...POST /did...)` sin comprobar `res.ok`), seguido de la creación y persistencia del `DidRecord` local en `:159` y siguientes.
- **Implicación práctica:** El registrar hace `POST` al VDR pero no revisa el código de respuesta; persiste el `DidRecord` local **aunque el VDR rechace** el registro. Resultado: el agente cree tener un DID publicado que el VDR no conoce → **divergencia local/VDR** difícil de detectar.
- **Workaround:** Validar el registro contra el VDR (resolver el DID tras crearlo) antes de darlo por bueno.

### 15. `StatusListStorage` requiere un `pg.Pool` (Postgres) en el adapter de referencia

- **Severidad:** Baja
- **Evidencia:** `src/revocation/postgres-status-list.storage.ts` recibe un `pg.Pool` por constructor y crea DDL idempotente sobre Postgres. El puerto `StatusListStorage` (`src/revocation/status-list-storage.interface.ts`) es portable a otros backends, pero el único adapter incluido en el core es Postgres.
- **Implicación práctica:** Un consumer que use otro motor (TypeORM/MySQL, MongoDB, DynamoDB, in-memory para tests) debe implementar `StatusListStorage` y conectarlo. Mientras tanto, la integración canónica asume Postgres disponible.
- **Workaround:** Reutilizar el `pg.Pool` de `DATABASE_URL` vía `StatusListStorageModule` (default en el issuer). Ver [Referencia · Revocación](./06-reference/05-revocation.md).

### 16. `ensureIssuer` / `ensureVerifier` sin id usan "el primer registro en DB"

- **Severidad:** Media
- **Evidencia:** `src/protocol/openid4vc/issuer.oid4vc.ts:105-107` (`getAllIssuers()` → `issuers[0]` cuando no se pasa `issuerId`); `src/protocol/openid4vc/verifier.oid4vc.ts:50-53` (`getAllVerifiers()` → `verifiers[0]` cuando no se pasa `verifierId`).
- **Implicación práctica:** Al omitir el id, ambas funciones toman el **primer** registro devuelto por la DB. En un despliegue **multi-tenant** o multi-issuer esto es peligroso: se puede operar sobre el issuer/verifier equivocado de forma no determinista.
- **Workaround:** Pasar siempre `issuerId` / `verifierId` explícito en escenarios con más de un issuer/verifier.

### 17. `createInvitation` usa el dominio dummy `example.org` por defecto

- **Severidad:** Baja
- **Evidencia:** `src/protocol/didcomm/invitation.ts:20` (`const domain = options?.domain ?? 'https://example.org'`)
- **Implicación práctica:** Si no se pasa `options.domain`, la URL de la invitación OOB se genera con `https://example.org`, un dominio inválido para producción. La invitación resultante no apuntará al host real.
- **Workaround:** Pasar siempre `options.domain` con el dominio público real del agente.

---

## Interoperabilidad / Calidad de API

### 18. JSDoc desincronizada con el comportamiento real

- **Severidad:** Baja
- **Evidencia:**
  - **Algoritmo por defecto:** `src/protocol/openid4vc/issuer.oid4vc.ts:294` documenta el default `['EdDSA']`, pero el código usa `['ES256']` (`:399` y `:401`, `supportedAlgorithms ?? ['ES256']`).
  - **Versión PE:** `src/protocol/openid4vc/verifier.oid4vc.ts:280` (JSDoc) menciona `version: 'v1.draft24'`, pero el código fija `'v1.draft21'` para PE (`:337`).
  - **`createVerifierAgent`:** `src/agent/verifier.agent.ts:37` menciona activar OID4VP "solo si se provee `options.openId4Vc`", parámetro **inexistente**; la activación real depende de `config.oid4vcBaseUrl` + `options.expressApp` (`:80`).
  - **`createVerificationRequest`:** `src/protocol/openid4vc/verifier.oid4vc.ts:284` documenta un `@param signingDidUrl` que **no existe** en la firma (`:288-291`, solo `agent, options`).
- **Implicación práctica:** La documentación inline induce a error sobre el algoritmo por defecto, la versión del perfil PE y los parámetros disponibles. El integrador puede asumir EdDSA cuando se firma con ES256, o esperar opciones que no existen.
- **Workaround:** Tratar el código como fuente de verdad. Para emisión OID4VCI, el default efectivo es **ES256**; el perfil PE de verificación es **draft21**.

---

## Distribución

### 19. Repo privado / submódulo

- **Severidad:** Baja
- **Evidencia:** `packages/identity-core` está declarado como submódulo git en `.gitmodules` apuntando a `https://bitbucket.org/fleetstudio/quarkid-identity-core.git` (repo **privado**); `package.json:3` declara `"version": "0.1.0"`.
- **Implicación práctica:** El paquete vive como submódulo de un repo privado y aún está en versión `0.1.0` (pre-1.0, sin garantías de estabilidad de API). El consumo requiere acceso al submódulo o a un registro privado, y la API puede cambiar entre versiones menores.
- **Workaround:** Fijar la referencia del submódulo (commit) y planificar actualizaciones controladas; no asumir estabilidad semántica antes de 1.0.

---

## Ver también

- [Flujos · Emisión OID4VCI](./05-flows/01-issuance-oid4vci.md)
- [Flujos · Verificación OID4VP](./05-flows/02-verification-oid4vp.md)
- [Flujos · Holder](./05-flows/03-holder.md)
- [Flujos · DIDComm](./05-flows/04-didcomm.md)
- [Referencia · KMS](./06-reference/02-kms.md)
- [Referencia · Records](./06-reference/03-records.md)
- [Referencia · Revocación](./06-reference/05-revocation.md)
- [Troubleshooting](./07-troubleshooting.md)
