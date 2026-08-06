# KeyTypes y ProofTypes en QuarkID

## Conceptos

### Keytype (tipo de clave)

Define **cómo se representa la clave pública** dentro del DID document. Determina el algoritmo criptográfico y el formato de serialización.

| Tipo en DID document | Algoritmo | Serialización |
|---|---|---|
| `JsonWebKey2020` crv P-256 | ECDSA P-256 | JWK (`publicKeyJwk`) |
| `JsonWebKey2020` crv Ed25519 | EdDSA Ed25519 | JWK (`publicKeyJwk`) |
| `Ed25519VerificationKey2018` | EdDSA Ed25519 | Base58 (`publicKeyBase58`) |
| `Ed25519VerificationKey2020` | EdDSA Ed25519 | Multibase (`publicKeyMultibase`) |

### proofType (tipo de prueba)

Define **cómo se firma la credencial W3C VC**. Cada suite de firma busca en el DID document una `verificationMethod` del tipo compatible.

| proofType | Key type requerido | Algoritmo de firma |
|---|---|---|
| `BbsBlsSignature2020` (**default** JSON-LD DIDComm) | `Bls12381G2Key2020` (`#key-bbs-ldp`) | BBS+ BLS12-381 |
| `BbsBlsSignatureProof2020` | derivado de BBS | Proof of knowledge (selective disclosure) |
| `Ed25519Signature2018` | `Ed25519VerificationKey2018` | EdDSA Ed25519 (override por request) |
| `Ed25519Signature2020` | `Ed25519VerificationKey2020` | EdDSA Ed25519 |
| `JsonWebSignature2020` | `JsonWebKey2020` (cualquier curva) | JWS (ES256 o EdDSA) |

---

## La relación entre ambos

El `proofType` le dice a Credo-TS qué suite de firma usar. Esa suite recorre el DID document del issuer buscando una `verificationMethod` del tipo que entiende. Si no la encuentra, falla con error.

```
proofType → suite de firma → busca key type en DID doc → firma con esa clave
```

**Ejemplo de error:** si el issuer tiene solo `JsonWebKey2020` P-256 pero se pide `Ed25519Signature2018`, Credo lanza:
```
CredoError: Missing verification method for key type Ed25519VerificationKey2018
```

---

## Claves en el issuer/verifier de QuarkID

El DID `did:web` puede exponer varias verification methods. Convención de fragmentos
(`#key-{curva}-{formato}`): el sufijo describe el **formato de VM / credencial**, no el transporte.

| Fragmento | Tipo VM | Uso |
|---|---|---|
| `#key-p256` | `JsonWebKey2020` P-256 | OID4VCI/OID4VP ES256 (SD-JWT / EUDI) |
| `#key-ed25519-jwk` | `JsonWebKey2020` Ed25519 | Fallback EdDSA en JWK (opcional) |
| `#key-ed25519-ldp` | `Ed25519VerificationKey2018` | JSON-LD `Ed25519Signature2018` (+ recipientKeys DIDComm) |
| `#key-bbs-ldp` | `Bls12381G2Key2020` | JSON-LD `BbsBlsSignature2020` / Proof2020 (default LDP) |

```json
{
  "verificationMethod": [
    {
      "id": "did:web:issuer#key-p256",
      "type": "JsonWebKey2020",
      "publicKeyJwk": { "kty": "EC", "crv": "P-256", "x": "...", "y": "..." }
    },
    {
      "id": "did:web:issuer#key-ed25519-ldp",
      "type": "Ed25519VerificationKey2018",
      "publicKeyBase58": "..."
    },
    {
      "id": "did:web:issuer#key-bbs-ldp",
      "type": "Bls12381G2Key2020",
      "publicKeyBase58": "..."
    }
  ],
  "assertionMethod": [
    "did:web:issuer#key-p256",
    "did:web:issuer#key-ed25519-ldp",
    "did:web:issuer#key-bbs-ldp"
  ]
}
```

---

## Por qué Credo 0.6.x no soporta JsonWebSignature2020 en DIDComm

Credo-TS implementa suites de firma JSON-LD para el módulo DIDComm (`DidCommJsonLdCredentialFormatService`). En la versión 0.6.x, las suites disponibles son:

- `Ed25519Signature2018`
- `Ed25519Signature2020`
- `BbsBlsSignature2020`

`JsonWebSignature2020` existe como estándar (W3C) pero **no está implementada** en el módulo DIDComm de Credo 0.6.x. Intentar usarla produce:
```
CredoError: No signature suite for proof type: JsonWebSignature2020
```

Por eso el issuer necesita la clave Ed25519 adicional para poder emitir credenciales W3C VC sobre DIDComm.

---

## Flujos y claves utilizadas

| Flujo | Protocolo | Formato de credencial | Clave usada | proofType |
|---|---|---|---|---|
| EUDI Wallet | OID4VCI (HTTP) | `dc+sd-jwt` | P-256 `#key-1` | N/A (firma JWS interna) |
| DIDComm | DIDComm v1 | W3C JSON-LD | `#key-bbs-ldp` (default) o `#key-ed25519-ldp` (override) | `BbsBlsSignature2020` / `Ed25519Signature2018` |

---

## Clave de conexión DIDComm (did:peer)

Es importante no confundir las claves del DID document con la **clave de conexión DIDComm**:

- Cuando se establece una conexión DIDComm (invitation → handshake), Credo genera automáticamente un `did:peer:4` por conexión.
- Ese `did:peer` contiene su propia clave Ed25519 para cifrado/descifrado de mensajes.
- Es **efímera y pairwise**: única por conexión, no es el DID principal del agente.
- No se usa para firmar credenciales; solo para el transporte DIDComm.
