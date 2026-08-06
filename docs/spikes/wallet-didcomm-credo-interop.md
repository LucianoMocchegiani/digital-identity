# Spike Fase 0 — Wallet Dart ↔ Issuer/Verifier Credo (Quark 2)

> **Obsoleto (julio 2026).** El handshake, Envelope V1 y `DidCommFlowSession` ya están en el SDK.
> Los endpoints HTTP legacy (`create-invitation`, `connections`) se reemplazaron por
> `POST .../didcomm/offer` y `POST .../didcomm/request`. Ver
> `packages/identity-core-dart/docs/04-flows/04-didcomm.md` y Postman `Quark-Flujos-DIDComm-OID4VC`.

**Fecha:** 2026-07-14  
**Estado:** Histórico — hallazgos de Fase 0  
**Plan padre:** `.claude/ai-work-flow-registry/plans/QUARK-PENDING-wallet-didcomm-quark2_2026-07-14.md`  
**Entorno:** Docker local `issuer :9001`, `holder :9005`, tunnel `issuer.pruebasaproduccunon.uno`

---

## Objetivo

Validar qué debe cambiar `identity-core-dart` para completar DID Exchange y recibir mensajes del `quark-issuer-service` / `quark-verifier-service` (Credo 0.7 vía `identity-core`).

---

## Setup usado

```bash
# Issuer saludable
curl http://localhost:9001/v1/health
# → {"ok":true}

# Crear invitación DIDComm (tenant gcba-issuer)
curl -X POST http://localhost:9001/v1/issuers/gcba-issuer/didcomm/create-invitation \
  -H "Content-Type: application/json" -d "{}"
```

**Respuesta ejemplo (2026-07-14):**

```json
{
  "invitation": "https://issuer.pruebasaproduccunon.uno?oob=eyJ..."
}
```

**OOB decodificado (Credo real):**

```json
{
  "@type": "https://didcomm.org/out-of-band/1.1/invitation",
  "@id": "f9e25b72-92da-45a0-bcfd-a5108a37ad87",
  "accept": ["didcomm/aip1", "didcomm/aip2;env=rfc19"],
  "handshake_protocols": [
    "https://didcomm.org/didexchange/1.1",
    "https://didcomm.org/connections/1.0"
  ],
  "services": [{
    "id": "#inline-0",
    "serviceEndpoint": "https://issuer.pruebasaproduccunon.uno/didcomm",
    "type": "did-communication",
    "recipientKeys": ["did:key:z6MkrT4WXsBmE8NHQv9m3TPLZtAPko6avwfPAsZ95Qrjt1gJ"],
    "routingKeys": []
  }]
}
```

---

## Hallazgo 1 — Credo no usa OOB 2.0 / didexchange 2.0 en la invitación

| Campo | Credo (issuer real) | Dart SDK hoy |
|---|---|---|
| OOB | `out-of-band/1.1/invitation` | Docs asumen 2.0 en varios lugares |
| Handshake | `didexchange/1.1` + `connections/1.0` | `didexchange/1.0/request` en `connection_service.dart` |
| AIP | `didcomm/aip1`, `aip2;env=rfc19` | No negociado explícitamente |
| Endpoint | `https://<dominio>/didcomm` | `HttpTransport` POST al endpoint del OOB |

**Acción Fase 1:** alinear a **didexchange/1.1** (y evaluar soporte `connections/1.0` legacy o rechazo explícito).

---

## Hallazgo 2 — Baseline Credo TS funciona (holder-service)

```bash
# Provision holder
curl -X POST http://localhost:9005/v1/holders \
  -H "Content-Type: application/json" \
  -d '{"holderId":"spike-holder-01"}'

# Recibir misma invitation URL
curl -X POST http://localhost:9005/v1/holders/spike-holder-01/didcomm/receive-invitation \
  -H "Content-Type: application/json" \
  -d @local/spike/receive-invitation-body.json
# → {"ok":true,"outOfBandRecordId":"..."}

# Tras ~8s — conexión completed en ambos lados
curl http://localhost:9005/v1/holders/spike-holder-01/didcomm/connections
curl http://localhost:9001/v1/issuers/gcba-issuer/didcomm/connections
# → state: "completed"
```

El backend Quark 2 **sí** establece DIDComm contra el tunnel público. El gap está **solo en el SDK Dart**.

---

## Hallazgo 3 — `recipientKeys` del OOB es `did:key` Ed25519

La clave en `recipientKeys` es **Ed25519** (`did:key:z6Mk...`), no X25519 directo.

El Dart SDK intenta derivar X25519 vía `DidKey.resolve()` → `keyAgreement` en el DID Document del issuer (`did:web` en `/{walletId}/did.json`). **Hay que verificar** que esa resolución funciona desde el móvil (HTTP a `issuer.../gcba-issuer/did.json`).

Si falla la resolución, `_sendRequest` cae a **JSON plano** (`transport.send` sin JWE) — Credo en prod probablemente **rechaza** mensajes sin cifrar.

---

## Hallazgo 4 — Cifrado Dart vs Credo (actualizado 2026-07-14)

| | Dart (`didcomm_envelope_v1.dart`) | Credo (`identity-core`) |
|---|---|---|
| Content-Type HTTP | `application/didcomm-envelope-enc` | `application/didcomm-envelope-enc` |
| Envelope alg | `Anoncrypt` + `xchacha20poly1305_ietf` | Igual (DIDComm v1) |
| CEK wrap (anoncrypt) | `nacl.box` efímero: `ephem_pk(32)‖nonce(24)‖box(cek)` | `InternalKeyManagementService` + tweetnacl (`internal.kms.ts`) |
| Ed25519→X25519 | `crypto_sign_ed25519_pk_to_curve25519` | `convertTo(X25519PublicJwk)` |
| DID Exchange | `didexchange/1.1/request` | `didexchange/1.1/request` |

**Fix aplicado (Fase 1 parcial):** `DidCommEnvelopeV1` + `HttpTransport` alineados a Credo. El **415** del spike queda resuelto.

**Hallazgo 500 (2026-07-15):** Tras el fix de Content-Type, el issuer acepta el POST pero falla al descifrar/procesar. Causas probables corregidas en código:
- Payload C20P ahora usa `crypto_aead_chacha20poly1305_ietf` (libsodium), no `cryptography` ChaCha20 genérico.
- DID Exchange request para `did:peer:2` ya no envía `did_doc~attach` sin firmar (Credo resuelve el DID desde el campo `did`).

**Pendiente:** procesar `didexchange/1.1/response` (HTTP response o WS) para `ConnectionState.complete`.

---

## Hallazgo 5 — Inbound al holder: WS, no solo HTTP

`quark-issuer-service/main.ts` monta `WebSocketServer` en el **mismo** `httpServer` que Express/Credo.

El holder Credo completa el handshake en ~8s: el issuer envía la **response** por el canal que Credo negocia (HTTP response + WS inbound en el agente holder).

Para la **wallet móvil**:

- El `did:peer:2` que genera Dart **no incluye `serviceEndpoint`** (sin `services` en `DidPeer.create`) → el issuer **no tiene URL** para empujar mensajes al teléfono por HTTP.
- **Conclusión:** la wallet debe abrir **WebSocket cliente** hacia el host del issuer/verifier durante el flujo (como acordamos en el plan) y recibir ahí `didexchange/response`, `offer-credential`, `request-presentation`, etc.

Path WS exacto: **pendiente** (Credo `DidCommWsInboundTransport` sobre el server Node — verificar si es `/` o subpath).

---

## Hallazgo 6 — Test Dart automatizado

Archivo: `packages/identity-core-dart/test/spike/didcomm_credo_interop_spike_test.dart`

```bash
cd packages/identity-core-dart
flutter test test/spike/didcomm_credo_interop_spike_test.dart \
  --dart-define=SPIKE_INVITATION_FILE=../../local/spike/receive-invitation-body.json
```

**Resultado 2026-07-14 en Windows:** falla al abrir Isar (`isar.dll` no encontrada en VM de test). El parse del OOB **sí corre** antes del fallo.

**Workaround spike:** ejecutar en dispositivo/emulador Android/iOS, o instalar libs Isar para Windows tests, o extraer `ConnectionService` a test sin Isar (helper futuro).

---

## Matriz de acciones (entrada a Fase 1)

| # | Gap | Acción |
|---|---|---|
| G1 | `didexchange/1.0` vs `1.1` | Cambiar `@type` y handlers a 1.1 |
| G2 | Sin procesar response | Parser `didexchange/1.1/response` + estado `complete` |
| G3 | Sin WS cliente | `WebSocketTransport` + loop durante flujo |
| G4 | JWE puede diferir | Capturar wire format Credo; alinear `DidCommPack`/`Unpack` |
| G5 | `did:peer` sin service | No necesario si inbound es WS al issuer (holder no expone HTTP público) |
| G6 | Sin persistencia exchange | Isar stores para credential/proof exchange (Fase 2–3) |
| G7 | Docs incorrectos | Actualizar `04-didcomm.md` y `07-limitations.md` |

---

## Comandos útiles (local)

| Acción | Comando |
|---|---|
| Invitación issuer | `POST /v1/issuers/gcba-issuer/didcomm/create-invitation` |
| Conexiones issuer | `GET /v1/issuers/gcba-issuer/didcomm/connections` |
| Offer credential | `POST /v1/issuers/gcba-issuer/didcomm/offer-credential` |
| Invitación verifier | `POST /v1/verifiers/{verifierId}/didcomm/create-invitation` |

Colección Postman: `postman/Quark-Flujos-DIDComm-OID4VC.postman_collection.json` (carpeta `01 - DIDComm Flow`).

---

## Próximos pasos inmediatos

1. [ ] Capturar JWE real del holder-service → issuer (log nivel debug o proxy local).
2. [ ] Confirmar path WebSocket (`wss://issuer.../`).
3. [ ] Probar `acceptInvitation` en emulador Android con invitation fresca.
4. [ ] Implementar G1–G3 en `identity-core-dart` (Fase 1 del plan).

---

**Fin del spike (iteración 1)**
