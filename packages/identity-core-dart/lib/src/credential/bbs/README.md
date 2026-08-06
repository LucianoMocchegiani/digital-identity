# credential/bbs (Dart)

Capa holder BBS+ para DIDComm present-proof (paridad QUARK-990).

## Piezas

| Archivo | Rol |
|---|---|
| `constants.dart` | Proof types |
| `reveal_frame.dart` | Paths PEX → frame |
| `materialize_reveal.dart` | Frame → doc revelado (MVP sin jsonld.frame) |
| `bbs_nquads.dart` / `bbs_verify_data.dart` | URDNA2015 → mensajes + índices |
| `bbs_ld_suite.dart` | Derive/verify LD + FFI |
| `bbs_crypto.dart` | Desktop Node oracle / mobile Dart+FFI |
| `ffi/bbs_pairing.dart` | `libbbs` `blsCreateProof` / `blsVerifyProof` |
| `claim_path_filter.dart` | UI claims según PD |

## Nativo

`native/bbs/` + `android/.../jniLibs/*/libbbs.so`.  
Diseño: `docs/spikes/bbs-dart-native-design.md`.
