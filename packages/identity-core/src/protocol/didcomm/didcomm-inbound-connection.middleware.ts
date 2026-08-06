import type { Agent } from '@credo-ts/core'
import {
  DidCommConnectionsApi,
  DidCommCredentialExchangeRepository,
  DidCommCredentialRole,
  DidCommProofExchangeRepository,
  DidCommProofRole,
  DidCommTransportService,
  type DidCommMessageHandlerMiddleware,
} from '@credo-ts/didcomm'

/**
 * Tras `didexchange/response` el peer rota a `did:peer` y Credo puede fallar al
 * resolver `messageContext.connection` por claves. Para mensajes inbound que
 * dependen de la conexión (complete, request-credential, presentation),
 * resolvemos por `threadId` y enlazamos la sesión WS para entrega outbound.
 */
export function registerDidCommInboundConnectionMiddleware(agent: Agent): void {
  const middleware: DidCommMessageHandlerMiddleware = async (messageContext, next) => {
    const msgType = messageContext.message.type ?? ''
    const threadId = messageContext.message.threadId

    const isComplete =
      msgType.includes('didexchange') && msgType.endsWith('/complete')
    const isRequestCredential =
      msgType.includes('issue-credential') && msgType.endsWith('/request-credential')
    const isPresentation =
      msgType.includes('present-proof') && msgType.endsWith('/presentation')
    const needsConnection = isComplete || isRequestCredential || isPresentation

    if (needsConnection && !messageContext.connection && threadId) {
      try {
        const connectionsApi =
          messageContext.agentContext.dependencyManager.resolve(DidCommConnectionsApi)
        if (isComplete) {
          const connection = await connectionsApi.getByThreadId(threadId)
          if (connection.isReady) {
            messageContext.connection = connection
          }
        } else {
          let connectionId: string | undefined
          if (isRequestCredential) {
            const credentialRepo = messageContext.agentContext.dependencyManager.resolve(
              DidCommCredentialExchangeRepository,
            )
            const exchanges = await credentialRepo.findByQuery(messageContext.agentContext, {
              threadId,
              role: DidCommCredentialRole.Issuer,
            })
            connectionId = exchanges[0]?.connectionId
          } else {
            const proofRepo = messageContext.agentContext.dependencyManager.resolve(
              DidCommProofExchangeRepository,
            )
            const exchanges = await proofRepo.findByQuery(messageContext.agentContext, {
              threadId,
              role: DidCommProofRole.Verifier,
            })
            connectionId = exchanges[0]?.connectionId
          }
          if (connectionId) {
            const connection = await connectionsApi.findById(connectionId)
            if (connection?.isReady) {
              messageContext.connection = connection
            }
          }
        }
      } catch {
        // El handler reportará el error si sigue sin conexión.
      }
    }

    if (
      needsConnection &&
      messageContext.connection?.id &&
      messageContext.sessionId
    ) {
      try {
        const transportService =
          messageContext.agentContext.dependencyManager.resolve(DidCommTransportService)
        transportService.setConnectionIdForSession(
          messageContext.sessionId,
          messageContext.connection.id,
        )
      } catch {
        // Sin sesión enlazada, issue-credential será undeliverable para holders móviles.
      }
    }

    await next()
  }

  const didcomm = agent as unknown as {
    didcomm: {
      registerMessageHandlerMiddleware(m: DidCommMessageHandlerMiddleware): void
    }
  }
  didcomm.didcomm.registerMessageHandlerMiddleware(middleware)
}
