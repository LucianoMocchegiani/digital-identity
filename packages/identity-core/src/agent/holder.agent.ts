import { Agent, DependencyManager, SdJwtVcModule, W3cCredentialsModule, W3cV2CredentialsModule } from '@credo-ts/core'
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
  DidCommCredentialV2Protocol,
  DidCommProofV2Protocol,
} from '@credo-ts/didcomm'
import { OpenId4VcHolderModule } from '@credo-ts/openid4vc'
import { setGlobalConfig } from '@openid4vc/oauth2'

import { setupHolderListeners } from '../protocol/didcomm/holder.listener'
import { QuarkJsonLdCredentialFormatService } from '../protocol/didcomm/quark-jsonld-credential-format.service'
import { QuarkDifPresentationExchangeProofFormatService } from '../protocol/didcomm/quark-dif-pex-proof-format.service'
import { ensureKeyDid } from '../did/key-did'
import { resolveLogger } from '../types/logger.types'
import { buildDidsModule } from './dids.module'
import {
  buildInjectedKeyManagementModule,
  buildOptionalAskarModule,
  registerInjectedStorageAndKms,
} from './agent-storage-wire'
import type { CredoAgentBaseConfig } from '../types/config.types'
import type {
  CreateHolderAgentOptions,
  CreateRootHolderAgentOptions,
  DidCommHttpInboundApp,
} from './create-agent-options.types'
import { buildRootAgentInitConfig } from './credo-init-config'
import { DidCommWsOutboundTransportDelayedClose } from '../protocol/didcomm/transport'
import { quarkDocumentLoader } from '../credential/bbs/quark-document-loader'

export type { CreateHolderAgentOptions, CreateRootHolderAgentOptions }

/**
 * Crea e inicializa el agente Credo del holder.
 *
 * Habilita los siguientes protocolos:
 * - **DIDComm v1** — recepción y presentación de credenciales W3C JSON-LD vía mensajería cifrada
 * - **OID4VCI / OID4VP** — emisión y presentación de credenciales vía HTTP (EUDI Wallet)
 * - **SD-JWT VC** — credenciales con divulgación selectiva
 *
 * Si `options.fetchOverride` está presente, reemplaza `agentDependencies.fetch` en los
 * módulos OID4VC internos. Esto es necesario cuando las URLs generadas por `@openid4vc`
 * deben ser reescritas antes de realizar la petición (p. ej. en entornos Docker sin TLS).
 *
 * @param config - Configuración base del agente (wallet, KMS, DIDComm endpoint, VDR)
 * @param options - Opciones opcionales: servidor WebSocket, delay de cierre, logger, fetch override
 * @returns Agente Credo inicializado con listeners DIDComm activos
 */
export async function createHolderAgent(
  config: CredoAgentBaseConfig,
  options: CreateHolderAgentOptions
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
        port: config.didcommPort ?? 9205,
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
        port: config.didcommPort ?? 9205,
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
        w3cV2Credentials: new W3cV2CredentialsModule(),
        sdJwtVc: new SdJwtVcModule(),
        openId4VcHolder: new OpenId4VcHolderModule(),
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
          credentials: {
            credentialProtocols: [
              new DidCommCredentialV2Protocol({
                credentialFormats: [new QuarkJsonLdCredentialFormatService()],
              }),
            ],
          },
          proofs: {
            proofProtocols: [
              new DidCommProofV2Protocol({
                proofFormats: [new QuarkDifPresentationExchangeProofFormatService()],
              }),
            ],
          },
        }),
      },
      dependencies: options.fetchOverride
        ? { ...agentDependencies, fetch: options.fetchOverride }
        : agentDependencies,
    },
    dependencyManager
  )

  await agent.initialize()

  const did = await ensureKeyDid(agent, { keyType: 'Ed25519' })
  resolveLogger(options.logger).log(`[Holder] DID listo: ${did}`)

  setupHolderListeners(agent, { label: listenerLabel, logger: options.logger })
  return agent
}

/**
 * Crea e inicializa el agente root del holder con soporte multi-tenant.
 *
 * Los listeners DIDComm se registran una sola vez en el root y atienden
 * eventos de todos los tenants. Cada tenant inicializa su propio DID key
 * dentro del contexto aislado al crearse con `ensureTenant`.
 *
 * @param config - Configuración de infra (KMS, records, endpoints)
 * @param options - Servidor WebSocket opcional y logger
 * @returns Agente root inicializado listo para crear/gestionar tenants
 */
export async function createRootHolderAgent(
  config: CredoAgentBaseConfig,
  options: CreateRootHolderAgentOptions
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
        port: config.didcommPort ?? 9205,
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
    inboundTransports.push(new DidCommWsInboundTransport({ port: config.didcommPort ?? 9205 }))
  }

  const closeDelayMs = options?.transportCloseDelayMs ?? 10000
  const listenerLabel = options?.listenerLabel ?? 'Holder'

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
        w3cV2Credentials: new W3cV2CredentialsModule(),
        sdJwtVc: new SdJwtVcModule(),
        openId4VcHolder: new OpenId4VcHolderModule(),
        tenants: new TenantsModule(),
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
          credentials: {
            credentialProtocols: [
              new DidCommCredentialV2Protocol({
                credentialFormats: [new QuarkJsonLdCredentialFormatService()],
              }),
            ],
          },
          proofs: {
            proofProtocols: [
              new DidCommProofV2Protocol({
                proofFormats: [new QuarkDifPresentationExchangeProofFormatService()],
              }),
            ],
          },
        }),
      },
      dependencies: options?.fetchOverride
        ? { ...agentDependencies, fetch: options.fetchOverride }
        : agentDependencies,
    },
    dependencyManager
  )

  await agent.initialize()

  setupHolderListeners(agent, { label: listenerLabel, logger: options?.logger })
  resolveLogger(options?.logger).log('[Holder Root] Agente root inicializado con soporte multi-tenant')
  return agent
}
