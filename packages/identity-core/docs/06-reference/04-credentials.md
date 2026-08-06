---
id: credentials
title: Credenciales
sidebar_position: 4
---

# Credenciales

Esta referencia documenta los formatos de credencial soportados por `@quarkid/identity-core` y los _builders_ de `credential.builder.ts` para armar _payloads_ W3C JSON-LD en el flujo DIDComm. Las Presentation Definitions DIF PEX las arma el consumidor (issuer/verifier Nest o el caller de `requestProof`); no hay un builder gen�rico en la librer�a.

## Formatos de credencial soportados

La librer�a se monta sobre Credo-TS 0.7 y habilita dos formatos de credencial, cada uno asociado a un transporte distinto:

| Formato | Transporte | M�dulo Credo | Uso |
| --- | --- | --- | --- |
| **W3C JSON-LD** (Verifiable Credential) | DIDComm v1 (mensajer�a cifrada) | `DidCommJsonLdCredentialFormatService` dentro de `DidCommCredentialV2Protocol` (protocolo issue-credential v2) | Emisi�n y recepci�n de credenciales entre issuer y holder por conexi�n DIDComm. |
| **SD-JWT VC** (divulgaci�n selectiva) | OID4VCI (HTTP / OAuth2) | `SdJwtVcModule` + `OpenId4VcIssuerModule` | Emisi�n v�a endpoint OID4VCI (compatible con EUDI Wallet). |

Detalle verificado en los agentes (`src/agent/issuer.agent.ts`, `src/agent/holder.agent.ts`):

- El protocolo de credenciales DIDComm usa `QuarkJsonLdCredentialFormatService` (extiende Credo): firma/verifica `BbsBlsSignature2020` con la capa MATTR; otros `proofType` (p. ej. `Ed25519Signature2018`) delegan a Credo. Por DIDComm s�lo viajan credenciales **W3C JSON-LD** (sin AnonCreds ni SD-JWT).
- El m�dulo `SdJwtVcModule` est� siempre activo, y `OpenId4VcIssuerModule` se monta s�lo cuando hay `oid4vcBaseUrl` + `expressApp`. La emisi�n SD-JWT VC se hace v�a OID4VCI (ver [Emisi�n OID4VCI](../05-flows/01-issuance-oid4vci.md)).
- Las _proofs_ DIDComm usan `QuarkDifPresentationExchangeProofFormatService` (PEX + `deriveProof` BBS antes de armar la VP; verify BBS en el verifier). OID4VP sigue el camino Credo/SD-JWT (ver [Verificaci�n OID4VP](../05-flows/02-verification-oid4vp.md)).
- **No** existe soporte de mDoc / ISO mDL en el c�digo de la librer�a. No lo asumas.

Los _builders_ documentados a continuaci�n (`credential.builder.ts`) construyen exclusivamente _payloads_ **W3C JSON-LD** para el flujo DIDComm. El _payload_ de una credencial SD-JWT en OID4VCI se arma de otra forma (mapper de credenciales del issuer); ver [Emisi�n OID4VCI](../05-flows/01-issuance-oid4vci.md).

## `credential.builder.ts`

_Builders_ para construir _payloads_ de credenciales W3C JSON-LD en el flujo DIDComm. M�dulo: `src/credential/credential.builder.ts`.

### `CredentialParams`

Par�metros base para ofrecer o proponer una credencial:

```ts
interface CredentialParams {
  credential: {
    '@context'?: unknown
    credentialSubject?: Record<string, unknown>
    type?: string[]
  }
  proofType?: string
}
```

- `credential['@context']` ? opcional. Si se omite, se genera con `buildCredentialContext`.
- `credential.credentialSubject` ? datos del sujeto (opcional).
- `credential.type` ? tipos custom de la credencial (opcional; por defecto `['GenericCredential']`).
- `proofType` ? tipo de prueba (opcional; por defecto `BbsBlsSignature2020`, ver `getProofOptions`). Si el request trae otro valor, ese gana.

### `buildCredentialContext(customTypes)`

Construye el array `@context` para una credencial JSON-LD a partir de tipos custom.

```ts
function buildCredentialContext(
  customTypes: string[]
): (string | Record<string, string>)[]
```

- Si `customTypes` est� vac�o, devuelve los contextos por defecto: `['https://www.w3.org/2018/credentials/v1', 'http://schema.org/']`.
- Si hay tipos custom, agrega al final un objeto que mapea cada tipo a `https://www.w3.org/2018/credentials#<tipo>`.

### `buildOfferCredentialPayload(params, options)`

Construye el _payload_ de credencial para `offerCredential` (lado **issuer**).

```ts
function buildOfferCredentialPayload(
  params: CredentialParams,
  options: { credentialId: string; issuerDid: string; holderDid: string }
): Record<string, unknown>
```

Devuelve un objeto credencial W3C con:

- `@context` ? `params.credential['@context']` o el resultado de `buildCredentialContext(customTypes)`.
- `id` ? `options.credentialId`.
- `type` ? `['VerifiableCredential', ...customTypes]`, donde `customTypes` es `params.credential.type ?? ['GenericCredential']`.
- `issuer` ? `options.issuerDid`.
- `issuanceDate` ? fecha actual en ISO 8601.
- `credentialSubject` ? el `credentialSubject` de `params`, con `id` por defecto igual a `options.holderDid` si no se especific�.

### `buildProposalCredentialPayload(params, options)`

Construye el _payload_ de credencial para `proposeCredential` (lado **holder**).

```ts
function buildProposalCredentialPayload(
  params: CredentialParams,
  options: { holderDid: string }
): Record<string, unknown>
```

Similar al anterior, pero sin `id`, sin `issuer` y orientado a la propuesta del holder:

- `@context` ? igual criterio que en la oferta.
- `type` ? `['VerifiableCredential', ...customTypes]`.
- `issuanceDate` ? fecha actual en ISO 8601.
- `credentialSubject` ? con `id` por defecto `options.holderDid`.

### `getProofOptions(params)`

Devuelve las opciones de prueba para los _credential formats_.

```ts
function getProofOptions(params: { proofType?: string }): {
  proofType: string
  proofPurpose: string
}
```

- `proofType` ? `params.proofType` o, por defecto, `'BbsBlsSignature2020'`.
- `proofPurpose` ? siempre `'assertionMethod'`.

### `toCredentialPayload(encoded, json)`

Serializa un _credential record_ de Credo a JSON legible.

```ts
function toCredentialPayload(encoded: unknown, json: unknown): unknown
```

- Si `encoded` es un `string`, lo devuelve tal cual.
- Si `encoded` es un objeto, lo serializa con `JsonTransformer.toJSON`.
- En caso contrario, si `json` es un objeto, serializa `json`; si no, devuelve `encoded`.

## Ejemplo: armar el payload de una oferta W3C JSON-LD

```ts
import {
  buildOfferCredentialPayload,
  getProofOptions,
  type CredentialParams,
} from '@quarkid/identity-core'

const params: CredentialParams = {
  credential: {
    type: ['UniversityDegreeCredential'],
    credentialSubject: {
      degree: 'Licenciatura en Inform�tica',
      university: 'Universidad Nacional',
    },
  },
  // proofType opcional; si se omite usa BbsBlsSignature2020 (request gana si viene expl?cito)
}

const payload = buildOfferCredentialPayload(params, {
  credentialId: 'urn:uuid:1234',
  issuerDid: 'did:web:issuer.example.com',
  holderDid: 'did:key:z6Mk...',
})

const proof = getProofOptions({ proofType: params.proofType })
// proof => { proofType: 'BbsBlsSignature2020', proofPurpose: 'assertionMethod' }
```

El `payload` resultante es una credencial W3C lista para emitir v�a DIDComm:

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "http://schema.org/",
    { "UniversityDegreeCredential": "https://www.w3.org/2018/credentials#UniversityDegreeCredential" }
  ],
  "id": "urn:uuid:1234",
  "type": ["VerifiableCredential", "UniversityDegreeCredential"],
  "issuer": "did:web:issuer.example.com",
  "issuanceDate": "2026-06-16T12:00:00.000Z",
  "credentialSubject": {
    "degree": "Licenciatura en Inform�tica",
    "university": "Universidad Nacional",
    "id": "did:key:z6Mk..."
  }
}
```

## Notas

- El `proofType` por defecto es **`BbsBlsSignature2020`**, con `proofPurpose` siempre `assertionMethod`.
- Estos _builders_ son para el flujo **DIDComm W3C JSON-LD**. El flujo **SD-JWT VC v�a OID4VCI** se arma de manera distinta (no usa estos _builders_); ver [Emisi�n OID4VCI](../05-flows/01-issuance-oid4vci.md).
- El campo `id` del `credentialSubject` cae por defecto al DID del holder (`holderDid`) cuando no se especifica.

## Ver tambi�n

- [Emisi�n OID4VCI](../05-flows/01-issuance-oid4vci.md)
- [Verificaci�n OID4VP](../05-flows/02-verification-oid4vp.md)
- [Records](./03-records.md)
- [Revocaci�n](./05-revocation.md)
- [Limitaciones](../08-limitations.md)
