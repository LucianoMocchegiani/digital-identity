# Revocation Module

Módulo de revocación de credenciales SD-JWT VC basado en [IETF Token Status List (TSL)](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/).

## Decisión sobre librería

Se usa `@sd-jwt/jwt-status-list@^0.19.0` en lugar de su sucesor `@owf/token-status-list` porque:

- El original está más maduro y ampliamente adoptado en el ecosistema SD-JWT.
- Solo necesitamos soporte JWT (no CWT/CBOR): todas las credenciales QuarkID son JOSE/SD-JWT VC.
- La API core es compatible con la del sucesor, por lo que la migración futura será trivial cuando `@owf` madure.

## Arquitectura

```
packages/identity-core/src/revocation/
├── index.ts                            # Barrel export del módulo
├── revocation.service.ts               # Orquestador de bajo nivel
├── revocation.issuer.ts                # Fachada de alto nivel para issuers
├── revocation.factory.ts               # createRevocationIssuer(deps)
├── ports.ts                            # SignerProvider + StatusListUriBuilder
├── signer.derivation.ts                # Derivación de SignerMetadata desde agente Credo
├── status-list.service.ts              # compress/decompress/sign/decode
├── messaging.interface.ts              # Puerto + token de mensajería
├── status-list-storage.interface.ts    # Puerto StatusListStorage
├── postgres-status-list.storage.ts     # Adapter Postgres (pg.Pool)
├── status-list.types.ts                # StatusList, StatusType, params, payloads
└── revocation.errors.ts                # Errores específicos del módulo
```

El módulo sigue el patrón **port + adapter** establecido por `RecordStorage`:

- **`StatusListStorage`** (puerto): define el contrato de persistencia. El core solo usa este contrato.
- **`PostgresStatusListStorage`** (adapter): implementación de referencia sobre `pg.Pool`. Crea las tablas con DDL idempotente y soporta transacciones reales.
- El servicio Nest consumidor provee el `pg.Pool` al adapter y resuelve el storage vía DI (símbolo Nest `STATUS_LIST_STORAGE`).

## Conceptos

- **StatusList**: bitstring comprimido (DEFLATE+ZLIB) que representa el estado de N credenciales.
- **Granularidad**: una StatusList por VCT (`vct`) por tenant (`walletId`).
- **Índice**: posición única dentro de la StatusList asignada a cada credencial emitida.
- **URI del StatusList**: se construye como `<issuerDid-sin-prefijo>/statuslist/<vct>` (ver `buildStatusListUri` en `revocation.service.ts`).

## Storage (puerto + adapter)

### Puerto `StatusListStorage`

```ts
interface StatusListStorage {
  findByWalletAndVct(walletId, vct): Promise<StatusListInfo | null>
  findById(id): Promise<StatusListInfo | null>
  create({ walletId, vct, bits, capacity, compressedBitstring, nextIndex }): Promise<StatusListInfo>
  updateCompressedBitstring(id, compressed, nextIndex): Promise<void>
  incrementRevokedCount(id): Promise<void>
  saveRevocation({ statusListId, index, credentialId?, reason?, revokedBy? }): Promise<void>
  findRevocation(statusListId, index): Promise<{...} | null>
  updateRevocation({ statusListId, index, reason?, revokedBy? }): Promise<void>
  withTransaction<T>(fn: (tx: StatusListStorage) => Promise<T>): Promise<T>
}
```

### Adapter `PostgresStatusListStorage`

Recibe un `pg.Pool` por constructor. Al inicializar crea (idempotente, con reintentos):

- `status_lists (id UUID, wallet_id, vct, bits, capacity, compressed_bitstring, next_index, revoked_count, last_updated_at, created_at, updated_at)` + `UNIQUE (wallet_id, vct)`.
- `status_list_revocations (id UUID, status_list_id FK ON DELETE CASCADE, index, credential_id, reason, revoked_by, revoked_at)` + `UNIQUE (status_list_id, index)`.

La implementación cubre el flujo de revocation con **transacciones reales**: `revoke()` y `allocateIndex()` ejecutan sus múltiples operaciones dentro de `withTransaction`, garantizando atomicidad ante fallos.

### Cómo se inyecta desde un servicio Nest

```typescript
// quark-issuer-service/source/src/storage/status-list-storage.module.ts
// (junto a RecordStorageModule; espejo del patrón de records)
import { Global, Module } from '@nestjs/common'
import { Pool } from 'pg'
import {
  PostgresStatusListStorage,
  type StatusListStorage,
} from '@quarkid/identity-core'
import { RECORD_DATABASE_POOL } from './record-storage.tokens'
import { STATUS_LIST_STORAGE } from './status-list-storage.tokens'

@Global()
@Module({
  providers: [
    {
      provide: STATUS_LIST_STORAGE,
      inject: [RECORD_DATABASE_POOL],
      useFactory: (pool: Pool): StatusListStorage =>
        new PostgresStatusListStorage(pool),
    },
  ],
  exports: [STATUS_LIST_STORAGE],
})
export class StatusListStorageModule {}
```

El módulo reutiliza el `pg.Pool` de `RecordStorageModule` por defecto. Si se necesita separar la DB de StatusList de la de records, ver `quark-issuer-service/source/src/storage/README.md`.

## Uso

### 1. Para issuers: usar `RevocationIssuer` + `createRevocationIssuer`

El caso de uso recomendado para issuers es la fachada de alto nivel. Una vez inyectados los adapters (`SignerProvider`, `StatusListUriBuilder`, `StatusListStorage`, `MessagingService`), el issuer solo llama métodos concretos por `walletId` — no construye `SignerOptions` a mano.

```typescript
// En el wiring del módulo Nest (ver sección "Puertos y fachada de alto nivel" abajo)
const revocationIssuer = createRevocationIssuer({
  storage,        // StatusListStorage (puerto)
  signers,        // SignerProvider (puerto)
  uriBuilder,     // StatusListUriBuilder (puerto)
  messaging,      // MessagingService (puerto, opcional)
})

// Crear (o recuperar si ya existe) la StatusList para un VCT
const { listId, uri } = await revocationIssuer.createStatusList('tenant-1', 'UniversityDegree')

// Asignar índice al emitir credencial
const { index, uri } = await revocationIssuer.allocateIndex('tenant-1', 'UniversityDegree', {
  credentialId: 'credential-123',
})

// Revocar credencial (atómico: bitstring + counter + audit log)
const { revokedAt, status } = await revocationIssuer.revoke('tenant-1', 'UniversityDegree', 5, {
  reason: 'Credencial vencida',
  revokedBy: 'admin-1',
})

// Consultar estado de un índice
const { status, updatedAt } = await revocationIssuer.getStatus('tenant-1', 'UniversityDegree', 5)

// Obtener el JWT firmado de la StatusList
const { jwt, uri } = await revocationIssuer.getStatusListJwt('tenant-1', 'UniversityDegree', { ttl: 43200 })
```

### 2. Para uso genérico o admin: `RevocationService` directo

`RevocationService` (el orquestador de bajo nivel) ya recibe los puertos por constructor, por lo que la API pública tampoco exige `issuerDid`/`issuerKey`. Se usa para casos donde el consumidor quiere más control (p. ej. herramientas de admin, tests de integración, scripts batch).

```typescript
// Inyectar `revocationService: RevocationService` y usarlo directamente:
const { listId, uri } = await revocationService.createStatusList({
  walletId: 'tenant-1',
  vct: 'UniversityDegree',
})
```

### 3. (Avanzado) Construir un `SignerOptions` a mano

Útil solo para tests o adapters custom del `SignerProvider`. El `StatusListService.signAsJwt` delega la firma a un KMS. El objeto debe cumplir con `SignerOptions` (definido en `types/status-list.types.ts:70`):

```typescript
import type { SignerOptions } from '@quarkid/identity-core'

const signer: SignerOptions = {
  did: 'did:web:issuer.example.com',
  keyId: 'key-1',
  kid: 'did:web:issuer.example.com#key-1',
  alg: 'ES256', // default si se omite
  kms: {
    async sign({ keyId, algorithm, data }) {
      const { signature } = await agent.kms.sign({ keyId, algorithm, data })
      return { signature }
    },
  },
}
```

> **No usar esta API en código de issuer**: en su lugar, implementar `SignerProvider` y dejar que el core lo invoque.

## API Reference

### `StatusListService`

| Método | Firma | Descripción |
|---|---|---|
| `setLogger` | `(logger: CredoLogger) => void` | Inyecta un logger Credo-TS en el servicio. |
| `createEmptyList` | `(bits: 1\|2\|4\|8 = 1, capacity = 16384) => StatusList` | Crea una `StatusList` vacía (todos los bits en 0). |
| `setStatus` | `(list, index, value: StatusType) => void` | Marca el índice con el estado indicado. |
| `getStatus` | `(list, index) => StatusType` | Lee el estado de un índice. |
| `getBitsPerStatus` | `(list) => BitsPerStatus` | Devuelve la cantidad de bits por entrada. |
| `compress` | `(list) => string` | Devuelve la lista comprimida en base64url. |
| `decompress` | `(compressed, bits) => StatusList` | Reconstruye la `StatusList` desde el string. |
| `getCapacity` | `(list) => number` | Cantidad de entradas de la lista. |
| `findFreeIndex` | `(list, fromIndex = 0) => number \| null` | Devuelve el siguiente índice con estado 0 o `null` si no hay. |
| `signAsJwt` | `(list, signer, { uri, ttl?, exp? }) => Promise<string>` | Firma la lista como `statuslist+jwt`. Requiere `uri`. |
| `decodeJwt` | `(jwt) => { list, payload }` | Decodifica un JWT de StatusList; lanza `InvalidStatusListJwtError` ante error. |
| `extractReference` | `(credentialJwt) => StatusListEntry` | Extrae `{ idx, uri }` desde el claim `status_list` de una credencial. |
| `buildStatusClaim` | `(idx, uri) => { status_list }` | Helper para construir el claim a inyectar en una credencial. |

> Nota: `StatusListService` no expone `verifyJwt`/`extractReference` con verificación criptográfica integrada. La verificación de firma depende del consumidor y del `Kms` que tenga disponible.

### `RevocationService`

| Método | Firma | Descripción |
|---|---|---|
| `setLogger` | `(logger: CredoLogger) => void` | Inyecta un logger (propaga también a `StatusListService`). |
| `createStatusList` | `(params) => Promise<{ listId, uri }>` | Crea la StatusList para `(walletId, vct)`. Idempotente: si ya existe, devuelve la existente. Resuelve el signer vía `SignerProvider` y la URI vía `StatusListUriBuilder`. |
| `allocateIndex` | `(params) => Promise<{ index, uri }>` | Crea la lista si no existe y asigna un índice libre. **Atómico** vía `withTransaction`. |
| `revoke` | `(params) => Promise<{ revokedAt, status: number }>` | Marca el índice como inválido. **Atómico** vía `withTransaction` (bitstring + counter + audit log). |
| `getStatus` | `(walletId, vct, index) => Promise<{ status, updatedAt? }>` | Devuelve el estado actual de un índice. |
| `getStatusListJwt` | `(walletId, vct, { ttl?, exp? }) => Promise<{ jwt, uri }>` | Genera el JWT firmado de la lista. Resuelve el signer vía `SignerProvider`. |
| `getStatusListInfo` | `(walletId, vct) => Promise<StatusListInfo \| null>` | Metadata persistida sin descomprimir el bitstring. |

> El constructor de `RevocationService` recibe los puertos `SignerProvider` y `StatusListUriBuilder` por DI: cada llamada resuelve el firmante y arma la URI internamente, por lo que la API pública **no exige** `issuerDid`/`issuerKey`/`signer` por invocación. Los consumidores que quieran construir el signer a mano deben usar la API interna del módulo (no recomendada).

### `SignerOptions` (resumen)

```typescript
interface SignerMetadata {
  did: string
  keyId: string
  kid: string
  alg?: string     // default: 'ES256'
}

interface SignerOptions extends SignerMetadata {
  kms: {
    sign(opts: { keyId: string; algorithm: string; data: Uint8Array }):
      Promise<{ signature: Uint8Array }>
  }
}
```

El `kms` debe seguir siendo válido después de que `resolveSigner` retorne: el core firma más tarde, dentro de la misma operación. En agentes multi-tenant eso significa que el KMS no puede ser el de una sesión ya cerrada — ver el wiring del issuer más abajo.

### `StatusListStorage` (puerto)

| Método | Descripción |
|---|---|
| `findByWalletAndVct(walletId, vct)` | Recupera la metadata de la lista. |
| `findById(id)` | Recupera la lista por id interno. |
| `create({...})` | Persiste una nueva lista. |
| `updateCompressedBitstring(id, compressed, nextIndex)` | Actualiza el bitstring y el cursor `nextIndex`. |
| `incrementRevokedCount(id)` | Incrementa el contador de revocaciones. |
| `saveRevocation({...})` | Inserta registro de revocación. Mapea `23505` → `CredentialAlreadyRevokedError`. |
| `findRevocation(statusListId, index)` | Busca registro de revocación previo. |
| `updateRevocation({...})` | Actualiza motivo de una revocación existente. |
| `withTransaction(fn)` | Ejecuta `fn` dentro de una transacción Postgres (`BEGIN`/`COMMIT`/`ROLLBACK`). Si ya está dentro de una, devuelve el mismo `tx` (no anida). |

## Errores

Definidos en `errors/revocation.errors.ts`. Todos extienden `RevocationError` y exponen un `code` estable.

| Clase | `code` | Cuándo se lanza |
|---|---|---|
| `StatusListNotFoundError` | `STATUS_LIST_NOT_FOUND` | `allocateIndex`/`revoke`/`getStatus`/`getStatusListJwt` cuando no existe lista para `(walletId, vct)`. |
| `NoFreeIndexError` | `NO_FREE_INDEX` | `allocateIndex` cuando la lista está al 100% de capacidad. |
| `IndexOutOfBoundsError` | `INDEX_OUT_OF_BOUNDS` | `revoke`/`getStatus` con `index < 0` o `index >= capacity`. |
| `InvalidStatusListJwtError` | `INVALID_STATUS_LIST_JWT` | `StatusListService.decodeJwt` al fallar el parseo. |
| `StatusListExpiredError` | `STATUS_LIST_EXPIRED` | Definida pero no lanzada por el código actual — reservada para uso futuro del consumidor. |
| `StatusListSignatureError` | `STATUS_LIST_SIGNATURE_INVALID` | Definida pero no lanzada por el código actual — reservada para uso futuro del consumidor. |
| `CredentialAlreadyRevokedError` | `CREDENTIAL_ALREADY_REVOKED` | `saveRevocation` cuando choca con la constraint UNIQUE (Postgres `23505`). |

## Eventos

`RevocationService` publica eventos a través del puerto `MessagingService` (inyectable via token `MESSAGING_SERVICE = Symbol('MessagingService')`). Si el puerto no se provee, los `publishEvent` son no-op. **El core no impone el transporte**: el consumidor decide si el adapter es RabbitMQ, Kafka, una cola in-memory, etc.

| Routing Key | Payload | Cuándo se emite |
|---|---|---|
| `revocation.status-list.created` | `{ walletId, vct, listId, uri, bits, capacity, timestamp }` | `createStatusList` crea una lista nueva (no cuando recupera una existente). |
| `revocation.status-list.allocated` | `{ walletId, vct, listId, index, credentialId?, timestamp }` | `allocateIndex` asigna un índice. |
| `credential.revoked` | `{ walletId, vct, listId, index, reason?, revokedBy?, timestamp }` | `revoke` completa la revocación. |

Si la publicación falla, el error se loguea y la operación de revocación no se aborta (fire-and-forget, ver `revocation.service.ts`).

## Puertos y fachada de alto nivel

Además de los puertos `StatusListStorage` y `MessagingService`, el módulo expone dos puertos para resolver concerns que varían por consumidor:

### `SignerProvider` (puerto)

```typescript
interface SignerProvider {
  resolveSigner(walletId: string): Promise<SignerOptions>
}
```

Encapsula *cómo* se obtiene el `SignerOptions` (DID, keyId, kid, alg, kms) para un tenant. El core lo invoca cuando necesita firmar; el consumidor decide si lo resuelve desde un agente Credo, un KMS externo o configuración estática.

Token Nest: `SIGNER_PROVIDER = Symbol('SignerProvider')`.

### `StatusListUriBuilder` (puerto)

```typescript
interface StatusListUriBuilder {
  build(walletId: string, vct: string, issuerDid: string): string
}
```

Encapsula *cómo* se deriva la URI pública de la StatusList. El core no impone un esquema: el consumidor decide si la URI es DID-based, HTTP bajo su API pública, etc.

Token Nest: `STATUS_LIST_URI_BUILDER = Symbol('StatusListUriBuilder')`.

### `RevocationIssuer` (fachada de alto nivel)

`RevocationService` es la API genérica de bajo nivel. `RevocationIssuer` es una fachada delgada pensada para issuers que quieren llamar métodos concretos por `walletId` sin construir un `SignerOptions` a mano.

```typescript
class RevocationIssuer {
  createStatusList(walletId, vct, options?): Promise<{ listId, uri }>
  allocateIndex(walletId, vct, options?): Promise<{ index, uri }>
  revoke(walletId, vct, index, options?): Promise<{ revokedAt, status }>
  getStatus(walletId, vct, index): Promise<{ status, updatedAt? }>
  getStatusListJwt(walletId, vct, options?): Promise<{ jwt, uri }>
}
```

### `createRevocationIssuer(deps)` (factory)

```typescript
interface RevocationIssuerDeps {
  storage: StatusListStorage
  signers: SignerProvider
  uriBuilder: StatusListUriBuilder
  messaging?: MessagingService
}

function createRevocationIssuer(deps: RevocationIssuerDeps): RevocationIssuer
```

Arma el `StatusListService`, el `RevocationService` y la fachada `RevocationIssuer` con los puertos ya inyectados. Equivale a:

```typescript
const statusListService = new StatusListService()
const revocation = new RevocationService(statusListService, deps.storage, deps.signers, deps.uriBuilder, deps.messaging)
const issuer = new RevocationIssuer(revocation)
```

### Ejemplo: wiring completo desde un servicio Nest (issuer de QuarkID)

```typescript
// quark-issuer-service/source/src/revocation/signer.provider.ts
@Injectable()
export class CredoWalletSignerProvider implements SignerProvider {
  async resolveSigner(walletId: string): Promise<SignerOptions> {
    const metadata = await withWallet(walletId, (agent) => resolveSignerFromAgent(agent, opts))

    // Cada firma abre su propia sesión: `withWallet` cierra el contenedor del
    // tenant al retornar, y el core firma después de resolver el signer.
    return {
      ...metadata,
      kms: {
        sign: (options) => withWallet(walletId, (agent) => agent.kms.sign(options)),
      },
    }
  }
}

// quark-issuer-service/source/src/revocation/uri.builder.ts
@Injectable()
export class HttpStatusListUriBuilder implements StatusListUriBuilder {
  build(walletId: string, vct: string, _issuerDid: string): string {
    return `${environmentConfig().publicBaseUrl}/v1/issuers/${walletId}/revocation/status-list/${vct}`
  }
}

// quark-issuer-service/source/src/revocation/revocation.module.ts
@Global()
@Module({
  imports: [StatusListStorageModule, MessagingModule, JwtModule.registerAsync({...})],
  providers: [
    CredoWalletSignerProvider,
    HttpStatusListUriBuilder,
    {
      provide: REVOCATION_ISSUER,
      inject: [STATUS_LIST_STORAGE, CredoWalletSignerProvider, HttpStatusListUriBuilder, MESSAGING_SERVICE],
      useFactory: (storage, signers, uriBuilder, messaging): RevocationIssuer =>
        createRevocationIssuer({ storage, signers, uriBuilder, messaging }),
    },
    RevocationIssuerService, // fachada Nest que delega a RevocationIssuer
  ],
  exports: [RevocationIssuerService, REVOCATION_ISSUER],
})
export class RevocationIssuerModule {}
```

Con ese wiring, el resto del issuer (controller, `OpenId4VcService`, etc.) habla únicamente con `RevocationIssuerService`, que es delegación pura.

## Helpers de derivación de signer

Para consumers con un agente Credo, el core expone utilidades que permiten construir un `SignerProvider` sin reimplementar la lógica de derivación de claves:

| Helper | Firma | Propósito |
|---|---|---|
| `resolveSignerFromAgent` | `(agent: Agent, options?: SignerDerivationOptions) => Promise<SignerMetadata>` | Deriva DID, `keyId`, `kid` y `alg` desde un agente Credo. El `kms` lo completa el consumer, que es quien conoce el ciclo de vida de la sesión. |
| `pickDidRecordKey` | `(keys: DidRecordKey[], fragment?: string) => DidRecordKey \| undefined` | Elige la clave del `DidRecord` que matchea `fragment` (con o sin `#`); fallback a la primera si no hay match exacto. |
| `deriveAlgFromKms` | `(agent: Agent, keyId: string) => Promise<string>` | Deriva el `alg` JWS del JWK público de una clave KMS (`P-256 → ES256`, `Ed25519 → EdDSA`, etc.). |

### `resolveSignerFromAgent(agent, options?)`

Estrategia por defecto (sin overrides):

1. Toma el primer DID creado del método `web` (configurable vía `didMethod`).
2. Selecciona la clave del DID según `keyFragment` (default `key-p256` — la clave primaria P-256 que Credo crea en `did:web`).
3. Deriva el `alg` JWS del JWK público de la clave (P-256 → `ES256`, Ed25519 → `EdDSA`, etc.); si el JWK ya trae `alg`, se respeta.
4. Construye el `kid` como `${did}#${didDocumentRelativeKeyId}`.

```typescript
interface SignerDerivationOptions {
  /** Override del algoritmo JWS. Si está definido, se usa tal cual. */
  algOverride?: string
  /** Override del `kid` completo. Si está definido, se usa tal cual. */
  kidOverride?: string
  /** Fragmento del DID URL a usar (con o sin `#`; se normaliza). Default: `key-p256`. */
  keyFragment?: string
  /** Método DID a buscar en el agente. Default: `web`. */
  didMethod?: 'web' | 'key'
}
```

Ejemplo para un consumer que no es el issuer de QuarkID:

```typescript
import {
  resolveSignerFromAgent,
  type SignerProvider,
  type SignerOptions,
} from '@quarkid/identity-core'
import type { Agent } from '@credo-ts/core'

const signers: SignerProvider = {
  async resolveSigner(walletId): Promise<SignerOptions> {
    const metadata = await withWallet(walletId, (agent: Agent) =>
      resolveSignerFromAgent(agent, {
        // Opcional: si el agente tiene un fragmento no estándar
        keyFragment: 'key-ed25519',
      })
    )

    return {
      ...metadata,
      kms: {
        sign: (options) => withWallet(walletId, (agent: Agent) => agent.kms.sign(options)),
      },
    }
  },
}
```

`pickDidRecordKey` y `deriveAlgFromKms` están exportados para que el consumer pueda componer su propia lógica de selección sin reimplementar el matching de fragmento ni la tabla de algoritmos. Por ejemplo, un consumer que necesite firmar con una clave distinta de la primaria puede combinar ambos helpers.

## Migración de clientes (v0.x → post record-storage-injection)

Si venís del código anterior, estos son los cambios de superficie pública:

| Antes | Ahora |
|---|---|
| `IStatusListRepository` (interface) | `StatusListStorage` (interface) |
| `import from '.../revocation/interfaces/status-list-repository.interface'` | `import { StatusListStorage } from '@quarkid/identity-core'` (o `.../revocation/status-list-storage.interface`) |
| `getStatus(walletId, vct, index)` (puerto) | Eliminado. La operación equivalente se hace en memoria con `statusListService.getStatus(list, index)`. |
| `MESSAGING_SERVICE = 'MESSAGING_SERVICE'` (string) | `MESSAGING_SERVICE = Symbol('MessagingService')` |
| Adapter TypeORM en `quark-issuer-service/.../typeorm-status-list.repository.ts` | `PostgresStatusListStorage` provisto por `StatusListStorageModule` (Nest), vive en core. |
| `findById`, `updateCompressedBitstring`, etc. (sin transacciones) | Mismas firmas + `withTransaction<T>(fn)` para atomicidad. |