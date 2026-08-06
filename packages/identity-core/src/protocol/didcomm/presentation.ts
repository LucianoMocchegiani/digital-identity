import type { DidCommProofExchangeRecord } from '@credo-ts/didcomm'

/** Interfaz mínima del agent Credo para proofs (verifier). */
export interface ProofsAgent {
  didcomm?: {
    proofs?: {
      requestProof: (opts: unknown) => Promise<DidCommProofExchangeRecord>
      findById: (proofExchangeRecordId: string) => Promise<DidCommProofExchangeRecord | null>
      getFormatData: (proofExchangeRecordId: string) => Promise<unknown>
    }
  }
}

export interface RequestProofParams {
  connectionId: string
  /** Presentation Definition DIF PEX que expresa los requisitos de presentación. */
  presentationDefinition: Record<string, unknown>
  challenge?: string
  domain?: string
}

export interface RequestProofResult {
  proofExchangeRecordId: string
  state: string
  mode: string
  error?: string
}

/** Detalle persistido de una verificación DIDComm present-proof. */
export interface DidCommProofDetails {
  proofExchangeRecordId: string
  state: string
  role: string
  protocolVersion: string
  connectionId?: string
  threadId: string
  createdAt: string
  isVerified?: boolean
  errorMessage?: string
  /** DIF PEX solicitado por el verifier, incluyendo challenge y domain. */
  request?: unknown
  /** VP JSON-LD recibida, con presentation_submission y credenciales presentadas. */
  presentation?: unknown
}

type PresentationExchangeFormatData = {
  request?: { presentationExchange?: unknown }
  presentation?: { presentationExchange?: unknown }
}

/**
 * Solicita una prueba al holder como verifier via DIDComm.
 */
export async function requestProof(
  agent: ProofsAgent | null,
  params: RequestProofParams
): Promise<RequestProofResult> {
  if (!agent?.didcomm?.proofs) {
    return { proofExchangeRecordId: '', state: 'error', mode: 'error', error: 'Agent or proofs module not ready' }
  }

  try {
    const record = await agent.didcomm.proofs.requestProof({
      connectionId: params.connectionId,
      protocolVersion: 'v2',
      proofFormats: {
        presentationExchange: {
          presentationDefinition: params.presentationDefinition,
          options: {
            challenge: params.challenge ?? `challenge-${Date.now()}`,
            domain: params.domain,
          },
        },
      },
    })
    return {
      proofExchangeRecordId: record.id,
      state: record.state,
      mode: 'presentationDefinition',
    }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err)
    return { proofExchangeRecordId: '', state: 'error', mode: 'error', error: message }
  }
}

/**
 * Obtiene el resultado completo de una verificación DIDComm present-proof.
 *
 * Recupera tanto el exchange record de Credo-TS como los adjuntos DIF PEX
 * persistidos para el request y la presentación. La presentación contiene la
 * VP JSON-LD y sus `verifiableCredential`, por lo que permite auditar qué
 * credenciales y claims fueron verificados.
 *
 * @param agent - Agente verifier de Credo-TS asociado al tenant
 * @param proofExchangeRecordId - ID del exchange retornado por DIDComm
 * @returns Detalle de la prueba o `null` si no existe
 */
export async function getDidCommProofDetails(
  agent: ProofsAgent | null,
  proofExchangeRecordId: string
): Promise<DidCommProofDetails | null> {
  const proofs = agent?.didcomm?.proofs
  if (!proofs) return null

  const record = await proofs.findById(proofExchangeRecordId)
  if (!record) return null

  const formatData = (await proofs.getFormatData(
    proofExchangeRecordId
  )) as PresentationExchangeFormatData

  return {
    proofExchangeRecordId: record.id,
    state: record.state,
    role: record.role,
    protocolVersion: record.protocolVersion,
    connectionId: record.connectionId,
    threadId: record.threadId,
    createdAt: record.createdAt.toISOString(),
    isVerified: record.isVerified,
    errorMessage: record.errorMessage,
    request: formatData.request?.presentationExchange,
    presentation: formatData.presentation?.presentationExchange,
  }
}
