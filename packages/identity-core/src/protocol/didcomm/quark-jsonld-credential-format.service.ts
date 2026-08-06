import {
  AgentContext,
  CredoError,
  JsonEncoder,
  JsonTransformer,
  W3cCredentialRecord,
  W3cCredentialService,
  W3cJsonLdVerifiableCredential,
  utils,
} from '@credo-ts/core'
import {
  DidCommAttachment,
  DidCommAttachmentData,
  DidCommCredentialFormatSpec,
  DidCommJsonLdCredentialFormatService,
} from '@credo-ts/didcomm'

import {
  BBS_PROOF_TYPE,
  resolveBbsDocumentLoader,
  resolveBbsKmsKeyId,
  signBbsCredential,
  verifyBbsCredential,
} from '../../credential/bbs'

const JSONLD_VC = 'aries/ld-proof-vc@v1.0'

/**
 * Format service JSON-LD DIDComm con soporte BBS+ (QUARK-990).
 *
 * Si `proofType` es `BbsBlsSignature2020`, firma/verifica con la capa MATTR de identity-core
 * (Credo 0.7 no modela Bls12381 en PublicJwk). Cualquier otro proofType delega a Credo Ed25519.
 */
export class QuarkJsonLdCredentialFormatService extends DidCommJsonLdCredentialFormatService {
  public async acceptRequest(
    agentContext: AgentContext,
    options: {
      credentialFormats?: { jsonld?: { verificationMethod?: string } }
      attachmentId?: string
      requestAttachment: DidCommAttachment
    }
  ) {
    const credentialRequest = options.requestAttachment.getDataAsJson() as {
      credential: Record<string, unknown>
      options: {
        proofType: string
        proofPurpose?: string
        challenge?: string
        domain?: string
        created?: string
        credentialStatus?: unknown
      }
    }

    if (credentialRequest.options.proofType !== BBS_PROOF_TYPE) {
      return super.acceptRequest(agentContext, options as never)
    }

    const foundFields = ['challenge', 'domain', 'credentialStatus', 'created'].filter(
      (field) => (credentialRequest.options as Record<string, unknown>)[field] !== undefined
    )
    if (foundFields.length > 0) {
      throw new CredoError(
        `Some fields are not currently supported in credential options: ${foundFields.join(', ')}`
      )
    }

    const issuerDid =
      typeof credentialRequest.credential.issuer === 'string'
        ? credentialRequest.credential.issuer
        : (credentialRequest.credential.issuer as { id?: string } | undefined)?.id
    if (!issuerDid) throw new CredoError('Missing issuer in credential request')

    const bbs = await resolveBbsKmsKeyId(agentContext, issuerDid)
    const verificationMethod =
      options.credentialFormats?.jsonld?.verificationMethod ?? bbs.verificationMethod

    const signed = await signBbsCredential(agentContext, {
      credential: credentialRequest.credential,
      verificationMethod,
      kmsKeyId: bbs.kmsKeyId,
    })

    const format = new DidCommCredentialFormatSpec({
      attachmentId: options.attachmentId,
      format: JSONLD_VC,
    })

    return {
      format,
      attachment: new DidCommAttachment({
        id: format.attachmentId,
        mimeType: 'application/json',
        data: new DidCommAttachmentData({ base64: JsonEncoder.toBase64(signed) }),
      }),
    }
  }

  public async processCredential(
    agentContext: AgentContext,
    options: {
      credentialExchangeRecord: {
        credentials: { credentialRecordType: string; credentialRecordId: string }[]
      }
      attachment: DidCommAttachment
      requestAttachment: DidCommAttachment
    }
  ) {
    const credentialAsJson = options.attachment.getDataAsJson() as Record<string, unknown>
    const proofType = (credentialAsJson.proof as { type?: string } | undefined)?.type

    if (proofType !== BBS_PROOF_TYPE) {
      return super.processCredential(agentContext, options as never)
    }

    const requestAsJson = options.requestAttachment.getDataAsJson() as {
      credential: Record<string, unknown>
      options: {
        proofType: string
        proofPurpose?: string
        challenge?: string
        domain?: string
        created?: string
      }
    }

    this.verifyReceivedCredentialMatchesRequestBbs(credentialAsJson, requestAsJson)

    const result = await verifyBbsCredential(credentialAsJson, {
      documentLoader: resolveBbsDocumentLoader(agentContext),
    })
    if (!result.verified) {
      throw new CredoError(`Failed to validate BBS credential, error = ${result.error}`)
    }

    const credential = JsonTransformer.fromJSON(credentialAsJson, W3cJsonLdVerifiableCredential)
    const w3cCredentialService = agentContext.dependencyManager.resolve(W3cCredentialService)
    const verifiableCredential = await w3cCredentialService.storeCredential(agentContext, {
      record: W3cCredentialRecord.fromCredential(credential),
    })
    options.credentialExchangeRecord.credentials.push({
      credentialRecordType: this.credentialRecordType,
      credentialRecordId: verifiableCredential.id,
    })
  }

  private verifyReceivedCredentialMatchesRequestBbs(
    credential: Record<string, unknown>,
    request: {
      credential: Record<string, unknown>
      options: {
        proofType: string
        proofPurpose?: string
        challenge?: string
        domain?: string
        created?: string
      }
    }
  ) {
    const proof = credential.proof as Record<string, unknown> | undefined
    if (!proof || Array.isArray(proof)) {
      throw new CredoError('Credential proof arrays are not supported')
    }
    const withoutProof = { ...credential }
    delete withoutProof.proof
    if (proof.type !== request.options.proofType) {
      throw new CredoError(
        'Received credential proof type does not match proof type from credential request'
      )
    }
    if (request.options.proofPurpose && proof.proofPurpose !== request.options.proofPurpose) {
      throw new CredoError(
        'Received credential proof purpose does not match proof purpose from credential request'
      )
    }
    if (!utils.areObjectsEqual(withoutProof as object, request.credential as object)) {
      throw new CredoError('Received credential does not match credential request')
    }
  }
}
