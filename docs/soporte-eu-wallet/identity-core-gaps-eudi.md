# identity-core — Brechas para compatibilidad EUDI Wallet

Análisis de lo que falta en `packages/identity-core` para soportar los flujos
OID4VCI, OID4VP y SD-JWT requeridos por la EUDI Wallet.

Versión analizada: estado actual del repo (marzo 2026).

---

## Estado actual del paquete

El paquete está construido **100% sobre DIDComm v1** con un método DID propio (`did:custom`).
Nada de lo que usa la EUDI Wallet (OID4VCI, OID4VP, SD-JWT) está implementado.

Resumen de lo que existe hoy:

| Área | Qué hace hoy |
|---|---|
| DID methods | Solo `did:custom` (registro en vdr-service interno) |
| Tipos de clave | Solo Ed25519 (hardcodeado en `OneDidRegistrar`) |
| Emisión de credenciales | W3C JSON-LD vía DIDComm v1 |
| Presentación | DIF PEX vía DIDComm v1 |
| Módulos Credo | `W3cCredentialsModule` + `DidCommModule` |
| Transporte | WebSocket + HTTP DIDComm |
| OID4VCI | No existe |
| OID4VP | No existe |
| SD-JWT | No existe |

---

## Brecha 1 — `buildDidsModule`: métodos DID faltantes

**Archivo:** `src/agent/build-dids-module.ts`

**Estado actual:**

```typescript
export function buildDidsModule(config: OneDidRegistrarConfig): DidsModule {
  return new DidsModule({
    resolvers: [new OneDidResolver(config.vdrServiceUrl)],
    registrars: [new OneDidRegistrar(config)],
  })
}
```

Solo registra `did:custom`. Para EUDI el holder necesita al menos cuatro métodos más:

| Método | Rol | Por qué es necesario |
|---|---|---|
| `did:key` | Resolver + Registrar | Proof of possession en OID4VCI. El issuer puede pedir un `did:key` en el proof JWT |
| `did:jwk` | Resolver + Registrar | Key binding en SD-JWT (`cnf.jwk`). Método preferido en ecosistemas JOSE/OID4VP |
| `did:web` | Solo Resolver | Resolver el DID del issuer (el issuer típicamente publica un `did:web`) |
| `did:peer` | Resolver + Registrar | Conexiones DIDComm con verifiers que usen DIDComm v2 |

**Lo que hay que cambiar:**

```typescript
import { DidsModule } from '@credo-ts/core'
import { KeyDidRegistrar, KeyDidResolver } from '@credo-ts/core'
import { JwkDidRegistrar, JwkDidResolver } from '@credo-ts/core'
import { WebDidResolver } from '@credo-ts/core'
import { PeerDidRegistrar, PeerDidResolver } from '@credo-ts/didcomm'

export function buildDidsModule(config: OneDidRegistrarConfig): DidsModule {
  return new DidsModule({
    resolvers: [
      new OneDidResolver(config.vdrServiceUrl),
      new KeyDidResolver(),
      new JwkDidResolver(),
      new WebDidResolver(),
      new PeerDidResolver(),
    ],
    registrars: [
      new OneDidRegistrar(config),
      new KeyDidRegistrar(),
      new JwkDidRegistrar(),
      new PeerDidRegistrar(),
    ],
  })
}
```

**Impacto:** afecta los tres agents (holder, issuer, verifier) ya que todos llaman a `buildDidsModule`.

---

## Brecha 2 — `OneDidRegistrar`: solo soporta Ed25519

**Archivo:** `src/adapters/did/one-did-registrar.ts`

**Estado actual:**

El registrar hardcodea `Ed25519` como único tipo de clave permitido:

```typescript
const ed25519Type = { kty: 'OKP' as const, crv: 'Ed25519' as const }

if (options.options?.createKey) {
  const opts = options.options.createKey
  const createResult = await kms.createKey({
    type:
      opts.type.kty === 'OKP' && opts.type.crv === 'Ed25519'
        ? ed25519Type
        : (opts.type as { kty: 'OKP'; crv: 'Ed25519' }),  // casteo forzado — falla con P-256
  })
```

Si se pide una clave P-256 (`{ kty: 'EC', crv: 'P-256' }`), el casteo a `Ed25519` rompe la firma o genera una clave incorrecta.

**Lo que hay que cambiar:**

Ampliar `OneDidCreateOptions` para aceptar `EC/P-256` y eliminar el casteo forzado. La función de creación de clave debe pasar el tipo tal como viene, validando que sea un tipo soportado por el KMS.

**Impacto:** solo afecta `did:custom`. `did:key` y `did:jwk` manejan sus propias claves internamente.

---

## Brecha 3 — `OpenId4VcHolderModule` no está en ningún agent

**Archivo:** `src/agent/create-holder-agent.ts`

**Estado actual:**

Los módulos del holder son:

```typescript
modules: {
  keyManagement: buildKeyManagementModule(config.kms),
  dids: buildDidsModule({ ... }),
  w3cCredentials: new W3cCredentialsModule({}),
  didcomm: new DidCommModule({ ... }),
}
```

No hay ningún módulo OID4VC. Para soportar OID4VCI (recibir credenciales) y OID4VP (presentar) hay que agregar `OpenId4VcHolderModule` de `@credo-ts/openid4vc`.

**Lo que hay que agregar al holder:**

```typescript
import { OpenId4VcHolderModule } from '@credo-ts/openid4vc'

modules: {
  keyManagement: buildKeyManagementModule(config.kms),
  dids: buildDidsModule({ ... }),
  w3cCredentials: new W3cCredentialsModule({}),
  sdJwtVc: new SdJwtVcModule(),          // SD-JWT VC
  openId4VcHolder: new OpenId4VcHolderModule(),  // OID4VCI + OID4VP
  didcomm: new DidCommModule({ ... }),   // DIDComm existente, se mantiene
}
```

**Lo que hay que agregar al issuer** (para emitir via OID4VCI):

```typescript
import { OpenId4VcIssuerModule } from '@credo-ts/openid4vc'

// Requiere configuración de credentialRequestToCredentialMapper y signingKey
openId4VcIssuer: new OpenId4VcIssuerModule({ ... })
```

**Lo que hay que agregar al verifier** (para verificar via OID4VP):

```typescript
import { OpenId4VcVerifierModule } from '@credo-ts/openid4vc'

openId4VcVerifier: new OpenId4VcVerifierModule()
```

**Dependencia nueva en `package.json`:**

```json
"peerDependencies": {
  "@credo-ts/core": "*",
  "@credo-ts/didcomm": "*",
  "@credo-ts/node": "*",
  "@credo-ts/openid4vc": "*"   // agregar
}
```

---

## Brecha 4 — `SdJwtVcModule` no existe

**Archivo:** `src/agent/create-*.ts` (los tres agents)

**Estado actual:**

Solo existe `W3cCredentialsModule`. La EUDI Wallet emite credenciales en formato **SD-JWT VC** (Selective Disclosure JWT Verifiable Credential), no W3C JSON-LD.

**Lo que hay que agregar a los tres agents:**

```typescript
import { SdJwtVcModule } from '@credo-ts/core'

modules: {
  ...
  sdJwtVc: new SdJwtVcModule(),
}
```

`SdJwtVcModule` provee `agent.sdJwtVc` con:
- `sign()` — emitir SD-JWT VC (issuer)
- `present()` — crear VP con key binding (holder)
- `verify()` — verificar credencial (verifier)
- `store()` / `getAll()` — almacenamiento en wallet

---

## Brecha 5 — `credentialBindingResolver` no existe

**Archivo:** a crear en `src/utils/`

**Qué es:** cuando el holder solicita una credencial via OID4VCI, el issuer puede soportar distintos mecanismos de binding (`did:key`, `did:jwk`, JWK crudo). El `credentialBindingResolver` es un callback que el holder provee para decidir cómo vincular la credencial a su clave.

**Lo que hay que crear:**

```typescript
// src/utils/credential-binding-resolver.ts

import { KeyType } from '@credo-ts/core'
import type { Agent } from '@credo-ts/core'
import type { OpenId4VciCredentialBindingResolver } from '@credo-ts/openid4vc'

export function buildCredentialBindingResolver(
  agent: Agent
): OpenId4VciCredentialBindingResolver {
  return async ({ supportedDidMethods, supportsJwk, keyType }) => {
    // Preferir did:key si el issuer lo soporta
    if (supportedDidMethods?.includes('did:key')) {
      const result = await agent.dids.create({
        method: 'key',
        options: { keyType: keyType ?? KeyType.P256 },
      })
      const verificationMethodId =
        result.didState.didDocument?.verificationMethod?.[0]?.id
      if (verificationMethodId) {
        return { method: 'did', didUrl: verificationMethodId }
      }
    }

    // Fallback: JWK crudo (siempre disponible)
    if (supportsJwk) {
      const key = await agent.kms.createKey({
        type: { kty: 'EC', crv: 'P-256' },
      })
      return { method: 'jwk', jwk: key.publicJwk }
    }

    // Fallback final: did:jwk
    const result = await agent.dids.create({
      method: 'jwk',
      options: { keyType: keyType ?? KeyType.P256 },
    })
    const verificationMethodId =
      result.didState.didDocument?.verificationMethod?.[0]?.id
    return { method: 'did', didUrl: verificationMethodId! }
  }
}
```

Este resolver se pasa al llamar `agent.openId4VcHolder.requestCredentials()`.

---

## Brecha 6 — listeners del holder son DIDComm-only

**Archivo:** `src/listeners/holder-listeners.ts`

**Estado actual:**

Los listeners escuchan `DidCommCredentialStateChanged` y `DidCommProofStateChanged`. Estos eventos solo se disparan en flujos DIDComm. Los flujos OID4VCI/OID4VP son HTTP síncronos — no emiten estos eventos.

**Qué implica:**

Para OID4VCI el flujo es llamada directa (no hay listener):

```typescript
// Flujo OID4VCI — el holder llama APIs síncronas, no hay evento que escuchar
const offer = await agent.openId4VcHolder.resolveCredentialOffer(offerUri)
const { accessToken } = await agent.openId4VcHolder.requestToken({ resolvedCredentialOffer: offer })
const credentials = await agent.openId4VcHolder.requestCredentials({
  resolvedCredentialOffer: offer,
  accessToken,
  credentialBindingResolver: buildCredentialBindingResolver(agent),
})
```

Para OID4VP:

```typescript
const authRequest = await agent.openId4VcHolder.resolveOpenId4VpAuthorizationRequest(requestUri)
await agent.openId4VcHolder.acceptOpenId4VpAuthorizationRequest({
  authorizationRequest: authRequest,
  selectedCredentials: { ... },
})
```

**Lo que hay que hacer:** los listeners DIDComm existentes **se mantienen** (compatibilidad con flujos actuales). Hay que exponer funciones auxiliares (en `src/credentials/` o un nuevo `src/openid4vc/`) que encapsulen los flujos OID4VC para que los servicios NestJS los llamen.

---

## Resumen de cambios por archivo

| Archivo | Cambio | Prioridad |
|---|---|---|
| `package.json` | Agregar `@credo-ts/openid4vc` como peer dep | Alta |
| `src/agent/build-dids-module.ts` | Agregar resolvers/registrars para `did:key`, `did:jwk`, `did:web`, `did:peer` | Alta |
| `src/agent/create-holder-agent.ts` | Agregar `OpenId4VcHolderModule` + `SdJwtVcModule` | Alta |
| `src/agent/create-issuer-agent.ts` | Agregar `OpenId4VcIssuerModule` + `SdJwtVcModule` | Alta |
| `src/agent/create-verifier-agent.ts` | Agregar `OpenId4VcVerifierModule` + `SdJwtVcModule` | Alta |
| `src/adapters/did/one-did-registrar.ts` | Eliminar casteo forzado a Ed25519, soportar P-256 | Media |
| `src/utils/credential-binding-resolver.ts` | Crear resolver de binding (nuevo archivo) | Alta |
| `src/openid4vc/` (nuevo) | Funciones auxiliares para flujos OID4VCI/OID4VP | Media |
| `src/listeners/holder-listeners.ts` | Sin cambios — mantener compatibilidad DIDComm | — |

---

## Lo que NO hay que tocar

- `InternalKeyManagementService` / `ExternalKeyManagementService` — el KMS ya soporta P-256 nativamente via Askar/backend externo
- `InternalWalletStorageService` / `ExternalWalletStorageService` — el storage es agnóstico al tipo de credencial
- `DidCommWsOutboundTransportDelayedClose` — transporte DIDComm, sin relación con OID4VC
- Listeners de issuer y verifier actuales — siguen funcionando para flujos DIDComm

---

*Análisis basado en Credo-TS 0.6.x — marzo 2026*
