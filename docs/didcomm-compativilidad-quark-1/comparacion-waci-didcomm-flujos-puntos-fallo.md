# WACI vs DIDComm v2 (Credo) — Comparación de flujos, puntos de fallo y necesidad del bridge

**Versión:** 1.0
**Fecha:** 2026-06-26
**Fuentes:**

- `docs/waci-protocol-detallado.md` (WACI paso a paso, este repo)
- `docs/didcomm-protocol-detallado.md` (DIDComm v2/Credo paso a paso, este repo)
- `docs/propuesta-bridge-waci-didcomm.md` (propuesta previa)
- Código real: `@extrimian/waci`, `@quarkid/agent@1.0.0`, `@credo-ts/didcomm`, `quark-wallet`, `quark-issuer-service`, `quark-verifier-service`

---

## 1. Resumen ejecutivo

WACI y DIDComm v2 **no son el mismo protocolo**: aunque WACI reutiliza los message types de DIDComm v2.0/3.0, **difieren en 7 dimensiones críticas** que hacen imposible que un holder Credo-nativo (la wallet Quark2.0) participe en un flujo WACI del Emisor/Verificador de Quark2.0 sin una capa de traducción. Esa capa es el bridge.

**Pero** el bridge **no siempre es la respuesta correcta**. Si el objetivo estratégico es migrar Quark a un stack 100% nativo Credo y abandonar el SDK de Extrimian, hay alternativas más limpias. La decisión depende del horizonte de migración y de qué actores externos deben mantenerse compatibles.

---

## 2. Comparación flujo a flujo

Para cada protocolo, los **mismos pasos conceptuales** pero con mecanismos radicalmente distintos. La tabla sigue los actores lógicos.

### 2.1 Emisión de credencial

| Paso conceptual                         | WACI (Emisor / Verificador Quark2.0)                                                                                                                       | DIDComm v2 (Credo)                                                                                                     | Compatible directo?                         |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| **1. Handshake**                        | No existe. El OOB es un mensaje simple con `goal_code: streamlined-vc`.                                                                                    | Requerido: OOB con `didexchange/2.0/request` embebido, genera `did:peer:2` por ambos lados y crea `ConnectionRecord`.  | ❌ — Emisor WACI no entiende `didexchange`. |
| **2. Offer**                            | `issue-credential/3.0/offer-credential` con `attachments[CredentialManifest, CredentialFulfillment-template]`.                                             | `issue-credential/2.0/offer-credential` con `credentials~attach[jsonld]` (preview de la VC no firmada).                | ❌ — Attachments DIF vs JSON-LD planos.     |
| **3. Request**                          | `issue-credential/3.0/request-credential` con `attachments[CredentialApplication]` (VP firmada con `BbsBlsSignature2020`).                                 | `issue-credential/2.0/request-credential` con `requests~attach[jsonld]` (no exige firma en la request).                | ❌ — formato y prueba distintos.            |
| **4. Issue**                            | `issue-credential/3.0/issue-credential` con `attachments[CredentialFulfillment]` que contiene `verifiableCredential[]` firmadas con `BbsBlsSignature2020`. | `issue-credential/2.0/issue-credential` con `credentials~attach[jsonld]` con `proof: Ed25519Signature2018`.            | ❌ — proof suite distintos.                 |
| **5. ACK**                              | `issue-credential/3.0/ack` con `body.status: "OK"`.                                                                                                        | `issue-credential/2.0/ack` con `status: "OK"`.                                                                         | ✅ — Mismo formato y semántica.             |
| **Persistencia**                        | Sin state machine. El SDK llama callbacks por mensaje.                                                                                                     | State machine con `DidCommCredentialExchangeRecord` y estados: `offer-sent → request-sent → credential-issued → done`. | ❌ — Distinta filosofía.                    |
| **Aprobación del usuario en el holder** | SDK llama `handleCredentialFulfillment`; la wallet decide cuándo guardar la VC. El holder tiene UI entre cada paso.                                        | Listener `OfferReceived` auto-acepta. No hay prompt al usuario por defecto.                                            | ⚠️ — Distinta UX esperada.                  |

### 2.2 Verificación / presentación

| Paso conceptual     | WACI (Verificador Quark2.0)                                                                                                  | DIDComm v2 (Credo)                                                                                                 | Compatible directo?                                              |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| **1. Handshake**    | No existe.                                                                                                                   | Requerido: `didexchange/2.0`.                                                                                      | ❌                                                               |
| **2. Request**      | `present-proof/3.0/request-presentation` con `attachments[PresentationDefinition]`.                                          | `present-proof/2.0/request-presentation` con `request_presentations~attach[presentationExchange]` (PD embebido).   | ✅ parcial — DIF PEX es estándar, pero la envoltura es distinta. |
| **3. Presentation** | `present-proof/3.0/presentation` con `attachments[PresentationSubmission]` (VP con `presentation_submission` y prueba BBS+). | `present-proof/2.0/presentation` con `request_presentations~attach[presentationExchange]` (VP con prueba Ed25519). | ❌ — proof suite distintos.                                      |
| **4. ACK**          | `present-proof/3.0/ack` con `body.status`.                                                                                   | `present-proof/2.0/ack` con `status`.                                                                              | ✅ — Mismo formato.                                              |
| **Persistencia**    | Sin state machine.                                                                                                           | State machine `ProofStateChanged`.                                                                                 | ❌                                                               |

### 2.3 Out-of-band invitation

| Aspecto             | WACI OOB                                               | DIDComm v2 OOB                                                                       |
| ------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| **Tipo de mensaje** | `https://didcomm.org/out-of-band/2.0/invitation`       | `https://didcomm.org/out-of-band/2.0/invitation` (mismo!)                            |
| **Discriminador**   | `body.goal_code: "streamlined-vc" \| "streamlined-vp"` | `attachments[0].data.json['@type']` con `didexchange/2.0/request`                    |
| **Adjuntos**        | Vacío o con el `goal_code` en el body.                 | `attachments[]` con handshake `didexchange` embebido + posible `request-credential`. |
| **DID del emisor**  | `did:quarkid` (operacional, fijo).                     | `did:peer:2` (generado en el momento).                                               |
| **recipientKeys**   | Opcional.                                              | Lista de claves X25519 para ECDH-ES (obligatorio).                                   |

Aunque comparten el message type, **el discriminador y los adjuntos los hacen incompatibles en la práctica**. Un parser de Credo que reciba un OOB-WACI no sabrá qué hacer (no hay handshake) y un parser de Extrimian que reciba un OOB-Credo verá un `didexchange` que no entiende.

### 2.4 Identificadores de thread

| WACI                                             | DIDComm v2                               |
| ------------------------------------------------ | ---------------------------------------- |
| `pthid` (parent thread ID) = id de la invitación | `~thread.pthid` = id de la invitación    |
| `thid` (thread ID) = id del mensaje anterior     | `~thread.thid` = id del mensaje anterior |

Ambos llevan la misma idea pero **con field names distintos**. Un parser de Credo que mire `pthid` directamente no encuentra nada.

### 2.5 Transporte

| WACI                                              | DIDComm v2                                                           |
| ------------------------------------------------- | -------------------------------------------------------------------- |
| Socket.IO sin cifrar, JSON plano.                 | HTTP POST o WebSocket con cifrado JWE (ECDH-ES + A256KW, authcrypt). |
| Path `/socket.io`.                                | HTTP `/didcomm` (path configurable) o WS.                            |
| Mensajes en claro visibles para el intermediario. | Mensajes encriptados end-to-end (anonymity + confidentiality).       |

---

## 3. Puntos de fallo detallados

### F1 — Handshake (RFC 0023/0168)

**Qué falla.** WACI **no implementa DIDExchange**. Emite OOB invitations que son sólo metadata del flow + goal_code. Credo **requiere** establecer una conexión (`DidCommConnectionRecord`) antes de iniciar cualquier intercambio. Si Credo recibe un OOB-WACI, su parser intentará extraer el handshake `didexchange/2.0/request` del attachment y al no encontrarlo rechaza la invitación.

**Por qué.** Diferente modelo de confianza. Extrimian confía en que el OOB lleva el `from` correcto y la oferta llega después, sin canal cifrado. DIDComm cifra el canal desde el inicio para no exponer metadatos (DID, tipo de credencial solicitada, etc.) a observadores.

**Cómo lo mitiga el bridge.** El bridge actúa como un **peer DID real** frente al holder Credo. Cuando recibe el OOB-WACI:

1. Decodifica la metadata (`goal_code`, `from`, etc.).
2. Genera un par de claves X25519+Ed25519 efímero y construye su propio `did:peer:2`.
3. Construye un OOB-DIDComm estándar con `attachments[0].data.json['@type']: "didexchange/2.0/request"`, su DID, su `serviceEndpoint` (que apunta al bridge) y `recipientKeys`.
4. Devuelve esa URL al frontend Quark como si fuera la invitación original.
5. El holder Credo hace el DIDExchange normal contra el bridge y la conexión queda establecida.

### F2 — Formato de los attachments

**Qué falla.** Los attachments DIF Credential Manifest/Fulfillment (WACI) viven dentro de `attachments[]` con `format: 'dif/credential-manifest/manifest@v1.0'`. Credo usa `credentials~attach[]` con `formats: [{attach_id, format: 'jsonld'}]`. El `JsonLdCredentialFormatService` de Credo **no entiende** el shape de Manifest ni viceversa — el `WACIInterpreter` de Extrimian no sabe parsear `formats`.

**Por qué.** Son esquemas DIF distintos. Credential Manifest es un estándar separado de la propuesta DIF para ofertas. JSON-LD VC es lo que Credo espera como payload.

**Cómo lo mitiga el bridge.** El bridge intercepta cada mensaje antes de reenviarlo y reescribe los attachments:

| Dirección          | Operación                                                                                                                                                                                                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **WACI → DIDComm** | Parsea el manifest. Extrae la `presentation_definition` (si hay) → la deja como `presentation_definition`. Extrae los `output_descriptors` → arma una `credential` JSON-LD con `@context`, `type`, `credentialSubject` (placeholder). Lo pone como `credentials~attach[0].data.json`. |
| **DIDComm → WACI** | Recibe el `credentials~attach` con la VC firmada. Lo envuelve en `attachments[]` con `format: 'dif/credential-manifest/fulfillment@v1.0'`, adjuntando el `descriptor_map` y el `manifest_id` original.                                                                                |

### F3 — Suite criptográfica

**Qué falla.** Credo firma VCs y VPs con `Ed25519Signature2018` por default. Extrimian firma con `BbsBlsSignature2020` (BBS+, con divulgación selectiva). Credo puede añadir BbsBlsSignature2020 pero requiere instalar `@mattrglobal/jsonld-signatures-bbs` + suites y registrarlos en `w3cCredentials` API. Sin esa integración, **Credo no puede verificar la firma de las VCs emitidas por WACI**.

**Por qué.** BbsBlsSignature2020 es un proof suite distinto: usa BLS12-381 en lugar de Ed25519, requiere commitments especiales y un nuevo suite para verificación.

**Cómo lo mitiga el bridge.** Opción A (recomendada): el bridge **re-firma** las VCs en el límite WACI↔DIDComm. Si recibe una VC firmada con BbsBlsSignature2020 desde el Emisor, la verifica, extrae los claims, y la re-firma con Ed25519Signature2018 antes de inyectarla al holder Credo. Esto evita tocar la wallet Quark. Opción B: agregar `BbsBlsSignature2020` a `identity-core` y configurar Credo para verificar — trabajo de 1-2 semanas, introduce una dependencia cripto nueva.

### F4 — Cifrado en transporte

**Qué falla.** Credo espera JWE cifrado (ECDH-ES + A256KW + authcrypt) en cada mensaje entrante. Extrimian envía JSON plano por Socket.IO. Si Credo intenta recibir un mensaje WACI en su transporte HTTP/WS, no puede descifrarlo — falla con `JWE parse error` o similar.

**Por qué.** DIDComm v2 asume confidencialidad end-to-end como requisito de la capa de transporte. WACI asume que el canal (Socket.IO) ya provee confidencialidad a nivel de transporte TLS.

**Cómo lo mitiga el bridge.** El bridge expone un endpoint HTTP en `/didcomm` al que Credo puede mandar mensajes cifrados. El bridge los descifra (tiene su propia clave X25519), los lee, y los re-empaqueta al formato Socket.IO que espera el Emisor/Verificador WACI. En la otra dirección, recibe Socket.IO del Emisor/Verificador, los cifra como JWE y los inyecta al holder Credo.

### F5 — Tracking de thread

**Qué falla.** WACI usa `pthid` y `thid` planos. DIDComm usa `~thread.thid` y `~thread.pthid` (decoradores DIDComm v2 con tilde). Si un parser Credo mira `thid` plano no lo encuentra. Si un parser Extrimian mira `~thread.thid` lo ignora.

**Por qué.** DIDComm v2 introduce los "decorators" con prefijo `~` como convención para metadata del protocolo. WACI hereda la idea pero no usa el prefijo.

**Cómo lo mitiga el bridge.** Reescritura trivial en cada mensaje: convierte `pthid` ↔ `~thread.pthid`, `thid` ↔ `~thread.thid`.

### F6 — Aprobación del usuario en el holder

**Qué falla.** En Credo el listener `OfferReceived` auto-acepta (`acceptOffer` se llama inmediatamente). En WACI, el holder muestra UI entre cada paso (`handleCredentialFulfillment` decide si guardar la VC). El **comportamiento UX** difiere.

**Por qué.** Distinto modelo de control: Credo delega en el integrador cuándo aprobar; WACI invierte la responsabilidad al holder.

**Cómo lo mitiga el bridge.** Dos opciones:

- **Dejar que Credo auto-acepte.** El bridge sólo traduce mensajes; el usuario ve el resultado final cuando aparece la VC en su wallet. UX más simple.
- **Insertar pausa antes de `acceptOffer`.** El bridge, al recibir el `offer-credential` del Emisor, no lo reenvía inmediatamente al holder. Lo guarda y notifica al frontend Quark ("¿Querés recibir esta credencial?"). Cuando el usuario confirma, el bridge reenvía. Esto requiere un canal de control adicional (HTTP al frontend Quark2.0) que no existe en WACI.

### F7 — Resolución de DID

**Qué falla.** El Emisor/Verificador WACI usan `did:quarkid` operacional. El Verificador usa el mismo patrón. En el flujo DIDComm nativo, el bridge usaría `did:peer:2` para sí mismo. Si el holder Credo intenta resolver el `did:quarkid` del Emisor para verificar una firma, **debe** tener un resolver `did:quarkid` configurado.

**Por qué.** Credo por default resuelve `did:key`, `did:jwk`, `did:peer`. `did:web` requiere `WebDidResolver` registrado.

**Cómo lo mitiga el bridge.** Esto NO lo mitiga el bridge, lo mitiga `quark-resolver` (el servicio `quark-resolver` utilizando una nueva estrategia que resuelva `did:quarkid`). El bridge puede llamar al resolver para validar la firma de las VCs antes de re-firmar con Ed25519. **El resolver es una pieza complementaria al bridge, no parte del mismo.**

---

## 4. ¿Es necesario el bridge?

La respuesta depende del objetivo estratégico del equipo.

### Escenario A — Migración total al stack Credo-nativo (recomendado si es viable)

**Objetivo:** abandonar Extrimian SDK y WACI por completo. Reescribir Emisor y Verificador sobre `quark-issuer-service` y `quark-verifier-service`.

**Acciones:**

1. Reescribir el Emisor como un wrapper HTTP sobre `quark-issuer-service`. Endpoint REST para crear plantillas + iniciar emisión.
2. Reescribir el Verificador como wrapper HTTP sobre `quark-verifier-service`. Endpoint REST para crear PresentationDefinition + verificar.
3. Frontend Quark2.0 genera OOB invitations nativas Credo (`did:peer:2` por sesión).
4. Holders Quark2.0 se conectan a issuers/verifiers directamente vía DIDExchange.

**¿Bridge necesario?** **No.**

**Pros:** Sin capas intermedias, sin traducción, sin superficie de ataque adicional. Sin dependencia de `@extrimian/waci` ni `@quarkid/agent@1.0.0`. El equipo se queda con un solo stack (Credo).

**Contras:** No es compatible con deployments WACI pre-existentes (si hay otros issuers/verifiers Extrimian desplegados en producción contra los que la wallet Quark2.0 deba interoperar). El Emisor y Verificador actuales quedan obsoletos.

**Esfuerzo:** 6-10 semanas (re-escritura del Emisor y Verificador).

### Escenario B — Interoperabilidad con ecosistema Extrimian pre-existente

**Objetivo:** que la wallet Quark2.0 funcione contra Emisores/Verificadores WACI que ya están en producción (clientes que ya usan Extrimian).

**Acciones:**

1. Construir el bridge (3-4 semanas).
2. Mantener Emisor/Verificador WACI hasta que todos los clientes migren al equivalente Credo.

**¿Bridge necesario?** **Sí.**

**Pros:** Compatibilidad inmediata con deployments existentes. No requiere migración forzada de clientes.

**Contras:** Capa adicional a mantener. Si Extrimian cambia WACI en una versión futura, el bridge rompe. Latencia extra.

**Esfuerzo:** 3-4 semanas (construir) + mantenimiento continuo.

### Escenario C — Híbrido (recomendado como estrategia de transición)

**Objetivo:** migrar gradualmente. Emisión primero (donde WACI es más débil), verificación al final (donde WACI es más fuerte).

**Fase 1 (mes 1-2):** Reescribir el Emisor sobre `quark-issuer-service` nativo Credo. El bridge **no es necesario** para emisión porque el Emisor ya habla DIDComm nativo.
**Fase 2 (mes 3-4):** Reescribir el Verificador. Bridge **tampoco es necesario**.
**Fase 3 (mes 5+):** Deprecar WACI y `@extrimian/waci`. Eliminar el SDK del monorepo.

**¿Bridge necesario?** **No en ninguna fase.**

**Pros:** Migración incremental sin bloquear features. Empezar por donde WACI tiene más fricción. Cada fase entrega valor.

**Contras:** Requiere reemplazar el Emisor y Verificador manualmente.

**Esfuerzo:** 6-8 semanas totales (un poco menos que escenario A porque se hace en fases).

### Escenario D — Mantener WACI por incompatibilidad con clientes legacy

Si existen clientes que **realmente** no pueden migrar (p. ej. wallets hardware con SDK Extrimian quemado en firmware), el bridge es la única salida. Pero hay que considerar:

- ¿Cuántos clientes legacy hay? Si son <10% de la base, forzar la migración puede ser más económico que mantener un bridge para siempre.
- ¿El proveedor Extrimian tiene roadmap de migración a DIDComm nativo? Si sí, el bridge tiene fecha de caducidad natural. Si no, el bridge es una carga permanente.

---

## 5. Matriz de decisión

| Pregunta                                                                             | Bridge                               | Reescritura nativa |
| ------------------------------------------------------------------------------------ | ------------------------------------ | ------------------ |
| ¿Necesito que la wallet Quark2.0 funcione contra **emisores Extrimian legacy**?      | ✅ Sí                                | ❌ No              |
| ¿Tengo 3+ meses de runway para reescribir Emisor/Verificador?                        | ❌ No                                | ✅ Sí              |
| ¿Hay deployments WACI en producción contra los que **no** controlo la actualización? | ✅ Sí                                | ❌ No              |
| ¿Quiero eliminar `@extrimian/waci` y `@quarkid/agent@1.0.0` del monorepo?            | ❌ No (bridge los sigue necesitando) | ✅ Sí              |
| ¿Hay wallets de terceros que sólo hablan WACI?                                       | ✅ Sí                                | ❌ No              |
| ¿Quiero minimizar superficie de ataque?                                              | ❌ No (más servicios)                | ✅ Sí              |

---

## 6. Análisis técnico-económico del bridge

Si se opta por el bridge:

### Servicios que el bridge SÍ requiere

| Servicio                   | Estado           | Notas                                                      |
| -------------------------- | ---------------- | ---------------------------------------------------------- |
| `quark-resolver` (did:web) | ✅ Ya existe     | Necesario para validar firmas del Emisor/Verificador WACI. |
| `quark-api-gateway`        | ✅ Ya existe     | Punto de entrada para el frontend.                         |
| **Nuevo: `quark-bridge`**  | ❌ Por construir | Servicio nuevo, único propósito: traducir WACI ↔ DIDComm.  |

### Servicios que el bridge NO reemplaza

- `quark-issuer-service` y `quark-verifier-service` siguen siendo el camino nativo Credo.
- El bridge se monta **delante** del Emisor/Verificador WACI actuales (no los reemplaza).
- `quark-holder-service` no participa del bridge: el holder **es** la wallet Quark2.0.

### Riesgos del bridge

| Riesgo                                                                         | Mitigación                                                         |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| **Punto único de fallo** entre wallet Quark2.0 y Emisor/Verificador WACI.      | Replicar el bridge, health checks, circuit breakers.               |
| **Latencia añadida** (2 hops extra: holder → bridge → WACI issuer).            | Conexiones persistentes, no relays.                                |
| **Mapping 1:1 con message types** que puede romperse si Extrimian cambia WACI. | Pin a una versión del SDK, suite de tests E2E con golden messages. |
| **Cifrado/descifrado** requiere keys management robusto.                       | KMS externo (Vault o equivalente), rotación.                       |
| **Session state** (mapping `pthid` ↔ connectionId ↔ peerDid).                  | Persistir en Redis con TTL.                                        |

### Costo de no construirlo

Si el equipo decide NO construir el bridge y NO reescribir el Emisor/Verificador tampoco, la wallet Quark2.0 queda **aislada del ecosistema Extrimian** y no puede interoperar con los deployments actuales. El equipo debe aceptar esa decisión y planificar la migración.

---

## 7. Recomendación

**Recomendación primaria:** **Escenario C (híbrido sin bridge)**.

Razones:

1. Los servicios `quark-issuer-service` y `quark-verifier-service` ya están construidos y operativos (vistos en el código). El equipo ha invertido en Credo.
2. El bridge introduce una capa de traducción permanente que se vuelve legacy code eventualmente.
3. El esfuerzo de reescribir Emisor/Verificador (6-10 semanas) es comparable al de construir y mantener el bridge (3-4 semanas + ongoing), pero el resultado final con reescritura es **más simple**.
4. Migrar Emisor primero (donde WACI tiene más fricción: `BbsBlsSignature2020` + Credential Manifest) elimina el caso de uso del bridge.

**Recomendación secundaria (si hay clientes legacy ineludibles):** **Escenario B con bridge**, pero con un **plan de sunset explícito**: el bridge se depreca cuando el último cliente legacy migra, con fecha objetivo (p. ej. 12 meses).

**Lo que NO recomiendo:**

- Construir el bridge como solución permanente.
- Construir el bridge sin un plan de migración paralelo del Emisor/Verificador (sería mantener dos sistemas paralelos por tiempo indefinido).
- Reemplazar el bridge con un rewrite completo del SDK Extrimian (esfuerzo 6+ meses, alto riesgo de divergencia con upstream).

### Acciones concretas para el escenario C

1. **Documentar las APIs del Emisor/Verificador actuales** (qué endpoints REST exponen hoy, qué templates manejan).
2. **Construir un wrapper HTTP fino** sobre `quark-issuer-service` que reemplace al Emisor WACI. Mantener la misma API HTTP para no romper el frontend.
3. **Idem para el Verificador** sobre `quark-verifier-service`.
4. **Testing E2E** con la wallet Quark2.0 real contra los nuevos servicios (sin bridge, comunicación directa DIDComm).
5. **Deprecar `@extrimian/waci` y `@quarkid/agent@1.0.0`** del package.json.
6. **Cortar Socket.IO** del frontend, reemplazarlo por HTTP normal al frontend + DIDComm directo.

### Lo que igual se necesita (independiente del escenario)

- **`quark-resolver` con `WebDidStrategy`** para que Credo pueda resolver los `did:web` operativos del Emisor/Verificador nativo (que se mantendrán hasta migrar completamente a `did:peer` o `did:key`).
- **Configurar `BbsBlsSignature2020` en `identity-core`** si alguna VC legacy del Emisor WACI debe ser verificable directamente por la wallet Quark2.0 (no por el bridge). Trabajo de 1-2 semanas.
- **Migrar credenciales existentes** (si hay VCs WACI emitidas a usuarios que deben poder usar la wallet Quark2.0): script de re-emisión o de wrapping con Ed25519.

---

## 8. Conclusión

**El bridge NO es necesario si el equipo está dispuesto a invertir 6-10 semanas en reescribir el Emisor y el Verificador sobre los servicios Credo-nativos existentes.** Esa es la dirección más limpia y la que mejor alinea Quark2.0 con su dirección técnica actual.

El bridge **SÍ es necesario sólo si hay un compromiso firme de mantener compatibilidad con deployments WACI legacy durante un horizonte definido (≤12 meses)**, con plan explícito de sunset.

Antes de tomar la decisión, responder estas tres preguntas:

1. ¿Cuántos clientes/emisores/verificadores en producción hablan WACI hoy?
2. ¿Puedo controlar cuándo migran esos clientes?
3. ¿El equipo tiene bandwidth para reescribir el Emisor/Verificador en los próximos 2-3 meses?

Si la respuesta a la 1 es "pocos", a la 2 es "sí", y a la 3 es "sí": **no construyas el bridge, reescribe**. Si alguna de las tres respuestas es "no" o "depende": **construye el bridge con sunset plan**.

---

**Fin del documento**
