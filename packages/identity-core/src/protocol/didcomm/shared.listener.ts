import type { Agent } from '@credo-ts/core'
import { TenantsApi } from '@credo-ts/tenants'
import {
  DidCommConnectionEventTypes,
  DidCommEventTypes,
  DidCommOutOfBandEventTypes,
} from '@credo-ts/didcomm'
import { resolveLogger } from '../../types/logger.types'
import type { CredoLogger } from '../../types/logger.types'

export interface SharedListenersOpts {
  label: string
  logger?: CredoLogger
  /**
   * Callback cuando una conexión queda lista para protocolo
   * (DID Exchange `completed` o handshake-reuse OOB).
   */
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>
}

/**
 * Payload del callback {@link SharedListenersOpts.onConnectionReady}.
 *
 * Usado por el issuer para enlazar un pending offer (`outOfBandId`) con la
 * conexión DIDComm recién establecida o reusada.
 */
export interface ConnectionReadyPayload {
  /** ID del `DidCommConnectionRecord`. */
  connectionId: string
  /** ID del OOB que originó (o reusó) la conexión; ausente en algunos edge cases. */
  outOfBandId?: string
  /** `true` si Credo reusó una conexión existente vía handshake-reuse. */
  reused: boolean
}

/**
 * Registra listeners de mensajería DIDComm (received / processed) solo para log.
 *
 * @param agent - Agente Credo (root o single-wallet)
 * @param opts - Etiqueta de log y logger opcional
 */
export function setupMessageListeners(agent: Agent, opts: SharedListenersOpts): void {
  const log = resolveLogger(opts.logger)
  agent.events.on(DidCommEventTypes.DidCommMessageReceived as string, (e: unknown) => {
    const msg = (e as { payload?: { message?: { type?: string } } })?.payload?.message
    const type = msg?.type ?? (msg as { ['@type']?: string })?.['@type'] ?? 'unknown'
    log.log(`[${opts.label}] DidCommMessageReceived type=${type}`)
  })
  agent.events.on(DidCommEventTypes.DidCommMessageProcessed as string, (e: unknown) => {
    const payload = (e as {
      payload?: {
        error?: unknown
        message?: { type?: string; ['@type']?: string }
        connection?: { id?: string; state?: string }
      }
    })?.payload
    const msgType =
      payload?.message?.type ?? payload?.message?.['@type'] ?? 'unknown'
    const connId = payload?.connection?.id
    const connState = payload?.connection?.state
    if (payload?.error) {
      log.log(
        `[${opts.label}] DidCommMessageProcessed type=${msgType} error=${String(payload.error)}`,
      )
    } else {
      log.log(
        `[${opts.label}] DidCommMessageProcessed type=${msgType}` +
          (connId != null ? ` connection=${connId} state=${connState}` : ''),
      )
    }
  })
}

/**
 * Registra listeners de conexión DIDComm y handshake-reuse OOB.
 *
 * Cuando el estado pasa a `completed`, o Credo emite `HandshakeReused`,
 * invoca `opts.onConnectionReady` (si está definido) para disparar pending offers.
 *
 * @param agent - Agente Credo (root multi-tenant o single-wallet)
 * @param opts - Etiqueta, logger y callback opcional de conexión lista
 */
export function setupConnectionListeners(agent: Agent, opts: SharedListenersOpts): void {
  const log = resolveLogger(opts.logger)
  agent.events.on(
    DidCommConnectionEventTypes.DidCommConnectionStateChanged as string,
    (e: {
      payload?: {
        connectionRecord?: {
          state?: string
          id?: string
          outOfBandId?: string
        }
      }
    }) => {
      const record = e?.payload?.connectionRecord
      const state = record?.state
      const id = record?.id
      log.log(`[${opts.label}] Connection ${id} state=${state}`)
      if (state === 'completed' && id && opts.onConnectionReady) {
        void Promise.resolve(
          opts.onConnectionReady({
            connectionId: id,
            outOfBandId: record?.outOfBandId,
            reused: false,
          }),
        ).catch((err) => {
          log.error(`[${opts.label}] onConnectionReady failed: ${String(err)}`)
        })
      }
    },
  )

  agent.events.on(
    DidCommOutOfBandEventTypes.HandshakeReused as string,
    (e: {
      payload?: {
        connectionRecord?: { id?: string }
        outOfBandRecord?: { id?: string }
      }
    }) => {
      const connectionId = e?.payload?.connectionRecord?.id
      const outOfBandId = e?.payload?.outOfBandRecord?.id
      log.log(
        `[${opts.label}] HandshakeReused connection=${connectionId} oob=${outOfBandId}`,
      )
      if (connectionId && opts.onConnectionReady) {
        void Promise.resolve(
          opts.onConnectionReady({
            connectionId,
            outOfBandId,
            reused: true,
          }),
        ).catch((err) => {
          log.error(
            `[${opts.label}] onConnectionReady (reuse) failed: ${String(err)}`,
          )
        })
      }
    },
  )
}

/**
 * Encuentra el `tenantId` dueño de un record de credencial o proof iterando los
 * tenants y buscando el record por id en cada contexto.
 *
 * Necesario porque los listeners del root agent reciben eventos de TODOS los
 * tenants, pero las operaciones (`acceptOffer`, `acceptRequest`, `acceptCredential`,
 * `acceptPresentation`, `selectCredentialsForRequest`, etc.) deben ejecutarse en
 * el contexto del tenant correcto — si no, Credo retorna `null` en `getById` y
 * rompe con "Cannot read properties of null (reading 'protocolVersion')".
 *
 * @param rootAgent - Agente root con `TenantsModule`
 * @param recordId - ID del credential/proof exchange record
 * @param kind - Colección Credo a consultar (`credentials` | `proofs`)
 * @returns `tenantId` o `null` si no se encuentra / no hay TenantsApi
 */
export async function findTenantIdForRecord(
  rootAgent: Agent,
  recordId: string,
  kind: 'credentials' | 'proofs',
): Promise<string | null> {
  try {
    const api = rootAgent.dependencyManager.resolve(TenantsApi)
    const tenants = await api.getAllTenants()
    for (const tenant of tenants) {
      try {
        const found = await api.withTenantAgent({ tenantId: tenant.id }, async (tenantAgent) => {
          try {
            const a = tenantAgent as unknown as {
              didcomm: {
                credentials: { findById(id: string): Promise<unknown> }
                proofs: { findById(id: string): Promise<unknown> }
              }
            }
            return await a.didcomm[kind].findById(recordId)
          } catch {
            return null
          }
        })
        if (found) return tenant.id
      } catch {
        // tenant no inicializado, seguir con el siguiente
      }
    }
  } catch {
    // TenantsApi no disponible (root agent sin TenantsModule) — modo single-tenant
  }
  return null
}
