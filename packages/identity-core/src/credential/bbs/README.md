# credential/bbs

Capa BBS+ (MATTR) para W3C JSON-LD en `@quarkid/identity-core` (QUARK-990).

Credo 0.7 no modela Bls12381 en `PublicJwk`; este módulo firma, verifica y deriva fuera del path genérico de Credo.

## Piezas

| Archivo | Rol |
|---|---|
| `constants.ts` | Proof types, context BBS, `isBbsProofType` |
| `bbs-credential.ts` | `signBbsCredential`, `verifyBbsCredential`, `deriveBbsProof` |
| `reveal-frame.ts` | Paths PEX → frame de reveal |
| `pex-bbs-derive.ts` | Derive / verify en present-proof PEX |
| `absolutize-verification-method.ts` | DID URL absolutas para VMs de `did:peer` |
| `quark-document-loader.ts` | Loader sin `jsonld.frame` para `did:…#fragment` |

## Integración DIDComm

- Emisión/recepción: `QuarkJsonLdCredentialFormatService`
- Present-proof: `QuarkDifPresentationExchangeProofFormatService` (holder derive; verifier verify)

Default de emisión: BBS; si el offer/request trae otro `proofType`, ese gana.
