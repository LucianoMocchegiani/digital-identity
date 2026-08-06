import type { Agent } from '@credo-ts/core'
import { OpenId4VcVerifierEvents } from '@credo-ts/openid4vc'
import type { OpenId4VcVerificationSessionStateChangedEvent } from '@credo-ts/openid4vc'
import { resolveLogger } from '../../types/logger.types'
import type { CredoLogger } from '../../types/logger.types'

export interface Oid4VcVerifierListenerOptions {
  label?: string
  logger?: CredoLogger
}

function decodeJwtHeader(token: unknown): Record<string, unknown> | undefined {
  if (typeof token !== 'string') return undefined
  const tokenParts = token.split('.')
  if (tokenParts.length < 2) return undefined
  try {
    const b64 = tokenParts[0].replace(/-/g, '+').replace(/_/g, '/')
    const normalized = b64.padEnd(Math.ceil(b64.length / 4) * 4, '=')
    return JSON.parse(Buffer.from(normalized, 'base64').toString('utf8')) as Record<string, unknown>
  } catch {
    return undefined
  }
}

export function setupOid4VcVerifierListeners(agent: Agent, opts: Oid4VcVerifierListenerOptions): void {
  const label = opts.label ?? 'OID4VP'
  const log = resolveLogger(opts.logger)

  agent.events.on(
    OpenId4VcVerifierEvents.VerificationSessionStateChanged,
    (event: OpenId4VcVerificationSessionStateChangedEvent) => {
      const { verificationSession } = event.payload
      log.log(`session=${verificationSession.id} state=${verificationSession.state}`, label)
      if (verificationSession.errorMessage) {
        log.error(`session=${verificationSession.id} error=${verificationSession.errorMessage}`, label)
        const responsePayload = verificationSession.authorizationResponsePayload
        const vpToken = responsePayload
          ? (responsePayload as Record<string, unknown>).vp_token
          : undefined
        const idToken = responsePayload
          ? (responsePayload as Record<string, unknown>).id_token
          : undefined
        const vpTokenHeader = Array.isArray(vpToken) ? decodeJwtHeader(vpToken[0]) : decodeJwtHeader(vpToken)
        const idTokenHeader = decodeJwtHeader(idToken)
        const diagnostic = {
          sessionId: verificationSession.id,
          openId4VpVersion: verificationSession.openId4VpVersion,
          hasAuthorizationResponsePayload: !!responsePayload,
          responsePayloadKeys: responsePayload ? Object.keys(responsePayload) : [],
          vpTokenType: Array.isArray(vpToken) ? 'array' : typeof vpToken,
          vpTokenHeader,
          idTokenHeader,
          requestJwtHeader: decodeJwtHeader(verificationSession.authorizationRequestJwt),
          hasPresentationSubmission: responsePayload
            ? !!(responsePayload as Record<string, unknown>).presentation_submission
            : false,
        }
        log.error(`session=${verificationSession.id} diag=${JSON.stringify(diagnostic)}`, label)
      }
    }
  )
}
