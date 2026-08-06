import {
  AgentContext,
  CredoError,
  DifPresentationExchangeService,
  DifPresentationExchangeSubmissionLocation,
  JsonTransformer,
  Kms,
  TypedArrayEncoder,
  W3cJsonLdVerifiablePresentation,
  W3cJwtVerifiablePresentation,
} from '@credo-ts/core'
import {
  DidCommAttachment,
  DidCommAttachmentData,
  DidCommDifPresentationExchangeProofFormatService,
  DidCommProofFormatSpec,
} from '@credo-ts/didcomm'
import { absolutizeVerificationMethodForDid } from '../../credential/bbs/absolutize-verification-method'
import {
  applyBbsDeriveToPexCredentials,
  presentationDefinitionForHolderVpSigning,
  verifyBbsCredentialsInPresentation,
  type PexCredentialEntry,
} from '../../credential/bbs/pex-bbs-derive'
import { isBbsProofType } from '../../credential/bbs/constants'

const PRESENTATION_EXCHANGE_PRESENTATION = 'dif/presentation-exchange/submission@v1.0'

/**
 * PEX proof format con selective disclosure BBS+ (QUARK-990).
 *
 * Antes de armar la VP, deriva `BbsBlsSignatureProof2020` según paths del PD.
 * En verificación, valida VCs BBS con la capa MATTR (Credo 0.7 no registra esas suites).
 */
export class QuarkDifPresentationExchangeProofFormatService extends DidCommDifPresentationExchangeProofFormatService {
  public async acceptRequest(
    agentContext: AgentContext,
    options: {
      attachmentId?: string
      requestAttachment: DidCommAttachment
      proofFormats?: {
        presentationExchange?: {
          credentials?: Record<string, PexCredentialEntry[]>
        }
      }
    }
  ) {
    const ps = agentContext.dependencyManager.resolve(DifPresentationExchangeService)
    const format = new DidCommProofFormatSpec({
      format: PRESENTATION_EXCHANGE_PRESENTATION,
      attachmentId: options.attachmentId,
    })
    const { presentation_definition: presentationDefinition, options: pexOptions } =
      options.requestAttachment.getDataAsJson() as {
        presentation_definition: Record<string, unknown>
        options?: { challenge?: string; domain?: string }
      }

    let credentials = options.proofFormats?.presentationExchange?.credentials
    if (!credentials) {
      const credentialsForRequest = await ps.getCredentialsForRequest(
        agentContext,
        presentationDefinition as never
      )
      credentials = ps.selectCredentialsForRequest(credentialsForRequest) as Record<
        string,
        PexCredentialEntry[]
      >
    }

    const kms = agentContext.resolve(Kms.KeyManagementApi)
    const challenge =
      pexOptions?.challenge ?? TypedArrayEncoder.toBase64Url(kms.randomBytes({ length: 32 }))

    const derivedCredentials = await applyBbsDeriveToPexCredentials(
      agentContext,
      credentials,
      presentationDefinition,
      challenge
    )

    // Credo firma la VP con ldp_vc.proof_type del PD; BBS-only no matchea Ed25519 del holder.
    const pdForVp = presentationDefinitionForHolderVpSigning(
      presentationDefinition,
      derivedCredentials
    )

    // did:peer suele devolver VM con id relativo (#key-…); documentLoader exige DID URL absoluta.
    // getVerificationMethodForSubjectId es private en tipos Credo; se parchea solo durante createPresentation.
    type PsWithGetVm = {
      getVerificationMethodForSubjectId: (
        ctx: AgentContext,
        subjectId: string
      ) => Promise<{ id: string; controller?: string }>
    }
    const psMutable = ps as unknown as PsWithGetVm
    const getVm = psMutable.getVerificationMethodForSubjectId.bind(ps)
    psMutable.getVerificationMethodForSubjectId = async (ctx, subjectId) => {
      const vm = await getVm(ctx, subjectId)
      return absolutizeVerificationMethodForDid(vm, subjectId)
    }

    let presentation: Awaited<ReturnType<typeof ps.createPresentation>>
    try {
      presentation = await ps.createPresentation(agentContext, {
        presentationDefinition: pdForVp as never,
        credentialsForInputDescriptor: derivedCredentials as never,
        challenge,
        domain: pexOptions?.domain,
      })
    } finally {
      psMutable.getVerificationMethodForSubjectId = getVm
    }

    if (!presentation) throw new CredoError('Failed to create presentation for request.')
    if (presentation.verifiablePresentations.length > 1) {
      throw new CredoError('Invalid amount of verifiable presentations. Only one is allowed.')
    }
    if (
      presentation.presentationSubmissionLocation === DifPresentationExchangeSubmissionLocation.EXTERNAL
    ) {
      throw new CredoError('External presentation submission is not supported.')
    }

    const encodedFirstPresentation = presentation.verifiablePresentations[0].encoded
    return {
      attachment: new DidCommAttachment({
        id: format.attachmentId,
        mimeType: 'application/json',
        data: new DidCommAttachmentData({ json: encodedFirstPresentation }),
      }),
      format,
    }
  }

  public async processPresentation(
    agentContext: AgentContext,
    options: {
      requestAttachment: DidCommAttachment
      attachment: DidCommAttachment
      proofRecord: unknown
    }
  ): Promise<boolean> {
    const presentation = options.attachment.getDataAsJson()
    if (typeof presentation === 'string' && presentation.includes('~')) {
      throw new CredoError('Received SD-JWT VC in PEX proof format. This is not supported yet.')
    }

    let jsonPresentation: Record<string, unknown>
    if (typeof presentation === 'string') {
      const parsed = W3cJwtVerifiablePresentation.fromSerializedJwt(presentation)
      jsonPresentation = parsed.presentation.toJSON() as Record<string, unknown>
    } else {
      const parsed = JsonTransformer.fromJSON(presentation, W3cJsonLdVerifiablePresentation)
      jsonPresentation = parsed.toJSON() as Record<string, unknown>
    }

    const vcs = jsonPresentation.verifiableCredential
    const list = Array.isArray(vcs) ? vcs : vcs ? [vcs] : []
    const hasBbs = list.some((raw) =>
      isBbsProofType((raw as { proof?: { type?: string } })?.proof?.type)
    )

    if (hasBbs) {
      const ps = agentContext.dependencyManager.resolve(DifPresentationExchangeService)
      const request = options.requestAttachment.getDataAsJson() as {
        presentation_definition: unknown
        options?: { challenge?: string }
      }
      if (!jsonPresentation.presentation_submission) {
        agentContext.config.logger.error('PEX presentation without presentation_submission')
        return false
      }
      const challenge = request.options?.challenge
      if (!challenge) {
        agentContext.config.logger.error('PEX presentation without challenge')
        return false
      }
      try {
        ps.validatePresentationDefinition(request.presentation_definition as never)
        ps.validatePresentationSubmission(jsonPresentation.presentation_submission as never)
      } catch (e) {
        agentContext.config.logger.error('PEX structural validation failed', e as Error)
        return false
      }

      const bbs = await verifyBbsCredentialsInPresentation(agentContext, jsonPresentation)
      if (!bbs.ok) {
        agentContext.config.logger.error(`BBS VC verify failed: ${bbs.error}`)
        return false
      }

      // No llamar a super ni a verifyPresentation con VCs vacías: Credo no tiene suite BBS
      // y `verifiableCredential: []` no pasa class-validator.
      // VCs BBS ya verificadas con MATTR; binder holder vía challenge del proof de la VP.
      const vpProof = jsonPresentation.proof as
        | { challenge?: string; type?: string }
        | Array<{ challenge?: string; type?: string }>
        | undefined
      const proofs = Array.isArray(vpProof) ? vpProof : vpProof ? [vpProof] : []
      const matchesChallenge = proofs.some((p) => p.challenge === challenge)
      if (!matchesChallenge) {
        agentContext.config.logger.error('VP challenge mismatch for BBS presentation')
        return false
      }
      return true
    }

    return super.processPresentation(agentContext, options as never)
  }
}
