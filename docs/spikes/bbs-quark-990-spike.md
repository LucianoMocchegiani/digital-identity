# Spike QUARK-990 — BBS+ en Credo-TS 0.7 + identity-core

**Fecha:** 2026-07-22  
**Ticket:** QUARK-990  
**Stack actual:** `@credo-ts/*@0.7.0`, KMS internal (Ed25519 + P-256)

## Hallazgos

### 1. `@credo-ts/bbs-signatures` no existe para Credo 0.7

- Última estable: `0.5.19` (peer `@credo-ts/core@0.5.19`).
- Hay alphas `0.6.0-*`; **no hay paquete 0.7**.
- En Credo 0.5 el módulo registraba `SignatureSuiteToken` + `Bls12381g2SigningProvider` y `KeyType.Bls12381g2`.

### 1.1 Por qué Credo sacó BBS (oficial)

Credo **deprecó y eliminó** el módulo BBS+ a propósito (no es un olvido de 0.7). Fuentes:

- Changelog Credo (`packages/core/CHANGELOG.md`, commit `e936068`): la implementación BBS+ en la que se basaban estaba **desactualizada, sin mantenimiento y no recomendada**. Sugieren extraer el código de una versión anterior o armar un módulo custom; dan la bienvenida a contribuciones del **BBS nuevo** (trabajo de SDOs / IETF CFRG).
- Issue [#2120 — Deprecate / remove BBS module?](https://github.com/openwallet-foundation/credo-ts/issues/2120) (Timo Glastra, dic 2024; cerrado ago 2025): el módulo casi no se usaba y ya no se recomendaba; posible reintroducción con una versión más nueva. Comentario de ACA-Py (swcurran): mismo problema — **sin artefacto ARM** de la lib BBS, dolor en CI/devs; lo sacaron del default.
- MATTR: `@mattrglobal/bbs-signatures` está **deprecated** a favor de `pairing_crypto` / [BBS Signature Scheme](https://www.ietf.org/archive/id/draft-irtf-cfrg-bbs-signatures-03.html) moderno.

**Implicación para Quark:** QUARK-990 usa a propósito el stack **legacy** (MATTR + `BbsBlsSignature2020`) para alinear con Extrimian/Quark 1. Es el camino que Credo abandonó; a medio plazo conviene vigilar el BBS IETF y un posible retorno en Credo.

### 2. Credo 0.7 eliminó BLS del modelo de claves

- `PublicJwk` soporta: Ed25519, X25519, P-256/384/521, secp256k1, RSA.
- **No** hay `Bls12381*PublicJwk`.
- `W3cCredentialsModule` solo registra `Ed25519Signature2018` / `2020`.
- `W3cJsonLdCredentialService.signCredential` exige que el `PublicJwk` de la verification method matchee `supportedPublicJwkTypes` de la suite → **no se puede enchufar BBS solo registrando un SuiteClass** sin que Credo entienda la clave BLS.

### 3. DIDComm JSON-LD firma vía Credo

`DidCommJsonLdCredentialFormatService.acceptRequest` siempre llama a `W3cJsonLdCredentialService.signCredential`. Para BBS hay que **interceptar** ese camino (subclass del format service o servicio propio de firma).

### 4. deriveProof sí existe en core 0.7

`@credo-ts/core` expone `deriveProof` (API temporal sobre JSON-LD signatures) que recibe `suite` + `revealDocument` + `nonce`. Utilizable si aportamos la suite BBS (MATTR / portada).

## Decisión de stack (cerrada para QUARK-990)

| Capa | Elección |
|---|---|
| Claves BLS / sign-verify BBS raw | `@mattrglobal/bls12381-key-pair` + `@mattrglobal/bbs-signatures` |
| Suites LD + deriveProof | `@mattrglobal/jsonld-signatures-bbs` (BbsBlsSignature2020 / Proof2020) |
| Integración Credo DIDComm | Format service Quark que, si `proofType` es BBS, firma/verifica con capa propia; si no, delega a Credo Ed25519 |
| KMS | Extender `InternalKeyManagementService` con Bls12381G2 (JWK custom / material Base58); external KMS ya declara el tipo |
| DID | Mismo `did:web` + `#key-bbs-ldp` (`Bls12381G2Key2020`) |
| Dart futuro | Misma semántica MATTR (WASM/FFI); no bloquear TS |

## Riesgos

- Binario opcional `node-bbs-signatures` (Linux/macOS x86); en Windows/ARM cae a WASM (más lento, OK para MVP).
- Interop byte-level con Extrimian depende de contexts/canonize idénticos — este ticket alinea suite + flujo, no garantiza WACI 3.0.
- Sin `PublicJwk` BLS, Credo no resolverá `#key-bbs-ldp` en APIs genéricas (`getPublicJwkFromVerificationMethod`); solo nuestro código BBS debe tocar esa VM.
- `KeyManagementApi.createKey` valida `type` con Zod (sin BLS): crear BLS vía `createBls12381G2Key` (backend internal directo), nunca `agent.kms.createKey({ type: { keyType: 'Bls12381G2' } })`.
- `signBbsCredential` / verify / derive deben usar `resolveBbsDocumentLoader` (Credo); sin loader falla con `credentials/v1 could not be fetched`.

## Go / No-go

**Go** con capa BBS propia + format service Quark.  
**No-go** esperar `@credo-ts/bbs-signatures@0.7` (no existe hoy).

## Siguiente paso de implementación

1. ~~KMS Bls12381G2~~  
2. ~~`#key-bbs-ldp` en WebDidRegistrar / ensureWebDid~~  
3. ~~Módulo `credential/bbs` (sign / verify / derive)~~  
4. ~~`QuarkJsonLdCredentialFormatService` + `QuarkDifPresentationExchangeProofFormatService`~~  
5. ~~Default `getProofOptions` → `BbsBlsSignature2020`~~  
6. Tests unitarios (parcial) + E2E local (volúmenes recreados) — pendiente en servicios Nest

## Estado cableado (present-proof)

- Holder/verifier agents registran `QuarkDifPresentationExchangeProofFormatService` (derive antes de VP; verify BBS en `processPresentation`).
- Holder `acceptOffer`: `proofType` del offer si viene; si no, default BBS.
- Servicios Nest ya dependen de `file:../../packages/identity-core` (rebuild + recrear volúmenes Docker).

## Continuación Dart / wallet (2026-07-27)

Ver [`bbs-dart-wallet-spike.md`](bbs-dart-wallet-spike.md): holder Dart con reveal frame + bridge MATTR (desktop/CI); native mobile pendiente.

## E2E wallet (desktop)

1. Rebuild issuer/verifier locales con identity-core BBS (ya en master).
2. Flutter desktop wallet con `identity_core_dart` path local (`feat/bbs-selective-disclosure`).
3. Offer BBS → scan/receive → store VC.
4. Request BBS SD (solo `name`) → share sheet muestra solo claims del PD → presentar.
5. `GET .../didcomm/request/:pendingRequestId` → `done` / `isVerified: true`.
6. Regresión Ed25519 offer+request completa.
