---
id: dids
title: Referencia de DIDs
sidebar_position: 3
---

# Referencia de DIDs

Esta página documenta los métodos DID soportados por el SDK y la API de `DidService`, accesible desde la sesión activa como `session.dids`.

En los flujos habituales (OID4VCI, OID4VP) el SDK gestiona los DIDs de forma automática. El integrador solo necesita acceder a esta API en casos puntuales que se describen al final de este documento.

---

## Métodos soportados

| Método | Creación local | Key types soportados | Resolución |
|---|---|---|---|
| `did:key` | Sí | Ed25519, P-256 | Local (sin red) |
| `did:jwk` | Sí | Ed25519, P-256 | Local (sin red) |
| `did:peer` (numAlgo 2) | Sí (API de bajo nivel) | Ed25519 + X25519 | No integrada al resolver — usar `DidPeer.resolve()` directamente |
| `did:web` | No — solo resolución | — | HTTP GET a `/.well-known/did.json` o `/{path}/did.json` |

**Notas:**

- `did:key` y `did:jwk` son los únicos métodos que `DidService.ensureDid` puede crear. `did:peer` se construye mediante `DidPeer.create(...)` directamente y no se integra con el store por defecto.
- `did:web` solo se resuelve: el SDK hace un `GET` al endpoint canónico del DID Document. Para un DID sin segmentos de path (`did:web:example.com`) el endpoint es `https://example.com/.well-known/did.json`; con segmentos adicionales (`did:web:example.com:path:to`) el endpoint es `https://example.com/path/to/did.json`.
- Cualquier método distinto de `key`, `jwk` y `web` recibido por el resolver retorna `null`.

---

## API

### `ensureDid`

```dart
Future<String> ensureDid({
  required KeyType keyType,
  required String method,
})
```

Busca en el store un DID del `method` indicado que esté asociado a una clave del `keyType` indicado. Si existe, lo retorna; si no, genera una nueva clave, crea el DID correspondiente, guarda ambos en sus respectivos stores y retorna el DID creado.

- `keyType`: tipo de clave criptográfica. Los valores prácticos son `KeyType.ed25519` y `KeyType.p256`.
- `method`: método DID a usar. Valores válidos: `'key'` o `'jwk'`. Cualquier otro valor lanza `UnsupportedError`.

**Ejemplo:**

```dart
// Obtener (o crear) un did:key con Ed25519
final did = await session.dids.ensureDid(
  keyType: KeyType.ed25519,
  method: 'key',
);

// Obtener (o crear) un did:jwk con P-256
final didJwk = await session.dids.ensureDid(
  keyType: KeyType.p256,
  method: 'jwk',
);
```

---

### `getSigningDid`

```dart
Future<SigningDidInfo> getSigningDid(KeyType keyType)
```

Retorna el DID y la información de firma para el `keyType` indicado, creándolo si no existe. Internamente llama a `ensureDid` con el método preferido según el key type: `'jwk'` para P-256 y `'key'` para Ed25519.

El tipo de retorno `SigningDidInfo` es un record con tres campos:

| Campo | Tipo | Descripción |
|---|---|---|
| `did` | `String` | El DID completo (p. ej. `did:key:z6Mk...`). |
| `keyId` | `String` | UUID de la clave en el `keyStore`. Se puede obtener vía `session.keyStore.getById(keyId)` (equivalente a `DidRecord.keyIds.first`). |
| `verificationMethodId` | `String` | `id` del primer verification method en el DID Document (p. ej. `did:key:z6Mk...#z6Mk...`). |

> **Uso interno:** este método es utilizado internamente por los flujos OID4VCI y OID4VP para el holder binding. El integrador normalmente no necesita llamarlo directamente.

---

### `resolve`

```dart
Future<Map<String, dynamic>?> resolve(String did)
```

Resuelve `did` a su DID Document mediante el `UniversalDidResolver`. Retorna el documento como `Map<String, dynamic>` o `null` si el método no está soportado, el DID es inválido o la resolución HTTP falla (para `did:web`).

Métodos que el resolver puede resolver: `did:key`, `did:jwk` y `did:web`.

**Ejemplo:**

```dart
final document = await session.dids.resolve('did:key:z6Mk...');
if (document != null) {
  final vms = document['verificationMethod'] as List<dynamic>;
  print('Verification methods: ${vms.length}');
}
```

---

## Cuándo los necesita el integrador

En los flujos normales del SDK (OID4VCI, OID4VP), los DIDs se crean y resuelven automáticamente mediante `getSigningDid`/`ensureDid`. DIDComm gestiona sus propias claves (X25519 en el `keyStore`) y usa `did:peer` de bajo nivel sin pasar por `DidService` — ver [DIDComm](../04-flows/04-didcomm.md). Los casos en que el integrador sí accede a `session.dids` directamente son:

- **Mostrar el DID propio en la UI:** obtener el DID del holder para mostrarlo en un perfil o para compartirlo con un tercero.

  ```dart
  final did = await session.dids.ensureDid(
    keyType: KeyType.ed25519,
    method: 'key',
  );
  // Mostrar 'did' en pantalla
  ```

- **Resolver un DID externo:** verificar el DID Document de un issuer o verifier durante un flujo personalizado.

  ```dart
  final issuerDocument = await session.dids.resolve('did:web:issuer.example.com');
  ```

- **Debugging y diagnóstico:** inspeccionar qué DIDs están almacenados o verificar que el DID Document generado tiene la estructura esperada.

  ```dart
  final allDids = await session.didStore.getAll();
  for (final record in allDids) {
    print('${record.did} — método: ${record.method}');
  }
  ```

---

## Ver también

- [Stores](01-stores.md) — `didStore` donde se persisten los `DidRecord`
- [KMS](04-kms.md) — las claves criptográficas asociadas a cada DID
- [OID4VCI](../04-flows/02-oid4vci.md) — flujo de emisión donde el SDK usa `getSigningDid` internamente
