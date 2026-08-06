---
id: stores
title: Referencia de Stores
sidebar_position: 1
---

# Referencia de Stores

Los stores son la capa de persistencia del SDK. Cada uno gestiona un tipo de dato dentro de la base de datos Isar del wallet.

> ⚠️ **Limitación actual:** Isar 3.1.0 no cifra el archivo `.isar` completo. Los campos sensibles se cifran con AES-256-GCM por campo (`enc:v1:`) cuando la sesión tiene `cryptoContext` (vía `WalletService`). Metadatos e índices pueden quedar en claro. Ver [Limitaciones #1](../07-limitations.md).

## Modelo general

Todos los stores se acceden como getters de la clase `WalletSession` (ver [Ciclo de vida del wallet](../03-wallet-lifecycle.md)). No se instancian directamente: el SDK los crea y los inyecta al abrir una sesión.

Reglas de acceso:

- Mientras la sesión está **desbloqueada**, los getters devuelven la instancia del store.
- Después de llamar a `lock()` (o `WalletService.lock()`), cualquier acceso a un getter lanza `WalletLockedError`. Los streams activos deben cancelarse **antes** de llamar a `lock()`; de lo contrario emitirán un error al intentar acceder a la base de datos cerrada:

  ```dart
  final sub = store.watch().listen((items) { /* ... */ });
  // ... al bloquear:
  await sub.cancel();
  await walletService.lock();
  ```
- Internamente, todos los stores comparten una única instancia de `RecordStore`, que es el wrapper sobre Isar. Al llamar a `lock()`, `RecordStore.close()` libera los recursos de la base de datos.

## Cifrado por campo

Si la sesión se abrió con `WalletService`, `RecordStore.cryptoContext` está presente y los stores sensibles cifran al escribir y descifran al leer. El formato en disco es `enc:v1:` + base64 (AES-256-GCM). Valores sin ese prefijo se tratan como **legacy en texto plano** y se devuelven tal cual hasta que se reescriban.

| Store | Campos cifrados | En claro (ejemplos) |
|---|---|---|
| `keyStore` | `privateJwkJson` | `publicJwkJson`, `keyId`, `did` |
| `credentialStore` | JWT, claims, JSON de credencial, issuer signed (ver abajo) | `vct`, `types`, `issuerDid`, fechas |
| `deferredStore` | `accessTokenJson`, `responseJson` | `issuerMetadataJson`, timestamps |

Detalle por formato en `credentialStore`:

- **SD-JWT VC:** `compactSdJwt`, `prettyClaimsJson`; opcionalmente `issuerMetadataJson`, `displayMetadataJson`
- **W3C VC:** `credentialJson`; opcionalmente `displayMetadataJson`
- **mDoc:** `issuerSignedBase64`, `namespacesJson`; opcionalmente `displayMetadataJson`

`didStore`, `activityStore` y `connectionStore` **no** cifran campos hoy. Si se abre la sesión con `WalletSession.fromRecordStore()` sin `cryptoContext`, ningún store cifra (integración avanzada / tests).

---

## Tabla resumen

| Getter en `WalletSession` | Tipo del store | Qué almacena | Métodos disponibles |
|---|---|---|---|
| `credentialStore` | `CredentialRecordStore` | Credenciales verificables (SD-JWT VC, W3C VC, mDoc) | `save`, `update`, `delete`, `getById`, `getAll`, `watch` |
| `didStore` | `DidRecordStore` | DIDs controlados por el wallet | `save`, `update`, `delete`, `getById`, `getAll`, `watch` |
| `keyStore` | `KeyRecordStore` | Pares de claves criptográficas | `save`, `update`, `delete`, `getById`, `getAll`, `watch` |
| `activityStore` | `ActivityRecordStore` | Historial de issuance y presentación | `save`, `update`, `delete`, `getById`, `getAll`, `watch` |
| `deferredStore` | `DeferredCredentialRecordStore` | Credenciales diferidas pendientes de recuperación | `save`, `update`, `delete`, `getById`, `getAll`, `watch` |
| `connectionStore` | `ConnectionRecordStore` | Conexiones DIDComm establecidas | `save`, `delete`, `getById`, `getAll`, `watchAll` |

> **Nota:** `ConnectionRecordStore` no implementa `RecordService<T>` y su API difiere ligeramente de los demás: no expone `update` y su stream se llama `watchAll()` en lugar de `watch()`.

## Detalle por store

### `credentialStore` — `CredentialRecordStore`

Gestiona las tres familias de credenciales verificables soportadas por el SDK. Internamente rutea cada operación a la colección Isar correspondiente según el subtipo concreto (`SdJwtVcRecord`, `W3cCredentialRecord`, `MdocRecord`).

```dart
Future<void> save(CredentialRecord record)
Future<void> update(CredentialRecord record)
Future<void> delete(String id)
Future<CredentialRecord?> getById(String id)
Future<List<CredentialRecord>> getAll()
Stream<List<CredentialRecord>> watch()
```

`watch()` combina los tres streams de colección con `Rx.combineLatest3` (de la dependencia `rxdart`) y emite la lista unificada cada vez que cualquiera de ellas cambia. El integrador típicamente usa este store para mostrar y actualizar la pantalla principal de credenciales de la wallet.

---

### `didStore` — `DidRecordStore`

Almacena los DIDs que el wallet controla (es decir, para los que tiene la clave privada). El campo de dominio del modelo es `did` (el DID completo, p. ej. `did:key:z6Mk...`). El parámetro `id` que reciben `getById` y `delete` corresponde a ese mismo valor — es la interfaz genérica de `RecordService<T>`.

```dart
Future<void> save(DidRecord record)
Future<void> update(DidRecord record)
Future<void> delete(String id)
Future<DidRecord?> getById(String id)
Future<List<DidRecord>> getAll()
Stream<List<DidRecord>> watch()
```

En la mayoría de los flujos, el SDK administra este store internamente mediante `DidService`. El integrador raramente lo manipula de forma directa.

---

### `keyStore` — `KeyRecordStore`

Persiste los pares de claves criptográficas asociadas a los DIDs. El identificador lógico de cada `KeyRecord` es `keyId` (UUID v4). Las claves hardware-backed tienen `privateJwk` nulo; el campo `isHardwareBacked` distingue ambos casos.

```dart
Future<void> save(KeyRecord record)
Future<void> update(KeyRecord record)
Future<void> delete(String id)
Future<KeyRecord?> getById(String id)
Future<List<KeyRecord>> getAll()
Stream<List<KeyRecord>> watch()
```

Este store es **de uso interno**. El SDK lo opera a través del KMS (`session.kms`) y de `DidService`. El integrador no debe manipularlo directamente salvo para casos de diagnóstico o migración de claves.

---

### `activityStore` — `ActivityRecordStore`

Registra el historial de actividad del wallet: emisiones de credenciales (`IssuanceActivity`) y presentaciones (`PresentationActivity`). Ambos subtipos se almacenan en la misma colección Isar.

```dart
Future<void> save(Activity record)
Future<void> update(Activity record)
Future<void> delete(String id)
Future<Activity?> getById(String id)
Future<List<Activity>> getAll()
Stream<List<Activity>> watch()
```

El integrador puede usar este store para construir una pantalla de historial reactiva. El SDK escribe en él automáticamente al completar flujos de issuance y presentación. Recordá cancelar la suscripción en el `dispose` del widget o del controlador para evitar accesos tras el bloqueo:

```dart
late StreamSubscription<List<Activity>> _sub;

@override
void initState() {
  super.initState();
  _sub = session.activityStore.watch().listen((activities) {
    setState(() => _activities = activities);
  });
}

@override
void dispose() {
  _sub.cancel();
  super.dispose();
}
```

---

### `deferredStore` — `DeferredCredentialRecordStore`

Persiste los `DeferredCredentialRecord` necesarios para reintentar la recuperación de credenciales cuyo issuer devolvió un `transaction_id` en lugar de la credencial inmediata (flujo OID4VCI deferred; ver [OID4VCI](../04-flows/02-oid4vci.md)).

```dart
Future<void> save(DeferredCredentialRecord record)
Future<void> update(DeferredCredentialRecord record)
Future<void> delete(String id)
Future<DeferredCredentialRecord?> getById(String id)
Future<List<DeferredCredentialRecord>> getAll()
Stream<List<DeferredCredentialRecord>> watch()
```

El SDK gestiona este store internamente durante el flujo deferred. El integrador puede consultarlo para mostrar credenciales pendientes o implementar una lógica de reintento periódico.

---

### `connectionStore` — `ConnectionRecordStore`

Almacena las conexiones DIDComm establecidas. A diferencia de los demás stores, `ConnectionRecordStore` **no** implementa `RecordService<T>`: no tiene método `update` y su stream se llama `watchAll()`.

```dart
Future<ConnectionRecord?> getById(String connectionId)
Future<List<ConnectionRecord>> getAll()
Future<void> save(ConnectionRecord record)
Future<void> delete(String connectionId)
Stream<List<ConnectionRecord>> watchAll()
```

El campo `connectionId` es el identificador de la conexión (distinto del `id` Isar interno). El SDK actualiza este store durante el protocolo DIDComm de establecimiento de conexión. El integrador puede usarlo para listar contactos o verificar el estado de una conexión.

## Reactividad

Los stores que exponen streams son:

| Store | Método de stream | Tipo emitido |
|---|---|---|
| `credentialStore` | `watch()` | `Stream<List<CredentialRecord>>` |
| `didStore` | `watch()` | `Stream<List<DidRecord>>` |
| `keyStore` | `watch()` | `Stream<List<KeyRecord>>` |
| `activityStore` | `watch()` | `Stream<List<Activity>>` |
| `deferredStore` | `watch()` | `Stream<List<DeferredCredentialRecord>>` |
| `connectionStore` | `watchAll()` | `Stream<List<ConnectionRecord>>` |

Todos emiten la lista completa inmediatamente al suscribirse (`fireImmediately: true`) y luego ante cada cambio en la colección correspondiente.

### Patrón de UI con `StreamBuilder`

El ejemplo siguiente muestra cómo renderizar la lista de credenciales de forma reactiva sin ningún paquete de estado adicional:

```dart
StreamBuilder<List<CredentialRecord>>(
  stream: session.credentialStore.watch(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }
    final credentials = snapshot.data!;
    return ListView.builder(
      itemCount: credentials.length,
      itemBuilder: (context, index) {
        final credential = credentials[index];
        return ListTile(title: Text(credential.id));
      },
    );
  },
)
```

El mismo patrón aplica a cualquier otro store: basta con reemplazar `session.credentialStore.watch()` por el getter y el método del store deseado (p. ej. `session.connectionStore.watchAll()`).

## Ejemplos comunes

### Listar todas las credenciales

```dart
final credentials = await session.credentialStore.getAll();
for (final credential in credentials) {
  print(credential.id);
}
```

### Obtener una credencial por ID

```dart
final credential = await session.credentialStore.getById('mi-id');
if (credential != null) {
  // usar la credencial
}
```

### Eliminar una credencial

```dart
await session.credentialStore.delete('mi-id');
// No lanza error si el ID no existe.
```

### Escuchar el historial de actividad en tiempo real

`activityStore` expone `watch()`, por lo que puede suscribirse de la misma forma reactiva. Guardá la suscripción y cancelala en `dispose` para evitar leaks y errores tras el bloqueo del wallet:

```dart
final sub = session.activityStore.watch().listen((activities) {
  print('Total de actividades: ${activities.length}');
});

// En dispose o al bloquear la wallet:
await sub.cancel();
```

Si se prefiere una lectura única (por ejemplo, al cargar una pantalla sin reactividad), se usa `getAll()`:

```dart
final activities = await session.activityStore.getAll();
```

### Consultar credenciales diferidas pendientes

```dart
final pending = await session.deferredStore.getAll();
print('Credenciales diferidas pendientes: ${pending.length}');
```

## Ver también

- [Credenciales](02-credentials.md)
- [Ciclo de vida del wallet](../03-wallet-lifecycle.md)
- [Errores](06-errors.md)
