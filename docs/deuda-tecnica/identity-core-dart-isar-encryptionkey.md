# Deuda técnica: `identity-core-dart` — clave de cifrado en `RecordStore.open`

**Estado:** mitigado (junio 2026) — ver [wallet PIN / cifrado campo](tickets.md) (finalizado).

## Contexto original

`WalletService` deriva una clave de 32 bytes con **Argon2id(PIN + salt)** y la pasa a `RecordStore.open` como `encryptionKey`, con la intención de abrir Isar cifrado con AES-256.

## Qué sigue sin resolverse (motor Isar 3)

El parámetro **`encryptionKey`** en `RecordStore.open` **no se aplica al motor Isar** (`encryptionKey ignored` en `record_store.dart`). El fichero `.isar` completo **no** queda cifrado por esa clave.

## Mitigación implementada (Ruta C)

| Problema | Solución |
|---|---|
| PIN incorrecto abre sesión | Hash Argon2id en secure storage (`wallet_pin_hash_*`) → `WrongPinError` antes de abrir Isar |
| Credenciales/claves legibles en disco | Cifrado AES-256-GCM por campo (`enc:v1:`) en `KeyRecordStore`, `CredentialRecordStore`, `DeferredCredentialRecordStore` vía `WalletCryptoContext` |

**Rama:** `feat/field-cipher-pin-hash` en `identity-core-dart`.

## Pendiente opcional

- Migración automática de registros legacy en texto plano (PR3).
- `android:allowBackup="false"` en `quark-wallet`.
- Cifrado de metadatos / archivo `.isar` completo (requeriría Isar 4, Drift/SQLCipher u otra vía).

## Archivos relevantes

- `packages/identity-core-dart/lib/src/record/record_store.dart`
- `packages/identity-core-dart/lib/src/crypto/`
- `packages/identity-core-dart/lib/src/wallet/wallet_service.dart`
- `packages/identity-core-dart/docs/07-limitations.md` (#1)
