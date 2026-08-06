import { Agent, DependencyManager, SdJwtVcModule, W3cCredentialsModule } from '@credo-ts/core'
import {
  agentDependencies,
  DidCommHttpInboundTransport,
  DidCommWsInboundTransport,
} from '@credo-ts/node'
import { TenantsModule } from '@credo-ts/tenants'
import {
  DidCommModule,
  DidCommHttpOutboundTransport,
  DidCommModuleConfig,
  DidCommProofV2Protocol,
} from '@credo-ts/didcomm'
import { OpenId4VcVerifierModule } from '@credo-ts/openid4vc'
import { setGlobalConfig } from '@openid4vc/oauth2'

import { setupVerifierListeners } from '../protocol/didcomm/verifier.listener'
import { QuarkDifPresentationExchangeProofFormatService } from '../protocol/didcomm/quark-dif-pex-proof-format.service'
import { setupOid4VcVerifierListeners } from '../protocol/openid4vc/verifier.oid4vc.listener'
import { initializeVerifierOid4vc } from '../protocol/openid4vc/verifier.oid4vc'
import { ensureWebDid } from '../did/web-did'
import { resolveLogger } from '../types/logger.types'
import { buildDidsModule } from './dids.module'
import {
  buildInjectedKeyManagementModule,
  buildOptionalAskarModule,
  registerInjectedStorageAndKms,
} from './agent-storage-wire'
import type { CredoAgentBaseConfig } from '../types/config.types'
import type {
  CreateRootVerifierAgentOptions,
  CreateVerifierAgentOptions,
  DidCommHttpInboundApp,
  OpenId4VcVerifierApp,
} from './create-agent-options.types'
import { buildRootAgentInitConfig } from './credo-init-config'
import { DidCommWsOutboundTransportDelayedClose } from '../protocol/didcomm/transport'
import { quarkDocumentLoader } from '../credential/bbs/quark-document-loader'
import { registerDidCommInboundConnectionMiddleware } from '../protocol/didcomm/didcomm-inbound-connection.middleware'

/**
 * Crea e inicializa el agente Credo del verifier.
 *
 * Habilita los siguientes protocolos:
 * - **DIDComm v1** — verificación de presentaciones W3C JSON-LD vía mensajería cifrada
 * - **SD-JWT VC** — verificación de credenciales con divulgación selectiva (siempre activo)
 * - **OID4VP** — verificación vía HTTP/OAuth2 (EUDI Wallet), activo solo si se provee `options.openId4Vc`
 *
 * @param config - Configuración base del agente (wallet, KMS, DIDComm endpoint, VDR)
 * @param options - Opciones opcionales: logger, servidor WebSocket, y config OID4VP
 * @returns Agente Credo inicializado con listeners DIDComm activos
 */
export async function createVerifierAgent(
  config: CredoAgentBaseConfig,
  options: CreateVerifierAgentOptions
): Promise<Agent> {
  setGlobalConfig({ allowInsecureUrls: true })

  const dependencyManager = new DependencyManager()

  registerInjectedStorageAndKms(dependencyManager, options)
  dependencyManager.registerInstance(
    DidCommModuleConfig,
    new DidCommModuleConfig({ endpoints: [config.didcommEndpoint] })
  )

  const inboundTransports: import('@credo-ts/didcomm').DidCommInboundTransport[] = []

  if (options.expressApp) {
    inboundTransports.push(
      new DidCommHttpInboundTransport({
        app: options.expressApp as unknown as DidCommHttpInboundApp,
        path: '/didcomm',
        port: config.didcommPort ?? 9204,
      }),
    )
    if (options.wsServer) {
      inboundTransports.push(
        new DidCommWsInboundTransport({ server: options.wsServer } as {
          server: import('ws').WebSocketServer
        }),
      )
    }
  } else if (options.wsServer) {
    inboundTransports.push(
      new DidCommWsInboundTransport({ server: options.wsServer } as {
        server: import('ws').WebSocketServer
      }),
    )
  } else {
    inboundTransports.push(
      new DidCommWsInboundTransport({
        port: config.didcommPort ?? 9204,
      }),
    )
  }

  const closeDelayMs = options.transportCloseDelayMs ?? 10000
  const listenerLabel = options.listenerLabel ?? options.wallet.id

  const agent = new Agent(
    {
      config: buildRootAgentInitConfig(options.logger),
      modules: {
        ...buildOptionalAskarModule(options),
        keyManagement: buildInjectedKeyManagementModule(options),
        dids: buildDidsModule({
          vdrServiceUrl: config.vdrServiceUrl,
          didcommEndpoint: config.didcommEndpoint,
          useHttpForWebDid: config.useHttpForWebDid,
        }),
        w3cCredentials: new W3cCredentialsModule({
          documentLoader: quarkDocumentLoader,
        }),
        sdJwtVc: new SdJwtVcModule(),
        ...(config.oid4vcBaseUrl && options.expressApp && {
          openId4VcVerifier: new OpenId4VcVerifierModule({
            baseUrl: config.oid4vcBaseUrl,
            app: options.expressApp as unknown as OpenId4VcVerifierApp,
            endpoints: { authorizationRequest: '/authorize' },
          }),
        }),
        didcomm: new DidCommModule({
          endpoints: [config.didcommEndpoint],
          transports: {
            inbound: inboundTransports,
            outbound: [
              new DidCommHttpOutboundTransport(),
              new DidCommWsOutboundTransportDelayedClose(closeDelayMs),
            ],
          },
          connections: { autoAcceptConnections: true },
          mediator: false,
          mediationRecipient: false,
          credentials: false,
          proofs: {
            proofProtocols: [
              new DidCommProofV2Protocol({
                proofFormats: [new QuarkDifPresentationExchangeProofFormatService()],
              }),
            ],
          },
        }),
      },
      dependencies: agentDependencies,
    },
    dependencyManager
  )

  await agent.initialize()

  registerDidCommInboundConnectionMiddleware(agent)

  const url = new URL(config.didcommEndpoint)
  const host = url.port ? `${url.hostname}%3A${url.port}` : url.hostname
  const domain = `${host}:${options.wallet.id}`
  const { did } = await ensureWebDid(agent, {
    domain,
    didcommEndpoint: config.didcommEndpoint,
    addDidCommKey: true,
  })
  resolveLogger(options.logger).log(`[Verifier] DID listo: ${did}`)

  if (config.oid4vcBaseUrl && options.verifierOptions) {
    await initializeVerifierOid4vc(agent, options.verifierOptions)
  }

  setupOid4VcVerifierListeners(agent, { label: listenerLabel, logger: options.logger })
  setupVerifierListeners(agent, {
    label: listenerLabel,
    logger: options.logger,
    onConnectionReady: options.onConnectionReady,
  })
  return agent
}

/**
 * Crea e inicializa el agente root del verifier con soporte multi-tenant.
 *
 * Las rutas OID4VP se registran una vez en Express para todos los tenants.
 * Cada tenant inicializa su propio DID web y verifier record dentro de su
 * contexto aislado al crearse con `ensureTenant`.
 *
 * @param config - Configuración de infra (KMS, records, endpoints)
 * @param options - Express app opcional para OID4VP, wsServer y logger
 * @returns Agente root inicializado listo para crear/gestionar tenants
 */
export async function createRootVerifierAgent(
  config: CredoAgentBaseConfig,
  options: CreateRootVerifierAgentOptions
): Promise<Agent> {
  setGlobalConfig({ allowInsecureUrls: true })

  const dependencyManager = new DependencyManager()
  registerInjectedStorageAndKms(dependencyManager, options)
  dependencyManager.registerInstance(
    DidCommModuleConfig,
    new DidCommModuleConfig({ endpoints: [config.didcommEndpoint] })
  )

  const inboundTransports: import('@credo-ts/didcomm').DidCommInboundTransport[] = []

  if (options?.expressApp) {
    inboundTransports.push(
      new DidCommHttpInboundTransport({
        app: options.expressApp as unknown as DidCommHttpInboundApp,
        path: '/didcomm',
        port: config.didcommPort ?? 9204,
      }),
    )
    if (options.wsServer) {
      inboundTransports.push(
        new DidCommWsInboundTransport({ server: options.wsServer } as { server: import('ws').WebSocketServer }),
      )
    }
  } else if (options?.wsServer) {
    inboundTransports.push(
      new DidCommWsInboundTransport({ server: options.wsServer } as { server: import('ws').WebSocketServer }),
    )
  } else {
    inboundTransports.push(new DidCommWsInboundTransport({ port: config.didcommPort ?? 9204 }))
  }

  const closeDelayMs = options?.transportCloseDelayMs ?? 10000
  const listenerLabel = options?.listenerLabel ?? 'Verifier'

  const agent = new Agent(
    {
      config: buildRootAgentInitConfig(options.logger),
      modules: {
        ...buildOptionalAskarModule(options),
        keyManagement: buildInjectedKeyManagementModule(options),
        dids: buildDidsModule({
          vdrServiceUrl: config.vdrServiceUrl,
          didcommEndpoint: config.didcommEndpoint,
          useHttpForWebDid: config.useHttpForWebDid,
        }),
        w3cCredentials: new W3cCredentialsModule({
          documentLoader: quarkDocumentLoader,
        }),
        sdJwtVc: new SdJwtVcModule(),
        tenants: new TenantsModule(),
        ...(config.oid4vcBaseUrl && options?.expressApp && {
          openId4VcVerifier: new OpenId4VcVerifierModule({
            baseUrl: config.oid4vcBaseUrl,
            app: options.expressApp as unknown as OpenId4VcVerifierApp,
            endpoints: { authorizationRequest: '/authorize' },
          }),
        }),
        didcomm: new DidCommModule({
          endpoints: [config.didcommEndpoint],
          transports: {
            inbound: inboundTransports,
            outbound: [
              new DidCommHttpOutboundTransport(),
              new DidCommWsOutboundTransportDelayedClose(closeDelayMs),
            ],
          },
          connections: { autoAcceptConnections: true },
          mediator: false,
          mediationRecipient: false,
          credentials: false,
          proofs: {
            proofProtocols: [
              new DidCommProofV2Protocol({
                proofFormats: [new QuarkDifPresentationExchangeProofFormatService()],
              }),
            ],
          },
        }),
      },
      dependencies: agentDependencies,
    },
    dependencyManager
  )

  await agent.initialize()

  registerDidCommInboundConnectionMiddleware(agent)

  setupOid4VcVerifierListeners(agent, { label: listenerLabel, logger: options?.logger })
  setupVerifierListeners(agent, {
    label: listenerLabel,
    logger: options?.logger,
    onConnectionReady: options?.onConnectionReady,
  })
  resolveLogger(options?.logger).log('[Verifier Root] Agente root inicializado con soporte multi-tenant')
  return agent
}
