# DIDs múltiples del Holder — EUDI Wallet

## Por qué el holder usa múltiples DIDs

El holder no tiene una sola identidad fija como un issuer. En cambio, genera DIDs **efímeros o por propósito** para:

1. **Privacidad**: evitar correlación entre presentaciones distintas
2. **Separación de contextos**: un DID para recibir credenciales (OID4VCI), otro para presentarlas (OID4VP)
3. **Binding criptográfico**: el DID actúa como proof of possession de la clave privada

---

## DID portfolio al crear un wallet nuevo

Al inicializar un holder se genera un set de claves/DIDs upfront, cada uno optimizado para un protocolo:

```
Wallet nuevo
├── did:key  (Ed25519)    →  DIDComm / AIP 2.0
├── did:key  (P-256)      →  OID4VCI proof of possession
└── did:jwk  (P-256)      →  OID4VP / SD-JWT key binding
```

No se usan todos a la vez. El wallet tiene varios disponibles y **selecciona el correcto según el protocolo negociado** — igual que una persona que tiene DNI, pasaporte y licencia: documentos distintos para contextos distintos.

---

## did:key

Codifica directamente una clave pública en el identificador. No requiere resolución externa.

```
did:key:z6Mk...   ← Ed25519
did:key:zDna...   ← P-256 (secp256r1)
```

Generación: se toma la clave pública, se codifica en multibase/multicodec, y eso es el DID. El DID Document se deriva algorítmicamente, sin necesidad de resolver contra ningún servidor.

**Usos:**
- Autenticación del wallet en OID4VCI (proof of possession)
- Key binding en SD-JWT
- DIDComm peer-to-peer

---

## did:jwk

Codifica la clave pública como un JWK en base64url dentro del DID.

```
did:jwk:eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2Ii4uLn0=
```

Generación: `base64url(JSON.stringify(jwk))`. El DID Document también se deriva sin resolución.

**Usos:**
- Ecosistemas JOSE/JWT (OID4VP usa JWTs)
- `cnf.jwk` en SD-JWT VC: el issuer embebe el JWK del holder en la credencial
- Key binding proof en presentaciones: el holder firma el `kb-jwt` con esa clave

---

## Cuándo usa cada método

| Contexto | DID method | Tipo de clave |
|---|---|---|
| Proof of possession en issuance (OID4VCI) | `did:key` o `did:jwk` | P-256 |
| Key binding en SD-JWT VP | `did:jwk` (vía `cnf`) | P-256 |
| mDL / ISO 18013-5 | ninguno (DeviceKey directo) | P-256 |
| DIDComm / AIP 2.0 | `did:key` o `did:peer` | Ed25519 + X25519 |

---

## Por qué claves distintas por protocolo

| Protocolo | Requiere | Motivo |
|---|---|---|
| DIDComm v1/v2 | Ed25519 + X25519 | signing + key agreement (ECDH) |
| OID4VCI / OID4VP | P-256 | compatible con Secure Enclave iOS/Android |
| mDL ISO 18013-5 | P-256 | estándar del documento de viaje |

Ed25519 no sirve para ECDH (key agreement), entonces DIDComm necesita al menos dos claves: una para firmar y una para cifrar. P-256 puede hacer ambas pero es más lento.

---

## Flujo OID4VCI + SD-JWT (issuance → presentation)

```
Issuance:
1. Wallet genera par de claves P-256  →  construye did:jwk o did:key
2. Wallet envía proof JWT al Issuer   →  prueba que controla esa clave
3. Issuer emite SD-JWT con cnf: { jwk: <public_key> }
4. Holder guarda VC con su clave embebida

Presentation (OID4VP):
5. Holder construye VP + kb-jwt firmado con la misma clave privada
6. Verifier resuelve did:jwk del cnf → verifica firma → key binding ok
```

---

## Por qué no did:web para el holder

`did:web` requiere hosting público — no tiene sentido para un dispositivo móvil. `did:key` y `did:jwk` son **self-contained**: se resuelven sin infraestructura, perfectos para identidades efímeras de wallet.

La EUDI ARF recomienda P-256 como curva base por compatibilidad con HSM/Secure Enclave en móviles, de ahí que `did:jwk` con `crv: P-256` sea el más común en las implementaciones de referencia.

---

## Soporte en Credo-TS

*(Versión analizada: 0.6.x — marzo 2026)*

### Métodos DID soportados nativamente

| Método | Paquete | Para el holder |
|---|---|---|
| `did:key` | `@credo-ts/core` | Sí — central para wallets |
| `did:jwk` | `@credo-ts/core` | Sí — OID4VCI/OID4VP |
| `did:peer` | `@credo-ts/didcomm` | Sí — DIDComm / P2P |
| `did:web` | `@credo-ts/core` | Típico de issuer/verifier |

### Tipos de clave soportados (Askar KMS)

| Tipo | Algoritmo | Uso |
|---|---|---|
| Ed25519 | EdDSA | Firma JWT, DIDComm |
| X25519 | ECDH | Key agreement DIDComm (derivable desde Ed25519) |
| P-256 | ES256 | OID4VC, SD-JWT VC, Secure Enclave |
| secp256k1 | ES256K | Ledgers (Ethereum, etc.) |

### Creación de DIDs en código

```typescript
// did:key con Ed25519
await agent.dids.create({
  method: 'key',
  options: { keyType: KeyType.Ed25519 }
})

// did:key con P-256
await agent.dids.create({
  method: 'key',
  options: { keyType: KeyType.P256 }
})

// did:jwk con P-256 (OID4VCI)
await agent.dids.create({
  method: 'jwk',
  options: { keyType: KeyType.P256 }
})

// Solo clave, sin DID (para cnf.jwk directo)
const key = await agent.kms.createKey({ type: { kty: 'EC', crv: 'P-256' } })
```

### OID4VCI y OID4VP — `@credo-ts/openid4vc`

El módulo `OpenId4VcHolderModule` cubre el flujo completo del holder:

- `resolveCredentialOffer()` — resuelve el offer del issuer
- `requestToken()` / `refreshToken()` — gestión de access tokens
- `requestCredentials()` — solicita credencial con binding
- `resolveOpenId4VpAuthorizationRequest()` — procesa el request del verifier
- `acceptOpenId4VpAuthorizationRequest()` — responde con VP
- `selectCredentialsForPresentationExchangeRequest()` — selección automática DIF PEX
- `selectCredentialsForDcqlRequest()` — selección automática DCQL

Lo único que hay que escribir es el **`credentialBindingResolver`** — un callback que decide qué DID/key usar según lo que soporta el issuer:

```typescript
credentialBindingResolver: async ({ supportedDidMethods, supportsJwk }) => {
  if (supportedDidMethods?.includes('did:key')) {
    const did = await agent.dids.create({
      method: 'key',
      options: { keyType: KeyType.P256 }
    })
    return {
      method: 'did',
      didUrl: did.didDocument.verificationMethod[0].id
    }
  }
  if (supportsJwk) {
    const key = await agent.kms.createKey({ type: { kty: 'EC', crv: 'P-256' } })
    return { method: 'jwk', jwk: key.publicJwk }
  }
}
```

### SD-JWT y key binding (`cnf.jwk`)

Nativo y completo via `SdJwtVcApi`:

| Tipo de binding | Clase |
|---|---|
| DID binding | `SdJwtVcHolderDidBinding` |
| JWK binding | `SdJwtVcHolderJwkBinding` |

La credencial SD-JWT se almacena con el `kmsKeyId` correspondiente en `SdJwtVcRecord`. Al presentar, el holder firma el `kb-jwt` con la clave privada vinculada automáticamente.

### DIDComm

- **v1** — completo y maduro con Ed25519 + X25519. Incluye issue-credential, present-proof, mediator.
- **v2** — solo mensajería básica (`ping`). Los protocolos de credenciales sobre DIDComm v2 aún no están implementados.

### Resumen: nativo vs. a implementar

| Capacidad | Estado |
|---|---|
| `did:key`, `did:jwk`, `did:peer` | Nativo |
| KMS Ed25519, P-256, X25519 | Nativo |
| OID4VCI completo (holder) | Nativo |
| OID4VP completo (holder) | Nativo |
| SD-JWT con `cnf.jwk` key binding | Nativo |
| DIDComm v1 completo | Nativo |
| `credentialBindingResolver` | A implementar (callback) |
| DIDComm v2 protocolos completos | No disponible aún |
| P-384 / P-521 | No soportado (limitación Askar JS) |
| KMS externo (Google KMS, AWS KMS) | En roadmap |
