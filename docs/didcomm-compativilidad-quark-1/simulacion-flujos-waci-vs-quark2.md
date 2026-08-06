# Simulación de flujos WACI vs Quark 2 — Casos ficticios paso a paso

**Versión:** 1.0  
**Fecha:** 2026-07-08  
**Fuentes:** `ba-miba/miba-connect`, `generic-issuer-back`, `quark-holder-service`, `packages/identity-core`

---

## Setup ficticio

| Actor | DID |
|---|---|
| Holder (el `did` en el body) | `did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA` |
| Verifier (el `from` del OOB) | `did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw` |
| Invitation ID | `d9fa48b9-1e67-499e-bfcd-53ee96aec52f` |

El OOB del ejemplo decodificado:

```json
{
  "type": "https://didcomm.org/out-of-band/2.0/invitation",
  "id": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "body": {
    "goal_code": "streamlined-vp",
    "accept": ["didcomm/v2"]
  }
}
```

Es un flujo de **verificación** (`streamlined-vp`), no de emisión.

---

## Caso 1 — Verificación WACI feliz (lo que pasa cuando llamás `PUT /credentialsbbs/waci`)

### Paso 0 — Request HTTP

```http
PUT /credentialsbbs/waci
```

```json
{
  "did": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "message": "didcomm://?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiZDlmYTQ4YjktMWU2Ny00OTllLWJmY2QtNTNlZTk2YWVjNTJmIiwiZnJvbSI6ImRpZDpxdWFya2lkOkVpRG03aXlkU2xVaGNLeVVsYUFwd28xX0V0STRvSnA1dFlDZ1daX3FxOGlhcHciLCJib2R5Ijp7ImdvYWxfY29kZSI6InN0cmVhbWxpbmVkLXZwIiwiYWNjZXB0IjpbImRpZGNvbW0vdjIiXX19"
}
```

**Por dentro:** `WaciController` → `WaciService.processMessage()` → `VcService.processMessage()` → detecta WACI → `WACIProtocol.processMessage()`.

**Respuesta HTTP:** `true` (no devuelve el mensaje DIDComm; eso sale por otro canal).

---

### Paso 1 — miba-connect decodifica el OOB

Internamente queda el mensaje del paso 0 y se guarda en storage con clave `thid` / `pthid`.

El `WACIInterpreter` del lado **Holder** ve `goal_code: streamlined-vp` y arma:

```json
{
  "type": "https://didcomm.org/present-proof/3.0/propose-presentation",
  "id": "msg-001-propose",
  "pthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "to": ["did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw"],
  "body": {}
}
```

**Por dentro:** `agentKMS.packMessage()` → JWE DIDComm v2 → `agentTransport.sendMessage()` → Socket.IO al verifier.

**Estado storage (ficticio):**

```
storage["d9fa48b9-..."] = [ OOB_invitation ]
storage["msg-001-propose"] = [ propose-presentation ]
```

---

### Paso 2 — El verifier responde (llega por WebSocket, no por HTTP)

El verifier WACI procesa el `propose-presentation` y devuelve:

```json
{
  "type": "https://didcomm.org/present-proof/3.0/request-presentation",
  "id": "msg-002-request",
  "thid": "msg-001-propose",
  "pthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA"],
  "body": {},
  "attachments": [{
    "id": "pd-001",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/definitions@v1.0",
    "data": {
      "json": {
        "presentation_definition": {
          "id": "pd-generic-credential",
          "input_descriptors": [{
            "id": "generic-credential-card",
            "name": "Credencial Genérica",
            "constraints": {
              "fields": [{
                "path": ["$.type"],
                "filter": { "type": "array", "contains": { "const": "GenericCredential" } }
              }]
            }
          }]
        }
      }
    }
  }]
}
```

**Por dentro en miba-connect:** llega por `TransportEvents.Message` → `VcService.processMessageArrived()` → unpack JWE → `processMessage()` otra vez.

El callback `getCredentialPresentation` del holder detecta que hay `inputDescriptors`, busca credenciales del holder en Mongo, y como está en modo async emite:

**Webhook al sistema externo (wallet/app):**

```json
{
  "eventType": "PRESENTATION_REQUEST",
  "eventData": {
    "invitationId": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
    "holderDID": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
    "verifierDID": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
    "credentialsToPresent": [
      {
        "data": {
          "id": "vc-fake-001",
          "type": ["VerifiableCredential", "GenericCredential"]
        },
        "styles": {},
        "display": {}
      }
    ]
  }
}
```

**En este punto el flujo se PAUSA.** miba-connect no manda la presentación sola; espera que alguien externo confirme qué credenciales presentar.

---

### Paso 3 — El sistema externo confirma (`presentation-proceed`)

```http
PUT /credentialsbbs/waci/oob/presentation-proceed
```

```json
{
  "invitationId": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "verifiableCredentials": [{
    "id": "vc-fake-001",
    "data": {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://w3id.org/security/bbs/v1"
      ],
      "type": ["VerifiableCredential", "GenericCredential"],
      "issuer": {
        "id": "did:quarkid:EiIssuerFake123",
        "name": "GCBA"
      },
      "issuanceDate": "2026-07-08T12:00:00Z",
      "credentialSubject": {
        "id": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
        "nombre": "Juan Ficticio"
      },
      "proof": {
        "type": "BbsBlsSignature2020"
      }
    }
  }]
}
```

**Por dentro:** `WACIProtocol.presentationProceed()` → `waciInterpreter.presentationProceed()` → firma con `signPresentation()` vía KMS (BBS+) → arma:

```json
{
  "type": "https://didcomm.org/present-proof/3.0/presentation",
  "id": "msg-003-present",
  "thid": "msg-002-request",
  "from": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "to": ["did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw"],
  "attachments": [{
    "format": "dif/presentation-exchange/submission@v1.0",
    "data": {
      "json": {
        "verifiablePresentation": "... VP firmada con presentation_submission ..."
      }
    }
  }]
}
```

→ pack JWE → Socket.IO al verifier.

---

### Paso 4 — El verifier valida y responde ACK

```json
{
  "type": "https://didcomm.org/present-proof/3.0/ack",
  "id": "msg-004-ack",
  "thid": "msg-003-present",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA"],
  "body": { "status": "OK" }
}
```

**Por dentro en holder:** `handlePresentationAck()` → webhook `HOLDER_PRESENTATION_FINISHED` → desconecta WebSocket → limpia storage del `invitationId`.

**Fin del flujo. Verificación exitosa.**

---

## Caso 2 — Emisión WACI feliz (mismo endpoint, distinto `goal_code`)

Si el OOB tuviera `goal_code: streamlined-vc` (emisión desde `generic-issuer-back`):

### Paso 0 — Holder escanea QR de emisión

Mismo `PUT /credentialsbbs/waci` pero el OOB decodificado es:

```json
{
  "type": "https://didcomm.org/out-of-band/2.0/invitation",
  "id": "inv-emision-001",
  "from": "did:quarkid:EiIssuerFake123",
  "body": {
    "goal_code": "streamlined-vc",
    "accept": ["didcomm/v2"]
  }
}
```

### Paso 1 — Holder manda ProposeCredential (automático)

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/propose-credential",
  "id": "msg-101",
  "pthid": "inv-emision-001",
  "from": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "to": ["did:quarkid:EiIssuerFake123"]
}
```

### Paso 2 — Issuer responde OfferCredential con Manifest + Fulfillment template

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/offer-credential",
  "id": "msg-102",
  "thid": "msg-101",
  "from": "did:quarkid:EiIssuerFake123",
  "to": ["did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA"],
  "attachments": [
    {
      "format": "dif/credential-manifest/manifest@v1.0",
      "data": {
        "json": {
          "credential_manifest": {
            "id": "manifest-001",
            "output_descriptors": []
          }
        }
      }
    },
    {
      "format": "dif/credential-manifest/fulfillment@v1.0",
      "data": {
        "json": {
          "credential_fulfillment": {
            "id": "fulfillment-001",
            "manifest_id": "manifest-001"
          },
          "verifiableCredential": []
        }
      }
    }
  ]
}
```

**No hay pausa ni webhook aquí** (a menos que el manifest pida VCs previas). El holder sigue automático.

### Paso 3 — Holder manda RequestCredential

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/request-credential",
  "id": "msg-103",
  "thid": "msg-102",
  "from": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "to": ["did:quarkid:EiIssuerFake123"],
  "attachments": [{
    "format": "dif/credential-manifest/application@v1.0",
    "data": {
      "json": {
        "credential_application": {
          "id": "app-001",
          "manifest_id": "manifest-001"
        }
      }
    }
  }]
}
```

### Paso 4 — Issuer manda IssueCredential con VC firmada BBS+

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/issue-credential",
  "id": "msg-104",
  "thid": "msg-103",
  "from": "did:quarkid:EiIssuerFake123",
  "to": ["did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA"],
  "attachments": [{
    "format": "dif/credential-manifest/fulfillment@v1.0",
    "data": {
      "json": {
        "credential_fulfillment": {
          "id": "fulfillment-002",
          "manifest_id": "manifest-001"
        },
        "verifiableCredential": [{
          "@context": [
            "https://www.w3.org/2018/credentials/v1",
            "https://w3id.org/security/bbs/v1"
          ],
          "type": ["VerifiableCredential", "GenericCredential"],
          "issuer": { "id": "did:quarkid:EiIssuerFake123" },
          "credentialSubject": {
            "id": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
            "nombre": "Juan Ficticio"
          },
          "proof": { "type": "BbsBlsSignature2020" }
        }]
      }
    }
  }]
}
```

### Paso 5 — Holder guarda la VC y manda ACK

`handleCredentialFulfillment()` → guarda en Mongo → webhook `CREDENTIAL_ARRIVED` → manda:

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/ack",
  "id": "msg-105",
  "thid": "msg-104",
  "from": "did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA",
  "to": ["did:quarkid:EiIssuerFake123"],
  "body": { "status": "OK" }
}
```

**Fin. Credencial en wallet del holder.**

---

## Caso 3 — Verificación fallida (firma inválida)

Mismos pasos 0–3 del Caso 1, pero en el paso 4 el verifier no manda ACK sino:

```json
{
  "type": "https://didcomm.org/report-problem/2.0/problem-report",
  "id": "msg-004-error",
  "thid": "msg-003-present",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiDX9dOZ-c9gnLVJs6BxlWy1Ur5CaJyxzHiHDeuCrRpolA"],
  "body": {
    "code": "signature_verification_failed",
    "comment": "Invalid BbsBlsSignature2020 proof"
  }
}
```

**Por dentro:** `handlePresentationAck()` con status distinto → webhook con `verified: false` → limpia storage → desconecta WebSocket.

---

## Caso 4 — Qué pasaría si Quark 2 recibiera el MISMO OOB

Mismo body que el Caso 1, pero procesado por `quark-holder-service` / wallet Credo:

### Paso 0 — Holder recibe OOB

`receiveInvitation()` en `identity-core` normaliza `_oob` → `oob` y llama `didcomm.oob.receiveInvitationFromUrl()`.

### Paso 1 — Credo intenta DID Exchange

Credo busca en el OOB un adjunto `didexchange/2.0/request` con `serviceEndpoint` y `recipientKeys`.

**No los encuentra.** El OOB solo tiene `goal_code: streamlined-vp` y `from`.

### Resultado: falla aquí

```
Error: No service endpoint found in invitation
// o
Error: Unable to establish connection — missing didexchange attachment
```

**No llega nunca a `propose-presentation` ni a `request-presentation`.** El flujo muere en el paso 1.

Si por algún milagro Credo aceptara el OOB y mandara `didexchange/2.0/request` por HTTP a `/didcomm`, el verifier WACI (Socket.IO) no lo entendería porque espera `propose-presentation/3.0` por Socket.IO, no un handshake DID Exchange por HTTP.

---

## Resumen visual de la divergencia

### Verificación

```
WACI (miba-connect):
  OOB(vp) → ProposePresentation → RequestPresentation → [PAUSA webhook]
  → presentation-proceed → PresentProof → ACK
  Transporte: Socket.IO + JWE
  Versión: present-proof/3.0
  Thread: pthid/thid planos

Quark 2 (Credo):
  OOB(vp) → ❌ FALLA (no hay didexchange en OOB)
  Si funcionara: didexchange → request-presentation/2.0 → presentation/2.0 → ack/2.0
  Transporte: HTTP /didcomm + JWE
  Versión: present-proof/2.0
  Thread: ~thread.pthid / ~thread.thid (decoradores Credo)
```

### Emisión

```
WACI (miba-connect / generic-issuer-back):
  OOB(vc) → ProposeCredential → OfferCredential(Manifest) → RequestCredential
  → IssueCredential(BBS+) → Ack
  Transporte: Socket.IO + JWE
  Versión: issue-credential/3.0

Quark 2 (Credo):
  OOB(vc) → ❌ FALLA (no hay didexchange en OOB)
  Si funcionara: didexchange → offer-credential/2.0 → request-credential/2.0
  → issue-credential/2.0 → ack/2.0
  Transporte: HTTP /didcomm + JWE
  Versión: issue-credential/2.0
  Firma default: Ed25519 (no BBS+ sin config extra)
```

---

## Tabla comparativa rápida

| Aspecto | WACI (miba-connect) | Quark 2 (Credo) |
|---|---|---|
| Primer mensaje tras OOB | `propose-credential` / `propose-presentation` (3.0) | `didexchange/2.0/request` |
| Handshake DID Exchange | No existe | Obligatorio |
| Versión protocolo | 3.0 | 2.0 |
| Adjuntos emisión | Credential Manifest / Fulfillment | JSON-LD `credentials~attach` |
| Transporte | Socket.IO + JWE | HTTP `/didcomm` + JWE |
| Thread IDs | `pthid` / `thid` planos | `~thread.pthid` / `~thread.thid` |
| Pausa UX verificación | Sí (webhook + `presentation-proceed`) | Auto-acepta (listeners Credo) |
| Firma VC | `BbsBlsSignature2020` | `Ed25519Signature2018` por default |
| DID method | `did:quarkid` | `did:key` / `did:web` / `did:peer` |
| QR param | `?_oob=` | `?oob=` (normalizado en identity-core) |

---

## Referencias en código

| Componente | Archivo clave |
|---|---|
| Endpoint holder WACI | `ba-miba/miba-connect/source/src/modules/waci/waci.controller.ts` |
| Orquestación WACI | `ba-miba/miba-connect/source/src/modules/vc/protocol/waci_protocol.service.ts` |
| Envío transporte | `ba-miba/miba-connect/source/src/modules/vc/vc.service.ts` |
| Webhooks | `ba-miba/miba-connect/source/src/modules/event_listener/event_listener.service.ts` |
| Emisor WACI legacy | `generic-issuer-back/source/src/quark/waci/waci-protocol.service.ts` |
| Holder Quark 2 | `packages/identity-core/src/protocol/didcomm/invitation.ts` |
| Issuer listener Credo | `packages/identity-core/src/protocol/didcomm/issuer.listener.ts` |
| Protocolo WACI SDK | `@extrimian/waci` → `waci-interpreter.js`, `waci-message.d.ts` |

---

## Caso 5 — Traducción bridge mensaje a mensaje

Este caso retoma el **mismo setup del Caso 1** (verificación `streamlined-vp`) y el **Caso 2** (emisión `streamlined-vc`), pero inserta `quark-bridge` entre la wallet Credo y el backend WACI legacy.

El bridge actúa como **dos peers distintos**:

| Lado | Rol del bridge | DID ficticio | Transporte |
|---|---|---|---|
| Hacia wallet Credo | Verifier/issuer proxy con DID Exchange | `did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab` | HTTP `POST /didcomm` (JWE) |
| Hacia backend WACI | Holder proxy (como miba-connect) | `did:quarkid:EiBridgeProxyHolder000000000000000000000` | Socket.IO `/socket.io` (JWE) |

**Session Redis (ficticia):**

```json
{
  "sessionId": "sess-bridge-7f3a",
  "waciInvitationId": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "goalCode": "streamlined-vp",
  "legacyPeerDid": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "walletDid": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
  "bridgeCredoDid": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "bridgeWaciDid": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "threadMap": {
    "waciPthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
    "credoPthid": "bridge-oob-001",
    "waciThidPropose": null,
    "credoThidRequest": null
  },
  "ttlSeconds": 3600
}
```

---

### 5.A — Verificación con bridge (feliz)

Flujo completo: **Wallet Credo ↔ Bridge (HTTP/JWE) ↔ Verifier WACI (Socket.IO/JWE)**

#### Paso 0 — Wallet escanea QR WACI legacy

La wallet obtiene el mismo QR del Caso 1:

```
didcomm://?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiZDlmYTQ4YjktMWU2Ny00OTllLWJmY2QtNTNlZTk2YWVjNTJmIiwiZnJvbSI6ImRpZDpxdWFya2lkOkVpRG03aXlkU2xVaGNLeVVsYUFwd28xX0V0STRvSnA1dFlDZ1daX3FxOGlhcHciLCJib2R5Ijp7ImdvYWxfY29kZSI6InN0cmVhbWxpbmVkLXZwIiwiYWNjZXB0IjpbImRpZGNvbW0vdjIiXX19
```

En lugar de mandarlo a miba-connect, la wallet llama:

```http
POST /v1/bridge/verify/start
Authorization: Bearer <jwt>
```

```json
{
  "waciInvitation": "didcomm://?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiZDlmYTQ4YjktMWU2Ny00OTllLWJmY2QtNTNlZTk2YWVjNTJmIiwiZnJvbSI6ImRpZDpxdWFya2lkOkVpRG03aXlkU2xVaGNLeVVsYUFwd28xX0V0STRvSnA1dFlDZ1daX3FxOGlhcHciLCJib2R5Ijp7ImdvYWxfY29kZSI6InN0cmVhbWxpbmVkLXZwIiwiYWNjZXB0IjpbImRpZGNvbW0vdjIiXX19",
  "walletDid": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"
}
```

**Bridge hace internamente:**

1. Decodifica el OOB WACI (input del Caso 1).
2. Abre Socket.IO contra el verifier WACI.
3. Persiste sesión en Redis (`sess-bridge-7f3a`).
4. Construye un **OOB sintético Credo-compatible** con DID Exchange embebido.

**Respuesta HTTP al wallet:**

```json
{
  "sessionId": "sess-bridge-7f3a",
  "credoInvitationUrl": "https://quark-bridge:9007/oob?oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiYnJpZGdlLW9vYi0wMDEiLCJsYWJlbCI6IlF1YXJrIEJyaWRnZSIsImhhbmRzaGFrZV9wcm90b2NvbHMiOlsiaHR0cHM6Ly9kaWRjb21tLm9yZy9kaWRleGNoYW5nZS8yLjAiXSwic2VydmljZXMiOlt7ImlkIjoiI2lubGluZSIsInR5cGUiOiJkaWQtY29tbXVuaWNhdGlvbiIsInJlY2lwaWVudEtleXMiOlsiRjZCQkY2RjY0RjY0Q0QjE5QjY4QjY4QjY4QjY4QjY4QjY4QjY4Il0sInJvdXRpbmdLZXlzIjpbXSwic2VydmljZUVuZHBvaW50IjoiaHR0cHM6Ly9xdWFyay1icmlkZ2U6OTAwNy9kaWRjb21tIn1dLCJhdHRhY2htZW50cyI6W3siQGlkIjoicmVxdWVzdC0wIiwibWltZS10eXBlIjoiYXBwbGljYXRpb24vanNvbiIsImRhdGEiOnsianNvbiI6eyJAdHlwZSI6Imh0dHBzOi8vZGlkY29tbS5vcmcvZGlkZXhjaGFuZ2UvMi4wL3JlcXVlc3QiLCJAaWQiOiJkZXgtcmVxLTAwMSIsImxhYmVsIjoiUXVhcmsgQnJpZGdlIiwiZ29hbF9jb2RlIjoic3RyZWFtbGluZWQtdnAiLCJnb2FsIjoiV0FDSSBsZWdhY3kgdmVyaWZpY2F0aW9uIHByb3h5In19fV19"
}
```

OOB sintético decodificado que recibe la wallet:

```json
{
  "type": "https://didcomm.org/out-of-band/2.0/invitation",
  "id": "bridge-oob-001",
  "label": "Quark Bridge",
  "handshake_protocols": ["https://didcomm.org/didexchange/2.0"],
  "services": [{
    "id": "#inline",
    "type": "did-communication",
    "recipientKeys": ["F6BBF6F64FCC4B19B68B68B68B68B68B68B68B68B68B68B68"],
    "routingKeys": [],
    "serviceEndpoint": "https://quark-bridge:9007/didcomm"
  }],
  "attachments": [{
    "@id": "request-0",
    "mime-type": "application/json",
    "data": {
      "json": {
        "@type": "https://didcomm.org/didexchange/2.0/request",
        "@id": "dex-req-001",
        "label": "Quark Bridge",
        "goal_code": "streamlined-vp",
        "goal": "WACI legacy verification proxy"
      }
    }
  }]
}
```

| Transformación | WACI (input) | Bridge (output Credo) |
|---|---|---|
| Parámetro QR | `?_oob=` | `?oob=` (normalizado) |
| DID Exchange | Ausente | `attachments[0]` con `didexchange/2.0/request` |
| `serviceEndpoint` | Ausente | `https://quark-bridge:9007/didcomm` |
| `recipientKeys` | Ausente | Clave X25519 del bridge |
| `from` legacy | Se guarda en Redis, no se expone al wallet | Wallet ve al bridge como peer |

---

#### Paso 1 — DID Exchange: Wallet → Bridge

**Mensaje Credo (wallet → bridge), JWE descifrado:**

```json
{
  "type": "https://didcomm.org/didexchange/2.0/response",
  "id": "dex-resp-wallet-001",
  "~thread": { "thid": "dex-req-001" },
  "connection~sig": "...",
  "connection": {
    "did": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
    "did_doc": { "...": "DID Document del wallet" }
  }
}
```

**Bridge responde al wallet:**

```json
{
  "type": "https://didcomm.org/didexchange/2.0/complete",
  "id": "dex-complete-bridge-001",
  "~thread": { "thid": "dex-req-001" }
}
```

**Estado Credo:** `ConnectionRecord` = `completed`.

**En paralelo, bridge inicia el lado WACI** (sin DID Exchange):

```json
{
  "type": "https://didcomm.org/present-proof/3.0/propose-presentation",
  "id": "bridge-waci-001",
  "pthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "to": ["did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw"],
  "body": {}
}
```

→ `packMessage()` → JWE → Socket.IO al verifier.

| Transformación | Credo (wallet) | WACI (bridge → verifier) |
|---|---|---|
| Primer mensaje de flujo | `didexchange/2.0/response` | `present-proof/3.0/propose-presentation` |
| Threading | `~thread.thid` | `pthid` = invitationId WACI original |
| DID emisor | `did:key:...` (wallet) | `did:quarkid:...` (proxy holder del bridge) |
| Transporte | HTTP POST `/didcomm` | Socket.IO emit |

**Redis actualizado:** `threadMap.waciThidPropose = "bridge-waci-001"`

---

#### Paso 2 — Verifier WACI → Bridge: RequestPresentation

**Mensaje WACI entrante (JWE descifrado por bridge):**

```json
{
  "type": "https://didcomm.org/present-proof/3.0/request-presentation",
  "id": "msg-002-request",
  "thid": "bridge-waci-001",
  "pthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiBridgeProxyHolder000000000000000000000"],
  "body": {},
  "attachments": [{
    "id": "pd-001",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/definitions@v1.0",
    "data": {
      "json": {
        "presentation_definition": {
          "id": "pd-generic-credential",
          "input_descriptors": [{
            "id": "generic-credential-card",
            "name": "Credencial Genérica",
            "constraints": {
              "fields": [{
                "path": ["$.type"],
                "filter": { "type": "array", "contains": { "const": "GenericCredential" } }
              }]
            }
          }]
        }
      }
    }
  }]
}
```

**Bridge traduce y envía al wallet (Credo v2):**

```json
{
  "type": "https://didcomm.org/present-proof/2.0/request-presentation",
  "id": "bridge-credo-002",
  "~thread": {
    "thid": "bridge-credo-001",
    "pthid": "bridge-oob-001"
  },
  "from": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "to": ["did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"],
  "body": {
    "goal_code": "streamlined-vp",
    "comment": "Legacy WACI verification via bridge",
    "will_confirm": true
  },
  "attachments": [{
    "id": "request-0",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/definitions@v1.0",
    "data": {
      "json": {
        "presentation_definition": {
          "id": "pd-generic-credential",
          "input_descriptors": [{
            "id": "generic-credential-card",
            "name": "Credencial Genérica",
            "constraints": {
              "fields": [{
                "path": ["$.type"],
                "filter": { "type": "array", "contains": { "const": "GenericCredential" } }
              }]
            }
          }]
        }
      }
    }
  }]
}
```

| Campo | WACI 3.0 (entrada) | Credo 2.0 (salida) |
|---|---|---|
| `type` | `present-proof/3.0/request-presentation` | `present-proof/2.0/request-presentation` |
| `thid` | `bridge-waci-001` | `~thread.thid` = `bridge-credo-001` (nuevo ID interno bridge) |
| `pthid` | `d9fa48b9-...` (invitation WACI) | `~thread.pthid` = `bridge-oob-001` (invitation Credo) |
| `from` | `did:quarkid:EiDm7iyd...` (verifier real) | `did:peer:2:Ez6L...` (bridge como verifier proxy) |
| `to` | `did:quarkid:EiBridge...` | `did:key:...` (wallet) |
| Adjunto PEX | `dif/presentation-exchange/definitions@v1.0` | Igual (PEX es compatible) |
| UX pausa WACI | En miba-connect: webhook + `presentation-proceed` | Bridge **no pausa**: reenvía directo; la wallet Credo auto-selecciona credenciales |

**Redis:** guarda `waciThidRequest = "msg-002-request"`, `credoThidRequest = "bridge-credo-002"`, copia del `presentation_definition`.

---

#### Paso 3 — Wallet → Bridge: Presentation

**Mensaje Credo entrante (wallet firma VP con Ed25519):**

```json
{
  "type": "https://didcomm.org/present-proof/2.0/presentation",
  "id": "wallet-pres-003",
  "~thread": { "thid": "bridge-credo-002", "pthid": "bridge-oob-001" },
  "from": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
  "to": ["did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab"],
  "body": {},
  "attachments": [{
    "id": "presentation-0",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/submission@v1.0",
    "data": {
      "json": {
        "presentation_submission": {
          "id": "ps-001",
          "definition_id": "pd-generic-credential",
          "descriptor_map": [{
            "id": "generic-credential-card",
            "format": "ldp_vc",
            "path": "$.verifiableCredential[0]"
          }]
        },
        "verifiablePresentation": {
          "@context": ["https://www.w3.org/2018/credentials/v1"],
          "type": ["VerifiablePresentation"],
          "holder": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
          "verifiableCredential": [{
            "@context": [
              "https://www.w3.org/2018/credentials/v1",
              "https://w3id.org/security/suites/ed25519-2020/v1"
            ],
            "type": ["VerifiableCredential", "GenericCredential"],
            "issuer": { "id": "did:quarkid:EiIssuerFake123" },
            "credentialSubject": {
              "id": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
              "nombre": "Juan Ficticio"
            },
            "proof": { "type": "Ed25519Signature2020" }
          }],
          "proof": { "type": "Ed25519Signature2020" }
        }
      }
    }
  }]
}
```

**Bridge traduce para WACI (re-firma BBS+ en el límite):**

```json
{
  "type": "https://didcomm.org/present-proof/3.0/presentation",
  "id": "bridge-waci-003",
  "thid": "msg-002-request",
  "pthid": "d9fa48b9-1e67-499e-bfcd-53ee96aec52f",
  "from": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "to": ["did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw"],
  "attachments": [{
    "id": "presentation-0",
    "media_type": "application/json",
    "format": "dif/presentation-exchange/submission@v1.0",
    "data": {
      "json": {
        "presentation_submission": {
          "id": "ps-001",
          "definition_id": "pd-generic-credential",
          "descriptor_map": [{
            "id": "generic-credential-card",
            "format": "ldp_vc",
            "path": "$.verifiableCredential[0]"
          }]
        },
        "verifiablePresentation": {
          "@context": [
            "https://www.w3.org/2018/credentials/v1",
            "https://w3id.org/security/bbs/v1"
          ],
          "type": ["VerifiablePresentation"],
          "holder": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
          "verifiableCredential": [{
            "@context": [
              "https://www.w3.org/2018/credentials/v1",
              "https://w3id.org/security/bbs/v1"
            ],
            "type": ["VerifiableCredential", "GenericCredential"],
            "issuer": { "id": "did:quarkid:EiIssuerFake123" },
            "credentialSubject": {
              "id": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
              "nombre": "Juan Ficticio"
            },
            "proof": { "type": "BbsBlsSignature2020" }
          }],
          "proof": { "type": "BbsBlsSignature2020" }
        }
      }
    }
  }]
}
```

| Transformación crítica | Entrada Credo | Salida WACI |
|---|---|---|
| Versión mensaje | `present-proof/2.0/presentation` | `present-proof/3.0/presentation` |
| Threading | `~thread.thid` | `thid` = `msg-002-request` (mapeado desde Redis) |
| Threading | `~thread.pthid` | `pthid` = invitation WACI original |
| Firma VC/VP | `Ed25519Signature2020` | `BbsBlsSignature2020` (re-firma en bridge) |
| `holder` / `credentialSubject.id` | `did:key:...` | `did:quarkid:EiBridge...` (proxy) |
| Adjunto | PEX submission (igual formato) | PEX submission (igual formato) |

→ JWE → Socket.IO al verifier.

**Nota:** Si el verifier WACI valida que `credentialSubject.id` coincida con el holder original de miba-connect, el bridge debe mantener un mapeo `did:key` ↔ `did:quarkid` por sesión o exigir que la wallet tenga DID legacy registrado.

---

#### Paso 4 — Verifier WACI → Bridge → Wallet: ACK

**Mensaje WACI entrante:**

```json
{
  "type": "https://didcomm.org/present-proof/3.0/ack",
  "id": "msg-004-ack",
  "thid": "bridge-waci-003",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiBridgeProxyHolder000000000000000000000"],
  "body": { "status": "OK" }
}
```

**Bridge traduce al wallet:**

```json
{
  "type": "https://didcomm.org/present-proof/2.0/ack",
  "id": "bridge-credo-004",
  "~thread": { "thid": "wallet-pres-003" },
  "from": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "to": ["did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"],
  "body": { "status": "OK" }
}
```

**Bridge notifica vía REST (alternativa/complemento al DIDComm):**

```http
POST /v1/bridge/verify/poll
```

```json
{
  "sessionId": "sess-bridge-7f3a"
}
```

**Respuesta:**

```json
{
  "status": "verified",
  "verified": true,
  "verifierDid": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw"
}
```

**Bridge limpia:** cierra Socket.IO, borra sesión Redis, estado Credo = `done`.

---

### 5.B — Verificación con bridge (fallida)

Mismos pasos 0–3 del 5.A. En el paso 4 el verifier WACI responde:

```json
{
  "type": "https://didcomm.org/report-problem/2.0/problem-report",
  "id": "msg-004-error",
  "thid": "bridge-waci-003",
  "from": "did:quarkid:EiDm7iydSlUhcKyUlApwo1_EtI4oJp5tYCgWZ_qq8ihapw",
  "to": ["did:quarkid:EiBridgeProxyHolder000000000000000000000"],
  "body": {
    "code": "signature_verification_failed",
    "comment": "Invalid BbsBlsSignature2020 proof"
  }
}
```

**Bridge traduce al wallet:**

```json
{
  "type": "https://didcomm.org/report-problem/2.0/problem-report",
  "id": "bridge-credo-error-004",
  "~thread": { "thid": "wallet-pres-003" },
  "from": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "to": ["did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"],
  "body": {
    "code": "signature_verification_failed",
    "comment": "Verifier rejected presentation (translated from WACI legacy)"
  }
}
```

**REST poll response:**

```json
{
  "status": "rejected",
  "verified": false,
  "error": {
    "code": "signature_verification_failed",
    "comment": "Invalid BbsBlsSignature2020 proof"
  }
}
```

---

### 5.C — Emisión con bridge (feliz)

Flujo: **Wallet Credo ↔ Bridge ↔ Issuer WACI (`generic-issuer-back`)**

Setup adicional:

| Actor | DID |
|---|---|
| Issuer WACI | `did:quarkid:EiIssuerFake123` |
| OOB emisión ID | `inv-emision-001` |
| `goal_code` | `streamlined-vc` |

#### Paso 0 — Wallet escanea QR de emisión

```http
POST /v1/bridge/issue/start
```

```json
{
  "waciInvitation": "didcomm://?_oob=<base64 con goal_code streamlined-vc>",
  "walletDid": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"
}
```

Bridge devuelve `sessionId` + `credoInvitationUrl` (OOB sintético con `goal_code: streamlined-vc` y DID Exchange, mismo patrón que 5.A paso 0).

#### Paso 1 — DID Exchange + ProposeCredential WACI

| Lado Credo | Lado WACI |
|---|---|
| Wallet manda `didexchange/2.0/response` | Bridge manda `issue-credential/3.0/propose-credential` |
| Bridge responde `didexchange/2.0/complete` | `pthid: inv-emision-001`, `from: did:quarkid:EiBridge...` |

**Mensaje WACI (bridge → issuer):**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/propose-credential",
  "id": "bridge-waci-101",
  "pthid": "inv-emision-001",
  "from": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "to": ["did:quarkid:EiIssuerFake123"],
  "body": {}
}
```

#### Paso 2 — OfferCredential: Manifest WACI → JSON-LD Credo

**WACI entrante (issuer → bridge):**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/offer-credential",
  "id": "msg-102",
  "thid": "bridge-waci-101",
  "from": "did:quarkid:EiIssuerFake123",
  "to": ["did:quarkid:EiBridgeProxyHolder000000000000000000000"],
  "attachments": [
    {
      "format": "dif/credential-manifest/manifest@v1.0",
      "data": { "json": { "credential_manifest": { "id": "manifest-001", "output_descriptors": [] } } }
    },
    {
      "format": "dif/credential-manifest/fulfillment@v1.0",
      "data": { "json": { "credential_fulfillment": { "id": "fulfillment-001", "manifest_id": "manifest-001" }, "verifiableCredential": [] } }
    }
  ]
}
```

**Credo saliente (bridge → wallet):**

```json
{
  "type": "https://didcomm.org/issue-credential/2.0/offer-credential",
  "id": "bridge-credo-102",
  "~thread": { "thid": "bridge-credo-101", "pthid": "bridge-oob-vc-001" },
  "from": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "to": ["did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"],
  "body": {
    "goal_code": "streamlined-vc",
    "credential_preview": {
      "@type": "https://didcomm.org/issue-credential/2.0/credential-preview",
      "attributes": [
        { "name": "nombre", "value": "Juan Ficticio" }
      ]
    }
  },
  "attachments": [{
    "id": "credential-0",
    "media_type": "application/json",
    "format": "aries/ld-proof-vc-detail@v1.0",
    "data": {
      "json": {
        "@context": ["https://www.w3.org/2018/credentials/v1"],
        "type": ["VerifiableCredential", "GenericCredential"],
        "credentialSubject": {
          "id": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
          "nombre": "Juan Ficticio"
        }
      }
    }
  }]
}
```

| Transformación | WACI 3.0 | Credo 2.0 |
|---|---|---|
| Tipo | `issue-credential/3.0/offer-credential` | `issue-credential/2.0/offer-credential` |
| Adjuntos | Credential Manifest + Fulfillment template | `credential_preview` + `aries/ld-proof-vc-detail` |
| Metadata manifest | `output_descriptors[]` del manifest | Extraídos a `credential_preview.attributes` |
| Threading | `thid` plano | `~thread.thid` / `~thread.pthid` |

**Opcional UX:** Bridge puede pausar aquí y notificar al frontend ("¿Aceptás esta credencial?") antes de reenviar al wallet — equivalente al webhook `PRESENTATION_REQUEST` de miba-connect pero para emisión.

#### Paso 3 — RequestCredential

**Credo entrante (wallet → bridge):**

```json
{
  "type": "https://didcomm.org/issue-credential/2.0/request-credential",
  "id": "wallet-req-103",
  "~thread": { "thid": "bridge-credo-102" },
  "from": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
  "to": ["did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab"],
  "body": { "comment": "Please issue the credential" }
}
```

**WACI saliente (bridge → issuer):**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/request-credential",
  "id": "bridge-waci-103",
  "thid": "msg-102",
  "from": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "to": ["did:quarkid:EiIssuerFake123"],
  "attachments": [{
    "format": "dif/credential-manifest/application@v1.0",
    "data": {
      "json": {
        "credential_application": {
          "id": "app-001",
          "manifest_id": "manifest-001"
        }
      }
    }
  }]
}
```

| Transformación | Credo 2.0 | WACI 3.0 |
|---|---|---|
| Body | `comment` simple | `credential_application` reconstruido desde manifest guardado en Redis |
| Adjunto | Ausente o mínimo | `dif/credential-manifest/application@v1.0` obligatorio |

#### Paso 4 — IssueCredential: BBS+ → Ed25519

**WACI entrante (issuer → bridge):**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/issue-credential",
  "id": "msg-104",
  "thid": "bridge-waci-103",
  "from": "did:quarkid:EiIssuerFake123",
  "to": ["did:quarkid:EiBridgeProxyHolder000000000000000000000"],
  "attachments": [{
    "format": "dif/credential-manifest/fulfillment@v1.0",
    "data": {
      "json": {
        "credential_fulfillment": { "id": "fulfillment-002", "manifest_id": "manifest-001" },
        "verifiableCredential": [{
          "@context": [
            "https://www.w3.org/2018/credentials/v1",
            "https://w3id.org/security/bbs/v1"
          ],
          "type": ["VerifiableCredential", "GenericCredential"],
          "issuer": { "id": "did:quarkid:EiIssuerFake123" },
          "credentialSubject": {
            "id": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
            "nombre": "Juan Ficticio"
          },
          "proof": { "type": "BbsBlsSignature2020" }
        }]
      }
    }
  }]
}
```

**Credo saliente (bridge → wallet):**

```json
{
  "type": "https://didcomm.org/issue-credential/2.0/issue-credential",
  "id": "bridge-credo-104",
  "~thread": { "thid": "wallet-req-103" },
  "from": "did:peer:2:Ez6LSGH6YE4D2BFQ2DZPTofBvnnJtDxfYWBgtDnTdV12ab",
  "to": ["did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK"],
  "attachments": [{
    "id": "credential-0",
    "media_type": "application/json",
    "format": "aries/ld-proof-vc-detail@v1.0",
    "data": {
      "json": {
        "@context": [
          "https://www.w3.org/2018/credentials/v1",
          "https://w3id.org/security/suites/ed25519-2020/v1"
        ],
        "type": ["VerifiableCredential", "GenericCredential"],
        "issuer": { "id": "did:quarkid:EiIssuerFake123" },
        "credentialSubject": {
          "id": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
          "nombre": "Juan Ficticio"
        },
        "proof": { "type": "Ed25519Signature2020" }
      }
    }
  }]
}
```

| Transformación crítica | WACI (entrada) | Credo (salida) |
|---|---|---|
| Adjunto | Manifest fulfillment + VC BBS+ | `aries/ld-proof-vc-detail` con VC Ed25519 |
| Firma | `BbsBlsSignature2020` | `Ed25519Signature2020` (bridge verifica BBS+, re-emite) |
| `credentialSubject.id` | `did:quarkid:EiBridge...` | `did:key:...` (wallet real) |
| Issuer DID | `did:quarkid:EiIssuerFake123` | Igual (wallet necesita resolver `did:quarkid` vía `quark-resolver`) |

#### Paso 5 — ACK bidireccional

**Wallet → Bridge:**

```json
{
  "type": "https://didcomm.org/issue-credential/2.0/ack",
  "id": "wallet-ack-105",
  "~thread": { "thid": "bridge-credo-104" },
  "body": { "status": "OK" }
}
```

**Bridge → Issuer WACI:**

```json
{
  "type": "https://didcomm.org/issue-credential/3.0/ack",
  "id": "bridge-waci-105",
  "thid": "msg-104",
  "from": "did:quarkid:EiBridgeProxyHolder000000000000000000000",
  "to": ["did:quarkid:EiIssuerFake123"],
  "body": { "status": "OK" }
}
```

**REST poll:**

```json
{
  "sessionId": "sess-bridge-issue-8b2c",
  "status": "completed",
  "credential": {
    "id": "urn:uuid:vc-bridge-001",
    "type": ["VerifiableCredential", "GenericCredential"]
  }
}
```

---

### 5.D — Tabla maestra de traducción (todos los message types)

#### Verificación

| # | Dirección | WACI 3.0 | Bridge | Credo 2.0 |
|---|---|---|---|---|
| 0 | Wallet → Bridge | — | Decodifica OOB WACI, sintetiza OOB Credo | Recibe OOB con DID Exchange |
| 1 | Wallet ↔ Bridge | — | Completa DID Exchange | `didexchange/2.0/response` → `complete` |
| 1b | Bridge → WACI | `present-proof/3.0/propose-presentation` | Traduce handshake → propose | — |
| 2 | WACI → Bridge → Wallet | `present-proof/3.0/request-presentation` | Mapea thread + versión | `present-proof/2.0/request-presentation` |
| 3 | Wallet → Bridge → WACI | — | Re-firma Ed25519 → BBS+ | `present-proof/2.0/presentation` → `3.0/presentation` |
| 4 | WACI → Bridge → Wallet | `present-proof/3.0/ack` o `problem-report` | Mapea thread + versión | `present-proof/2.0/ack` o `problem-report` |

#### Emisión

| # | Dirección | WACI 3.0 | Bridge | Credo 2.0 |
|---|---|---|---|---|
| 0 | Wallet → Bridge | — | Decodifica OOB, sintetiza OOB Credo | OOB + DID Exchange |
| 1 | Bridge → WACI | `issue-credential/3.0/propose-credential` | Post-DID-Exchange | — |
| 2 | WACI → Bridge → Wallet | `offer-credential` + Manifest | Manifest → `credential_preview` | `issue-credential/2.0/offer-credential` |
| 3 | Wallet → Bridge → WACI | — | Reconstruye `credential_application` | `issue-credential/2.0/request-credential` → `3.0/request-credential` |
| 4 | WACI → Bridge → Wallet | `issue-credential` + BBS+ fulfillment | BBS+ → Ed25519 | `issue-credential/2.0/issue-credential` |
| 5 | Wallet → Bridge → WACI | — | Mapea ack | `ack/2.0` → `ack/3.0` |

#### Transformaciones transversales (cada hop)

| Dimensión | Regla del bridge |
|---|---|
| Versión protocolo | `3.0` ↔ `2.0` en el campo `type` |
| Thread IDs | `pthid` ↔ `~thread.pthid`, `thid` ↔ `~thread.thid` (tabla en Redis por sesión) |
| Transporte | HTTP JWE (Credo) ↔ Socket.IO JWE (WACI) — descifra y re-cifra con claves del lado destino |
| Firma cripto | `BbsBlsSignature2020` ↔ `Ed25519Signature2020` en el límite (verifica + re-emite) |
| DID method | `did:quarkid` (lado WACI) ↔ `did:key` / `did:peer:2` (lado Credo) con proxy holder |
| QR param | `_oob` → `oob` al sintetizar invitación |
| DID Exchange | Ausente en WACI → bridge lo inyecta al sintetizar OOB para Credo |
| Pausa UX | `presentation-proceed` de miba-connect → opcional en bridge vía REST/SSE al frontend |

---

### 5.E — Diagrama secuencial verificación con bridge

```
Wallet (Credo)          quark-bridge              Verifier (WACI)
     │                       │                          │
     │ POST /bridge/verify/start (OOB WACI)            │
     │──────────────────────►│                          │
     │◄─ credoInvitationUrl ─│                          │
     │                       │                          │
     │ didexchange/response  │                          │
     │──────────────────────►│ propose-presentation/3.0 │
     │◄─ didexchange/complete│─────────────────────────►│
     │                       │◄─ request-presentation/3.0
     │◄─ request-presentation/2.0 (traducido)           │
     │                       │                          │
     │ presentation/2.0      │                          │
     │  (Ed25519 VP)         │                          │
     │──────────────────────►│ presentation/3.0         │
     │                       │  (BBS+ VP re-firmada)    │
     │                       │─────────────────────────►│
     │                       │◄─ ack/3.0 ──────────────│
     │◄─ ack/2.0 ────────────│                          │
     │                       │                          │
     │ POST /bridge/verify/poll                         │
     │◄─ { verified: true } ─│                          │
```

---

### 5.F — Riesgos y puntos de fallo del bridge (ficticios → reales)

| Punto | Qué puede romper | Mitigación |
|---|---|---|
| Mapeo `did:key` ↔ `did:quarkid` | Verifier WACI valida holder `did:quarkid` específico | Registrar DID legacy del usuario o proxy por sesión |
| Re-firma BBS+ | Pérdida de prueba original del issuer | Documentar que la VC en wallet es "bridge-attested"; idealmente agregar `BbsBlsSignature2020` a `identity-core` |
| Resolver `did:quarkid` | Wallet no puede verificar issuer legacy | `quark-resolver` con estrategia Modena (complementario al bridge) |
| Thread ID desincronizado | Mensaje huérfano si Redis expira | TTL generoso + cleanup en error + `problem-report` al wallet |
| Socket.IO desconectado | Bridge pierde sesión WACI mid-flight | Reconnect con mismo `pthid` desde storage WACI pattern |
| Manifest sin `output_descriptors` | Preview vacío en Credo | Defaults desde template del issuer o metadata REST |

---

**Fin del documento**
