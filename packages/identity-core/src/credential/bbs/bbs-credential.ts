import type { AgentContext } from '@credo-ts/core'
import { DidRepository, W3cCredentialsModuleConfig } from '@credo-ts/core'
import {
  BbsBlsSignature2020,
  BbsBlsSignatureProof2020,
  deriveProof as mattrDeriveProof,
} from '@mattrglobal/jsonld-signatures-bbs'
import { getBls12381G2KeyPair } from '../../kms/bbs-kms'
import {
  BBS_PROOF_TYPE_DERIVED,
} from './constants'
import { WEB_DID_KEY_BBS_LDP_FRAGMENT } from '../../did/registrar/web.registrar'

export type BbsDocumentLoader = (url: string) => Promise<{
  contextUrl: string | null
  documentUrl: string
  document: unknown
}>

export interface SignBbsCredentialOptions {
  /** Credencial JSON-LD sin proof. */
  credential: Record<string, unknown>
  /** DID URL de la verification method BLS (ej. `did:web:...#key-bbs-ldp`). */
  verificationMethod: string
  /** keyId KMS de la clave BLS del issuer. */
  kmsKeyId: string
  /**
   * Loader JSON-LD (contexts + DID Document).
   * Si se omite, se usa el de Credo `W3cCredentialsModuleConfig` vía `agentContext`.
   */
  documentLoader?: BbsDocumentLoader
}

export interface DeriveBbsProofOptions {
  /** VC firmada con BbsBlsSignature2020. */
  credential: Record<string, unknown>
  /** JSON-LD frame que indica qué claims revelar. */
  revealDocument: Record<string, unknown>
  /** Nonce / challenge del request-presentation. */
  nonce?: string
  documentLoader?: BbsDocumentLoader
}

/**
 * Adapta el documentLoader de Credo al contrato que espera jsonld-signatures / MATTR.
 */
export function resolveBbsDocumentLoader(
  agentContext: AgentContext,
  override?: BbsDocumentLoader
): BbsDocumentLoader {
  if (override) return override
  const moduleConfig = agentContext.dependencyManager.resolve(W3cCredentialsModuleConfig)
  const credoLoader = moduleConfig.documentLoader(agentContext)
  return async (url) => {
    const loaded = await credoLoader(url)
    return {
      contextUrl: loaded.contextUrl ?? null,
      documentUrl: loaded.documentUrl,
      document: loaded.document,
    }
  }
}

/**
 * Firma una credencial W3C JSON-LD con `BbsBlsSignature2020` usando la clave BLS del KMS.
 *
 * Credo 0.7 no modela BLS en `PublicJwk`; esta función es el camino canónico Quark (QUARK-990).
 * El material BLS vive en Postgres o en Vault KV según el driver Nest.
 */
export async function signBbsCredential(
  agentContext: AgentContext,
  options: SignBbsCredentialOptions
): Promise<Record<string, unknown>> {
  const keyPair = await getBls12381G2KeyPair(agentContext, options.kmsKeyId)
  const suite = new BbsBlsSignature2020({
    key: keyPair,
    verificationMethod: options.verificationMethod,
  })

  const documentLoader = resolveBbsDocumentLoader(agentContext, options.documentLoader)
  const jsigs = await import('jsonld-signatures')
  const signed = await jsigs.sign(options.credential, {
    suite,
    purpose: new jsigs.purposes.AssertionProofPurpose(),
    documentLoader,
  })
  return signed as Record<string, unknown>
}

/**
 * Verifica una VC con proof `BbsBlsSignature2020` o `BbsBlsSignatureProof2020`.
 *
 * La clave pública se toma del proof / documentLoader (DID del issuer), no del KMS local.
 */
export async function verifyBbsCredential(
  credential: Record<string, unknown>,
  options?: {
    documentLoader?: BbsDocumentLoader
  }
): Promise<{ verified: boolean; error?: string }> {
  try {
    const proof = credential.proof as { type?: string } | undefined
    const proofType = proof?.type
    const SuiteClass =
      proofType === BBS_PROOF_TYPE_DERIVED ? BbsBlsSignatureProof2020 : BbsBlsSignature2020
    const jsigs = await import('jsonld-signatures')
    const result = await jsigs.verify(credential, {
      suite: new SuiteClass(),
      purpose: new jsigs.purposes.AssertionProofPurpose(),
      documentLoader: options?.documentLoader,
    })
    return { verified: !!result.verified, error: result.error?.message }
  } catch (err: unknown) {
    return { verified: false, error: err instanceof Error ? err.message : String(err) }
  }
}

/**
 * Deriva un proof de selective disclosure (`BbsBlsSignatureProof2020`) desde una VC BBS.
 */
export async function deriveBbsProof(
  options: DeriveBbsProofOptions
): Promise<Record<string, unknown>> {
  const derived = await mattrDeriveProof(options.credential, options.revealDocument, {
    suite: new BbsBlsSignatureProof2020(),
    nonce: options.nonce ? Buffer.from(options.nonce) : undefined,
    documentLoader: options.documentLoader,
  })
  return derived as Record<string, unknown>
}

/**
 * Resuelve el kmsKeyId de `#key-bbs-ldp` para un DID creado en el wallet del agente.
 */
export async function resolveBbsKmsKeyId(
  agentContext: AgentContext,
  issuerDid: string
): Promise<{ verificationMethod: string; kmsKeyId: string }> {
  const didRepo = agentContext.dependencyManager.resolve(DidRepository)
  const record = await didRepo.findCreatedDid(agentContext, issuerDid)
  if (!record?.keys?.length) {
    throw new Error(`DID ${issuerDid} not found or has no keys in wallet`)
  }
  const bbsKey = record.keys.find((k) => k.didDocumentRelativeKeyId === WEB_DID_KEY_BBS_LDP_FRAGMENT)
  if (!bbsKey) {
    throw new Error(
      `Missing verification method ${WEB_DID_KEY_BBS_LDP_FRAGMENT} for ${issuerDid}. Create DID with addBbsKey.`
    )
  }
  return {
    verificationMethod: `${issuerDid}${WEB_DID_KEY_BBS_LDP_FRAGMENT}`,
    kmsKeyId: bbsKey.kmsKeyId,
  }
}
