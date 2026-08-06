import baseX from '@multiformats/base-x'
import {
  DidCommV1Service,
  DidDocument,
  DidDocumentRole,
  DidRecord,
  DidRepository,
  JsonTransformer,
  Kms,
} from '@credo-ts/core'
import type {
  AgentContext,
  DidCreateOptions,
  DidCreateResult,
  DidDeactivateResult,
  DidRegistrar,
  DidUpdateResult,
} from '@credo-ts/core'
import { createBls12381G2Key } from '../../kms/bbs-kms'
import {
  BBS_SECURITY_CONTEXT,
  BLS12381_G2_VERIFICATION_METHOD_TYPE,
} from '../../credential/bbs/constants'

const BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
const base58btc = baseX(BASE58_ALPHABET)

function ed25519JwkToBase58(publicJwk: { x: string }): string {
  const pubKeyBytes = Buffer.from(publicJwk.x, 'base64url')
  return base58btc.encode(pubKeyBytes)
}

/**
 * Convención de fragmentos en `did:web` (QUARK-990):
 * - Prefijo `#key-{curva|alg}` + sufijo por **formato de credencial / serialización**, no por transporte.
 * - `-jwk` → Verification Method `JsonWebKey2020` (JWK).
 * - `-ldp` → Verification Method para Linked Data Proofs / JSON-LD
 *   (`Ed25519VerificationKey2018` o `Bls12381G2Key2020` según la curva).
 *
 * Por qué dos Ed25519: misma curva, distinto **tipo de VM**. Credo / suites LDP
 * (`Ed25519Signature2018`) buscan `Ed25519VerificationKey2018` + Base58; OID4VC/JWS
 * usan `JsonWebKey2020`. No es el protocolo DIDComm en sí, sino el formato de prueba.
 */

/** `#key-p256` — P-256 / JsonWebKey2020. OID4VC–OID4VP (ES256). Siempre presente. */
export const WEB_DID_KEY_P256_FRAGMENT = '#key-p256'

/**
 * `#key-ed25519-jwk` — Ed25519 / JsonWebKey2020.
 * Fallback EdDSA cuando el flujo pide JWK (no LDP). Sufijo `-jwk` = formato de VM.
 */
export const WEB_DID_KEY_ED25519_JWK_FRAGMENT = '#key-ed25519-jwk'

/**
 * `#key-ed25519-ldp` — Ed25519 / Ed25519VerificationKey2018 (`publicKeyBase58`).
 * Firma (y recipientKeys) de credenciales JSON-LD con `Ed25519Signature2018`.
 * Sufijo `-ldp` = Linked Data Proof / formato de credencial, no el canal DIDComm.
 */
export const WEB_DID_KEY_ED25519_LDP_FRAGMENT = '#key-ed25519-ldp'

/**
 * `#key-bbs-ldp` — Bls12381G2 / Bls12381G2Key2020.
 * Emisión y presentaciones BBS+ (`BbsBlsSignature2020` / Proof2020). Sufijo `-ldp`
 * porque el proof vive en JSON-LD / LDP, no en SD-JWT.
 */
export const WEB_DID_KEY_BBS_LDP_FRAGMENT = '#key-bbs-ldp'

/**
 * Opciones de creación de un DID `did:web`.
 *
 * @property domain - Dominio público del agente (ej. `issuer.quarkid.com`)
 * @property keyType - Tipo de clave primaria. Por defecto P-256, recomendado para EUDI/OID4VC.
 * @property didcommEndpoint - Endpoint DIDComm para el campo `service` del DID Document.
 * @property addEd25519Key - Agrega `#key-ed25519-jwk` (Ed25519 JsonWebKey2020, fallback EdDSA).
 * @property addDidCommKey - Agrega `#key-ed25519-ldp` (Ed25519 LDP / Signature2018 + servicio DIDComm).
 * @property addBbsKey - Agrega `#key-bbs-ldp` (Bls12381G2 / BbsBlsSignature2020).
 */
export interface WebDidCreateOptions extends DidCreateOptions {
  method: 'web'
  did?: never
  didDocument?: never
  secret?: never
  options: {
    domain: string
    keyType?: { kty: 'EC'; crv: 'P-256' } | { kty: 'OKP'; crv: 'Ed25519' }
    didcommEndpoint?: string
    addEd25519Key?: boolean
    addDidCommKey?: boolean
    addBbsKey?: boolean
  }
}

/**
 * Implementa el DidRegistrar de Credo-TS para el método `did:web`.
 *
 * Genera un DID Document con hasta cuatro claves según las opciones:
 * - `#key-p256`: P-256 (JsonWebKey2020) — OID4VC/OID4VP ES256 (siempre).
 * - `#key-ed25519-jwk`: Ed25519 (JsonWebKey2020) — fallback EdDSA (si `addEd25519Key`).
 * - `#key-ed25519-ldp`: Ed25519 (Ed25519VerificationKey2018) — LDP Signature2018 (si `addDidCommKey`).
 * - `#key-bbs-ldp`: Bls12381G2 (Bls12381G2Key2020) — BBS+ LDP (si `addBbsKey`).
 *
 * No publica nada al VDR — el servicio consumidor expone el DID Document en `/.well-known/did.json`.
 */
export class WebDidRegistrar implements DidRegistrar {
  public readonly supportedMethods = ['web']

  /**
   * Crea un DID `did:web:{domain}` y lo persiste en el wallet del agente.
   *
   * @param agentContext - Contexto del agente Credo-TS (provee KMS y repositorios)
   * @param options - Dominio, tipo de clave y flags de claves adicionales
   * @returns Resultado con `state: 'finished'` y el DID Document generado, o `state: 'failed'`
   */
  async create(agentContext: AgentContext, options: WebDidCreateOptions): Promise<DidCreateResult> {
    const didRepository = agentContext.dependencyManager.resolve(DidRepository)
    const kms = agentContext.dependencyManager.resolve(Kms.KeyManagementApi)

    try {
      const { domain, keyType, addEd25519Key, addDidCommKey, addBbsKey, didcommEndpoint } = options.options
      const resolvedKeyType = keyType ?? { kty: 'EC' as const, crv: 'P-256' as const }

      const { publicJwk, keyId } = await kms.createKey({
        type: resolvedKeyType,
      } as Kms.KmsCreateKeyOptions<typeof resolvedKeyType>)

      const did = `did:web:${domain}`
      const authKeyRef = `${did}${WEB_DID_KEY_P256_FRAGMENT}`

      const didKeys: { didDocumentRelativeKeyId: string; kmsKeyId: string }[] = [
        { didDocumentRelativeKeyId: WEB_DID_KEY_P256_FRAGMENT, kmsKeyId: keyId },
      ]

      const verificationMethods: Record<string, unknown>[] = [
        {
          id: authKeyRef,
          type: 'JsonWebKey2020',
          controller: did,
          publicKeyJwk: publicJwk,
        },
      ]

      const assertionMethods: string[] = [authKeyRef]
      const authenticationMethods: string[] = [authKeyRef]

      if (addEd25519Key) {
        const ed25519Type = { kty: 'OKP' as const, crv: 'Ed25519' as const }
        const { publicJwk: ed25519Jwk, keyId: ed25519KeyId } = await kms.createKey({
          type: ed25519Type,
        } as Kms.KmsCreateKeyOptions<typeof ed25519Type>)

        const ed25519JwkKeyRef = `${did}${WEB_DID_KEY_ED25519_JWK_FRAGMENT}`
        verificationMethods.push({
          id: ed25519JwkKeyRef,
          type: 'JsonWebKey2020',
          controller: did,
          publicKeyJwk: ed25519Jwk,
        })
        assertionMethods.push(ed25519JwkKeyRef)
        authenticationMethods.push(ed25519JwkKeyRef)
        didKeys.push({ didDocumentRelativeKeyId: WEB_DID_KEY_ED25519_JWK_FRAGMENT, kmsKeyId: ed25519KeyId })
      }

      if (addDidCommKey) {
        // Misma curva Ed25519 que `-jwk`, pero VM LDP (Base58 / 2018) para Signature2018.
        const ed25519Type = { kty: 'OKP' as const, crv: 'Ed25519' as const }
        const { publicJwk: ed25519LdpJwk, keyId: ed25519LdpKeyId } = await kms.createKey({
          type: ed25519Type,
        } as Kms.KmsCreateKeyOptions<typeof ed25519Type>)

        const ed25519LdpKeyRef = `${did}${WEB_DID_KEY_ED25519_LDP_FRAGMENT}`
        const publicKeyBase58 = ed25519JwkToBase58(ed25519LdpJwk as { x: string })
        verificationMethods.push({
          id: ed25519LdpKeyRef,
          type: 'Ed25519VerificationKey2018',
          controller: did,
          publicKeyBase58,
        })
        assertionMethods.push(ed25519LdpKeyRef)
        authenticationMethods.push(ed25519LdpKeyRef)
        didKeys.push({ didDocumentRelativeKeyId: WEB_DID_KEY_ED25519_LDP_FRAGMENT, kmsKeyId: ed25519LdpKeyId })
      }

      let bbsKeyAdded = false
      if (addBbsKey) {
        const bbsCreated = await createBls12381G2Key(agentContext)

        const bbsLdpKeyRef = `${did}${WEB_DID_KEY_BBS_LDP_FRAGMENT}`
        verificationMethods.push({
          id: bbsLdpKeyRef,
          type: BLS12381_G2_VERIFICATION_METHOD_TYPE,
          controller: did,
          publicKeyBase58: bbsCreated.publicKeyBase58,
        })
        assertionMethods.push(bbsLdpKeyRef)
        didKeys.push({ didDocumentRelativeKeyId: WEB_DID_KEY_BBS_LDP_FRAGMENT, kmsKeyId: bbsCreated.keyId })
        bbsKeyAdded = true
      }

      const didDocumentJson: Record<string, unknown> = {
        '@context': [
          'https://www.w3.org/ns/did/v1',
          'https://w3id.org/security/suites/jws-2020/v1',
          ...(addDidCommKey ? ['https://w3id.org/security/suites/ed25519-2018/v1'] : []),
          ...(bbsKeyAdded ? [BBS_SECURITY_CONTEXT] : []),
        ],
        id: did,
        verificationMethod: verificationMethods,
        authentication: authenticationMethods,
        assertionMethod: assertionMethods,
        keyAgreement: addDidCommKey
          ? [authKeyRef, `${did}${WEB_DID_KEY_ED25519_LDP_FRAGMENT}`]
          : [authKeyRef],
      }

      const didDocument = JsonTransformer.fromJSON(didDocumentJson, DidDocument)

      if (didcommEndpoint && addDidCommKey) {
        const didCommService = new DidCommV1Service({
          id: `${did}#didcomm`,
          serviceEndpoint: didcommEndpoint,
          recipientKeys: [`${did}${WEB_DID_KEY_ED25519_LDP_FRAGMENT}`],
          routingKeys: [],
        })
        didDocument.service = [...(didDocument.service ?? []), didCommService]
      }

      const didRecord = new DidRecord({
        did,
        role: DidDocumentRole.Created,
        didDocument,
        keys: didKeys,
        tags: {},
      })
      await didRepository.save(agentContext, didRecord)

      return {
        didDocumentMetadata: {},
        didRegistrationMetadata: {},
        didState: { state: 'finished', did, didDocument, secret: {} },
      }
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error)
      const causeErr = error instanceof Error ? (error as Error & { cause?: unknown }).cause : undefined
      const cause = causeErr instanceof Error ? ` (causa: ${causeErr.message})` : ''
      return {
        didDocumentMetadata: {},
        didRegistrationMetadata: {},
        didState: { state: 'failed', reason: `unknownError: ${message}${cause}` },
      }
    }
  }

  async update(): Promise<DidUpdateResult> {
    return {
      didDocumentMetadata: {},
      didRegistrationMetadata: {},
      didState: { state: 'failed', reason: 'notSupported: cannot update did:web did' },
    }
  }

  async deactivate(): Promise<DidDeactivateResult> {
    return {
      didDocumentMetadata: {},
      didRegistrationMetadata: {},
      didState: { state: 'failed', reason: 'notSupported: cannot deactivate did:web did' },
    }
  }
}
