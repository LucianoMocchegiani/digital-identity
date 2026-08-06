import { randomUUID } from 'crypto'
import type {
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
} from '@credo-ts/didcomm'
import { DidsApi, type DependencyManager } from '@credo-ts/core'
import {
  buildOfferCredentialPayload,
  buildProposalCredentialPayload,
  getProofOptions,
} from '../../credential/credential.builder'
import type { CredentialParams } from '../../credential/credential.builder'

/** Interfaz mínima del agent Credo para credentials (issuer/holder). */
export interface CredentialsAgent {
  dependencyManager: DependencyManager
  didcomm?: {
    credentials?: {
      offerCredential: (opts: unknown) => Promise<DidCommCredentialExchangeRecord>
      proposeCredential: (opts: unknown) => Promise<DidCommCredentialExchangeRecord>
    }
    connections?: {
      findById: (id: string) => Promise<DidCommConnectionRecord | null>
    }
  }
}

export interface OfferCredentialParams extends CredentialParams {
  connectionId: string
  issuerDid?: string
}

export interface OfferCredentialResult {
  credentialExchangeId: string
  state: string
  credentialId: string
}

export interface ProposeCredentialParams extends CredentialParams {
  connectionId: string
}

export interface ProposeCredentialResult {
  credentialExchangeId: string
  state: string
}

/**
 * Ofrece una credencial como issuer via DIDComm.
 * El DID del issuer se resuelve desde el wallet del agente si no se indica en `params.issuerDid`.
 */
export async function offerCredential(
  agent: CredentialsAgent | null,
  params: OfferCredentialParams,
): Promise<OfferCredentialResult | { error: string }> {
  if (!agent?.didcomm?.credentials) return { error: 'Agent not ready' }

  const conn = await agent.didcomm?.connections?.findById(params.connectionId)
  if (!conn) return { error: `Connection ${params.connectionId} not found` }

  let issuerDid = params.issuerDid
  if (!issuerDid) {
    const didRecords = await agent.dependencyManager.resolve(DidsApi).getCreatedDids({ method: 'web' })
    issuerDid = didRecords[0]?.did ?? ''
  }

  const holderDid = conn.theirDid ?? conn.previousTheirDids?.[0] ?? ''
  const credentialId = `urn:uuid:${randomUUID()}`

  const credential = buildOfferCredentialPayload(params, { credentialId, issuerDid, holderDid })
  const proofOptions = getProofOptions(params)

  try {
    const exchange = await agent.didcomm.credentials.offerCredential({
      connectionId: params.connectionId,
      protocolVersion: 'v2',
      credentialFormats: {
        jsonld: {
          credential,
          options: proofOptions,
        },
      },
    })
    return { credentialExchangeId: exchange.id, state: exchange.state, credentialId }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err)
    return { error: message }
  }
}

/**
 * Propone una credencial como holder via DIDComm.
 * El DID del holder se resuelve desde el wallet del agente.
 */
export async function proposeCredential(
  agent: CredentialsAgent | null,
  params: ProposeCredentialParams,
): Promise<ProposeCredentialResult | { error: string }> {
  if (!agent?.didcomm?.credentials) return { error: 'Agent not ready' }

  const conn = await agent.didcomm?.connections?.findById(params.connectionId)
  if (!conn) return { error: `Connection ${params.connectionId} not found` }

  const keyDids = await agent.dependencyManager.resolve(DidsApi).getCreatedDids({ method: 'key' })
  const holderDid = keyDids[0]?.did ?? ''
  const credential = buildProposalCredentialPayload(params, { holderDid })
  const proofOptions = getProofOptions(params)

  try {
    const exchange = await agent.didcomm.credentials.proposeCredential({
      connectionId: params.connectionId,
      protocolVersion: 'v2',
      credentialFormats: {
        jsonld: {
          credential,
          options: proofOptions,
        },
      },
      comment: 'Requesting credential',
    })
    return { credentialExchangeId: exchange.id, state: exchange.state }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err)
    return { error: message }
  }
}
