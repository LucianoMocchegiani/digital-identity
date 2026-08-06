import type { Agent } from '@credo-ts/core'
import { OpenId4VcIssuerEvents } from '@credo-ts/openid4vc'
import type { OpenId4VcIssuanceSessionStateChangedEvent } from '@credo-ts/openid4vc'
import { resolveLogger } from '../../types/logger.types'
import type { CredoLogger } from '../../types/logger.types'

export interface Oid4VcIssuerListenerOptions {
  label?: string
  logger?: CredoLogger
}

export function setupOid4VcIssuerListeners(agent: Agent, opts: Oid4VcIssuerListenerOptions): void {
  const label = opts.label ?? 'OID4VC'
  const log = resolveLogger(opts.logger)

  agent.events.on(
    OpenId4VcIssuerEvents.IssuanceSessionStateChanged,
    (event: OpenId4VcIssuanceSessionStateChangedEvent) => {
      const { issuanceSession } = event.payload
      log.log(`session=${issuanceSession.id} state=${issuanceSession.state}`, label)
      if (issuanceSession.errorMessage) {
        log.error(`session=${issuanceSession.id} error=${issuanceSession.errorMessage}`, label)
      }
    }
  )
}
