# Métodos DID: qué son, cómo funcionan y cómo los usa EUDI vs nosotros

## Índice

1. [Qué es un DID (concepto base)](#1-qué-es-un-did-concepto-base)
2. [Cómo resolvemos DIDs hoy (nuestro sistema)](#2-cómo-resolvemos-dids-hoy-nuestro-sistema)
3. [did:key](#3-didkey)
4. [did:peer](#4-didpeer)
5. [did:jwk](#5-didjwk)
6. [did:web](#6-didweb)
7. [did:ebsi](#7-didebsi)
8. [did:ion](#8-didion)
9. [did:ethr](#9-didethr)
10. [Cómo gestiona EUDI las claves (HSM, WSCD)](#10-cómo-gestiona-eudi-las-claves-hsm-wscd)
11. [Tabla comparativa general](#11-tabla-comparativa-general)
12. [Qué necesitaríamos para interoperar](#12-qué-necesitaríamos-para-interoperar)

---

## 1. Qué es un DID (concepto base)

Un **DID (Decentralized Identifier)** es un identificador global único que:
- No depende de ninguna autoridad central (a diferencia de un email o username)
- Está ligado criptográficamente a un par de claves (pública + privada)
- Tiene un **DID Document** asociado que describe las claves públicas y los endpoints del sujeto

**Formato:**
```
did:<method>:<method-specific-identifier>
```

Ejemplos:
```
did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
did:ebsi:ziE2n8Ckhi6ut5Z8Cexrihd
did:web:university.edu
did:custom:abc123
```

El **DID Document** contiene:
```json
{
  "id": "did:custom:abc123",
  "verificationMethod": [{
    "id": "did:custom:abc123#key-1",
    "type": "Ed25519VerificationKey2018",
    "controller": "did:custom:abc123",
    "publicKeyBase58": "..."
  }],
  "authentication": ["did:custom:abc123#key-1"],
  "service": [{
    "type": "DIDCommMessaging",
    "serviceEndpoint": "ws://issuer-service:3000"
  }]
}
```

**Resolver un DID** = ir a buscar el DID Document para obtener la clave pública y el endpoint del sujeto.

---

## 2. Cómo resolvemos DIDs hoy (nuestro sistema)

### Lo que tenemos

En [`packages/credo/src/agent/build-dids-module.ts`](../../packages/credo/src/agent/build-dids-module.ts):

```typescript
export function buildDidsModule(config: OneDidRegistrarConfig): DidsModule {
  return new DidsModule({
    resolvers: [new OneDidResolver(config.vdrServiceUrl)],  // solo uno
    registrars: [new OneDidRegistrar(config)],
  })
}
```

En [`packages/credo/src/adapters/did/one-did-resolver.ts`](../../packages/credo/src/adapters/did/one-did-resolver.ts):

```typescript
export class OneDidResolver implements DidResolver {
  public readonly supportedMethods = ['custom']  // solo did:custom

  async resolve(_ctx, did) {
    const res = await fetch(`${this.baseUrl}/did/${encodeURIComponent(did)}`)
    // si no existe → error notFound
  }
}
```

### El problema

| Situación | Resultado |
|---|---|
| Holder recibe invitación de otro agente `did:custom` nuestro | ✅ Funciona |
| Holder recibe invitación de una wallet externa con `did:key` | ❌ `notFound` — no hay resolver |
| Holder recibe invitación de issuer EUDI con `did:ebsi` | ❌ `notFound` — no hay resolver |
| Holder recibe invitación de org con `did:web` | ❌ `notFound` — no hay resolver |

**El sistema hoy es un silo cerrado.** Solo puede comunicarse con agentes que usen `did:custom` en nuestro propio `vdr-service`.

### Cómo lo hace EUDI

EUDI define una interfaz abstracta inyectable:

```kotlin
fun interface LookupPublicKeyByDIDUrl {
    suspend fun resolveKey(didUrl: URI): PublicKey?
}
```

La librería no bundlea ningún resolver. La aplicación inyecta el que corresponda. Un multi-resolver despacha automáticamente según el método del DID que llegue.

---

## 3. did:key

### Cómo funciona

El DID **ES** la clave pública. La clave pública se codifica directamente en el string del DID usando multicodec + base58btc. No hay registro, no hay blockchain, no hay red.

**Algoritmo de creación:**
1. Generar par de claves (Ed25519, P-256, secp256k1, etc.)
2. Tomar los bytes crudos de la clave pública
3. Prefijar con el identificador multicodec del tipo de clave:

| Tipo de clave | Prefijo hex | Ejemplo DID |
|---|---|---|
| Ed25519 | `0xed01` | `did:key:z6Mk...` |
| P-256 | `0x1200` | `did:key:zDna...` |
| secp256k1 | `0xe701` | `did:key:zQ3...` |
| X25519 (ECDH) | `0xec01` | `did:key:z6LS...` |

4. Encodear con base58btc (multibase, prefijo `z`)
5. Prefijar `did:key:`

**Ejemplo concreto Ed25519:**
```
clave pública raw (32 bytes): 2e6fcce36701dc...
+ prefijo 0xed01
→ base58btc
→ did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
```

El `z` en `z6Mk...` es el indicador de base58btc en multibase.

**DID Document — se genera algorítmicamente, nadie lo guarda:**
```json
{
  "id": "did:key:z6Mk...",
  "verificationMethod": [{
    "id": "did:key:z6Mk...#z6Mk...",
    "type": "Ed25519VerificationKey2020",
    "publicKeyMultibase": "z6Mk..."
  }],
  "authentication": ["did:key:z6Mk...#z6Mk..."],
  "assertionMethod": ["did:key:z6Mk...#z6Mk..."],
  "keyAgreement": ["did:key:z6LS...#z6LS..."]  // X25519 derivado de Ed25519
}
```

### Dónde se guarda la clave privada

**En ningún lugar prescripto.** El spec no dicta dónde. En la práctica:
- En wallets móviles: Secure Enclave (iOS) o Android Keystore con TEE/StrongBox
- En wallets de desarrollo: memoria o archivo local
- No hay KMS, no hay servidor, no hay base de datos

La clave privada **nunca sale del dispositivo**.

### Dónde se guarda la clave pública / DID Document

**En ningún lugar externo.** La clave pública está codificada en el propio string del DID. El DID Document se reconstruye localmente por cualquier resolver que implemente el algoritmo. **Resolución 100% offline.**

### Necesita red para resolver

**No.** Cualquiera con el string `did:key:z6Mk...` puede reconstruir el DID Document sin hacer ninguna llamada HTTP.

### Limitaciones críticas

- **No hay rotación de claves.** Si la clave se compromete, el DID muere — hay que crear uno nuevo.
- **No hay revocación.** No se puede "deshabilitar" el DID.
- **Correlación.** La clave pública está visible en el DID → alguien que ve el DID en múltiples contextos puede correlacionar la identidad.

### EUDI lo usa para

- Todos los **holders (personas físicas)**. El wallet genera el DID del usuario localmente.
- Proofs en OpenID4VP: el wallet firma la presentación con su `did:key`.
- La spec EBSI **exige** `did:key` con P-256 para los holders.

### Nosotros

No lo usamos hoy. Nuestros holders usan `did:custom` registrado en nuestro VDR.
Agregar soporte requeriría registrar `KeyDidResolver` en el `DidsModule` — es un cambio de 3 líneas.

---

## 4. did:peer

### Cómo funciona

`did:peer` es un DID **pairwise** — existe solamente entre las dos partes que se lo intercambian. Nunca se publica en ningún registro externo. El "registro" es la memoria local de cada agente.

**Variantes (numalgo):**

| Numalgo | Cómo | Cuándo |
|---|---|---|
| `0` | Igual a `did:key`, clave única | Simple, sin endpoint |
| `1` | SHA-256 del DID document inicial | Clave con documento |
| `2` | Múltiples claves + endpoints codificados en el DID | Lo más común en DIDComm v2 |
| `4` | Hash corto + documento completo en long-form | Preferido en DIDComm v2 |

**Numalgo 2 — cómo se codifica:**

Cada clave tiene un prefijo de propósito antes de encodearla:
- `A` = assertionMethod
- `E` = keyAgreement (Encryption)
- `V` = authentication (Verification)
- `S` = service endpoint

```
did:peer:2
  .Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc   ← E = encryption key
  .Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V   ← V = verification key
  .SeyJ0IjoiZG0iLCJzIjp7InVyaSI6...                      ← S = service (base64url JSON)
```

**Long-form (numalgo 4):**
```
did:peer:4:<hash>:<base64url(did-document)>
```
El DID Document completo viaja dentro del propio DID → resolución offline inmediata.

### Dónde se guarda la clave privada

**En el dispositivo/wallet de cada parte.** Cada agente genera su propio par de claves para la relación. La clave privada nunca sale del agente.

### Dónde se guarda la clave pública / DID Document

**Local, en cada uno de los dos agentes.** Alice guarda el `did:peer` de Bob; Bob guarda el `did:peer` de Alice. No hay registro compartido. La base de datos del wallet (en nuestro caso, `wallet-service`) guarda este mapeo.

### Necesita red para resolver

**No.** Para numalgo 2 y 4 la resolución es cómputo local. Para numalgo 1 necesitás haber recibido el documento durante el handshake inicial.

### EUDI lo usa para

Internamente en DIDComm v2. Cada conexión entre agentes usa `did:peer` para el canal DIDComm cifrado. No se usa en los flujos OpenID4VCI/4VP (que van por HTTPS, no DIDComm).

### Nosotros

Credo lo soporta internamente — cuando dos agentes hacen el handshake DIDComm, usan `did:peer` por debajo para el canal seguro. No necesitamos hacer nada para esto — Credo lo maneja solo.

Lo que nos falta es el **resolver externo** para cuando llega un `did:peer` de una wallet que no conocemos. Agregar `PeerDidResolver` al `DidsModule` lo resolvería.

---

## 5. did:jwk

### Cómo funciona

Similar a `did:key` pero en lugar de bytes crudos con multicodec, usa un **JSON Web Key (JWK)** serializado en base64url.

**Algoritmo:**
1. Tomar la clave pública en formato JWK (RFC 7517)
2. Serializar a JSON
3. Encodear con base64url (sin padding)
4. Prefijar `did:jwk:`

**Ejemplo P-256:**
```json
{"crv":"P-256","kty":"EC","x":"acbIQiuMs...","y":"_KcyLj9vWD..."}
```
→ `did:jwk:eyJjcnYiOiJQLTI1NiIsImt0eSI6...`

**DID Document (generado algorítmicamente):**
```json
{
  "id": "did:jwk:eyJ...",
  "verificationMethod": [{
    "id": "did:jwk:eyJ...#0",
    "type": "JsonWebKey2020",
    "publicKeyJwk": { ...JWK original... }
  }],
  "assertionMethod": ["did:jwk:eyJ...#0"],
  "authentication": ["did:jwk:eyJ...#0"]
}
```

**Diferencia clave con `did:key`:** En `did:key` los bytes se codifican con multicodec (tabla de tipos). En `did:jwk` el JWK completo (con el campo `kty`, `crv`, etc.) va encodado — lo que hace el DID más largo pero más explícito en el tipo de clave.

**Problema de canonicalización:** El mismo JWK puede producir diferentes `did:jwk` dependiendo del orden de las propiedades JSON. Para ser determinístico se debe usar JCS (RFC 8785).

### Dónde se guarda la clave privada

Igual que `did:key` — en ningún lugar prescripto. En la práctica: wallet del dispositivo.

### Dónde se guarda la clave pública / DID Document

**Dentro del propio DID string.** Resolución offline, sin red.

### EUDI lo usa para

- Proofs en **OpenID4VCI**: el wallet incluye su clave como `did:jwk` en el JWT de prueba.
- **SD-JWT VC**: el `cnf.jwk` del credential puede referenciarse como `did:jwk`.
- Ecosistemas JOSE/OAuth donde JWK es el formato nativo.

### Nosotros

No lo usamos. Sería necesario si migramos a OpenID4VCI o SD-JWT.

---

## 6. did:web

### Cómo funciona

Usa un **servidor web y DNS** como registro. El DID Document es un archivo JSON en una URL HTTPS derivada del DID.

**Algoritmo de resolución:**
```
did:web:example.com
→ GET https://example.com/.well-known/did.json

did:web:example.com:users:alice
→ GET https://example.com/users/alice/did.json

did:web:example.com%3A8443
→ GET https://example.com:8443/.well-known/did.json
```

**El DID Document es un JSON estándar** servido por el servidor:
```json
{
  "@context": ["https://www.w3.org/ns/did/v1"],
  "id": "did:web:university.edu",
  "verificationMethod": [{
    "id": "did:web:university.edu#key-1",
    "type": "JsonWebKey2020",
    "publicKeyJwk": { "kty": "EC", "crv": "P-256", ... }
  }],
  "assertionMethod": ["did:web:university.edu#key-1"],
  "service": [{
    "type": "CredentialIssuer",
    "serviceEndpoint": "https://university.edu/credentials"
  }]
}
```

Para actualizar el DID Document: simplemente editás el archivo JSON en el servidor. Sin transacciones, sin gas, sin blockchain.

### Dónde se guarda la clave privada

**En el servidor del operador.** En producción: KMS cloud (AWS KMS, Azure Key Vault, HashiCorp Vault) o HSM on-premises. La clave privada nunca aparece en el `did.json` — solo la pública.

### Dónde se guarda la clave pública / DID Document

**En el servidor web** del controlador del DID. Es una URL HTTPS pública.

### Necesita red para resolver

**Sí.** Requiere un GET HTTPS al dominio. Sin acceso al servidor, no hay resolución.

### Vulnerabilidades

- Si el dominio expira → el DID desaparece
- Si alguien hackea el servidor → puede cambiar el DID Document silenciosamente
- DNS hijacking puede redirigir la resolución
- No hay historial de cambios (a diferencia de blockchain)

### EUDI lo usa para

- Algunos emisores e issuers de referencia usan `did:web`.
- Microsoft Entra Verified ID migró de `did:ion` a `did:web` como opción principal.
- Organizaciones grandes con dominio propio y web PKI existente.

### Nosotros

Hoy nuestro `vdr-service` expone `GET /:id/did.json` — técnicamente podría funcionar como backend para `did:web` si le damos un dominio público. Ya tiene la ruta implementada.

Para interoperar con organizaciones que usan `did:web`, solo faltaría agregar `WebDidResolver` al `DidsModule`.

---

## 7. did:ebsi

### Cómo funciona

`did:ebsi` es un DID anclado en la **blockchain de EBSI** — una red Hyperledger Besu (EVM-compatible) permisionada, operada por ~40 nodos distribuidos en 27 estados de la UE + Noruega + Liechtenstein.

**Formato del DID:**
```
did:ebsi:<identificador>
```
El identificador es base58btc de:
- 1 byte de versión (valor `1`)
- 16 bytes aleatorios

Ejemplo: `did:ebsi:z24q5bZBgQwDRpvPrJK9jc1s`

**Quién puede tener un `did:ebsi`:**
- **SOLO entidades legales** (organizaciones, universidades, gobiernos) — issuers, verifiers, TAOs
- **Los holders (personas físicas) usan `did:key`** — obligatorio en la spec EBSI
- Para registrar un `did:ebsi` hay que pasar por un proceso de onboarding formal con la UE

**Proceso de registro (complejo):**
1. Generar par de claves: ES256K para `capabilityInvocation`, ES256 para `authentication`/`assertionMethod`
2. Obtener un `VerifiableAuthorisationToOnboard` credential de un Trusted Issuer (requiere onboarding legal)
3. Obtener tokens de acceso del EBSI Authorisation Service (`didr_invite` scope, luego `didr_write` scope)
4. Enviar transacciones Ethereum firmadas al smart contract `DID-REGISTRY-V4`:
   - `insertDidDocument` — registro inicial
   - `addVerificationMethod` — agregar claves
   - `addVerificationRelationship` — ligar claves a sus roles
5. Esperar confirmación en la blockchain

**La blockchain EBSI:**
- **Stack**: Hyperledger Besu (Java, Apache 2.0)
- **Consenso**: QBFT (Quorum Byzantine Fault Tolerant) — proof-of-authority permisionada
  - Los validadores rotan la propuesta de bloques
  - ≥2/3 de validadores deben firmar antes de agregar un bloque
  - Actualmente ~40 nodos validadores
- **Acceso**: lecturas públicas sin autenticación, escrituras requieren tokens EBSI
- **Smart contract**: `DID-REGISTRY-V4` en Solidity, desplegado en EVM
- **Ambientes**: Dev, Test, Conformance, Pilot, Pre-Production, Production

### Dónde se guarda la clave privada

**Nunca en la blockchain.** Las opciones para entidades legales:
- **HSM (Hardware Security Module)**: recomendado para producción, accesible via PKCS#11
- **Cloud KMS**: AWS CloudHSM, Azure Dedicated HSM, Thales Luna
- Las claves de `capabilityInvocation` (para gestionar el DID on-chain) y `assertionMethod` (para firmar VCs) **deben ser claves distintas** — buena práctica de separación de responsabilidades

### Dónde se guarda la clave pública / DID Document

**En la blockchain EBSI** (Hyperledger Besu), en el smart contract `DID-REGISTRY-V4`. El estado se reconstruye leyendo los eventos del contrato. Las operaciones históricas también se conservan — se puede resolver el DID tal como era en una fecha pasada (importante para validar VCs emitidas hace tiempo).

### Necesita red para resolver

**Sí.** Hay que llamar al API de EBSI:
```
GET https://api-pilot.ebsi.eu/did-registry/v5/identifiers/{did}
```

Hay un paquete npm oficial: `@cef-ebsi/ebsi-did-resolver` que implementa la interfaz estándar `did-resolver` de DIF.

### Ventajas sobre sistemas centralizados

- El DID Document no puede modificarse sin la clave de control privada
- Hay historial inmutable de todos los cambios (`versionTime` queries)
- No depende de un servidor propio — depende de la red EBSI que es operada por los Estados Miembros

### EUDI lo usa para

- Todos los **issuers** oficiales (universidades, gobiernos, organismos acreditados)
- Todos los **verifiers** (organizaciones que solicitan presentaciones)
- Las **TAOs** (Trusted Accreditation Organisations) que dan accreditation a los issuers
- Para credenciales de tipo: diploma universitario, DNI digital, carnet de conducir, acreditaciones profesionales

### Nosotros

No lo usamos ni tenemos planes inmediatos. Si quisiéramos emitir credentials reconocidas por EUDI necesitaríamos:
1. Proceso de onboarding formal con EBSI
2. Registrar un `did:ebsi` para nuestro issuer
3. Firmar credentials con ES256 (P-256) en lugar de Ed25519
4. Agregar `EbsiDidResolver` al `DidsModule`

---

## 8. did:ion

### Cómo funciona

`did:ion` implementa el **protocolo Sidetree** como capa 2 sobre Bitcoin. Las operaciones DID se agregan en lotes, se suben a IPFS, y solo el hash del lote se ancla en Bitcoin.

**Por qué Bitcoin como base:** La blockchain de Bitcoin tiene la mayor seguridad y descentralización. Anclar en Bitcoin hace que el historial sea prácticamente inmutable y resistente a censura.

**Short-form vs Long-form:**

```
Short-form: did:ion:EiBJz4qiH27ByqFzqEZNnLmF5VCUVqH...
Long-form:  did:ion:EiBJz4qiH27ByqFzqEZNnLmF5VCUVqH...:eyJkZWx0YQ...
```

- **Short-form**: solo usable después de que la operación se ancló en Bitcoin. Requiere nodo ION.
- **Long-form**: contiene el estado inicial codificado en base64url después del `:`. **Usable inmediatamente, sin anchoring, sin red.** Cuando se ancla, el short-form pasa a ser canónico pero ambos resuelven igual.

Esto permite emitir credentials con un DID ION **antes de que se registre en Bitcoin** — útil en dev o en casos de baja latencia.

**Sistema de claves dual (rotación + recuperación):**

| Clave | Propósito | Cuándo se usa |
|---|---|---|
| **Update key** | Operaciones rutinarias de update | Cada vez que se actualiza el DID doc — se invalida y rota en cada uso |
| **Recovery key** | Recuperación si la update key se compromete | Solo en casos de emergencia — se guarda en cold storage |

La **update key** tiene forward secrecy: al actualizar, revelás la clave actual y comprometés (hasheás) la próxima. Si alguien roba la update key actual, no pueden predecir la siguiente.

La **recovery key** nunca se usa rutinariamente → va en el lugar más seguro posible (HSM cold, multi-sig, etc.).

### Dónde se guarda la clave privada

**No prescripto.** En la práctica:
- Recovery key: cold storage, HSM, o multi-sig
- Update key: HSM o KMS
- Microsoft usó Azure Key Vault para el deployment de Entra Verified ID con ION

### Dónde se guarda la clave pública / DID Document

- **Lotes de operaciones**: en IPFS (contenido distribuido, addressable por hash)
- **Anclas**: en la blockchain de Bitcoin (solo el hash del batch root)
- **Estado actual**: reconstructido por nodos ION reproduciendo todas las operaciones desde el origen
- **No hay documento almacenado directamente** — siempre es reconstruido

### EUDI lo usa para

No directamente. ION es principalmente del ecosistema Microsoft. EUDI usa `did:ebsi` para sus issuers. Sin embargo, Microsoft Entra Verified ID (que puede interoperar con EUDI) soportó ION — aunque en 2024 empezó a deprecarlo en favor de `did:web`.

### Nosotros

No lo usamos ni es prioritario. Demasiada infraestructura (nodo Bitcoin + IPFS) para los beneficios actuales.

---

## 9. did:ethr

### Cómo funciona

`did:ethr` convierte cualquier **dirección Ethereum** en un DID válido. No se necesita registrar nada — la dirección Ethereum ya es implícitamente un DID.

```
did:ethr:0xb9c5714089478a327f09197987f16f9e5d936e8a
did:ethr:mainnet:0xb9c5714089478a327f09197987f16f9e5d936e8a
```

El DID Document se reconstruye leyendo los **eventos del smart contract ERC-1056** en Ethereum. Sin eventos: hay un documento default con solo la dirección como clave controller. Con eventos: se van agregando claves delegate y atributos según el historial.

**Operaciones soportadas:**
- `addDelegate(identity, type, delegate, validity)` → agrega clave temporal (con expiración)
- `setAttribute(identity, name, value, validity)` → agrega claves no-Ethereum o endpoints
- `changeOwner(identity, newOwner)` → transfiere el control del DID a otra dirección

**Multi-sig:** Si el `newOwner` es un smart contract multi-sig, el DID queda controlado por múltiples firmantes.

### Dónde se guarda la clave privada

**En la wallet Ethereum** del controlador (MetaMask, hardware wallet como Ledger/Trezor, o KMS para enterprise). Requiere secp256k1 (ECDSA) para firmar transacciones Ethereum.

### Dónde se guarda la clave pública / DID Document

- **Eventos**: en la blockchain Ethereum (log de eventos del contrato ERC-1056)
- **Estado**: reconstructido por el resolver leyendo los eventos en orden

### Necesita red para resolver

**Sí.** Requiere JSON-RPC a un nodo Ethereum (Infura, Alchemy, o propio).

### EUDI lo usa para

No directamente. EUDI usa `did:ebsi`. `did:ethr` es más del ecosistema Ethereum/Web3.

### Nosotros

No lo usamos. No es relevante para nuestro stack actual.

---

## 10. Cómo gestiona EUDI las claves (HSM, WSCD)

### Para entidades legales (issuers / verifiers)

EUDI **recomienda fuertemente HSMs** para producción. El CLI de EBSI tiene soporte explícito para hardware wallets via **PKCS#11** (estándar de facto para comunicarse con HSMs y smartcards).

Las claves se dividen por propósito:
- **`capabilityInvocation`**: Para firmar transacciones on-chain (gestión del DID). Clave ES256K (secp256k1).
- **`assertionMethod`**: Para firmar Verifiable Credentials. Clave ES256 (P-256).

**Nunca** usar la misma clave para ambos propósitos.

HSMs típicos en uso:
- Thales Luna Network HSM
- AWS CloudHSM
- Azure Dedicated HSM
- Entrust nShield

### Para holders (personas físicas): WSCD

El **WSCD (Wallet Secure Cryptographic Device)** es el componente que hace que la wallet EUDI alcance el **Nivel de Seguridad: Alto (LoA High)** según eIDAS 2.0.

**Definición**: Un dispositivo resistente a manipulación que provee un entorno para proteger activos críticos y ejecutar operaciones criptográficas de forma segura. La clave privada **nunca puede exportarse** en configuraciones de alta seguridad.

**Componentes:**

```
┌─────────────────────────────────────────┐
│            Wallet App (UI)              │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │   WSCA (Wallet Secure Crypto    │    │
│  │   Application)                  │    │
│  │   - Key generation              │    │
│  │   - Signing                     │    │
│  │   - Key derivation              │    │
│  └──────────────┬──────────────────┘    │
│                 │ SCI (Secure           │
│                 │ Cryptographic         │
│                 │ Interface)            │
│  ┌──────────────▼──────────────────┐    │
│  │   WSCD (Hardware)               │    │
│  │   - Claves privadas protegidas  │    │
│  │   - Tamper-resistant            │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

**Los 4 tipos de WSCD:**

| Tipo | Descripción | Dónde vive la clave | Ejemplo |
|---|---|---|---|
| **Remote WSCD** | HSM en la nube, acceso vía internet | Cloud-based HSM | Servicio de firma remota con backend HSM |
| **Local External WSCD** | Dispositivo físico externo | Hardware token / smartcard | Llave USB de seguridad, smartcard gubernamental |
| **Local Internal WSCD** | Embebido en el dispositivo del usuario | SIM, eSIM, embedded Secure Element | Applet criptográfico en eSIM |
| **Local Native WSCD** | APIs de seguridad del OS | Hardware-backed keystore del dispositivo | **Android StrongBox / TEE**, **iOS Secure Enclave** |

**Por plataforma:**

- **Android**: Keystore con hardware-backed Keymaster
  - `StrongBox`: procesador de seguridad dedicado (el más seguro)
  - `TEE` (Trusted Execution Environment): software-aislado dentro del SoC
  - Acceso via Android Keystore API
- **iOS**: Secure Enclave — coprocesador de seguridad dedicado en el SoC de Apple
  - Acceso via Keychain Services / CryptoKit
  - Las claves **no pueden exportarse** desde el Secure Enclave

### Cómo lo comparamos nosotros

| Aspecto | EUDI | Nosotros |
|---|---|---|
| KMS para issuers | HSM (PKCS#11) + EBSI CLI | `kms-service` propio con PostgreSQL |
| KMS para holders | WSCD (Secure Enclave / StrongBox / HSM) | `kms-service` externo o InternalKMS con PostgreSQL |
| Separación de claves | `capabilityInvocation` ≠ `assertionMethod` | Una sola clave Ed25519 por DID |
| Exportabilidad | Claves no exportables en LoA High | Claves en PostgreSQL — exportables |
| Certificación | Common Criteria EAL4+ para WSCD | No aplica |

Nuestro `kms-service` tiene una arquitectura equivalente a un **KMS lógico** (operaciones delegadas, claves centralizadas) pero con una implementación más simple (PostgreSQL en lugar de HSM). No alcanza LoA High pero es suficiente para el propósito actual.

---

## 11. Tabla comparativa general

| Propiedad | did:key | did:peer | did:jwk | did:web | did:ebsi | did:ion | did:ethr | did:custom (nosotros) |
|---|---|---|---|---|---|---|---|---|
| **Clave privada guardada en** | Holder (libre) | Device / wallet | Holder (libre) | Servidor KMS/HSM | HSM / device (WSCD) | HSM / KMS | Ethereum wallet / HSM | kms-service (PostgreSQL) |
| **Clave pública / DID Doc guardada en** | En el DID string | Local (cada peer) | En el DID string | Servidor HTTPS | Blockchain Besu | IPFS + Bitcoin | Ethereum event log | vdr-service (PostgreSQL) |
| **Necesita red para resolver** | No | No | No | Sí (HTTPS) | Sí (EBSI API) | Long-form: No / Short-form: Sí | Sí (Ethereum RPC) | Sí (vdr-service HTTP) |
| **Rotación de claves** | No | Por relación | No | Sí (editar JSON) | Sí (on-chain) | Sí (update op) | Sí (delegates) | No implementado |
| **Revocación / desactivación** | No | N/A | No | Sí (borrar archivo) | Sí (on-chain) | Sí | Sí | No implementado |
| **Quién controla** | Quien tiene la clave | Cada peer | Quien tiene la clave | Operador del dominio | Entidad legal (permisionada) | Quien tiene las claves | Dirección ETH | Nosotros (centralizado) |
| **Descentralización** | Máxima | Máxima (pairwise) | Máxima | Mínima (DNS/web) | Parcial (chain permisionada) | Alta (Bitcoin L2) | Media (ETH) | Ninguna |
| **Uso principal** | Holders, dev | Conexiones DIDComm | OID4VC, SD-JWT | Emisores enterprise | Emisores/Verif. EU | Enterprise MS | Ecosistema Ethereum | Nuestro sistema |
| **Costo** | Gratis | Gratis | Gratis | Hosting del servidor | Permisionado + gas | Tx Bitcoin (batched) | ETH gas | Infraestructura propia |
| **Interoperable con EUDI** | ✅ Nativo | ✅ DIDComm | ✅ OpenID4VCI | ✅ Amplio soporte | ✅ Oficial | ⚠️ Parcial | ❌ No directo | ❌ No |

---

## 12. Qué necesitaríamos para interoperar

### Cambios de bajo esfuerzo (alta prioridad)

**1. Agregar resolvers al `DidsModule`** — permite recibir invitaciones de wallets externas:

```typescript
// packages/credo/src/agent/build-dids-module.ts
import {
  DidsModule,
  KeyDidResolver,   // did:key
  PeerDidResolver,  // did:peer
  WebDidResolver,   // did:web
} from '@credo-ts/core'

export function buildDidsModule(config: OneDidRegistrarConfig): DidsModule {
  return new DidsModule({
    resolvers: [
      new OneDidResolver(config.vdrServiceUrl),  // did:custom (nuestro)
      new KeyDidResolver(),                       // did:key (holders EUDI, wallets externas)
      new PeerDidResolver(),                      // did:peer (DIDComm estándar)
      new WebDidResolver(),                       // did:web (organizaciones externas)
    ],
    registrars: [new OneDidRegistrar(config)],
  })
}
```

Esto desbloquea interoperabilidad con cualquier wallet DIDComm que use estos métodos.

### Cambios de esfuerzo medio

**2. Exponer el VDR con dominio público** — para que verificadores externos puedan:
- Resolver nuestros `did:custom` desde fuera
- Verificar el estado de revocación de nuestras credentials

**3. Soportar `did:web` para nuestros issuers** — si queremos ser identificables por dominio en lugar de `did:custom`:
```
did:web:issuer.nuestrodomain.com
→ GET https://issuer.nuestrodomain.com/.well-known/did.json
```
El `vdr-service` ya tiene `GET /:id/did.json` implementado — faltaría el dominio y el registrar.

### Cambios de alto esfuerzo (largo plazo)

**4. Implementar OpenID4VCI** — para emitir credentials a cualquier wallet EUDI:
- Protocolo sobre HTTPS estándar (reemplaza DIDComm para emisión)
- Requiere endpoints de autorización OAuth2 + `/credential`

**5. Implementar OpenID4VP** — para verificar presentations de wallets EUDI:
- Protocolo sobre HTTPS estándar (reemplaza DIDComm para verificación)

**6. Migrar credentials a SD-JWT VC** — para divulgación selectiva y compatibilidad EUDI:
- El KMS ya soporta BLS12381G2 → podría usarse para BBS+ (JSON-LD selectivo)
- O migrar a SD-JWT (JWT-based, más simple)

**7. Onboarding EBSI** — si queremos ser un issuer oficial en el ecosistema europeo:
- Proceso legal y técnico formal
- Registrar `did:ebsi` para nuestro issuer
- Firmar con ES256 (P-256) además de Ed25519



fuente: https://github.com/eu-digital-identity-wallet/