import { Agent, CacheModule, DependencyManager, InMemoryLruCache, SdJwtVcModule, W3cCredentialsModule } from '@credo-ts/core'
import {
  agentDependencies,
  DidCommHttpInboundTransport,
  DidCommWsInboundTransport,
} from '@credo-ts/node'
import {
  DidCommModule,
  DidCommHttpOutboundTransport,
  DidCommModuleConfig,
  DidCommCredentialV2Protocol,
} from '@credo-ts/didcomm'
import { OpenId4VcIssuerModule } from '@credo-ts/openid4vc'
import { TenantsModule } from '@credo-ts/tenants'
import { setGlobalConfig } from '@openid4vc/oauth2'

import { setupDidCommIssuerListeners } from '../protocol/didcomm/issuer.listener'
import { QuarkJsonLdCredentialFormatService } from '../protocol/didcomm/quark-jsonld-credential-format.service'
import { setupOid4VcIssuerListeners } from '../protocol/openid4vc/issuer.oid4vc.listener'
import { buildSdJwtCredentialMapper, initializeIssuerOid4vc } from '../protocol/openid4vc/issuer.oid4vc'
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
  CreateIssuerAgentOptions,
  CreateRootIssuerAgentOptions,
  DidCommHttpInboundApp,
  OpenId4VcIssuerApp,
} from './create-agent-options.types'
import { buildRootAgentInitConfig } from './credo-init-config'
import { DidCommWsOutboundTransportDelayedClose } from '../protocol/didcomm/transport'
import { quarkDocumentLoader } from '../credential/bbs/quark-document-loader'
import { registerDidCommInboundConnectionMiddleware } from '../protocol/didcomm/didcomm-inbound-connection.middleware'

/**
 * Crea e inicializa el agente Credo del issuer.
 *
 * Habilita los siguientes protocolos:
 * - **DIDComm v1** — emisión de credenciales W3C JSON-LD vía mensajería cifrada
 * - **SD-JWT VC** — credenciales con divulgación selectiva (siempre activo)
 * - **OID4VCI** — emisión vía HTTP/OAuth2 (EUDI Wallet), activo si `config.oid4vcBaseUrl` y `options.expressApp` están definidos
 *
 * @param config - Configuración base del agente (wallet, KMS, endpoints, oid4vcBaseUrl opcional)
 * @param options - Express app opcional para OID4VCI, wsServer y logger
 * @returns Agente Credo inicializado con listeners DIDComm activos
 */
export async function createIssuerAgent(
  config: CredoAgentBaseConfig,
  options: CreateIssuerAgentOptions
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
        port: config.didcommPort ?? 3001,
      }),
    )
    if (options.wsServer) {
      inboundTransports.push(
        new DidCommWsInboundTransport({ server: options.wsServer as import('ws').WebSocketServer } as {
          server: import('ws').WebSocketServer
        }),
      )
    }
  } else if (options.wsServer) {
    inboundTransports.push(
      new DidCommWsInboundTransport({ server: options.wsServer as import('ws').WebSocketServer } as {
        server: import('ws').WebSocketServer
      }),
    )
  } else {
    inboundTransports.push(
      new DidCommWsInboundTransport({
        port: config.didcommPort ?? 3001,
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
          openId4VcIssuer: new OpenId4VcIssuerModule({
            baseUrl: config.oid4vcBaseUrl,
            app: options.expressApp as unknown as OpenId4VcIssuerApp,
            credentialRequestToCredentialMapper: buildSdJwtCredentialMapper(),
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
          credentials: {
            credentialProtocols: [
              new DidCommCredentialV2Protocol({
                credentialFormats: [new QuarkJsonLdCredentialFormatService()],
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

  registerDidCommInboundConnectionMiddleware(agent)

  const url = new URL(config.didcommEndpoint)
  const host = url.port ? `${url.hostname}%3A${url.port}` : url.hostname
  const domain = `${host}:${options.wallet.id}`
  const { did } = await ensureWebDid(agent, {
    domain,
    didcommEndpoint: config.didcommEndpoint,
    addDidCommKey: true,
    addBbsKey: true,
  })
  resolveLogger(options.logger).log(`[Issuer] DID listo: ${did}`)

  if (config.oid4vcBaseUrl && options.expressApp && options.oid4vcOptions) {
    await initializeIssuerOid4vc(agent, { ...options.oid4vcOptions, issuerId: options.wallet.id })
  }

  setupOid4VcIssuerListeners(agent, { label: listenerLabel, logger: options.logger })
  setupDidCommIssuerListeners(agent, {
    label: listenerLabel,
    logger: options.logger,
    onConnectionReady: options.onConnectionReady,
  })
  return agent
}

/**
 * Crea e inicializa el agente root del issuer con soporte multi-tenant.
 *
 * El agente root no tiene wallet de negocio propia — sólo coordina tenants.
 * Cada tenant (wallet) se crea con `ensureTenant` y usa `withTenant` para
 * operar. Los listeners DIDComm y OID4VCI se registran una sola vez aquí
 * y atienden eventos de todos los tenants.
 *
 * @param config - Configuración de infra (KMS, records, endpoints)
 * @param options - Express app opcional para OID4VCI, wsServer y logger
 * @returns Agente root inicializado listo para crear/gestionar tenants
 */
export async function createRootIssuerAgent(
  config: CredoAgentBaseConfig,
  options: CreateRootIssuerAgentOptions
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
        port: config.didcommPort ?? 3001,
      }),
    )
    if (options.wsServer) {
      inboundTransports.push(
        new DidCommWsInboundTransport({ server: options.wsServer as import('ws').WebSocketServer } as {
          server: import('ws').WebSocketServer
        }),
      )
    }
  } else if (options.wsServer) {
    inboundTransports.push(
      new DidCommWsInboundTransport({ server: options.wsServer as import('ws').WebSocketServer } as {
        server: import('ws').WebSocketServer
      }),
    )
  } else {
    inboundTransports.push(new DidCommWsInboundTransport({ port: config.didcommPort ?? 3001 }))
  }

  const closeDelayMs = options.transportCloseDelayMs ?? 10000

  const listenerLabel = options.listenerLabel ?? 'Issuer'

  const agent = new Agent(
    {
      config: buildRootAgentInitConfig(options.logger),
      modules: {
        cache: new CacheModule({ cache: new InMemoryLruCache({ limit: 500 }) }),
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
        ...(config.oid4vcBaseUrl && options.expressApp && {
          openId4VcIssuer: new OpenId4VcIssuerModule({
            baseUrl: config.oid4vcBaseUrl,
            app: options.expressApp as unknown as OpenId4VcIssuerApp,
            credentialRequestToCredentialMapper: buildSdJwtCredentialMapper(),
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
          credentials: {
            credentialProtocols: [
              new DidCommCredentialV2Protocol({
                credentialFormats: [new QuarkJsonLdCredentialFormatService()],
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

  registerDidCommInboundConnectionMiddleware(agent)

  setupOid4VcIssuerListeners(agent, { label: listenerLabel, logger: options.logger })
  setupDidCommIssuerListeners(agent, {
    label: listenerLabel,
    logger: options.logger,
    onConnectionReady: options.onConnectionReady,
  })
  resolveLogger(options.logger).log('[Issuer Root] Agente root inicializado con soporte multi-tenant')
  return agent
}
