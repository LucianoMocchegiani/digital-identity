import {
  DidDocument,
  DidCommV1Service,
  DidDocumentRole,
  DidKey,
  DidRecord,
  DidRepository,
  JsonTransformer,
  Kms,
  utils,
} from '@credo-ts/core'
import type {
  AgentContext,
  DidCreateOptions,
  DidCreateResult,
  DidDeactivateResult,
  DidRegistrar,
  DidUpdateResult,
} from '@credo-ts/core'

/**
 * Configuración requerida por QuarkDidRegistrar.
 *
 * @property vdrServiceUrl - URL base del vdr-service donde se registran los DID Documents
 * @property didcommEndpoint - Endpoint DIDComm del agente, incluido como serviceEndpoint en el DID Document
 */
export interface QuarkDidRegistrarConfig {
  vdrServiceUrl: string
  didcommEndpoint: string
}

/**
 * Opciones de creación de DID did:custom.
 *
 * Permite crear un nuevo par de claves (`createKey`) o reutilizar una clave existente por `keyId`.
 * Si no se especifica ninguna opción, se genera automáticamente una clave Ed25519.
 */
export interface QuarkDidCreateOptions extends DidCreateOptions {
  method: 'custom'
  did?: never
  didDocument?: never
  secret?: never
  options: {
    createKey?: { type: { kty: string; crv: string } }
    keyId?: string
  }
}

/**
 * Implementa el DidRegistrar de Credo-TS para el método `did:custom` de QuarkID.
 *
 * Flujo de creación:
 * 1. Crea o recupera un par de claves (Ed25519 o P-256) vía KMS
 * 2. Deriva un DID Document a partir de `did:key` y reemplaza el identificador por `did:custom:<uuid>`
 * 3. Agrega un `DidCommV1Service` apuntando al endpoint DIDComm configurado
 * 4. Publica el DID Document en vdr-service via `POST /did`
 * 5. Persiste el `DidRecord` en el wallet de Credo-TS
 *
 * `update` y `deactivate` no están soportados y retornan `state: 'failed'`.
 */
export class QuarkDidRegistrar implements DidRegistrar {
  public readonly supportedMethods = ['custom']

  constructor(private readonly config: QuarkDidRegistrarConfig) {}

  /**
   * Crea un DID `did:custom` con su DID Document y lo publica en vdr-service.
   *
   * @param agentContext - Contexto del agente Credo-TS (provee KMS y repositorios)
   * @param options - Opciones de creación: tipo de clave o keyId existente
   * @returns Resultado con `state: 'finished'` y el DID creado, o `state: 'failed'` con el motivo
   * @throws Nunca — los errores se capturan y se retornan como `state: 'failed'`
   */
  async create(
    agentContext: AgentContext,
    options: QuarkDidCreateOptions
  ): Promise<DidCreateResult> {
    const didRepository = agentContext.dependencyManager.resolve(DidRepository)
    const kms = agentContext.dependencyManager.resolve(Kms.KeyManagementApi)

    try {
      let publicJwk: Record<string, unknown>
      let keyId: string

      const ed25519Type = { kty: 'OKP' as const, crv: 'Ed25519' as const }
      const p256Type = { kty: 'EC' as const, crv: 'P-256' as const }

      if (options.options?.createKey) {
        const opts = options.options.createKey
        const isP256 = opts.type.kty === 'EC' && opts.type.crv === 'P-256'
        const isEd25519 = opts.type.kty === 'OKP' && opts.type.crv === 'Ed25519'
        if (!isEd25519 && !isP256) {
          throw new Error(`Tipo de clave no soportado: ${JSON.stringify(opts.type)}`)
        }
        const createResult = await kms.createKey({
          type: isP256 ? p256Type : ed25519Type,
        } as Kms.KmsCreateKeyOptions<typeof ed25519Type | typeof p256Type>)
        publicJwk = createResult.publicJwk as Record<string, unknown>
        keyId = createResult.keyId
      } else if (options.options?.keyId) {
        const pk = await kms.getPublicKey({ keyId: options.options.keyId })
        if (!pk) {
          return {
            didDocumentMetadata: {},
            didRegistrationMetadata: {},
            didState: {
              state: 'failed',
              reason: `notFound: key '${options.options.keyId}' not found`,
            },
          }
        }
        publicJwk = pk as Record<string, unknown>
        keyId = options.options.keyId
      } else {
        const createResult = await kms.createKey({
          type: ed25519Type,
        } as Kms.KmsCreateKeyOptions<typeof ed25519Type>)
        publicJwk = createResult.publicJwk as Record<string, unknown>
        keyId = createResult.keyId
      }

      const jwk = Kms.PublicJwk.fromPublicJwk(
        publicJwk as { kty: 'OKP'; crv: 'Ed25519'; x: string; kid?: string }
      )
      const didKey = new DidKey(jwk)
      const newDid = `did:custom:${utils.uuid()}`
      const oldDid = didKey.did

      const docJson = didKey.didDocument.toJSON()
      const docStr = JSON.stringify(docJson)
      const newDocStr = docStr.split(oldDid).join(newDid)
      const didDocument = JsonTransformer.fromJSON(
        JSON.parse(newDocStr) as Record<string, unknown>,
        DidDocument
      )

      const recipientKeyId = `${newDid}#${jwk.fingerprint}`
      const didCommService = new DidCommV1Service({
        id: `${newDid}#inline-0`,
        serviceEndpoint: this.config.didcommEndpoint,
        recipientKeys: [recipientKeyId],
        routingKeys: [],
      })
      didDocument.service = [
        ...(didDocument.service ?? []),
        didCommService,
      ]

      const baseUrl = this.config.vdrServiceUrl.replace(/\/$/, '')
      await fetch(`${baseUrl}/did`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          id: newDid,
          document: didDocument.toJSON(),
        }),
      })

      const didRecord = new DidRecord({
        did: newDid,
        role: DidDocumentRole.Created,
        didDocument,
        keys: [
          {
            didDocumentRelativeKeyId: `#${jwk.fingerprint}`,
            kmsKeyId: keyId,
          },
        ],
        tags: { recipientKeyFingerprints: [jwk.fingerprint] },
      })
      await didRepository.save(agentContext, didRecord)

      return {
        didDocumentMetadata: {},
        didRegistrationMetadata: {},
        didState: {
          state: 'finished',
          did: newDid,
          didDocument,
          secret: {},
        },
      }
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error)
      const causeErr = error instanceof Error ? (error as Error & { cause?: unknown }).cause : undefined
      const cause = causeErr instanceof Error ? ` (causa: ${causeErr.message})` : ''
      return {
        didDocumentMetadata: {},
        didRegistrationMetadata: {},
        didState: {
          state: 'failed',
          reason: `unknownError: ${message}${cause} — vdrServiceUrl: ${this.config.vdrServiceUrl}`,
        },
      }
    }
  }

  async update(): Promise<DidUpdateResult> {
    return {
      didDocumentMetadata: {},
      didRegistrationMetadata: {},
      didState: {
        state: 'failed',
        reason: 'notSupported: cannot update did:custom did',
      },
    }
  }

  async deactivate(): Promise<DidDeactivateResult> {
    return {
      didDocumentMetadata: {},
      didRegistrationMetadata: {},
      didState: {
        state: 'failed',
        reason: 'notSupported: cannot deactivate did:custom did',
      },
    }
  }
}
