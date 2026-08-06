# Diseño — BBS+ nativo en identity-core-dart

**Fecha:** 2026-08-03  
**Estado:** Fases 0–3 cerradas (E2E Android BBS SD verificado)  
**Relacionado:** [bbs-quark-990-spike.md](bbs-quark-990-spike.md), [bbs-dart-wallet-spike.md](bbs-dart-wallet-spike.md)

## Decisiones cerradas

| Tema | Decisión |
|---|---|
| Arquitectura | LD suite en Dart + pairing nativo (`bbs` 0.4.x, mismo linaje MATTR) vía `dart:ffi` |
| Binding | `dart:ffi` directo (no MethodChannel para cripto BBS) |
| Alcance wallet | Holder-only: `blsCreateProof` + `blsVerifyProof` (+ verify VC en Dart). Sin emisión BLS en KMS wallet |
| Plataformas | Android primero (`arm64-v8a`); iOS en fase 1.5 con el mismo crate |
| Verify en device | Implementar; E2E present-proof se valida con verifier Nest |
| Oracle CI | `tool/bbs_mattr_bridge.mjs` + goldens de pairing; no runtime mobile |
| Ubicación nativo | `packages/identity-core-dart/native/bbs/` empaquetado en el plugin Flutter |

## Por qué este corte

MATTR ya separa `jsonld-signatures-bbs` (LD) de `bbs-signatures` (Rust→WASM). Paradym separa Credo (orquestación) de AnonCreds/Askar nativos. Quark copia esa forma: el teléfono no corre Node; el verifier Nest exige el mismo esquema de mensajes que MATTR.

## Fases

0. Diseño (este doc) — evita atajos incompatibles.  
1. Spike nativo — `libbbs` + FFI + verify golden MATTR / createProof round-trip.  
2. Suite LD Dart — frame/canonize/índices/ensamblar `BbsBlsSignatureProof2020`; goldens vs bridge.  
3. Cableado wallet — runtime mobile suite+FFI; E2E device.  
4. Hardening — CI binarios, limitations, regresión Ed25519.

## Criterio de hecho Fase 1

1. `blsVerifyProof` nativo acepta un proof generado por `@mattrglobal/bbs-signatures@1.2.0`.  
2. `blsCreateProof` nativo produce un proof que MATTR `blsVerifyProof` acepta (proofs son aleatorios: no comparar bytes).  
3. Binario host (Windows/Linux/macOS) para tests; `jniLibs/arm64-v8a/libbbs.so` para Android.
