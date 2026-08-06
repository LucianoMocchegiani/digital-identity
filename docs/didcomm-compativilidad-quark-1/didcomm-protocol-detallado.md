# Protocolo DIDComm v2 (RFC 0036/0037/0023): funcionamiento detallado manejado por Credo en Quark2.0

**Versión:** 1.0
**Fecha:** 2026-06-26
**Fuentes analizadas:**
- `@credo-ts/didcomm` (RFCs 0036, 0037, 0023, 0168 — out-of-band)
- `@credo-ts/didcomm` módulos `V2Protocol` + `JsonLdCredentialFormatService` + `DifPresentationExchangeProofFormatService`
- Wrappers y listeners propios en `quark/packages/identity-core/src/protocol/didcomm/`
- Servicios HTTP en `quark/quark-{issuer,holder,verifier}-service/source/src/didcomm/`
- Wallet Flutter en `quark/quark-wallet/lib/features/protocol_flows/didcomm/`
- Paquete Dart `identity-core-dart/lib/src/protocol/didcomm/`

---

## 1. Qué es DIDComm v2 y cómo Credo lo implementa

DIDComm v2 es el protocolo estándar mantenido por el Decentralized Identity Foundation (DIF). Define tres RFCs principales:

- **RFC 0023** — Out-of-Band protocol (mensajes handshake iniciales para establecer conexión + adjuntar protocolos de aplicación).
- **RFC 0036** — Issue Credential (intercambio de credenciales, 4-5 mensajes: proposal → offer → request → issue → ack).
- **RFC 0037** — Present Proof (presentación de prueba, 4-5 mensajes: proposal → request → presentation → ack).

Credo es una de las principales implementaciones de referencia. En Quark2.0, los tres servicios NestJS (`quark-issuer-service`, `quark-holder-service`, `quark-verifier-service`) y la wallet Flutter usan Credo como su motor DIDComm. Los wrappers en `identity-core` exponen una API más delgada y multi-tenant sobre Credo.

### Diferencia clave vs WACI

WACI **reutiliza los message types de DIDComm v2 pero fusiona cada paso del protocolo con un callback de negocio**, de modo que cada actor ejecuta request+response en una sola operación. DIDComm v2 separa claramente la fase de conexión (establecer un `connection` con `did:peer` y `serviceEndpoint`), la fase de propuesta-offer, y la fase de entrega. El emisor espera activamente las respuestas del holder en cada paso; el flujo se pausa entre cada intercambio hasta que el usuario del wallet aprueba la siguiente acción.

### Message types usados por Credo (v2)

Definidos como constantes en `@credo-ts/didcomm`:

```ts
// RFC 0023 (Out-of-band)
'https://didcomm.org/out-of-band/2.0/invitation'

// RFC 0168 (Connection Protocol también llamado DIDExchange en v2)
'https://didcomm.org/didexchange/2.0/request'
'https://didcomm.org/didexchange/2.0/response'
'https://didcomm.org/didexchange/2.0/ack'
'https://didcomm.org/didexchange/2.0/complete'
'https://didcomm.org/didexchange/2.0/problem-report'

// RFC 0036 (Issue Credential v2.0)
'https://didcomm.org/issue-credential/2.0/propose-credential'
'https://didcomm.org/issue-credential/2.0/offer-credential'
'https://didcomm.org/issue-credential/2.0/request-credential'
'https://didcomm.org/issue-credential/2.0/issue-credential'
'https://didcomm.org/issue-credential/2.0/ack'
'https://didcomm.org/issue-credential/2.0/problem-report'

// RFC 0037 (Present Proof v2.0)
'https://didcomm.org/present-proof/2.0/propose-presentation'
'https://didcomm.org/present-proof/2.0/request-presentation'
'https://didcomm.org/present-proof/2.0/presentation'
'https://didcomm.org/present-proof/2.0/ack'
'https://didcomm.org/present-proof/2.0/problem-report'
```

Note que las versiones son `2.0` (vs `3.0` en WACI). Quark configura:
```ts
protocolVersion: 'v2'
```
en cada `offerCredential`, `proposeCredential`, `requestProof`, etc.

---

## 2. Arquitectura interna: cómo Credo encapsula DIDComm

### 2.1 Protocol state machines

Credo implementa cada RFC como una **state machine** que vive en una **clase protocolo** (`DidCommCredentialV2Protocol`, `DidCommProofV2Protocol`, `DidCommDIDExchangeProtocol`, `DidCommOutOfBandProtocol`) y produce registros de estado persistidos (`DidCommCredentialExchangeRecord`, `DidCommProofExchangeRecord`, `DidCommConnectionRecord`, `OutOfBandRecord`).

El holder, issuer y verifier exponen APIs que disparan transiciones:

```ts
// Issuer (side, in @credo-ts/didcomm)
agent.didcomm.credentials.offerCredential({...})           // → state: 'offer-sent'
agent.didcomm.credentials.negotiateProposal({...})        // → state: 'offer-sent' (con negotiation)
agent.didcomm.credentials.acceptProposal({...})           // → state: 'offer-sent'
agent.didcomm.credentials.acceptRequest({...})            // → state: 'credential-issued'

// Holder
agent.didcomm.credentials.proposeCredential({...})        // → state: 'proposal-sent'
agent.didcomm.credentials.acceptOffer({...})              // → state: 'request-sent'
agent.didcomm.credentials.acceptCredential({...})         // → state: 'done'

// Verifier
agent.didcomm.proofs.requestProof({...})                  // → state: 'request-sent'
agent.didcomm.proofs.acceptPresentation({...})           // → state: 'done'

// Holder (proof)
agent.didcomm.proofs.selectCredentialsForRequest({...})   // → resuelve PEX
agent.didcomm.proofs.acceptRequest({...})                 // → state: 'presentation-sent'
```

Cada llamada escribe un registro en disco, envía el mensaje al destino (cifrado), y luego se reactiva cuando llega la respuesta disparando el evento `DidCommCredentialStateChanged` o `ProofStateChanged`.

### 2.2 Listeners reactivos

Credo es **event-driven**. La lógica reactiva que dice "cuando el issuer reciba un propose-credential, envíame un offer" se implementa en listeners sobre `agent.events`. En Quark2.0 esos listeners viven en:

- `issuer.listener.ts` — escucha `DidCommCredentialStateChanged` y reacciona a `ProposalReceived`, `RequestReceived`, `Done`.
- `holder.listener.ts` — escucha `DidCommCredentialStateChanged` y `ProofStateChanged`, reacciona a `OfferReceived`, `CredentialReceived`, `RequestReceived`.
- `verifier.listener.ts` — escucha `ProofStateChanged`, reacciona a `PresentationReceived`.
- `shared.listener.ts` — define `setupMessageListeners` y `setupConnectionListeners` (logs).
- `findTenantIdForRecord` — función auxiliar que itera los tenants para resolver a qué wallet pertenece un record (necesario porque el root agent registra los listeners una sola vez para todos los tenants).

### 2.3 Mensajería y transporte

Mensajes DIDComm v2 son **JWE compactos**: JSON cifrado en ECDH-ES+A256KW/A256GCM (authcrypt). Credo usa `@stablelib/jose` o `jsonwebtoken` (depende del runtime) para cifrar/descifrar. Los `recipientKeys` del emisor se distribuyen a través del out-of-band invitation.

Transportes disponibles (configurados en `issuer.agent.ts`, `holder.agent.ts`, `verifier.agent.ts`):

- **`DidCommHttpInboundTransport`** — escucha HTTP POST en `/didcomm` (configurable).
- **`DidCommHttpOutboundTransport`** — envía por HTTP POST.
- **`DidCommWsInboundTransport`** — escucha por WebSocket en un `ws` server (mismo server del Express o uno independiente).
- **`DidCommWsOutboundTransportDelayedClose`** — extiende `DidCommWsOutboundTransport` de Credo; después de `send()` espera `closeDelayMs` (default 10 s) antes de cerrar el socket. Necesario porque Credo cierra inmediatamente tras `send()`, y la contraparte puede no recibir el mensaje antes.
- **Mediator / mediationRecipient: false** — Quark **no** usa mediator. Se apaga explícitamente.

En el nivel de mensajes, cada invocación `offerCredential(...)` se traduce a:
1. Resolver el `connectionId` → obtener `theirDid`, `theirKey`, `theirEndpoint` del `DidCommConnectionRecord`.
2. Construir el mensaje JSON-LD con el attachment correspondiente.
3. Empaquetar JWE (ECDHE-1PU entre holder e issuer) autenticado por sender + recipient.
4. Enviar al `serviceEndpoint` del destinatario (HTTP POST o WS message).
5. Disparar el evento entrante si la respuesta es exitosa.

En Quark2.0 se configuran ambos transports de salida (HTTP y WS) y se prefiere HTTP si está disponible.

### 2.4 Multi-tenant y por qué existe `findTenantIdForRecord`

Un solo **root agent** (proceso NestJS) puede mantener N tenants (wallets). Cada tenant tiene su propio agente Credo aislado (`withTenant(rootAgent, tenantId, callback)` crea un sub-agente con su propio DID, storage, eventos). Sin embargo **los listeners se registran una sola vez en el root agent** y reciben eventos de TODOS los tenants. Para ejecutar operaciones sobre el record correcto, `findTenantIdForRecord` itera los tenants y devuelve el `tenantId` que contiene ese record.

`withWallet(walletId, callback)` (en `agent-store.ts`) hace `tenantMap.get(walletId) → tenantId` y luego `withTenant(rootAgent, tenantId, callback)`.

---

## 3. RFC 0023 + RFC 0168: Out-of-Band + DIDExchange (el handshake inicial)

### Diagrama de secuencia

```
Issuer                              Holder
   │                                   │
   │ (1) issuer crea OOB invitation    │
   │     con URL `https://...:didcomm  │
   │     endpoint` + recipientKey      │
   │                                   │
   │ (2) Holder escanea QR/deeplink    │
   │                                   │
   │ (3) Holder genera `did:peer:2`   │
   │     y construye DIDExchange       │
   │     Request                       │
   │                                   │
   │ (4) DIDExchange Request ────────►│
   │     (transport cifrado JWE)       │
   │                                   │
   │ (5) Issuer verifica request,      │
   │     crea ConnectionRecord,        │
   │     genera DIDExchange Response   │
   │                                   │
   │ (6) DIDExchange Response ◄───────│
   │                                   │
   │ (7) Holder verifica response,     │
   │     crea ConnectionRecord,        │
   │     envía DIDExchange Ack         │
   │                                   │
   │ (8) DIDExchange Ack ────────────►│
   │                                   │
   │     → state = "Completed"         │
   │     en ambos lados                 │
```

### Detalle de cada paso

**Paso 1 — Issuer crea invitación OOB (`POST /issuers/{walletId}/didcomm/create-invitation`)**

El emisor (servicio NestJS `quark-issuer-service`) hace:
```ts
const { invitationUrl, outOfBandRecord } = await createInvitation(agent, { domain })
```

`createInvitation` envuelve Credo:
```ts
const outOfBandRecord = await didcomm.oob.createInvitation()
const invitationUrl = outOfBandRecord.outOfBandInvitation.toUrl({ domain })
```

`outOfBandInvitation` es un envelope JWE cifrado con `from` del issuer y sus `recipientKeys`. El handshake attachment va embebido:

```json
{
  "type": "https://didcomm.org/out-of-band/2.0/invitation",
  "id": "<uuid>",
  "from": "<issuerDID>",
  "body": {
    "goal_code": "streamlined-vc"      // ← opcional; sin esto, es conexión genérica
  },
  "attachments": [{
    "id": "request-0",
    "media_type": "application/didcomm-plain+json",
    "data": {
      "json": {
        "@type": "https://didcomm.org/didexchange/2.0/request",
        "@id": "<uuid>",
        "from": "<issuerDID>",
        "goal_code": "streamlined-vc"
      }
    }
  }]
}
```

La URL final es:
```
https://example.com?oob=eyJ...<base64>
```
o bien con el nuevo formato base64url: `?_oob=...`. `normalizeInvitationUrl` en `identity-core/src/protocol/didcomm/invitation.ts:49-53` acepta ambas variantes.

Credo actualmente **no adjunta el `offer-credential`** en el OOB. El primer paso es siempre el handshake de conexión (DIDExchange). La oferta de credencial llegará después, una vez establecida la conexión.

**Paso 2 — Holder escanea el QR / abre el deeplink**

En `quark-wallet/lib/features/protocol_flows/didcomm/`, Flutter detecta el deeplink `https://.../?oob=...` (AppLinks en Android, Universal Links en iOS), navega a `/notifications/didcomm?url=...`, monta `DidCommNotificationScreen` que dispara `DidCommNotifier.build(url)`:

```dart
final result = await session.invitation.resolve(url);
```

`InvitationResolver.resolve` (en `identity-core-dart/lib/src/protocol/didcomm/oob/oob_resolver.dart`) parsea la URL, devuelve `DidCommInvitationResult` con el JSON desencriptado + `flowType` derivado del `goal_code`:
- `streamlined-vc` → `DidCommFlowType.credentialIssuance`
- `streamlined-vp` → `DidCommFlowType.presentation`
- ausente → `DidCommFlowType.connectionOnly`

`DidCommFlowType` decide qué pantalla mostrar al usuario (`verify_party_slide.dart` muestra la contraparte y exige confirmación). Una vez el usuario toca **Aceptar**, `acceptConnection()` llama a:
```dart
final connection = await session.didcomm.acceptInvitation(current.invitation);
```

Del lado servidor (`quark-holder-service`), `POST /holders/{walletId}/didcomm/receive-invitation` invoca:
```ts
await receiveInvitation(agent, invitationUrl)
```
que hace:
```ts
await didcomm.oob.receiveInvitationFromUrl(normalizedUrl, { label, reuseConnection: true })
```

`reuseConnection: true` reusa una conexión previa si detecta `theirDid` igual.

**Pasos 3-8 — DIDExchange handshake**

El handshake completo, que Credo maneja automáticamente vía `DidCommDIDExchangeProtocol`:

1. **Holder construye request**: genera un par de claves X25519 (enc) + Ed25519 (sig), publica un `did:peer:2` que las incluye en un `verificationMethod` + `keyAgreement` y `service[didexchange]`. El DID se construye a partir del `serviceEndpoint` del issuer.
2. **Holder → Issuer (Request)** cifrado con ECDH-ES entre la clave pública del issuer (recibida en el OOB) y la del holder.
3. **Issuer recibe Request**, verifica firma, crea `DidCommConnectionRecord` con estado `RequestReceived`. En auto-accept mode, automáticamente construye y envía el `Response` con su propio `did:peer:2`. En Quark, `connections: { autoAcceptConnections: true }`.
4. **Holder recibe Response**, verifica firma del issuer, crea su propio `DidCommConnectionRecord`. Construye y envía `Ack`.
5. **Issuer recibe Ack**, transiciona la conexión a `Completed`.
6. **Dispara evento `DidCommConnectionStateChanged`** en ambos lados.

El resultado es una `DidCommConnectionRecord` con:
```json
{
  "id": "<connectionId UUID>",
  "state": "completed",
  "did": "<issuer's did:peer:2>",
  "theirDid": "<holder's did:peer:2>",
  "theirKey": "<encryption key public JWK>",
  "theirLabel": "<label of the other party>",
  "theirDidDoc": { "...": "..." },
  "secretId": "<internal>",
  "protocol": "didexchange/2.0"
}
```

Quark expone `GET /holders/{walletId}/didcomm/connections` y `GET /issuers/{walletId}/didcomm/connections` que devuelven array de estos records.

### Detalles específicos del transporte (HTTP y WS)

`DidCommHttpInboundTransport` se monta en:
```ts
new DidCommHttpInboundTransport({ app: expressApp, path: '/didcomm', port: 3001 })
```
- holder escucha en **9205** por default.
- issuer en **3001**.
- verifier en **9204**.

Los tres pueden compartir el mismo `ws.WebSocketServer`. En esa variante se monta `DidCommWsInboundTransport({ server: wsServer })`. Al construir el mensaje saliente, Credo construye el JWE y lo envía como texto plano por WS (handshake + message frame `didcomm/v2`).

---

## 4. RFC 0036: Issue Credential — Flujo detallado

DIDComm v2 issue-credential maneja credenciales W3C JSON-LD a través de `DidCommJsonLdCredentialFormatService`. Quark configura **sólo v2**:

```ts
credentials: {
  credentialProtocols: [
    new DidCommCredentialV2Protocol({
      credentialFormats: [new DidCommJsonLdCredentialFormatService()],
    }),
  ],
}
```

El proof suite por defecto es `Ed25519Signature2018` (`proofType: 'Ed25519Signature2018'`). Se puede sobreescribir vía `proofType` en el DTO:

```ts
@IsOptional() @IsString() proofType?: string  // ej. 'BbsBlsSignature2020'
```

### Diagrama de secuencia completo

```
Issuer                                 Holder
   │                                       │
   │ [Conexión DIDExchange completada]     │
   │                                       │
   │ (1) offerCredential()                 │
   │     Construye VC:                     │
   │     - @context                        │
   │     - type: ["VerifiableCredential", │
   │              ...customTypes]          │
   │     - issuer: <issuerDID>             │
   │     - credentialSubject:              │
   │         { id: <holderDID>, ...data }  │
   │     - issuanceDate                    │
   │                                       │
   │     attachments:                      │
   │     - credential-preview en JSON-LD    │
   │       `formats`: [{"attach_id":       │
   │         "0", "format": "jsonld"}]      │
   │                                       │
   │                                       │
   │ (2) OfferCredential ─────────────────►│
   │     type=...issue-credential/2.0/     │
   │     offer-credential                  │
   │     thid=<parent>                     │
   │                                       │
   │                                       │
   │                                       │ (3) holder listener:
   │                                       │     state=OfferReceived
   │                                       │     → credentials.acceptOffer
   │                                       │       (automático si el holder
   │                                       │       está en auto-accept)
   │                                       │     credentials~attach, formats:
   │                                       │     jsonld {options: proofType,
   │                                       │       proofPurpose:}
   │                                       │
   │                                       │
   │ (4) RequestCredential ◄───────────────│
   │     type=...request-credential        │
   │     credentials~attach[] (format jsonld│
   │     con proof de la request)          │
   │                                       │
   │ (5) issuer listener:                  │
   │     state=RequestReceived             │
   │     → credentials.acceptRequest       │
   │       (firma VCs)                     │
   │                                       │
   │ (6) IssueCredential ─────────────────►│
   │     type=...issue-credential/2.0/     │
   │       issue-credential                │
   │     credentials~attach[] con VCs      │
   │     firmadas (proof Ed25519 sig)      │
   │                                       │
   │                                       │ (7) holder listener:
   │                                       │     state=CredentialReceived
   │                                       │     → credentials.acceptCredential
   │                                       │       (persiste VC en w3cRecord)
   │                                       │     state=Done
   │                                       │
   │ (8) Ack ◄─────────────────────────────│
   │     type=...ack                       │
   │                                       │
   │ (9) issuer state=Done                 │
   └───────────────────────────────────────┘
```

### Paso a paso

**Paso 1 — Issuer construye la credencial a ofrecer**

En `quark-issuer-service`, `CredentialsService.offerCredential(walletId, params)` ejecuta `offerCredential(agent, params)` desde `identity-core/src/protocol/didcomm/issuance.ts`. El método toma:

```ts
{
  connectionId: string,
  credential: {
    '@context'?: ['https://www.w3.org/2018/credentials/v1', ...],
    type?: ['GenericCredential'],              // se le prepende 'VerifiableCredential'
    credentialSubject: {                       // ej. {name: 'Ada', age: '30'}
      id?: '<holderDID>',                      // ← ojo: el DTO permite id opcional
    }
  },
  proofType?: 'Ed25519Signature2018',          // default
  issuerDid?: '<did:web:...>'                  // si se omite, el agent coge el primero did:web
}
```

`buildOfferCredentialPayload` (en `credential.builder.ts`) arma:
```ts
{
  '@context': [...DEFAULT_CONTEXTS, ...customTypes'],
  id: 'urn:uuid:<random>',
  type: ['VerifiableCredential', ...customTypes],
  issuer: '<issuerDID>',
  issuanceDate: new Date().toISOString(),
  credentialSubject: { id: '<holderDID>', ...customData }
}
```

`getProofOptions` añade `{ proofType: 'Ed25519Signature2018', proofPurpose: 'assertionMethod' }`.

Luego Credo envía:
```ts
agent.didcomm.credentials.offerCredential({
  connectionId: '...',
  protocolVersion: 'v2',
  credentialFormats: {
    jsonld: { credential, options: proofOptions }
  }
})
```

`protocolVersion: 'v2'` garantiza que se use RFC 0036 v2.0 y los message types de la lista superior.

**Paso 2 — Issuance de OfferCredential**

Credo construye internamente:
```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/offer-credential",
  "@id": "<uuid>",
  "~thread": { "thid": "<parent-thid>" },
  "from": "<issuerDID>",
  "to": ["<holderDID>"],
  "formats": [
    { "attach_id": "0", "format": "jsonld" }
  ],
  "credentials~attach": [{
    "@id": "0",
    "mime-type": "application/json",
    "data": {
      "json": { "...": "<VC JSON-LD no firmada todavía>" }
    }
  }]
}
```

Envuelto como JWE y enviado por HTTP POST a `theirDidDoc.service[didexchange].serviceEndpoint` o por WS frame `didcomm/v2`. El estado interno del issuer transiciona a `offer-sent`.

**Paso 3 — Holder recibe el OfferCredential**

Credo internamente:
1. Desencripta el JWE usando las claves privadas del holder.
2. Parsea el mensaje.
3. Identifica el thread, crea/actualiza un `DidCommCredentialExchangeRecord`.
4. Dispara `DidCommCredentialStateChanged` con estado `OfferReceived`.

En Quark, `setupHolderListeners` (en `holder.listener.ts:133-202`) registra un listener sobre ese evento:

```ts
case DidCommCredentialState.OfferReceived: {
  const tenantId = await findTenantIdForRecord(agent, record.id, 'credentials')
  // ...
  await api.withTenantAgent({ tenantId }, async (tenantAgent) => {
    await tenantAgent.didcomm.credentials.acceptOffer({
      credentialExchangeRecordId: record.id,
      credentialFormats: {
        jsonld: {
          options: {
            proofType: 'Ed25519Signature2018',
            proofPurpose: 'assertionMethod',
          },
        },
      },
    })
  })
}
```

Si se quisiera prompt al usuario antes de aceptar, **no hay opción aquí** — Quark auto-acepta. Es responsabilidad del agente decidirlo. Por eso en producción real se reemplaza este listener con uno que use un web service para registrar el record y pausar el flujo.

**Paso 4 — Holder envía RequestCredential**

Credo construye:
```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/request-credential",
  "@id": "<uuid>",
  "~thread": { "thid": "<offer.id>" },
  "to": ["<issuerDID>"],
  "formats": [{ "attach_id": "0", "format": "jsonld" }],
  "requests~attach": [{
    "@id": "0",
    "mime-type": "application/json",
    "data": {
      "json": { ...vacio si el holder no especifica... }
    }
  }]
}
```

Estado interno del holder → `request-sent`.

**Paso 5 — Issuer recibe Request**

Credo dispara `DidCommCredentialStateChanged` con estado `RequestReceived`. En Quark, `setupDidCommIssuerListeners` (`issuer.listener.ts:103-109`):

```ts
case DidCommCredentialState.RequestReceived: {
  await tenantA.didcomm.credentials.acceptRequest({
    credentialExchangeRecordId: record.id,
    comment: 'JSON-LD Credential',
  })
}
```

Credo internamente:
1. Toma la `credential` del Offer original.
2. Pide al Signer Service del agente (AS, KMS externo, Askar) que firme con la `assertionMethod` del DID issuer.
3. Produce:
```json
{
  "@context": ["https://www.w3.org/2018/credentials/v1", "..."],
  "type": ["VerifiableCredential", "GenericCredential"],
  "id": "urn:uuid:<id>",
  "issuer": "<issuerDID>",
  "issuanceDate": "2026-...",
  "credentialSubject": { "id": "<holderDID>", ... },
  "proof": {
    "type": "Ed25519Signature2018",
    "verificationMethod": "<issuerDID>#key-1",
    "created": "2026-...",
    "proofPurpose": "assertionMethod",
    "jws": "<signature>"
  }
}
```

**Paso 6 — Issuance de IssueCredential**

```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/issue-credential",
  "@id": "<uuid>",
  "~thread": { "thid": "<request.id>" },
  "from": "<issuerDID>",
  "to": ["<holderDID>"],
  "formats": [{ "attach_id": "0", "format": "jsonld" }],
  "credentials~attach": [{
    "@id": "0",
    "mime-type": "application/json",
    "data": {
      "json": {
        "@context": [...],
        "type": ["VerifiableCredential", "GenericCredential"],
        "...": "<VC firmada con Ed25519Signature2018>",
        "proof": {...}
      }
    }
  }]
}
```

Estado interno del issuer → `credential-issued`.

**Paso 7 — Holder recibe la credencial**

Credo dispara `DidCommCredentialStateChanged` con estado `CredentialReceived`. Listener en `holder.listener.ts:172-189`:

```ts
case DidCommCredentialState.CredentialReceived:
  await a.didcomm.credentials.acceptCredential({ credentialExchangeRecordId: record.id })
```

`acceptCredential`:
1. Verifica la firma (usa el resolver DID + KMS).
2. Verifica el credential status si hay VDR / revocation API.
3. Persiste en `W3cCredentialRecord` (`w3cCredentials` API).

**Paso 8 — Holder envía Ack**

Credo internamente:
```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/ack",
  "@id": "<uuid>",
  "~thread": { "thid": "<issue.id>" },
  "status": "OK"
}
```

**Paso 9 — Issuer ve Done**

`DidCommCredentialStateChanged` con estado `Done`. Listener (`issuer.listener.ts:110-112`):
```ts
case DidCommCredentialState.Done:
  log.log('Issuer: Credential exchange completed')
```

Si en cualquier paso algo falla, cualquiera puede emitir un `ProblemReport`:
```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/problem-report",
  "~thread": { "thid": "<último>" },
  "body": {
    "code": "<Enum: rejected, invalid-request, etc.>",
    "comment": "Mensaje humano"
  }
}
```

### Variante: flujo con propose-credential

En lugar de issuer-initiated, el holder puede iniciar con `proposeCredential()` (`POST /holders/{walletId}/didcomm/propose-credential`). Credo crea un thread nuevo y envía `propose-credential` con un payload preliminar:

```json
{
  "@type": "https://didcomm.org/issue-credential/2.0/propose-credential",
  "...": {
    "credential": { "type": ["GenericCredential"], "credentialSubject": {...} },
    "options": { "proofType": "Ed25519Signature2018" }
  }
}
```

Issuer lo recibe (`ProposalReceived`), reacciona vía `negotiateProposal` (que toma la propuesta del holder como base y la completa con su `issuer`) o `acceptProposal` (que ofrece la credencial registrada). Es el flujo "holder dice lo que quiere, issuer negocia y emite".

---

## 5. RFC 0037: Present Proof — Flujo detallado

Quark sólo soporta `presentationExchange` (DIF PEX) como format service:

```ts
proofs: {
  proofProtocols: [
    new DidCommProofV2Protocol({
      proofFormats: [new DidCommDifPresentationExchangeProofFormatService()],
    }),
  ],
}
```

`requestProof(...)` toma:
```ts
{
  connectionId: string,
  presentationDefinition?: Record<string, unknown>,  // DIF PEX
  credentialCount?: number,                            // genera PD genérica
  challenge?: string,
  domain?: string
}
```

`buildGenericPresentationDefinition` (en `credential/presentation.builder.ts`):
- Si `credentialCount` está definido, genera N descriptors obligatorios.
- Si no, genera hasta 20 descriptors opcionales con `submission_requirements: [{ rule: 'pick', min: 1, from: 'generic' }]` (presenta los que tenga).

Ejemplo de PD estándar:
```json
{
  "id": "req-gen-1",
  "input_descriptors": [{
    "id": "desc-generic-1",
    "name": "Generic Credential #1",
    "group": ["generic"],
    "constraints": {
      "fields": [{
        "path": ["$.type"],
        "filter": {
          "type": "array",
          "contains": { "const": "GenericCredential" }
        }
      }]
    }
  }]
}
```

### Diagrama de secuencia completo

```
Verifier                              Holder
   │                                       │
   │ [Conexión DIDExchange completada]      │
   │                                       │
   │ (1) verifier construye PD (ej. req-gen-1)│
   │     y challenge (UUID)                 │
   │                                       │
   │ (2) RequestPresentation ──────────────►│
   │     type=...present-proof/2.0/         │
   │       request-presentation             │
   │     attachment[0] = PresentationDefinition
   │                                       │
   │                                       │ (3) holder listener:
   │                                       │     state=RequestReceived
   │                                       │     → proofs.selectCredentialsForRequest
   │                                       │       (auto-match por PD)
   │                                       │     → proofs.acceptRequest
   │                                       │       (firma VP con Ed25519)
   │                                       │
   │ (4) Presentation ◄────────────────────│
   │     type=...present-proof/2.0/         │
   │       presentation                     │
   │     attachment[0] = PresentationSubmission
   │       con proof sobre el challenge     │
   │                                       │
   │ (5) verifier listener:                │
   │     state=PresentationReceived         │
   │     → proofs.acceptPresentation        │
   │                                       │
   │ (6) Ack ──────────────────────────────►│
   │                                       │
   │ (7) Holder state=Done                 │
```

### Paso a paso

**Pasos 1-2 — Verifier envía RequestPresentation**

`POST /verifiers/{walletId}/didcomm/request-proof` invoca `requestProof` (`protocol/didcomm/presentation.ts`):

```ts
const pd = params.presentationDefinition ?? buildGenericPresentationDefinition({credentialCount})
const mode = params.credentialCount ? `exact:${params.credentialCount}` : 'all'
const record = await agent.didcomm.proofs.requestProof({
  connectionId,
  protocolVersion: 'v2',
  proofFormats: {
    presentationExchange: {
      presentationDefinition: pd,
      options: { challenge: ..., domain: ... }
    }
  }
})
return { proofExchangeRecordId: record.id, state: record.state, mode }
```

Credo envía:
```json
{
  "@type": "https://didcomm.org/present-proof/2.0/request-presentation",
  "@id": "<uuid>",
  "~thread": { "thid": "<parent-thid>" },
  "from": "<verifierDID>",
  "to": ["<holderDID>"],
 "request_presentations~attach": [{
    "@id": "0",
    "mime-type": "application/json",
    "data": {
      "json": {
        "options": { "challenge": "<uuid>" },
        "presentation_definition": { "@context": [...], ... }
      }
    }
  }]
}
```

**Paso 3 — Holder recibe y prepara la presentación**

Listener `ProofStateChanged` (`holder.listener.ts:206-260`):

```ts
case DidCommProofState.RequestReceived:
  // 1. Auto-match: pedirle a Credo que encuentre VCs matching los input descriptors
  const { proofFormats } = await a.didcomm.proofs.selectCredentialsForRequest({
    proofExchangeRecordId: record.id,
  })
  const pex = (proofFormats as { presentationExchange?: Record<string, unknown> })?.presentationExchange
  // 2. Expandir selección si hay descriptors sin asignar y VCs elegibles en la wallet
  if (pex) await expandPexSelection(tenantAgent as unknown as Agent, record.id, pex, log)
  // 3. Construir y enviar PresentationSubmission firmada
  await a.didcomm.proofs.acceptRequest({
    proofExchangeRecordId: record.id,
    proofFormats,
  })
```

`expandPexSelection` es una extensión de Quark para asignar automáticamente VCs disponibles a descriptors vacíos. Itera `pd.input_descriptors`, mira qué descriptor IDs ya tienen `credentialsMap[id]` con algo asignado, y para los libres busca entre todos los `W3cCredentialRecord` con el mismo `type` (extraído de `constraints.fields.filter.contains.const`).

Credo firmará la `Presentation Submission` con la `authentication` key del holder usando `challenge` del PD como linked data proof challenge (en JSON-LD con `proofProofPurpose: 'authentication'`). El format service JSON-LD hace esto vía el signer service + Linked Data Proofs.

**Paso 4 — Holder envía Presentation**

```json
{
  "@type": "https://didcomm.org/present-proof/2.0/presentation",
  "@id": "<uuid>",
  "~thread": { "thid": "<request.id>" },
  "from": "<holderDID>",
  "to": ["<verifierDID>"],
  "request_presentations~attach": [{
    "data": {
      "json": {
        "@context": [...],
        "type": ["VerifiablePresentation", "PresentationSubmission"],
        "presentation_submission": {
          "id": "<uuid>",
          "definition_id": "<pd.id>",
          "descriptor_map": [{ "id": "<desc.id>", "format": "ldp_vp", "path": "$.verifiableCredential[0]" }]
        },
        "verifiableCredential": [<las VCs>],
        "proof": {
          "type": "Ed25519Signature2018",
          "verificationMethod": "<holderDID>#key-1",
          "challenge": "<uuid>",
          "proofPurpose": "authentication",
          "created": "...",
          "jws": "..."
        }
      }
    }
  }]
}
```

**Paso 5 — Verifier recibe y verifica**

`ProofStateChanged` con estado `PresentationReceived` dispara `setupVerifierListeners` (`verifier.listener.ts:32-71`):

```ts
case DidCommProofState.PresentationReceived:
  await api.withTenantAgent({ tenantId }, async (tenantAgent) => {
    await tenantAgent.didcomm.proofs.acceptPresentation({ proofExchangeRecordId: record.id })
  })
  log.log(VERIFIED_ASCII)
```

`acceptPresentation` en Credo internamente:
1. Verifica la firma Linked Data de la VP usando la `authentication` key del holder (resuelve `verificationMethod` desde DID vía dids API).
2. Verifica que el `challenge` coincida.
3. Verifica el `descriptor_map` que cada descriptor está satisfecho con las VCs presentadas (campos, formatos).
4. Verifica las VCs dentro (firma + status).

Si todo OK → estado `Done`. Si hay error, dispara un `ProblemReport` y estado `Abandoned`.

**Paso 6 — Verifier envía Ack**

```json
{
  "@type": "https://didcomm.org/present-proof/2.0/ack",
  "~thread": { "thid": "<presentation.id>" },
  "status": "OK"
}
```

**Paso 7 — Holder ve `Done` o error**

Credo dispara `ProofStateChanged` con estado `Done` o `Abandoned`. Holder listener (`holder.listener.ts:241-251`):
```ts
case ProofState.Done:
  log.log(VERIFIED_ASCII)
case ProofState.Declined || Abandoned:
  // → log NOT_VERIFIED_ASCII / REVOKED según mensaje
```

### Variante propose-presentation

El holder puede iniciar con `proposePresentation(...)` que envía `propose-presentation` con una PD preliminar. Verifier la recibe y responde con `request-presentation` (vía `acceptProposal`) con su PD definitiva. En Quark no se implementa en services — está disponible vía API low-level.

---

## 6. API HTTP expuesta por los servicios NestJS

### `quark-issuer-service` (puerto 3001)

```
POST   /issuers/{walletId}/didcomm/create-invitation   → {invitation: "<URL OOB>"}
GET    /issuers/{walletId}/didcomm/connections         → {connections: [{id, holderDid, issuerDid, theirLabel, state}]}
GET    /issuers/{walletId}/didcomm/connection/:id      → {id, holderDid, issuerDid, theirLabel, state}
POST   /issuers/{walletId}/didcomm/offer-credential    → {credentialExchangeId, state, credentialId}
```

### `quark-holder-service` (puerto 9007)

```
POST   /holders/{walletId}/didcomm/receive-invitation  → {ok, outOfBandRecordId}
POST   /holders/{walletId}/didcomm/propose-credential   → {credentialExchangeId, state}
GET    /holders/{walletId}/didcomm/connections          → {connections: [...]}
GET    /holders/{walletId}/didcomm/credentials          → {credentials: [W3C, W3C V2, SD-JWT]}
GET    /holders/{walletId}/didcomm/credentials-status   → {credentials: [...con revoked del VDR]}
GET    /holders/{walletId}/didcomm/credential-status/:id → {revoked, error?}
GET    /holders/{walletId}/did.json                     → DID Document del agent
```

### `quark-verifier-service` (puerto 9006)

```
POST   /verifiers/{walletId}/didcomm/create-invitation  → {invitation: "<URL OOB>"}
GET    /verifiers/{walletId}/didcomm/connections        → {connections: [...]}
POST   /verifiers/{walletId}/didcomm/request-proof      → {proofExchangeRecordId, state, mode}
```

Los tres exponen el puerto HTTP de inbound DIDComm en `/didcomm` (3001 / 9205 / 9204) y comparten un `ws.WebSocketServer` si se configura. Los métodos HTTP no reciben conexiones — sólo son disparados por el frontend Quark cuando quiere iniciar / aceptar un flujo.

---

## 7. Persistencia y multi-tenancy

### Multi-tenant

- Cada `walletId` mapea a un `tenantId` Credo (`agent-store.ts`).
- `withWallet(walletId, callback)` resuelve el tenant y hace `withTenant(rootAgent, tenantId, callback)`.
- `loadTenantMap` (en `identity-core/src/agent/tenant.ts`) se llama al boot y carga el mapa desde el `WalletStore` (DB Postgres).
- `registerTenant(walletId, tenantId)` (en `agent-store.ts:27-29`) re-registra cuando se crea un nuevo tenant en runtime (en `POST /issuers`).

### Almacenamiento de protocolos

- Cada record (`DidCommCredentialExchangeRecord`, `DidCommProofExchangeRecord`, `DidCommConnectionRecord`, `OutOfBandRecord`) se persiste con el storage backend del agente.
- Quark usa `Askar` (credtable/records API + openwallet DB) para todo.
- `DidCommMessageReceived` y demás eventos permiten enganchar lógica reactiva (ver `issuer.listener.ts:32-35`, `holder.listener.ts:14-30`).

---

## 8. Capa Flutter (wallet)

El wallet Flutter usa `identity-core-dart` (paquete local en `packages/identity-core-dart/`), que **NO depende de Credo Dart** (no hay Credo en Dart). En su lugar implementa los protocolos DIDComm manualmente:

- `DidCommService` (en `didcomm_service.dart`): fachada de alto nivel que orquesta RFC 0023, RFC 0036, RFC 0037.
- `ConnectionService`: implementa el flujo OOB → DIDExchange → ConnectionRecord.
- `CredentialExchangeService` (en `credential/credential_exchange_service.dart`): implementa el flujo holder para RFC 0036 con `handleOfferCredential()` + `handleIssueCredential()` — envía HTTP messages para cada respuesta.
- `ProofExchangeService` (en `proof/proof_exchange_service.dart`): implementa RFC 0037.
- `DidCommUnpack` / `DidCommPack`: cifrado JWE ECDH-ES+A256KW (en `crypto/`).
- `ConnectionRecord`, `CredentialExchangeRecord`, `ProofExchangeRecord`: modelos persistidos con Freezed.
- `Transport` HTTP con `dio` (cliente Dart HTTP).

Diferencia crítica: la wallet Flutter maneja la UX y la aprobación del usuario, pero **no maneja el estado de la conexión con un peer persistido** del mismo modo que Credo. Cada flujo se invoca manualmente en pantalla (`verify_party_slide.dart`, etc.). El deeplink handler (`AppLinksHandler`) abre la pantalla `DidCommNotificationScreen`.

States implementados (en `didcomm_provider.dart`):
```dart
sealed class DidCommFlowState {}
class DidCommVerifyPartyState extends DidCommFlowState { ... invitation, flowType }
class DidCommConnectingState extends DidCommFlowState {}
class DidCommSuccessState extends DidCommFlowState { ... connection }
class DidCommErrorState extends DidCommFlowState { ... message }
```

`DidCommFlowType`:
- `DidCommFlowType.credentialIssuance` → streamlined-vc
- `DidCommFlowType.presentation` → streamlined-vp
- `DidCommFlowType.connectionOnly` → sin goal_code

---

## 9. Endpoints compartidos / diferente a WACI

| Aspecto | DIDComm v2 en Quark | WACI en el Emisor/Verificador |
|---|---|---|
| Message types | `issue-credential/2.0/*`, `present-proof/2.0/*`, `didexchange/2.0/*` | `issue-credential/3.0/*`, `present-proof/3.0/*` |
| Conexión previa | Requerida (DIDExchange + ConnectionRecord) | No requerida (sólo OOB invitation) |
| DID del emisor/holder | `did:peer:2` (auto-generado por DIDExchange) | `did:jwk` o `did:web` del agente (operacional) |
| Identificador del flow | `protocolVersion: 'v2'` por API call | goal_code `streamlined-vc`/`streamlined-vp` |
| Attachment format | `formats: [{ attach_id, format: 'jsonld' }]` + `credentials~attach[]` (idem) | `attachments[]` con `format: 'dif/credential-manifest/manifest@v1.0'` |
| Estado persistente | State machines: `offer-sent`, `request-sent`, `credential-issued`, `done` | Sin state machine: el SDK del emisor decide cuándo armar cada mensaje |
| Driver reactivo | Listeners sobre `DidCommCredentialStateChanged` + `findTenantIdForRecord` | Step handlers imperativos + callbacks por actor |
| Transporte | HTTP POST en `/didcomm` o WS — cifrado JWE | Socket.IO en `/socket.io` — mensajes JSON sin cifrar |
| Proof suite | Ed25519Signature2018 | BbsBlsSignature2020 |
| Holder approval | Auto-accept en `OfferReceived` / `RequestReceived` (sin UI prompt) | Side conversation: el SDK no pausa; el integrador decide cuándo aceptar (en `handleCredentialFulfillment` etc.) |

---

## 10. Resumen del ciclo completo

### Emisión (RFC 0036)

```
Issuer                            Holder
  │                                  │
  │ OOB invitation                   │
  │ (con didexchange/2.0/request     │
  │  embebido)                       │
  │─────────────────────────────────►│  Escanea QR
  │                                  │  Usuario aprueba
  │                                  │  Genera did:peer:2
  │  DIDExchange Request             │
  │◄─────────────────────────────────│
  │  DIDExchange Response            │
  │─────────────────────────────────►│
  │  DIDExchange Ack                 │
  │◄─────────────────────────────────│
  │       → Connection: completed    │
  │                                  │
  │  offer-credential                │
  │─────────────────────────────────►│  Listener acepta
  │                                  │
  │  request-credential              │
  │◄─────────────────────────────────│  (con presentación vacía o
  │                                  │   con credential-application)
  │  issue-credential (VC firmada)   │
  │─────────────────────────────────►│
  │                                  │  Listener guarda
  │  ack                             │
  │◄─────────────────────────────────│
  │       → state = done             │
```

5 mensajes del flujo + 4 del handshake = 9 mensajes totales para emisión por DIDComm v2.

### Presentación (RFC 0037)

```
Verifier                          Holder
  │                                  │
  │ OOB invitation                   │
  │─────────────────────────────────►│  DIDExchange handshake → Connection
  │                                  │
  │  request-presentation (PD + challenge) │
  │─────────────────────────────────►│  selectCredentialsForRequest + acceptRequest
  │                                  │
  │  presentation (VP con VCs)       │
  │◄─────────────────────────────────│
  │  acceptPresentation (verifica)   │
  │                                  │
  │  ack                             │
  │─────────────────────────────────►│
```

5 mensajes del flujo + 4 del handshake = 9 mensajes totales para verificación.

---

## 11. Implicancia para interoperabilidad con WACI

Para hacer un bridge WACI ↔ DIDComm (la intención del documento `propuesta-bridge-waci-didcomm.md`), las diferencias fundamentales son:

1. **El bridge debe actuar como un Peer DID más** porque WACI envía el OOB sin requerir handshake. El bridge tendría que:
   - Capturar el OOB-WACI antes que llegue al SDK Extrimian del holder.
   - Construir un OOB-DIDComm estándar (`https://didcomm.org/out-of-band/2.0/invitation` con handshake `didexchange/2.0/request` embebido).
   - Establecer una conexión con el portapapeles de Credo usando `withWallet(walletId, agent => didcomm.oob.createInvitation(...))` y exponer un endpoint para recibir `didexchange/2.0/response`.

2. **Traducción de attachment formats**:
   - WACI `attachments[]` con `format: 'dif/credential-manifest/...'` → DIDComm `credentials~attach[]` con `formats: [{ attach_id, format: 'jsonld' }]`.
   - DIF PEX submission ↔ JSON-LD VP (con `presentation_submission` y `verifiableCredential`).

3. **Diferencia de proof suites**: Quark usa Ed25519Signature2018 por default; WACI usa BbsBlsSignature2020. El bridge debe acordar o hacer remapeo.

4. **Diferencia de cifrado**: DIDComm exige JWE cifrado (ECDH-ES+A256KW). WACI va sin cifrar por Socket.IO. Por eso el bridge tiene que actuar en el nivel transporte (interceptar antes de que el holder vea el mensaje en claro).

5. **No hay ConnectionRecord en WACI**. Quark requeriría crearlo y mantenerlo (lo hace el handshake `didexchange/2.0`).

---

**Fin del documento**