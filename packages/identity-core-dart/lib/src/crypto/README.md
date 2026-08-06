# crypto

Cifrado de campos, verificación de PIN y firmas LDP para presentaciones DIDComm.

## Componentes

| Archivo / carpeta | Rol |
|---------|-----|
| `field_cipher.dart` | AES-256-GCM; formato `enc:v1:` + base64 |
| `wallet_crypto_context.dart` | Clave de sesión en memoria + `FieldCipher` |
| `pin_verifier.dart` | Argon2id: clave de cifrado y hash de PIN (dominios separados) |
| `ldp/` | Contextos JSON-LD + `Ed25519Signature2018` para VP DIDComm (URDNA2015) |

## Uso

`WalletService` crea `WalletCryptoContext` al desbloquear. Los stores sensibles cifran campos con `RecordStore.cryptoContext` / `session.cryptoContext`.

Las VP DIDComm se firman con `DidCommPresentationBuilder` → `ldp/ed25519_signature_2018.dart`. Los contextos estáticos se regeneran con `packages/identity-core/scripts/export-ldp-contexts.mjs`.

## Campos protegidos

| Store | Campos cifrados |
|---|---|
| `KeyRecordStore` | `privateJwkJson` (null si hardware-backed) |
| `CredentialRecordStore` | SD-JWT, W3C y mDoc — ver [docs/05-reference/01-stores.md](../../../docs/05-reference/01-stores.md#cifrado-por-campo) |
| `DeferredCredentialRecordStore` | `accessTokenJson`, `responseJson` |

Valores legacy sin prefijo `enc:v1:` se leen sin modificar hasta reescritura o migración (PR3 pendiente).

## Errores

`FieldCipherError` — descifrado fallido (PIN/clave distinta o payload corrupto). No loguear valores cifrados ni claves.
