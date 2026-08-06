# Protocolo WACI: funcionamiento detallado paso a paso

**Versión:** 1.0
**Fecha:** 2026-06-26
**Fuentes analizadas:** SDK `@quarkid/agent@1.0.0` + paquete `@extrimian/waci` + código del Emisor y Verificador actuales

---

## 1. Qué es WACI

WACI (Web Access for Credential Issuance) es un **protocolo propietario de Extrimian** construido sobre DIDComm v2 con el objetivo de simplificar los flujos de emisión y verificación de credenciales verificables (VCs). No es un estándar público; la única implementación de referencia es el SDK `@extrimian/waci` (y `@extrimian/agent` que lo envuelve).

WACI se inspira en dos estándares DIF: **Credential Manifest** (para oferta de credenciales) y **Presentation Exchange** (para solicitud de presentación). Internamente **reutiliza los tipos de mensaje DIDComm v2/3.0** (issue-credential, present-proof, out-of-band, problem-report, ack) pero **no respeta la separación entre transporte y protocolo**: cada handler del SDK hace el ciclo completo de request/response en un solo paso, con callbacks que resuelven la lógica de negocio dentro del handler.

### Identificadores de los tipos de mensaje

Definidos en `@extrimian/waci/dist/types/waci-message.d.ts`:

```ts
SharedMessageType: OutOfBandInvitation =
  "https://didcomm.org/out-of-band/2.0/invitation";

IssuanceMessageType: ProposeCredential =
  "https://didcomm.org/issue-credential/3.0/propose-credential";
OfferCredential = "https://didcomm.org/issue-credential/3.0/offer-credential";
RequestCredential =
  "https://didcomm.org/issue-credential/3.0/request-credential";
IssueCredential = "https://didcomm.org/issue-credential/3.0/issue-credential";
IssuanceAck = "https://didcomm.org/issue-credential/3.0/ack";
ProblemReport = "https://didcomm.org/report-problem/2.0/problem-report";

PresentationMessageType: ProposePresentation =
  "https://didcomm.org/present-proof/3.0/propose-presentation";
RequestPresentation =
  "https://didcomm.org/present-proof/3.0/request-presentation";
PresentProof = "https://didcomm.org/present-proof/3.0/presentation";
PresentationAck = "https://didcomm.org/present-proof/3.0/ack";
ProblemReport = "https://didcomm.org/report-problem/2.0/problem-report";

GoalCode: Issuance = "streamlined-vc";
Presentation = "streamlined-vp";
```

Los goal codes `streamlined-vc` y `streamlined-vp` son el **identificador característico** de WACI frente a otros flujos DIDComm.

### Estructura del mensaje

```ts
type WACIMessage = {
  type: WACIMessageType;
  id: string; // ID único del mensaje
  from: string; // DID del emisor
  to?: string[]; // DIDs destinatarios
  body?: any; // Cuerpo del mensaje (goal_code, status, etc.)
  pthid?: string; // Parent Thread ID (raíz de la conversación)
  thid?: string; // Thread ID (mensaje anterior al que responde)
  attachments?: any[]; // Adjuntos con manifests, fulfillments, presentations
};
```

Los `attachments` siguen el formato DIF:

- `media_type: "application/json"` o `"application/ld+json"`
- `format: "dif/credential-manifest/manifest@v1.0"` | `"dif/credential-manifest/fulfillment@v1.0"` | `"dif/credential-manifest/application@v1.0"` | `"dif/presentation-exchange/definitions@v1.0"` | `"dif/presentation-exchange/submission@v1.0"`
- `data.json: { ... }` con el contenido.

---

## 2. Arquitectura interna del SDK

WACI se estructura en tres capas:

### Capa 1 — `WACIInterpreter`

Clase central que enruta mensajes a handlers según el `Actor` (Holder, Issuer, Verifier) y el `type`. Recibe un **thread completo** (array de mensajes), toma el último y lo despacha al handler registrado.

Métodos principales (vistos en `waci-interpreter.js`):

```ts
setUpFor<T>(params, actor); // Registra callbacks para un actor
isWACIMessage(message); // true si type ∈ WACIMessageType
createOOBInvitation(senderDID, goalCode, body);
// Construye un mensaje out-of-band
createOfferCredentialMessage(issuerDID, holderDID, manifest, fulfillment);
processMessage(messageThread); // Despacha el último mensaje al handler
```

`processMessage` recorre los `enabledActors` (registrados con `setUpFor`), busca `handlers[actor].get(message.type)`, lo ejecuta y devuelve `{ message, target, responseType }` donde:

- `target` = `message.to[0]` (a quién enviar la respuesta)
- `responseType` = `CreateThread` (nuevo thread) o `ReplyThread` (responde a uno existente)

### Capa 2 — Handlers por actor y step

Cada actor tiene handlers específicos que se registran con `@RegisterHandler(Actor.X, WACIMessageType.Y)` (decorador). Cada handler procesa un mensaje y devuelve el siguiente.

```
Actor = Holder (lado wallet):
  step-2-oob-invitation.handler       → OutOfBandInvitation
                                        → crea ProposeCredential | ProposePresentation
  step-4-offer-credential.handler     → OfferCredential
                                        → crea RequestCredential
  step-5-request-credential (NO en Holder)
  Issuance:
    step-6-issue-credential.handler   → IssueCredential
                                        → crea IssuanceAck
  Presentation:
    step-4-request-presentation.handler → RequestPresentation
                                        → crea PresentProof
    step-6-ack-message.handler          → PresentationAck
                                        → callback handlePresentationAck (no responde)

Actor = Issuer:
  Issuance:
    step-3-propose-credential.handler  → ProposeCredential
                                        → crea OfferCredential (con manifest + fulfillment)
    step-5-request-credential.handler   → RequestCredential
                                        → crea IssueCredential (VC firmada)
    step-7-ack-message.handler          → IssuanceAck
                                        → callback handleIssuanceAck (no responde)

Actor = Verifier:
  Presentation:
    step-3-propose-presentation.handler → ProposePresentation
                                        → crea RequestPresentation (con PresentationDefinition)
    step-5-present-proof.handler        → PresentProof
                                        → crea PresentationAck | ProblemReport

Común a todos:
  problem-report.handler               → ProblemReport
                                        → callback handlePresentationAck (genérico)
```

Cada handler del SDK tiene dos partes:

1. **Lógica de parseo** del mensaje recibido.
2. **Llamada al callback** del actor correspondiente para resolver la lógica de negocio (qué credencial ofrecer, qué VCs presentar, firmar, etc.).

### Capa 3 — Callbacks

Los callbacks son funciones provistas por el integrador (Emisor/Verificador) que el SDK invoca en momentos clave. Definidos en `@extrimian/waci/dist/callbacks/index.d.ts`:

**Holder:**

- `getHolderDID({ message })` → qué DID usar para responder.
- `getCredentialApplication({ manifest, fulfillment, message })` → qué VCs presentar de vuelta al issuer (caso unusual: el issuer pide VCs previas).
- `getCredentialPresentation({ inputDescriptors, frame, message })` → qué VCs presentar al verifier.
- `signPresentation({ contentToSign, challenge, domain?, message? })` → firma VP con la clave del holder.
- `handleCredentialFulfillment({ credentialFulfillment, message }) → boolean` → guarda la VC recibida, devuelve `true` si la aceptó.
- `handlePresentationAck({ status, message })` → notificación de ACK o problem-report.

**Issuer:**

- `getCredentialManifest({ invitationId, holderDid, message })` → construye el manifest con la oferta de credencial.
- `signCredential({ vc, message })` → firma la credencial antes de enviarla.
- `verifyCredential(...)` → verifica una VC que el holder presentó (caso unusual).
- `verifyPresentation({ presentation, challenge })` → verifica la firma de la presentación del holder.
- `credentialVerificationResult?({ result, error, thid, vcs, message })` → callback opcional al finalizar la verificación.
- `handleIssuanceAck({ status, from, pthid, thid, message })` → confirmación de que el holder recibió la VC.

**Verifier:**

- `getPresentationDefinition({ invitationId })` → devuelve los input descriptors que quieren presentarse.
- `verifyCredential(...)` → verifica cada VC de la presentación.
- `verifyPresentation({ presentation, challenge })` → verifica la firma de la presentación.
- `credentialVerificationResult?({ result, error, thid, vcs, message })` → callback al finalizar.

---

## 3. Almacenamiento de invitaciones

El SDK necesita persistir información entre el momento en que se crea la invitación y el momento en que el holder responde. Para esto usa una interfaz `IStorage` que el integrador implementa.

En el Emisor (`/quark/waci/waci-storage.service.ts`) la implementación persiste en DB PostgreSQL (JSON column) bajo la clave `waciStorageFile` (default `waci-protocol-ws.json`):

```ts
async saveInvitationData(invitationId: string, data: any)
async getInvitationData(invitationId: string)
async add(key, data) / get(key) / update(key, data) / remove(key)
```

El Verificador (`waci-protocol-utils.ts`) usa `WACIStorageService` + `InvitationStore` en memoria:

- `InvitationStore.set(kind, invitationId, data, opts)` guarda: `{ data, sessionId, ttlMs, singleUse }`.
- `InvitationStore.has(kind, id)` chequea existencia.
- `InvitationStore.get(kind, id)` recupera + valida TTL.
- `InvitationStore.consume(kind, id)` elimina (single-use).

Esta capa de storage se usa para mapear `pthid` (ID de la invitación original) → `waciInvitationId` → `sessionId`. El bridge entre el WebSocket y el frontend del Verificador.

---

## 4. Flujo ISSUANCE completo paso a paso

### Diagrama de secuencia

```
ISSUER                    SDK WACI                HOLDER
   │                          │                      │
   │ 1. createInvitation      │                      │
   ├─────────────────────────►│                      │
   │   (Issuance)             │                      │
   │                          │                      │
   │ 2. OutOfBandInvitation   │                      │
   │◄─────────────────────────┤                      │
   │   type=.../out-of-band   │                      │
   │   body.goal_code=        │                      │
   │     "streamlined-vc"     │                      │
   │                          │                      │
   │ 3. URL didcomm://?_oob=  │                      │
   │   base64url(...)         │                      │
   ├─────────────────────────┐ │                      │
   │                          │ │ 4. User escanea QR │
   │                          │ ├────────────────────►│
   │                          │ │                      │
   │                          │ │ 5. ProposeCredential│
   │                          │◄─────────────────────┤
   │                          │ │   type=.../propose-credential/3.0
   │                          │ │   pthid=invitation.id
   │                          │ │   from=holderDID
   │                          │ │   to=[issuerDID]
   │                          │ │                      │
   │ 6. getCredentialManifest │ │                      │
   │   {invitationId,         │ │                      │
   │    holderDID, message}   │ │                      │
   ├──────────────────────────►│ │                      │
   │   ←{manifest, fulfillment,│                      │
   │      options.challenge}  │ │                      │
   │                          │ │                      │
   │ 7. OfferCredential       │ │                      │
   │◄─────────────────────────┤ │                      │
   │   type=.../offer-credential/3.0                   │
   │   thid=propose.id        │ │                      │
   │   from=issuerDID         │ │                      │
   │   to=[holderDID]         │ │                      │
   │   attachments=[manifest, │ │                      │
   │               fulfillment]                       │
   │                          │ 8. OfferCredential    │
   │                          ├──────────────────────►│
   │                          │ │   (holder arma      │
   │                          │ │    CredentialRequest │
   │                          │ │    con las VCs que  │
   │                          │ │    quiere presentar │
   │                          │ │    si el manifest   │
   │                          │ │    lo pide)          │
   │                          │ │                      │
   │                          │ │ 9. RequestCredential │
   │                          │◄─────────────────────┤
   │                          │ │   type=.../request-credential/3.0
   │                          │ │   thid=offer.id     │
   │                          │ │   from=holderDID    │
   │                          │ │   to=[issuerDID]    │
   │                          │ │   attachments=      │
   │                          │ │     [Credential-    │
   │                          │ │      Application]   │
   │                          │ │  (firmada con       │
   │                          │ │   challenge del     │
   │                          │ │   manifest)         │
   │                          │ │                      │
   │ 10. verifyCredential,    │ │                      │
   │     verifyPresentation   │ │                      │
   │     (si el issuer pidió  │ │                      │
   │      VCs previas)        │ │                      │
   ├──────────────────────────►│ │                      │
   │                          │ │                      │
   │ 11. signCredential       │ │                      │
   │     (callback firma      │ │                      │
   │      cada VC del         │ │                      │
   │      fulfillment)        │ │                      │
   ├──────────────────────────►│ │                      │
   │                          │ │                      │
   │ 12. IssueCredential      │ │                      │
   │◄─────────────────────────┤ │                      │
   │   type=.../issue-credential/3.0                  │
   │   thid=request.id        │ │                      │
   │   from=issuerDID         │ │                      │
   │   attachments=[          │ │                      │
   │     {format:             │ │                      │
   │       dif/credential-    │ │                      │
   │         manifest/        │ │                      │
   │         fulfillment@     │ │                      │
   │         v1.0,            │ │                      │
   │      data.json: {        │ │                      │
   │        verifiableCredential[ │ │                  │
   │          ...firmadas]    │ │                      │
   │     }}                   │ │                      │
   │                          │ │                      │
   │                          │ │ 13. IssueCredential  │
   │                          │ ├─────────────────────►│
   │                          │ │                      │
   │                          │ │ 14. handleCredential-│
   │                          │ │    Fulfillment      │
   │                          │ │    (callback guarda │
   │                          │ │     las VCs)         │
   │                          │ │                      │
   │                          │ │ 15. IssuanceAck      │
   │                          │◄─────────────────────┤
   │                          │ │   type=.../ack      │
   │                          │ │   thid=issue.id     │
   │                          │ │   body.status="OK"  │
   │                          │ │                      │
   │ 16. handleIssuanceAck    │ │                      │
   │    (callback emite       │ │                      │
   │     evento credentialIssued│ │                   │
   │     al integrador)       │ │                      │
   ├──────────────────────────►│ │                      │
```

### Detalle de cada paso

**Paso 1 — El Emisor crea la invitación**

En el código del Emisor (`waci-protocol.service.ts:222-226`):

```ts
const invitationMessage = await this.agent.vc.createInvitationMessage({
  flow: CredentialFlow.Issuance,
});
```

Esto invoca `WACIInterpreter.createOOBInvitation(senderDID = issuerDID, goalCode = "streamlined-vc", body)` que devuelve:

```json
{
  "type": "https://didcomm.org/out-of-band/2.0/invitation",
  "id": "<uuid>",
  "from": "<issuerDID>",
  "body": {
    "goal_code": "streamlined-vc",
    "accept": ["didcomm/v2"]
  }
}
```

Luego el Emisor codifica el mensaje como base64url y lo prepende con `didcomm://?_oob=`. Esa URL es lo que termina en el QR.

**Paso 2 — El QR contiene sólo la invitación**

El mensaje out-of-band **no incluye la oferta de credencial**. Ésta se construye dinámicamente cuando el holder responde. Esto es importante: el QR es el mismo independientemente de a quién se lo muestre.

**Paso 3-4 — El holder escanea el QR y decodifica**

El holder (wallet MIBA / Extrimian) tiene un parser del prefijo `didcomm://?_oob=`. Decodifica el base64url, parsea el JSON, e identifica que es un `out-of-band invitation` con `goal_code: "streamlined-vc"`.

**Paso 5 — El holder envía ProposeCredential**

El handler `OOBInvitationHandler` (en `step-2-oob-invitation.handler.js`) se activa cuando el holder recibe la invitación. Su lógica:

```js
const message = messageThread[messageThread.length - 1];
switch (message.body.goal_code) {
  case GoalCode.Issuance:
    responseMessageType = WACIMessageType.ProposeCredential; // → streamlined-vc
    break;
  case GoalCode.Presentation:
    responseMessageType = WACIMessageType.ProposePresentation; // → streamlined-vp
}
const holderDID = await callbacks.holder.getHolderDID({ message });
return {
  responseType: WACIMessageResponseType.CreateThread,
  message: {
    type: responseMessageType,
    id: createUUID(),
    pthid: message.id, // ← PADRE = invitación original
    from: holderDID,
    to: [message.from], // ← al issuer
  },
};
```

Esto crea un **nuevo thread** (`responseType: CreateThread`). El `pthid` del nuevo thread es el `id` de la invitación original.

Antes de generar este mensaje, el SDK llama al callback `getHolderDID` que el holder implementó. Le pasa el mensaje recibido y espera un DID. El holder normalmente devuelve su DID principal.

**Paso 6 — El issuer construye el manifest**

Cuando el SDK del issuer recibe el `ProposeCredential`, activa `ProposeCredentialHandler` (en `step-3-propose-credential.handler.js`). Éste llama al callback `getCredentialManifest({ invitationId: message.pthid, holderDID: message.from, message })`.

**Lo que hace el Emisor en este callback** (`waci-protocol.service.ts:142-184`):

```ts
issueCredentials: async (waciInvitationId: string, holderId: string) => {
  const invitationData =
    await this.waciStorageService.getInvitationData(waciInvitationId); // Recupera {structureData, dynamicData, expiresAt}

  // Valida expiración del QR

  const credential = this.createGenericVC(
    // Construye el manifest
    invitationData.credentialData, //   con structureData + dynamicData
    this.agent.identity.getOperationalDID().value,
    holderId,
  );

  return new WACICredentialOfferSucceded(credential);
};
```

La función `createGenericVC` (líneas 329-415) construye el `WACICredentialOfferSucceded` con:

- `options.challenge` (UUID) + `options.domain` (default `"generic-issuer.com"`).
- `issuer`: `{ name, styles: { thumbnail, hero, text, background } }`.
- `credentials[]`: cada VC con su `credential` + `outputDescriptor`:
  - `credential`: JSON-LD con `@context`, `type: ["VerifiableCredential", "GenericCredential"]`, `issuer: { name, id }`, `issuanceDate`, `credentialSubject: { id: holderDid, type: 'Person', ...dynamicData }`.
  - `outputDescriptor`: schema, display (title/subtitle/description/properties), styles.

**Paso 7 — El issuer envía OfferCredential**

Con el resultado del callback, `ProposeCredentialHandler.createMessage()` (en step-3) construye dos adjuntos:

**Attachment 1: Credential Manifest** (`dif/credential-manifest/manifest@v1.0`)

```json
{
  "options": { "challenge": "<uuid>" },
  "credential_manifest": {
    "id": "<uuid>",
    "version": "0.1.0",
    "issuer": { "id": "<issuerDID>", "name": "...", "styles": {...} },
    "presentation_definition": {                  // ← sólo si hay input (VCs previas requeridas)
      "id": "<uuid>",
      "input_descriptors": [...],
      "frame": {...}
    },
    "output_descriptors": [
      { "id": "...", "schema": "...", "display": {...}, "styles": {...} },
      ...
    ]
  }
}
```

**Attachment 2: Credential Fulfillment (template)** (`dif/credential-manifest/fulfillment@v1.0`)

```json
{
  "@context": [
    "https://extrimian.blob.core.windows.net/rskec/credentialsv1.jsonld",
    "https://extrimian.blob.core.windows.net/rskec/credential-manifestfulfillmentv1.jsonld"
  ],
  "type": ["VerifiablePresentation", "CredentialFulfillment"],
  "credential_fulfillment": {
    "id": "<uuid>",
    "manifest_id": "<id del manifest>",
    "descriptor_map": [
      {
        "id": "<output.id>",
        "format": "ldp_vp",
        "path": "$.verifiableCredential[0]"
      }
    ]
  },
  "verifiableCredential": [] // ← vacío por ahora, se llena en issue
}
```

El envelope del mensaje:

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/offer-credential",
  "id": "<uuid>",
  "thid": "<proposeCredential.id>",
  "from": "<issuerDID>",
  "to": ["<holderDID>"],
  "body": {},
  "attachments": [manifest, fulfillmentTemplate]
}
```

**Paso 8-9 — El holder prepara la respuesta**

El handler `OfferCredentialHandler` (en `step-4-offer-credential.handler.js`) del holder se activa. Identifica el manifest y el fulfillmentTemplate. Si el manifest tiene `presentation_definition` (input descriptors), significa que el issuer requiere VCs previas antes de emitir la nueva.

Flujo:

1. Llama al callback `getCredentialApplication({ manifest, fulfillment, message })` que devuelve `{ credentialsToPresent, presentationProofTypes }`. **En el flujo streamlined-vc estándar (sin input descriptors requeridos), esto puede devolver vacío.**
2. Construye un `Credential Application` con la presentation_definition (si existe) y la firma con `signPresentation({ contentToSign, challenge: manifest.options.challenge, message })`.
3. Envía `RequestCredential` con `attachments: [CredentialApplication]`.

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/request-credential",
  "id": "<uuid>",
  "thid": "<offerCredential.id>",
  "from": "<holderDID>",
  "to": ["<issuerDID>"],
  "body": {},
  "attachments": [
    {
      "id": "<uuid>",
      "media_type": "application/json",
      "format": "dif/credential-manifest/application@v1.0",
      "data": {
        "json": {
          "@context": [
            "https://extrimian.blob.core.windows.net/rskec/securityv1.jsonld",
            "https://extrimian.blob.core.windows.net/rskec/credentialsv1.jsonld",
            "https://extrimian.blob.core.windows.net/rskec/credential-manifestapplicationv1.jsonld"
          ],
          "type": ["VerifiablePresentation", "CredentialApplication"],
          "credential_application": {
            "id": "<uuid>",
            "manifest_id": "<manifestId>",
            "format": {
              "ldp_vc": { "proof_type": ["<BbsBlsSignature2020|Ed25519>"] }
            }
          },
          "presentation_submission": {
            "id": "<uuid>",
            "definition_id": "<presentation_definition.id>",
            "descriptor_map": [{...}]
          },
          "verifiableCredential": [...],
          "proof": {
            "type": "...",
            "verificationMethod": "...",
            "created": "...",
            "proofPurpose": "...",
            "challenge": "...",
            "jws": "..."
          }
        }
      }
    }
  ]
}
```

**Paso 10 — El issuer verifica la solicitud**

`RequestCredentialHandler` (en `step-5-request-credential.handler.js`) del issuer:

1. Busca el `OfferCredential` original en el thread (filtrando por type).
2. Filtra los manifests que tienen `presentation_definition`.
3. Para cada `manifest` con `presentation_definition`, busca el application correspondiente en el mensaje actual (por `manifest_id`).
4. Si todas las applications están presentes, llama `verifyCredential` y `verifyPresentation` (callbacks del issuer) para validar la firma del holder.
5. Si la verificación pasa, sigue; si no, devuelve un `ProblemReport`.

**Paso 11-12 — El issuer firma y emite**

Si todo OK, `RequestCredentialHandler` itera sobre los `fulfillments` del OfferCredential original. Para cada uno:

1. Llama al callback `signCredential({ vc, message })` para obtener la VC firmada (con `BbsBlsSignature2020` por defecto).
2. Construye un nuevo attachment fulfillment con las VCs firmadas dentro.

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/issue-credential",
  "id": "<uuid>",
  "thid": "<requestCredential.id>",
  "from": "<issuerDID>",
  "to": ["<holderDID>"],
  "body": {},
  "attachments": [
    {
      "id": "<uuid>",
      "media_type": "application/json",
      "format": "dif/credential-manifest/fulfillment@v1.0",
      "data": {
        "json": {
          "@context": [...],
          "type": ["VerifiablePresentation", "CredentialFulfillment"],
          "credential_fulfillment": {...},
          "verifiableCredential": [
            { /* VC firmada con BbsBlsSignature2020 */ }
          ]
        }
      }
    }
  ]
}
```

En el callback del Emisor (`signCredential`), la firma se hace con la clave privada del DID operacional del agente. La VC firmada queda con `proof.proofPurpose = "assertionMethod"` y `proof.type = "BbsBlsSignature2020"`.

**Paso 13-14 — El holder recibe y guarda**

`IssueCredentialHandler` (en `step-6-issue-credential.handler.js`) del holder:

1. Llama al callback `handleCredentialFulfillment({ credentialFulfillment, message }) → boolean`.
2. El holder guarda la VC en su wallet (validando firma, formato, schema).
3. Si devuelve `false`, el handler responde con un `ProblemReport` (`"Holder did not accept the credential"`).
4. Si devuelve `true`, sigue.

**Paso 15-16 — El holder envía ACK**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/ack",
  "id": "<uuid>",
  "thid": "<issueCredential.id>",
  "from": "<holderDID>",
  "to": ["<issuerDID>"],
  "body": { "status": "OK" }
}
```

`IssuanceAckMessageHandler` (en `step-7-ack-message.handler.js`) del issuer:

1. Llama al callback `handleIssuanceAck({ status, from, pthid, thid, message })`.
2. **No responde** con ningún mensaje. Es el final del flujo.

En el Emisor actual (`agent.service.ts:270-296`), este callback está conectado al evento `agent.vc.credentialIssued` del SDK, que dispara `updateCredentialStatusOnIssued(invitationId, vc)` y notifica al frontend por Socket.IO.

---

## 5. Flujo PRESENTATION completo paso a paso

### Diagrama de secuencia

```
VERIFIER                  SDK WACI                  HOLDER
   │                          │                      │
   │ 1. createInvitation      │                      │
   ├─────────────────────────►│                      │
   │   (Presentation)         │                      │
   │                          │                      │
   │ 2. OutOfBandInvitation   │                      │
   │◄─────────────────────────┤                      │
   │   body.goal_code=        │                      │
   │     "streamlined-vp"     │                      │
   │                          │                      │
   │ 3. URL didcomm://?_oob=  │                      │
   ├─────────────────────────┐ │                      │
   │                          │ │ 4. Holder escanea QR│
   │                          │ ├────────────────────►│
   │                          │ │                      │
   │                          │ │ 5. ProposePresentation
   │                          │◄─────────────────────┤
   │                          │ │   pthid=invitation.id
   │                          │ │   from=holderDID    │
   │                          │ │   to=[verifierDID]  │
   │                          │ │                      │
   │ 6. getPresentationDef   │ │                      │
   │   {invitationId}         │ │                      │
   ├──────────────────────────►│ │                      │
   │   ←{inputDescriptors,    │ │                      │
   │      frame}              │ │                      │
   │                          │ │                      │
   │ 7. RequestPresentation   │ │                      │
   │◄─────────────────────────┤ │                      │
   │   attachments=[PD]       │ │                      │
   │                          │ │                      │
   │                          │ │ 8. RequestPresentation
   │                          │ ├─────────────────────►│
   │                          │ │                      │
   │                          │ │ 9. getCredentialPresentation
   │                          │ │    (callback muestra │
   │                          │ │     al usuario qué  │
   │                          │ │     VCs matchean)   │
   │                          │ │                      │
   │                          │ │ 10. signPresentation│
   │                          │ │     (firma VP con   │
   │                          │ │      challenge del  │
   │                          │ │      PD)            │
   │                          │ │                      │
   │                          │ │ 11. PresentProof    │
   │                          │◄─────────────────────┤
   │                          │ │   attachments=[VP]  │
   │                          │ │                      │
   │ 12. verifyPresentation   │ │                      │
   │     verifyCredential     │ │                      │
   │     (por cada VC del     │ │                      │
   │      descriptor_map)     │ │                      │
   ├──────────────────────────►│ │                      │
   │                          │ │                      │
   │ 13. credentialVerificationResult│                │
   │    callback ({result,    │ │                      │
   │      thid, vcs, message})│ │                      │
   │   → Guarda en DB         │ │                      │
   │   → Notifica por WS      │ │                      │
   ├──────────────────────────►│ │                      │
   │                          │ │                      │
   │ 14. PresentationAck      │ │                      │
   │◄─────────────────────────┤ │                      │
   │   body.status="OK"       │ │                      │
   │                          │ │                      │
   │                          │ │ 15. handlePresentationAck│
   │                          │ │     (callback del   │
   │                          │ │      holder notifica│
   │                          │ │      al usuario)    │
```

### Detalle de cada paso

**Paso 1-5 — Idéntico al flujo Issuance**, salvo que:

- `flow: CredentialFlow.Presentation` en `createInvitationMessage`.
- `body.goal_code: "streamlined-vp"`.
- El holder responde con `ProposePresentation` (no `ProposeCredential`).

**Paso 6 — El verifier construye la PresentationDefinition**

`ProposePresentationHandler` (en `step-3-propose-presentation.handler.js`):

```js
const message = messageThread[messageThread.length - 1];
const holderDID = message.from;
const verifierDID = message.to[0];
const invitationId = message.pthid;

const { inputDescriptors, frame } =
  await callbacks.verifier.getPresentationDefinition({ invitationId });
```

**En el Verificador actual** (`waci-protocol-utils.ts:368-443`), el callback arma una `PresentationDefinition` con `format: { ldp_vc: { proof_type: ['BbsBlsSignature2020'] } }`, `inputDescriptors[]` con `constraints.fields[]` que filtran por `$.type` y `$.issuer.id`, y `submissionRequirements[]` con `rule: 'pick'`.

**En el Emisor (caso "validar identidad del emisor por trusted issuers")** (`waci-protocol.service.ts:188-202`):

```ts
verifier: {
  presentationDefinition: async () => ({
    format: this.getProofFormatFromWACIData(),
    inputDescriptors: [
      {
        id: this.waciData?.idRequested || "generic-credential-card",
        name: this.waciData?.credentialRequested || "GenericCredential",
        constraints: { fields: this.getFieldsFromWACIData() },
      },
    ],
  });
}
```

**Paso 7 — El verifier envía RequestPresentation**

```json
{
  "type": "https://didcomm.org/present-proof/3.0/request-presentation",
  "id": "<uuid>",
  "thid": "<proposePresentation.id>",
  "from": "<verifierDID>",
  "to": ["<holderDID>"],
  "body": {},
  "attachments": [{
    "id": "<uuid>",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/definitions@v1.0",
    "data": {
      "json": {
        "options": { "challenge": "<uuid>" },
        "presentation_definition": {
          "id": "<uuid>",
          "input_descriptors": [...],
          "frame": {...}
        }
      }
    }
  }]
}
```

**Paso 8-10 — El holder arma la presentación**

`RequestPresentationHandler` (en `step-4-request-presentation.handler.js`):

1. Parsea el `presentation_definition` y el `challenge` del attachment.
2. Llama al callback `getCredentialPresentation({ inputDescriptors, frame, message })` → devuelve `credentialsToPresent` (las VCs que el holder tiene y satisfacen los input descriptors — el usuario las seleccionó previamente).
3. Construye el message data:

```json
{
  "@context": [
    "https://extrimian.blob.core.windows.net/rskec/securityv1.jsonld",
    "https://extrimian.blob.core.windows.net/rskec/credentialsv1.jsonld",
    "https://extrimian.blob.core.windows.net/rskec/presentation-exchangesubmissionv1.jsonld"
  ],
  "type": ["VerifiablePresentation", "PresentationSubmission"],
  "holder": "<holderDID>",
  "presentation_submission": {
    "id": "<uuid>",
    "definition_id": "<PD.id>",
    "descriptor_map": [
      { "id": "<descriptor.id>", "format": "ldp_vp", "path": "$.verifiableCredential[0]" }
    ]
  },
  "verifiableCredential": [...]
}
```

4. Llama a `signPresentation({ contentToSign, challenge, message })` para firmar el message data. El callback devuelve el message firmado con `proof.jws`.

5. Empaqueta en un attachment con `media_type: "application/ld+json"`, `format: "dif/presentation-exchange/submission@v1.0"`.

**Paso 11 — El holder envía PresentProof**

```json
{
  "type": "https://didcomm.org/present-proof/3.0/presentation",
  "id": "<uuid>",
  "thid": "<requestPresentation.id>",
  "from": "<holderDID>",
  "to": ["<verifierDID>"],
  "body": {},
  "attachments": [
    {
      "id": "<uuid>",
      "media_type": "application/ld+json",
      "format": "dif/presentation-exchange/submission@v1.0",
      "data": {
        "json": {
          /* presentación firmada */
        }
      }
    }
  ]
}
```

**Paso 12 — El verifier verifica**

`PresentProofHandler` (en `step-5-present-proof.handler.js`) del verifier:

1. Parsea la presentación.
2. Llama a `verifyPresentation({ presentation, challenge }) → { result, error }`. Si la firma es inválida, devuelve `ProblemReport`.
3. Si pasa, busca los `submissions` correspondientes a las `presentation_definition` que envió (por `definition_id`).
4. Para cada submission, llama a `verifyPresentation(pd, submission, verifyCredential)` (función interna del SDK que itera sobre cada descriptor y verifica cada VC apuntada por `descriptor_map.path`).
5. Va acumulando VCs verificadas en `vcs[]` y `result`.
6. Si todo verifica, llama al callback `credentialVerificationResult({ result: true, error: null, thid, vcs, message })`.

**En el Verificador actual** (`agent.service.ts:81-183`), ese callback está conectado al evento `agent.vc.presentationVerified`. Cuando dispara:

```ts
// 1. Resuelve sessionId desde waciInvitationId (vía storage + InvitationStore)
const waciId = (await wps.getStorage().get(thid))?.[0]?.pthid;
const { sessionId } = await invites.get("verify", waciId);

// 2. Guarda las VCs en Redis para visualización
await visualizationService.storeVisualizationData(sessionId, args.vcs);

// 3. Registra la verificación en la tabla 'verificaciones'
const estado = args.verified ? "exitosa" : "fallida";
await verificacionesService.registrarVerificacion(estado, {
  nombreVC: args.vcs[0].type,
  emisorDID: args.vcs[0].issuer.id,
  invitationId: waciId,
  sessionId,
});

// 4. Notifica al frontend por Socket.IO
await ws.notify(sessionId, { status: "success" });
```

**Paso 13-14 — El verifier responde con ACK o ProblemReport**

Si todo OK:

```json
{
  "type": "https://didcomm.org/present-proof/3.0/ack",
  "id": "<uuid>",
  "thid": "<presentProof.id>",
  "from": "<verifierDID>",
  "to": ["<holderDID>"],
  "body": { "status": "OK" }
}
```

Si hay error en cualquier paso:

```json
{
  "type": "https://didcomm.org/report-problem/2.0/problem-report",
  "id": "<uuid>",
  "thid": "<presenteProof.id>",
  "from": "<verifierDID>",
  "to": ["<holderDID>"],
  "body": {
    "code": "<error.code>",
    "comment": "<error.description>"
  }
}
```

**Paso 15 — El holder recibe el ACK**

`PresentationAckMessageHandler` (en `step-6-ack-message.handler.js`) del holder:

1. Llama al callback `handlePresentationAck({ status, message })`.

Si el status es `OK`, el holder sabe que la verificación fue exitosa. Si es un `ProblemReport`, sabe que falló y puede mostrar el error al usuario.

---

## 6. Eventos del SDK Extrimian

El SDK expone eventos al integrador (Emisor/Verificador/wallet) en `vc-protocol.d.ts:13-84`:

| Evento                 | Cuándo se dispara                                            | Datos                                                        |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `vcArrived`            | Lado Holder: cuando llega una VC de un issue-credential      | `{credentials, issuer, messageId}`                           |
| `credentialIssued`     | Lado Issuer: cuando recibe el ACK del Holder                 | `{vc, toDID, invitationId}`                                  |
| `vcVerified`           | Lado Issuer/Verifier: cuando verifica una VC individualmente | `{verified, presentationVerified, vc}`                       |
| `presentationVerified` | Lado Verifier: cuando TODA la presentación fue verificada    | `{verified, vcs, thid, invitationId, rejectMsg?, messageId}` |
| `ackCompleted`         | Cuando llega ACK o ProblemReport de cualquier flujo          | `{role: ActorRole, status, messageId, thid, invitationId?}`  |
| `problemReport`        | Cuando llega un ProblemReport                                | `{did, code, invitationId, messageId}`                       |

Estos eventos son los que conectan el SDK con el código del integrador. En el Emisor, `agent.service.ts:270-296` conecta `credentialIssued`, `problemReport`, `presentationVerified`, `credentialPresented`, `credentialArrived`, `ackCompleted`. En el Verificador, `agent.service.ts:69-241` conecta los mismos.

---

## 7. Diferencias clave del flujo Issuance vs Presentation

| Aspecto                                                         | Issuance                                                                 | Presentation                                                                  |
| --------------------------------------------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| `goal_code`                                                     | `streamlined-vc`                                                         | `streamlined-vp`                                                              |
| Respuesta del holder a OOB                                      | `ProposeCredential`                                                      | `ProposePresentation`                                                         |
| Adjuntos del issuer/verifier                                    | `Credential Manifest` + `Credential Fulfillment (template)`              | `Presentation Definition` (con `input_descriptors` + `format`)                |
| Adjuntos del holder                                             | `Credential Application` (firmada, con `verifiableCredential[]` previas) | `Presentation Submission` (firmada, con `verifiableCredential[]` a presentar) |
| Callback `getCredentialManifest` vs `getPresentationDefinition` | Construye el manifest                                                    | Construye el PD                                                               |
| Callback `signCredential` vs `signPresentation`                 | Firma cada VC del fulfillment                                            | Firma el VP completo                                                          |
| Mensaje final del holder                                        | `ack` con `body.status: "OK"`                                            | `ack` con `body.status: "OK"`                                                 |
| Estado de éxito                                                 | `credentialIssued` + `ackCompleted` (issuer) / `vcArrived` (holder)      | `presentationVerified` (verifier) + `ackCompleted` (holder)                   |

---

## 8. Persistencia de invitaciones en WACI

Durante el flujo, el SDK mantiene estado en dos lugares:

**Capa 1 — Storage de protocolo (`IStorage`)**

Lo usa el SDK para:

- Guardar mensajes recibidos (con `pthid` como clave) hasta que llega el siguiente mensaje del thread.
- Rastrear `thid` ↔ `pthid` cuando llegan mensajes fuera de orden.

En el Emisor: `waci-storage.service.ts` persiste en PostgreSQL (JSON column).
En el Verificador: `waci-storage.service.ts` persiste en FS (`waci-protocol-ws.json`).

**Capa 2 — Storage de aplicación**

Lo usa el integrador para guardar contexto de negocio:

- Qué credencial se emite para esa invitación.
- Quién es el holder (DID).
- Cuándo expira la invitación.
- Sesión de UI (sessionId, streamUrl, etc.).

En el Emisor: tabla `credential` con campos `invitationId`, `structureData`, `status`, `expiresAt`.
En el Verificador: `InvitationStore` (memoria) + tabla `verificaciones` + tabla `validaciones` + Redis para visualización.

---

## 9. Resumen del ciclo completo

### Issuance (5 mensajes + 1 ACK)

```
Issuer                    Holder
  │                          │
  │──(1) OOB Invitation────►│   [goal_code: streamlined-vc]
  │                          │
  │◄─(2) ProposeCredential──│   [pthid=1.id]
  │                          │
  │──(3) OfferCredential────►│   [thid=2.id, attachments: Manifest + Fulfillment template]
  │                          │
  │◄─(4) RequestCredential──│   [thid=3.id, attachments: Credential Application firmada]
  │                          │
  │──(5) IssueCredential────►│   [thid=4.id, attachments: Fulfillment con VCs firmadas]
  │                          │
  │◄─(6) IssuanceAck────────│   [thid=5.id, body.status="OK"]
  │                          │
 [FIN]
```

### Presentation (5 mensajes + 1 ACK)

```
Verifier                  Holder
  │                          │
  │──(1) OOB Invitation────►│   [goal_code: streamlined-vp]
  │                          │
  │◄─(2) ProposePresentation│   [pthid=1.id]
  │                          │
  │──(3) RequestPresentation►   [thid=2.id, attachments: Presentation Definition]
  │                          │
  │◄─(4) PresentProof───────│   [thid=3.id, attachments: Presentation Submission firmada]
  │                          │
  │──(5) PresentationAck────►│   [thid=4.id, body.status="OK"]
  │                          │
 [FIN]
```

Ambas variantes comparten los pasos 1, 2, 4 (request), y 5 (ack). Lo que cambia entre Issuance y Presentation es el contenido de los attachments en los mensajes 3 (offer/PD) y 4 (request/present), y la cantidad de adjuntos en 5 (issue lleva VCs, request-presentation no lleva nada más).

---

## 10. Implicancia para el bridge con la wallet Quark2.0

Para hacer un bridge que permita a la wallet Quark participar en estos flujos hay que traducir **cada uno de estos mensajes WACI a su equivalente DIDComm v2/DIF-PEX estándar**:

| Mensaje WACI                                                                                | Mensaje DIDComm v2 estándar                                                                                                      |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `out-of-band/2.0/invitation` con `goal_code: streamlined-vc`                                | `out-of-band/2.0/invitation` con `goal_code: "issue-vc"` + body `attachment[0].data.json: issue-credential/2.0/offer-credential` |
| `issue-credential/3.0/propose-credential`                                                   | `issue-credential/2.0/propose-credential` (opcional, el streamlined flow puede saltearlo)                                        |
| `issue-credential/3.0/offer-credential` con `attachments: [Manifest, Fulfillment template]` | `issue-credential/2.0/offer-credential` con `attachments: [offers~attach]` y `body.comment`                                      |
| `issue-credential/3.0/request-credential`                                                   | `issue-credential/2.0/request-credential`                                                                                        |
| `issue-credential/3.0/issue-credential`                                                     | `issue-credential/2.0/issue-credential` con `credentials~attach`                                                                 |
| `present-proof/3.0/propose-presentation`                                                    | `present-proof/2.0/propose-presentation` (opcional)                                                                              |
| `present-proof/3.0/request-presentation` con `attachments: [PresentationDefinition]`        | `present-proof/2.0/request-presentation` con `attachment[0].data.json: dif/presentation-exchange/definitions@v1.0` (PEX puro)    |
| `present-proof/3.0/presentation` con `attachments: [PresentationSubmission]`                | `present-proof/2.0/presentation` con `attachment[0].data.json: dif/presentation-exchange/submission@v1.0`                        |
| `present-proof/3.0/ack` / `issue-credential/3.0/ack`                                        | `ack` (igual)                                                                                                                    |

El bridge tendría que interceptar a nivel de transporte (Socket.IO), decodificar el mensaje WACI, transformar al formato DIF/Quark, reenviar por HTTP/WS nativo a la wallet Credo, y viceversa.

---

**Fin del documento**
