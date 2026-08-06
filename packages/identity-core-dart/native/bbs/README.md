# native/bbs — quark_bbs

Crate Rust (`bbs` 0.4.1) con ABI C compatible con `blsCreateProof` / `blsVerifyProof` de
`@mattrglobal/bbs-signatures@1.2.0` (QUARK-990).

## Criterio de hecho (cumplido)

1. `blsVerifyProof` nativo acepta proof golden MATTR.
2. `blsCreateProof` nativo produce proof que MATTR `blsVerifyProof` acepta (`verified: true`).
3. `libbbs.so` en `android/src/main/jniLibs/{arm64-v8a,armeabi-v7a}/`.

## Tests (Docker — sin MSVC en el host)

```bash
bash scripts/test_docker.sh
# opcional cross-check MATTR:
Get-Content testdata/last_created_proof.json -Raw | node ../../tool/bbs_verify_proof_mattr.mjs
```

## Build Android

```bash
bash scripts/build_android_docker.sh
```

## API

Ver `include/quark_bbs.h`. Diseño: `docs/spikes/bbs-dart-native-design.md`.
