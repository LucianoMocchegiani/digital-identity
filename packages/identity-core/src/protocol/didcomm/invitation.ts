import type { Agent } from '@credo-ts/core'

export interface CreateInvitationOptions {
  /** Dominio para la URL (ej. https://example.org) */
  domain?: string
  /**
   * `goal_code` OOB (RFC 0434). La wallet lo usa para clasificar el flujo:
   * `issue-vc` → emisión, `request-proof` → verificación; sin él cae en `connect`.
   */
  goalCode?: string
  /** Texto descriptivo del objetivo de la invitación (`goal`). */
  goal?: string
}

export interface CreateInvitationResult {
  /** URL OOB completa con `?oob=` (formato largo). */
  invitationUrl: string
  /** ID del `OutOfBandRecord` Credo; sirve para enlazar pending offers. */
  outOfBandId: string
  /**
   * Mensaje OOB en JSON (sin base64).
   * Útil para short URLs RFC 0434: el servidor lo sirve vía GET + `Accept: application/json`.
   */
  invitationMessage: Record<string, unknown>
  /** Record OOB serializado (debug / auditoría). */
  outOfBandRecord: unknown
}

/**
 * Crea una invitación Out-of-Band DIDComm desde el agente.
 *
 * @param agent - Agente Credo con módulo `didcomm.oob`
 * @param options - Dominio usado en `toUrl` (default `https://example.org`)
 * @returns URL de invitación y `outOfBandId` para pending offers
 */
export async function createInvitation(
  agent: Agent,
  options?: CreateInvitationOptions
): Promise<CreateInvitationResult> {
  const domain = options?.domain ?? 'https://example.org'
  const didcomm = (agent as { didcomm: { oob: { createInvitation(opts?: Record<string, unknown>): Promise<{ id: string; outOfBandInvitation: { toUrl(opts: { domain: string }): string; toJSON(): Record<string, unknown> }; toJSON?: () => unknown }> } } }).didcomm
  const outOfBandRecord = await didcomm.oob.createInvitation({
    ...(options?.goalCode && { goalCode: options.goalCode }),
    ...(options?.goal && { goal: options.goal }),
  })
  const invitationUrl = outOfBandRecord.outOfBandInvitation.toUrl({ domain })
  const outOfBandId = outOfBandRecord.id
  const invitationMessage = outOfBandRecord.outOfBandInvitation.toJSON()
  return {
    invitationUrl,
    outOfBandId,
    invitationMessage,
    outOfBandRecord: outOfBandRecord.toJSON ? outOfBandRecord.toJSON() : outOfBandRecord,
  }
}

export interface ReceiveInvitationOptions {
  /** Etiqueta del agente para la conexión */
  label?: string
}

/**
 * Normaliza URL de invitación: Credo usa `oob`, algunos sistemas usan `_oob`.
 */
function normalizeInvitationUrl(url: string): string {
  if (url.includes('_oob=') && !url.includes('oob=')) {
    return url.replace(/_oob=/g, 'oob=')
  }
  return url
}

/**
 * Recibe una invitación OOB (URL del issuer/verifier).
 *
 * Usa `reuseConnection: true` para reusar una conexión previa si Credo
 * detecta el mismo peer.
 *
 * @param agent - Agente Credo del holder/verifier
 * @param invitationUrl - URL con `oob=` o `_oob=`
 * @param options - Label opcional del agente
 * @returns `OutOfBandRecord` Credo
 */
export async function receiveInvitation(
  agent: Agent,
  invitationUrl: string,
  options?: ReceiveInvitationOptions
): Promise<unknown> {
  const normalizedUrl = normalizeInvitationUrl(invitationUrl)
  const agentConfig = (agent as { config?: { toJSON?: () => { label?: string } } }).config
  const label =
    options?.label ??
    (agentConfig?.toJSON ? agentConfig.toJSON()?.label : undefined) ??
    'agent'

  const didcomm = (agent as {
    didcomm: {
      oob: {
        receiveInvitationFromUrl(
          url: string,
          opts: { label: string; reuseConnection: boolean }
        ): Promise<{ outOfBandRecord: unknown }>
      }
    }
  }).didcomm

  const { outOfBandRecord } = await didcomm.oob.receiveInvitationFromUrl(
    normalizedUrl,
    {
      label,
      reuseConnection: true,
    }
  )
  return outOfBandRecord
}
