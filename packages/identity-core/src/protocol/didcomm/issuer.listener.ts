import type { Agent } from '@credo-ts/core'
import { DidsApi } from '@credo-ts/core'
import { TenantsApi } from '@credo-ts/tenants'
import { DidCommCredentialEventTypes, DidCommCredentialState } from '@credo-ts/didcomm'
import type { DidCommCredentialExchangeRecord } from '@credo-ts/didcomm'
import { randomUUID } from 'crypto'
import { resolveLogger } from '../../types/logger.types'
import type { CredoLogger } from '../../types/logger.types'
import { findTenantIdForRecord, setupConnectionListeners, setupMessageListeners } from './shared.listener'
import type { ConnectionReadyPayload } from './shared.listener'

export interface IssuerListenersOptions {
  label?: string
  logger?: CredoLogger
  /** Dispara pending offers DIDComm al completar / reusar conexión. */
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>
}

/**
 * Encuentra el `tenantId` dueño de un record iterando los tenants. (Deprecated:
 * ahora se usa `findTenantIdForRecord` exportado desde `./shared.listener` para
 * que issuer, holder y verifier compartan la misma lógica.)
 */

/**
 * Registra listeners DIDComm del issuer: mensajes, conexiones y ciclo de emisión.
 *
 * En `RequestReceived` acepta el request y firma la VC JSON-LD. Propaga
 * `onConnectionReady` a los listeners compartidos para pending offers.
 *
 * @param agent - Agente Credo root o single-wallet del issuer
 * @param opts - Etiqueta de log, logger y callback de conexión lista
 */
export function setupDidCommIssuerListeners(agent: Agent, opts: IssuerListenersOptions): void {
  const label = opts.label ?? 'Issuer'
  const shared = {
    label,
    logger: opts.logger,
    onConnectionReady: opts.onConnectionReady,
  }
  setupMessageListeners(agent, shared)
  setupConnectionListeners(agent, shared)

  agent.events.on(
    DidCommCredentialEventTypes.DidCommCredentialStateChanged,
    async (ev: { payload?: { credentialExchangeRecord?: DidCommCredentialExchangeRecord } }) => {
      const record = ev.payload?.credentialExchangeRecord
      if (!record) return
      const log = resolveLogger(opts.logger)
      try {
        const tenantId = await findTenantIdForRecord(agent, record.id, 'credentials')
        if (!tenantId) {
          log.warn(`[Issuer] No tenant found for credential record ${record.id}, skipping`)
          return
        }
        const api = agent.dependencyManager.resolve(TenantsApi)
        await api.withTenantAgent({ tenantId }, async (tenantAgent) => {
          const tenantA = tenantAgent as unknown as {
            dependencyManager: { resolve: (token: unknown) => unknown }
            didcomm: {
              credentials: {
                acceptRequest(opts: unknown): Promise<unknown>
                acceptProposal(opts: unknown): Promise<unknown>
                negotiateProposal(opts: unknown): Promise<unknown>
                getFormatData(id: string): Promise<unknown>
              }
            }
          }
          switch (record.state) {
            case DidCommCredentialState.ProposalReceived: {
              log.log('Issuer: Proposal received, sending offer...')
              const didsApi = tenantA.dependencyManager.resolve(DidsApi) as unknown as {
                getCreatedDids(opts: { method: string }): Promise<{ did?: string }[]>
              }
              const didRecords = await didsApi.getCreatedDids({ method: 'web' })
              const issuerDid = didRecords[0]?.did ?? ''
              const formatData = await tenantA.didcomm.credentials.getFormatData(record.id)
              const proposalJsonLd = (formatData as { proposal?: { jsonld?: { credential?: unknown; options?: unknown } } }).proposal?.jsonld

              if (proposalJsonLd?.credential) {
                const proposed = proposalJsonLd.credential as Record<string, unknown>
                const customTypes = ((proposed.type as string[]) ?? []).filter((t: string) => t !== 'VerifiableCredential')
                const credentialId = (proposed.id as string) || `urn:uuid:${randomUUID()}`

                const credential = {
                  ...proposed,
                  id: credentialId,
                  '@context':
                    (proposed['@context'] as unknown[])?.length > 1
                      ? proposed['@context']
                      : [
                          'https://www.w3.org/2018/credentials/v1',
                          'http://schema.org/',
                          Object.fromEntries(
                            customTypes.map((t: string) => [t, `https://www.w3.org/2018/credentials#${t}`])
                          ),
                        ],
                  issuer: (proposed.issuer as string) || issuerDid,
                }

                await tenantA.didcomm.credentials.negotiateProposal({
                  credentialExchangeRecordId: record.id,
                  credentialFormats: {
                    jsonld: {
                      credential,
                      options: proposalJsonLd.options,
                    },
                  },
                  comment: 'JSON-LD Credential Offer',
                })
              } else {
                await tenantA.didcomm.credentials.acceptProposal({
                  credentialExchangeRecordId: record.id,
                  comment: 'JSON-LD Credential Offer',
                })
              }
              break
            }
            case DidCommCredentialState.RequestReceived:
              log.log('Issuer: Request received, issuing credential...')
              await tenantA.didcomm.credentials.acceptRequest({
                credentialExchangeRecordId: record.id,
                comment: 'JSON-LD Credential',
              })
              break
            case DidCommCredentialState.Done:
              log.log('Issuer: Credential exchange completed')
              break
          }
        })
        log.log(`[Issuer] state ${String(record.state)} handled within tenant ${tenantId.slice(0, 8)}…`)
      } catch (err) {
        log.error('Credential listener error:', String(err))
        if (err instanceof Error && err.stack) {
          log.error('Stack trace:', err.stack)
        }
      }
    }
  )
}
