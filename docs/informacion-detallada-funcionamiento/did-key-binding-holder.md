# DID del Holder — Identidad DIDComm vs. Credential Binding

Explica por qué el holder maneja dos tipos de `did:key` distintos y por qué no se reutiliza el DID principal para el binding de credenciales.

---

## Dos usos distintos de `did:key`

El holder tiene dos contextos donde aparece un `did:key`, con propósitos completamente distintos:

| | DID principal del holder | DID de credential binding |
|---|---|---|
| **Tipo de clave** | Ed25519 | P-256 |
| **Creado por** | `ensureKeyDid()` al arrancar el agente | `credentialBindingResolver()` por cada credencial |
| **Usado para** | `ourDid` en conexiones DIDComm | `cnf.jwk` en el payload del SD-JWT VC |
| **Cuántos hay** | Uno por holder | Uno por credencial emitida |

---

## DID principal — identidad en DIDComm

El DID principal se crea al inicializar el agente holder y se usa como `ourDid` al aceptar invitaciones OOB:

```typescript
// agent-holder.ts
ensureKeyDid(agent, { keyType: 'Ed25519' })

// receive-invitation.ts
didcomm.oob.receiveInvitationFromUrl(url, { ourDid, ... })
```

**Por qué Ed25519:** DIDComm v1 firma los mensajes salientes con la clave del sender. El `DidCommMessageSender` de Credo busca una verification method Ed25519 en el DID document del holder. P-256 no es válido aquí — DIDComm lanza `MessageSendingError: no available Ed25519 keys`.

---

## Credential binding — `cnf.jwk` en el SD-JWT

Al recibir una credencial vía OID4VCI, el `credentialBindingResolver` crea una clave P-256 nueva y la embebe en el claim `cnf` del SD-JWT VC:

```typescript
// credential-binding-resolver.ts
const key = await agent.kms.createKey({ type: { kty: 'EC', crv: 'P-256' } })
return { method: 'jwk', keys: [Kms.PublicJwk.fromPublicJwk(key.publicJwk)] }
```

El `cnf.jwk` en el payload de la credencial queda así:

```json
{
  "cnf": {
    "jwk": {
      "kty": "EC",
      "crv": "P-256",
      "x": "B1hVz_o4F08j1q4tMVneKM6_k1eVVanUdGKm2IAup8Y",
      "y": "SUz8b7l9PXAwFlr_6dDmI1_RkKIG3_pM9_ZLsr6EBcw"
    }
  }
}
```

Al presentar la credencial (OID4VP), el holder firma el KB-JWT con la clave privada correspondiente a ese `cnf.jwk`, demostrando que controla la credencial.

**Por qué P-256:** OID4VCI usa ES256 (ECDSA P-256) para el key binding. La clave de binding no tiene nada que ver con DIDComm.

---

## Por qué no se reutiliza el DID principal para el binding

### 1. Propósitos distintos

El DID principal es la identidad del agente en el protocolo de mensajería. El `cnf.jwk` es un mecanismo de prueba de posesión de credencial. Mezclarlos acoplaría dos protocolos que no tienen relación.

### 2. Unlinkability (privacidad)

Si todas las credenciales compartieran el mismo `cnf.jwk`:

```
Verifier A → ve cnf.jwk = did:key:zABC → identifica al holder
Verifier B → ve cnf.jwk = did:key:zABC → puede correlacionar con Verifier A
```

Con una clave distinta por credencial, los verifiers no pueden correlacionar presentaciones entre sí aunque el holder presente credenciales distintas. Esto es un requisito de privacidad explícito en el spec SD-JWT VC.

### 3. Independencia de compromiso

Si la clave de binding de una credencial es comprometida, solo esa credencial se ve afectada. El DID principal del holder y el resto de las credenciales permanecen seguros.

---

## Flujo completo con ambos DIDs

```
arranque del agente
  └─ ensureKeyDid(Ed25519)  →  did:key:z6Mk...  (DID principal)

recepción de invitación DIDComm
  └─ receiveInvitation(ourDid = did:key:z6Mk...)
       └─ DIDComm firma mensajes con Ed25519 ✓

recepción de credencial OID4VCI
  └─ credentialBindingResolver()
       └─ createKey(P-256)  →  clave de binding fresca
       └─ cnf.jwk = { kty: EC, crv: P-256, x: ..., y: ... }

presentación OID4VP
  └─ KB-JWT firmado con la clave P-256 del cnf.jwk de esa credencial
```

---

## Acumulación de claves

Cada credencial emitida genera un par de claves P-256 nuevo almacenado en el KMS (PostgreSQL). En un holder de producción esto implica:

- Gestión del ciclo de vida de claves (borrar claves de credenciales revocadas)
- Potencialmente muchas claves si el holder recibe muchas credenciales

En el entorno local de desarrollo esto no es un problema — las claves se limpian al reiniciar el contenedor.
