import {
  OpenId4VcIssuerModule,
  OpenId4VcVerifierModule,
} from '@credo-ts/openid4vc'
import type { OpenId4VciCreateIssuerOptions, OpenId4VpCreateVerifierOptions } from '@credo-ts/openid4vc'
import { DidCommHttpInboundTransport } from '@credo-ts/node'
import type { Express } from 'express'

import type { CredoLogger } from '../types/logger.types'
import type { ConnectionReadyPayload } from '../protocol/didcomm/shared.listener'

/**
 * Tipos de app Express esperados por los módulos OID4VC de Credo-TS.
 *
 * Se derivan desde los constructores oficiales para reutilizarlos en issuer/verifier
 * y evitar incompatibilidades entre múltiples instalaciones de `@types/express`.
 */
export type OpenId4VcIssuerApp = ConstructorParameters<typeof OpenId4VcIssuerModule>[0]['app']
export type OpenId4VcVerifierApp = ConstructorParameters<typeof OpenId4VcVerifierModule>[0]['app']
export type DidCommHttpInboundApp = ConstructorParameters<typeof DidCommHttpInboundTransport>[0]['app']

/**
 * Opciones base compartidas por todos los agentes Credo.
 */
export interface CreateAgentOptions {
  wsServer?: object
  transportCloseDelayMs?: number
  /** Logger para los listeners (p. ej. Nest Logger). Si no se pasa, usa console. */
  logger?: CredoLogger
  /**
   * Función `fetch` personalizada que reemplaza el `agentDependencies.fetch` por defecto.
   *
   * Útil en entornos donde las URLs que la librería `@openid4vc` construye internamente
   * deben ser reescritas antes de realizar la petición HTTP (p. ej. reemplazar `https://`
   * por `http://` en servicios Docker que no tienen TLS). Afecta todas las peticiones
   * realizadas por el agente, incluyendo la verificación de tokens en el issuer.
   *
   * Si se omite, se usa el `fetch` provisto por `@credo-ts/node`.
   */
  fetchOverride?: typeof fetch
}

/** Opciones comunes del agente root multi-tenant (sin wallet de negocio). */
export interface RootAgentOptions extends CreateAgentOptions {
  /** Etiqueta en logs de listeners del proceso (p. ej. `Issuer`, `Holder`). */
  listenerLabel?: string
  /**
   * Implementación de record storage inyectada por el servicio
   * (`AskarRecordStorage` | `PostgresRecordStorage`).
   */
  recordStorage: import('../record/record-storage.interface').RecordStorage
  /**
   * Implementación de KMS primaria inyectada por el integrador
   * (`AskarKeyManagementService` | `PostgresKeyManagementService` | otro).
   * Define `defaultBackend` en Credo.
   */
  keyManagementService: import('../kms/key-management.interface').KeyManagementService
  /**
   * Backends KMS no-default (BBS, domain-key x5c, futuros).
   * El orden es el de resolución de Credo tras el primario.
   * Ejemplo producto Askar: `[domainKey?, bbsPostgres]`.
   */
  additionalKeyManagementServices?: import('../kms/key-management.interface').KeyManagementService[]
  /**
   * Store Askar (Nest/integrador). Si está presente, se registra `AskarModule` store-only
   * (`enableKms`/`enableStorage` false) con `ProfilePerWallet`.
   * Opcional: solo hace falta si algún adapter Askar está en uso.
   */
  askarStore?: import('./askar.module').QuarkAskarStoreOptions
}

/** Opciones OID4VCI del issuer: display, dpop algs y credential configurations soportadas. */
export type IssuerOid4vcOptions = Omit<OpenId4VciCreateIssuerOptions, 'metadataSigner'>

/** Opciones OID4VP del verifier: clientMetadata (client_name, logo_uri, etc.). */
export type VerifierOid4vcOptions = OpenId4VpCreateVerifierOptions

export interface CreateRootIssuerAgentOptions extends RootAgentOptions {
  /** Express app sobre el que Credo registra los endpoints OID4VCI. Requerido para activar OID4VCI. */
  expressApp?: Express
  /**
   * Callback al completar/reusar una conexión DIDComm.
   * Usado por el issuer para disparar pending offers (`POST .../didcomm/offer`).
   */
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>
}

/**
 * Opciones para `createIssuerAgent` (modo single-wallet legacy).
 *
 * Si `config.oid4vcBaseUrl` está definido y se pasa `expressApp`, activa OID4VCI automáticamente.
 */
export interface CreateIssuerAgentOptions extends CreateRootIssuerAgentOptions {
  wallet: { id: string; key: string }
  /** Opciones OID4VCI del issuer (modo single-wallet). */
  oid4vcOptions?: IssuerOid4vcOptions
}

export interface CreateRootHolderAgentOptions extends RootAgentOptions {
  /** Express app sobre el que Credo registra el inbound HTTP DIDComm. */
  expressApp?: Express
}

/**
 * Opciones para `createHolderAgent` (modo single-wallet legacy).
 */
export interface CreateHolderAgentOptions extends CreateRootHolderAgentOptions {
  wallet: { id: string; key: string }
}

export interface CreateRootVerifierAgentOptions extends RootAgentOptions {
  /** Express app sobre el que Credo registra los endpoints OID4VP. */
  expressApp?: Express
  /**
   * Callback al completar/reusar una conexión DIDComm.
   * Usado por el verifier para disparar pending proofs (`POST .../didcomm/request`).
   */
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>
}

/**
 * Opciones para `createVerifierAgent` (modo single-wallet legacy).
 */
export interface CreateVerifierAgentOptions extends CreateRootVerifierAgentOptions {
  wallet: { id: string; key: string }
  /**
   * Opciones OID4VP del verifier (clientMetadata, etc.).
   * Se registran en el well-known al arranque.
   */
  verifierOptions?: VerifierOid4vcOptions
}
