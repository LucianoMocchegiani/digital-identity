import type { Agent } from '@credo-ts/core'
import { TenantsApi } from '@credo-ts/tenants'
import { DidCommProofEventTypes, DidCommProofState } from '@credo-ts/didcomm'
import type { DidCommProofExchangeRecord } from '@credo-ts/didcomm'
import { resolveLogger } from '../../types/logger.types'
import type { CredoLogger } from '../../types/logger.types'
import {
  findTenantIdForRecord,
  setupConnectionListeners,
  setupMessageListeners,
  type ConnectionReadyPayload,
} from './shared.listener'

const VERIFIED_ASCII = `
╔═══════════════════════════╗
║                           ║
║   ✓  VERIFIED: true       ║
║   Proof valid & accepted  ║
║                           ║
╚═══════════════════════════╝
`

const NOT_VERIFIED_ASCII = `
╔═══════════════════════════╗
║                           ║
║   ✗  VERIFIED: false      ║
║   Proof invalid/rejected  ║
║                           ║
╚═══════════════════════════╝
`

export interface VerifierListenersOptions {
  label?: string
  logger?: CredoLogger
  /** Dispara pending proofs DIDComm al completar / reusar conexión. */
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>
}

/**
 * Registra listeners DIDComm del verifier: mensajes, conexiones y ciclo de verificación.
 *
 * Propaga `onConnectionReady` para pending proof requests (`POST .../didcomm/request`).
 */
export function setupVerifierListeners(agent: Agent, opts: VerifierListenersOptions): void {
  const label = opts.label ?? 'Verifier'
  const log = resolveLogger(opts.logger)
  const shared = {
    label,
    logger: opts.logger,
    onConnectionReady: opts.onConnectionReady,
  }
  setupMessageListeners(agent, shared)
  setupConnectionListeners(agent, shared)

  agent.events.on(
    DidCommProofEventTypes.ProofStateChanged as string,
    async (ev: { payload?: { proofRecord?: DidCommProofExchangeRecord; proofExchangeRecord?: DidCommProofExchangeRecord } }) => {
      const record = (ev.payload?.proofRecord ?? ev.payload?.proofExchangeRecord) as DidCommProofExchangeRecord | undefined
      if (!record) return
      log.log(`[Verifier] Proof ${record.id} state=${record.state}`)
      if (record.state === DidCommProofState.PresentationReceived) {
        try {
          const tenantId = await findTenantIdForRecord(agent, record.id, 'proofs')
          if (!tenantId) {
            log.warn(`[Verifier] No tenant found for proof record ${record.id}, skipping acceptPresentation`)
            return
          }
          const api = agent.dependencyManager.resolve(TenantsApi)
          await api.withTenantAgent({ tenantId }, async (tenantAgent) => {
            const a = tenantAgent as unknown as {
              didcomm: { proofs: { acceptPresentation(opts: unknown): Promise<unknown> } }
            }
            await a.didcomm.proofs.acceptPresentation({ proofExchangeRecordId: record.id })
          })
          log.log(`[Verifier] state ${String(record.state)} handled within tenant ${tenantId.slice(0, 8)}…`)
          log.log(VERIFIED_ASCII)
        } catch (err) {
          log.error(NOT_VERIFIED_ASCII)
          log.error('[Verifier] Proof accept error:', String(err))
          if (err instanceof Error && err.stack) {
            log.error('Stack trace:', err.stack)
          }
        }
      }
    }
  )
}
