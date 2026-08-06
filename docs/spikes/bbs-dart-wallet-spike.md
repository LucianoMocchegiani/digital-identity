# Spike — BBS+ holder en identity-core-dart (continuación QUARK-990)

**Fecha:** 2026-07-27 (actualizado 2026-08-03)  
**Alcance:** verify + deriveProof en wallet Dart; emisión sigue en issuer TS.  
**Diseño nativo:** [`bbs-dart-native-design.md`](bbs-dart-native-design.md)

## Decisión de cripto

| Capa | Elección |
|---|---|
| LD (frame / paths PEX) | Dart — `reveal_frame.dart` + suite LD (fase 2) |
| Pairing BBS | Crate `native/bbs` (`bbs` 0.4.1) vía `dart:ffi` — paridad MATTR `blsCreateProof` / `blsVerifyProof` |
| Oracle CI / desktop derive completo | Bridge Node `tool/bbs_mattr_bridge.mjs` |
| VP binder | `Ed25519Signature2018` (sin cambios) |

## Fase 0 — cerrada

Split LD Dart + FFI pairing; Android primero; holder-only; Node no es runtime mobile.

## Fase 1 — en curso (pairing nativo)

**Hecho**

- Crate `packages/identity-core-dart/native/bbs` con ABI `quark_bbs_bls_*`.
- Golden MATTR: verify nativo OK; createProof nativo → MATTR `blsVerifyProof` → `verified: true`.
- Tests vía Docker (`native/bbs/scripts/test_docker.sh`) — host sin MSVC `link.exe`.
- `libbbs.so` en `android/src/main/jniLibs/{arm64-v8a,armeabi-v7a}/`.
- Dart `lib/src/credential/bbs/ffi/bbs_pairing.dart` (`FfiBbsPairingApi`).

**Pendiente fase 1**

- Smoke FFI en device Android (moto e14 = `armeabi-v7a`).
- iOS static lib (fase 1.5).
- Host Windows: VS Build Tools C++ para compilar sin Docker.

## Fase 3 — en curso (wallet)

**Hecho**

- `DidCommService.sendPresentation` resuelve `issuerDidDocument` (`DidService.resolve`) para VCs `BbsBlsSignature2020` y lo pasa al presentation builder.

**Pendiente**

- E2E en device Android (offer BBS → present SD → verifier Nest `isVerified`).
- Confirmar que el issuer Quark usa `did:web` resoluble desde el teléfono.


**Hecho**

- Canonize Dart == MATTR (document, reveal, proof options con `sec:BbsBlsSignature2020` + security/v2).
- Mensajes = proofStatements ++ documentStatements (el proof aporta blank node `_:c14n0` — no omitir).
- Round-trip: mensajes Dart → MATTR `blsCreateProof` + `jsigs.verify` → `verified: true`.
- Mobile: `DartBbsLdSuite`; desktop: bridge Node.

**Límite MVP:** reveal por strip (sin `jsonld.frame`); VCs sin blank nodes en el subject.

## Cómo probar pairing

```bash
cd packages/identity-core-dart/native/bbs
bash scripts/test_docker.sh
bash scripts/build_android_docker.sh   # regenera jniLibs
```
