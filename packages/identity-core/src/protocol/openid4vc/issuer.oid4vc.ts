import type { Agent, DidDocument, SdJwtVcHolderBinding } from '@credo-ts/core'
import { DidsApi } from '@credo-ts/core'
import type {
  OpenId4VcIssuanceSessionRecord,
  OpenId4VcIssuerRecord,
  OpenId4VciCreateCredentialOfferOptions,
  OpenId4VciCreateIssuerOptions,
  OpenId4VciCredentialRequestToCredentialMapper,
  OpenId4VcUpdateIssuerRecordOptions,
  VerifiedOpenId4VcCredentialHolderBinding,
} from '@credo-ts/openid4vc'
import { OpenId4VcIssuerApi } from '@credo-ts/openid4vc'
import { getOid4VcSigningDidUrlForAlg } from '../../did/did'

type CredentialConfigurationsSupported =
  OpenId4VciCreateIssuerOptions['credentialConfigurationsSupported']
type CredentialConfiguration = CredentialConfigurationsSupported[string]

/**
 * Fusiona configs por clave preservando `display` visual cuando el llamador no lo provee
 * (p. ej. `createSdJwtOffer` solo sincroniza `claims`).
 */
function mergeCredentialConfigurationsSupported(
  existing: CredentialConfigurationsSupported,
  incoming?: CredentialConfigurationsSupported,
  preferIncomingDisplay = false,
): CredentialConfigurationsSupported {
  if (!incoming) return existing

  const merged: CredentialConfigurationsSupported = { ...existing }
  for (const configId of Object.keys(incoming)) {
    const incomingConfig = incoming[configId]
    if (!incomingConfig) continue

    const existingConfig = merged[configId]
    if (!existingConfig) {
      merged[configId] = incomingConfig
      continue
    }

    const display = preferIncomingDisplay
      ? (incomingConfig.display ?? existingConfig.display)
      : (existingConfig.display ?? incomingConfig.display)
    const claims =
      incomingConfig.claims !== undefined
        ? ({
            ...((existingConfig.claims ?? {}) as Record<string, unknown>),
            ...incomingConfig.claims,
          } as CredentialConfiguration['claims'])
        : existingConfig.claims

    // Mismo configId → mismo variant de format; el cast evita perder la unión al hacer spread.
    merged[configId] = {
      ...existingConfig,
      ...incomingConfig,
      display,
      claims,
    } as CredentialConfiguration
  }

  return merged
}

/**
 * Retorna el issuer identificado por `issuerId` actualizando su configuración,
 * o crea uno nuevo si no existe.
 *
 * Si se omite `issuerId`, busca el primer issuer en la DB (comportamiento legacy).
 * Merge de `credentialConfigurationsSupported` por clave; preserva `display` visual salvo
 * que el llamador envíe `display` explícito (POST/PATCH de metadata).
 *
 * @param agent - Agente Credo del issuer con `OpenId4VcIssuerModule` activo
 * @param options - Opciones del issuer (credentialConfigurationsSupported, display, etc.)
 * @param issuerId - ID estable del issuer. Si se omite, se usa el primer issuer en DB.
 * @returns Registro del issuer actualizado o recién creado
 */
export async function ensureIssuer(
  agent: Agent,
  options: OpenId4VciCreateIssuerOptions,
  issuerId?: string
): Promise<OpenId4VcIssuerRecord> {
  const issuerApi = agent.dependencyManager.resolve(OpenId4VcIssuerApi)

  if (issuerId) {
    try {
      const existing = await issuerApi.getIssuerByIssuerId(issuerId)
      await issuerApi.updateIssuerMetadata({
        issuerId: existing.issuerId,
        display: options.display ?? existing.display,
        credentialConfigurationsSupported: mergeCredentialConfigurationsSupported(
          existing.credentialConfigurationsSupported,
          options.credentialConfigurationsSupported,
          options.display !== undefined,
        ),
        dpopSigningAlgValuesSupported: options.dpopSigningAlgValuesSupported ?? existing.dpopSigningAlgValuesSupported,
        batchCredentialIssuance: existing.batchCredentialIssuance,
        authorizationServerConfigs: options.authorizationServerConfigs ?? existing.authorizationServerConfigs,
      })
      return issuerApi.getIssuerByIssuerId(existing.issuerId)
    } catch {
      return issuerApi.createIssuer({ ...options, issuerId })
    }
  }

  const issuers = await issuerApi.getAllIssuers()
  if (issuers.length > 0) {
    const existing = issuers[0]
    await issuerApi.updateIssuerMetadata({
      issuerId: existing.issuerId,
      display: options.display ?? existing.display,
      credentialConfigurationsSupported: mergeCredentialConfigurationsSupported(
        existing.credentialConfigurationsSupported,
        options.credentialConfigurationsSupported,
        options.display !== undefined,
      ),
      dpopSigningAlgValuesSupported: options.dpopSigningAlgValuesSupported ?? existing.dpopSigningAlgValuesSupported,
      batchCredentialIssuance: existing.batchCredentialIssuance,
      authorizationServerConfigs: options.authorizationServerConfigs ?? existing.authorizationServerConfigs,
    })
    return issuerApi.getIssuerByIssuerId(existing.issuerId)
  }

  return issuerApi.createIssuer(options)
}

/**
 * Inicializa el registro OID4VCI del issuer al arranque del servicio.
 *
 * Resuelve el DID Document del issuer directamente desde el wallet del agente (did:web)
 * para derivar el `metadataSigner`, sin que el llamador deba proveerlo.
 * Debe invocarse una sola vez durante el bootstrap, después de `ensureWebDid`.
 *
 * La metadata firmada queda almacenada en el `OpenId4VcIssuerRecord` y Credo la
 * sirve automáticamente cuando una wallet solicita `Accept: application/jwt`.
 *
 * @param agent - Agente Credo con `OpenId4VcIssuerModule` activo y did:web en el wallet
 * @param options - Opciones del issuer sin `metadataSigner`; acepta `issuerId` opcional
 * @returns Registro del issuer creado o actualizado
 */
export async function initializeIssuerOid4vc(
  agent: Agent,
  options: Omit<OpenId4VciCreateIssuerOptions, 'metadataSigner'> & { issuerId?: string }
): Promise<OpenId4VcIssuerRecord> {
  const didRecords = await agent.dependencyManager.resolve(DidsApi).getCreatedDids({ method: 'web' })
  const didDocument = didRecords[0]?.didDocument
  if (!didDocument) throw new Error('No did:web DID document found for metadataSigner')

  return ensureIssuer(
    agent,
    {
      ...options,
      metadataSigner: {
        method: 'did',
        didUrl: getOid4VcSigningDidUrlForAlg(didDocument, 'ES256'),
      },
    },
    options.issuerId
  )
}

/** Campos de metadata OID4VCI actualizables vía {@link patchIssuerOid4vcMetadata}. */
export type IssuerOid4vcMetadataPatch = Partial<
  Pick<
    OpenId4VcUpdateIssuerRecordOptions,
    | 'display'
    | 'credentialConfigurationsSupported'
    | 'dpopSigningAlgValuesSupported'
    | 'batchCredentialIssuance'
    | 'authorizationServerConfigs'
  >
>

/**
 * Indica que no existe un `OpenId4VcIssuerRecord` para el `issuerId` dado.
 *
 * @throws {IssuerOid4vcNotFoundError} Desde {@link patchIssuerOid4vcMetadata}
 */
export class IssuerOid4vcNotFoundError extends Error {
  constructor(readonly issuerId: string) {
    super(`OpenId4VcIssuerRecord no encontrado para issuerId '${issuerId}'`)
    this.name = 'IssuerOid4vcNotFoundError'
  }
}

/**
 * Actualiza metadata OID4VCI del issuer (merge sobre configs existentes).
 *
 * Persiste y re-firma el JWT en el record Credo **`OpenId4VcIssuerRecord`**
 * (`type: OpenId4VcIssuerRecord`). No modifica `DidRecord`, conexiones DIDComm ni sesiones.
 *
 * @param agent - Agente del tenant issuer
 * @param issuerId - `issuerId` público del registro OID4VCI
 * @param patch - Campos a fusionar (`credentialConfigurationsSupported` se mergea por clave)
 * @returns Registro issuer actualizado
 * @throws {IssuerOid4vcNotFoundError} Si el issuer no fue creado previamente en el tenant
 */
export async function patchIssuerOid4vcMetadata(
  agent: Agent,
  issuerId: string,
  patch: IssuerOid4vcMetadataPatch,
): Promise<OpenId4VcIssuerRecord> {
  const issuerApi = agent.dependencyManager.resolve(OpenId4VcIssuerApi)

  let existing: OpenId4VcIssuerRecord
  try {
    existing = await issuerApi.getIssuerByIssuerId(issuerId)
  } catch {
    throw new IssuerOid4vcNotFoundError(issuerId)
  }

  await issuerApi.updateIssuerMetadata({
    issuerId: existing.issuerId,
    display: patch.display ?? existing.display,
    credentialConfigurationsSupported: patch.credentialConfigurationsSupported
      ? mergeCredentialConfigurationsSupported(
          existing.credentialConfigurationsSupported,
          patch.credentialConfigurationsSupported,
          true,
        )
      : existing.credentialConfigurationsSupported,
    dpopSigningAlgValuesSupported:
      patch.dpopSigningAlgValuesSupported ?? existing.dpopSigningAlgValuesSupported,
    batchCredentialIssuance: patch.batchCredentialIssuance ?? existing.batchCredentialIssuance,
    authorizationServerConfigs:
      patch.authorizationServerConfigs ?? existing.authorizationServerConfigs,
  })

  return issuerApi.getIssuerByIssuerId(issuerId)
}

/**
 * Crea un credential offer con flujo pre-authorized code.
 *
 * @param agent - Agente Credo del issuer con `OpenId4VcIssuerModule` activo
 * @param issuerId - ID del issuer registrado (obtenido via `ensureIssuer`)
 * @param options - Opciones del offer: credenciales a ofrecer, flujo de autorización, etc.
 * @returns URL del credential offer y registro de la sesión de emisión
 */
export async function createCredentialOffer(
  agent: Agent,
  issuerId: string,
  options: OpenId4VciCreateCredentialOfferOptions
): Promise<{ credentialOffer: string; issuanceSession: OpenId4VcIssuanceSessionRecord }> {
  const issuerApi = agent.dependencyManager.resolve(OpenId4VcIssuerApi)

  return issuerApi.createCredentialOffer({
    ...options,
    issuerId,
  })
}

/**
 * Retorna el registro de una sesión de emisión por su ID.
 *
 * @param agent - Agente Credo del issuer con `OpenId4VcIssuerModule` activo
 * @param issuanceSessionId - ID de la sesión de emisión
 * @returns Registro de la sesión con su estado actual
 */
export async function getIssuanceSession(
  agent: Agent,
  issuanceSessionId: string
): Promise<OpenId4VcIssuanceSessionRecord> {
  const issuerApi = agent.dependencyManager.resolve(OpenId4VcIssuerApi)

  return issuerApi.getIssuanceSessionById(issuanceSessionId)
}

/**
 * Metadatos de emisión almacenados en la sesión al crear el offer.
 * Los lee `buildSdJwtCredentialMapper` al construir la credencial firmada.
 */
export interface SdJwtIssuanceMetadata {
  vct: string
  claims?: Record<string, unknown>
  disclosureFrame?: { _sd?: string[] }
  status?: {
    status_list: {
      idx: number
      uri: string
    }
  }
}

/** Opciones para `createSdJwtOffer`. */
export interface CreateSdJwtOfferOptions extends SdJwtIssuanceMetadata {
  configurationId: string
  preAuthorizedCode?: string
  /** Display labels por claim para que la wallet los muestre con nombres legibles. */
  claimsDisplay?: Record<string, { name: string; locale?: string }>
  /** Display del issuer (nombre de organización visible en la wallet). */
  issuerDisplay?: Array<{ name: string; locale?: string }>
  /** issuerId estable del registro OID4VCI. Si se omite, se usa el primer issuer en DB. */
  issuerId?: string
  /** Algoritmos soportados en el proof JWT del holder. Por defecto `['EdDSA']`. */
  supportedAlgorithms?: string[]
}

/**
 * Infiere el algoritmo que usó el holder para su proof JWT a partir del binding verificado.
 *
 * - `method: 'jwk'` → `kty === 'OKP'` → EdDSA, cualquier otro → ES256
 * - `method: 'did'` → fragment `z6Mk` → Ed25519/EdDSA, cualquier otro → ES256
 */
function extractProofAlg(holderBinding: VerifiedOpenId4VcCredentialHolderBinding): 'ES256' | 'EdDSA' {
  const firstKey = holderBinding.keys[0]
  if (firstKey.method === 'jwk') {
    return (firstKey.jwk as { kty: string }).kty === 'OKP' ? 'EdDSA' : 'ES256'
  }
  const fragment = firstKey.didUrl.split('#')[1] ?? ''
  return fragment.startsWith('z6Mk') ? 'EdDSA' : 'ES256'
}

/**
 * Convierte el `VerifiedOpenId4VcCredentialHolderBinding` de Credo al formato
 * `SdJwtVcHolderBinding` que espera `SdJwtVcApi.sign`.
 *
 * @param holderBinding - Binding verificado recibido en el mapper de credential request
 */
export function toSdJwtHolderBinding(
  holderBinding: VerifiedOpenId4VcCredentialHolderBinding
): SdJwtVcHolderBinding {
  const firstKey = holderBinding.keys[0]
  if (firstKey.method === 'did') {
    return { method: 'did', didUrl: firstKey.didUrl }
  }
  return { method: 'jwk', jwk: firstKey.jwk }
}

/**
 * Construye el `credentialRequestToCredentialMapper` para emisión de credenciales
 * en formato IETF SD-JWT VC (`dc+sd-jwt`).
 *
 * Resuelve el DID del issuer directamente desde el wallet del agente (did:web) usando
 * el `agentContext` provisto por Credo en cada credential request, sin necesidad de
 * getters externos. Lee los metadatos almacenados en `issuanceSession.issuanceMetadata`
 * y firma la credencial con la clave correspondiente al algoritmo del holder.
 *
 * @returns Mapper compatible con `OpenId4VcIssuerModule` de Credo-TS
 */
export function buildSdJwtCredentialMapper(): OpenId4VciCredentialRequestToCredentialMapper {
  return async ({ issuanceSession, holderBinding, agentContext }) => {
    const didsApi = agentContext.resolve(DidsApi)
    const didRecords = await didsApi.getCreatedDids({ method: 'web' })
    const didDocument = didRecords[0]?.didDocument
    if (!didDocument) throw new Error('No did:web DID document found in issuer wallet')

    const metadata = (issuanceSession.issuanceMetadata ?? {}) as unknown as SdJwtIssuanceMetadata
    const alg = extractProofAlg(holderBinding)
    const didUrl = getOid4VcSigningDidUrlForAlg(didDocument, alg)
    const did = didUrl.split('#')[0]

    return {
      type: 'credentials' as const,
      format: 'dc+sd-jwt' as const,
      credentials: [
        {
          payload: {
            vct: metadata.vct ?? 'QuarkCredential',
            iss: did,
            ...(metadata.status ? { status: metadata.status } : {}),
            ...(metadata.claims ?? {}),
          },
          issuer: { method: 'did' as const, didUrl },
          holder: toSdJwtHolderBinding(holderBinding),
          disclosureFrame: metadata.disclosureFrame,
        },
      ],
    }
  }
}

/**
 * Construye el objeto `credentialConfigurationsSupported` para un issuer SD-JWT
 * en formato `vc+sd-jwt`, incluyendo `credential_definition` con display por claim.
 */
function buildSdJwtCredentialConfiguration(
  configurationId: string,
  vct: string,
  claimsDisplay?: Record<string, { name: string; locale?: string }>,
  supportedAlgorithms?: string[]
): OpenId4VciCreateIssuerOptions['credentialConfigurationsSupported'] {
  const credentialSubject = claimsDisplay
    ? Object.fromEntries(
        Object.entries(claimsDisplay).map(([key, info]) => [
          key,
          { mandatory: false, display: [{ name: info.name, locale: info.locale ?? 'es' }] },
        ])
      )
    : undefined

  return {
    [configurationId]: {
      format: 'dc+sd-jwt',
      vct,
      ...(credentialSubject && { claims: credentialSubject }),
      // Compatibilidad dual: algunas wallets esperan `jwk` legacy y otras `did:jwk`.
      // Mantenemos ambos para evitar fallos de intersección en pruebas cruzadas.
      cryptographic_binding_methods_supported: ['did:jwk', 'jwk'],
      credential_signing_alg_values_supported: supportedAlgorithms ?? ['ES256'],
      proof_types_supported: {
        jwt: { proof_signing_alg_values_supported: supportedAlgorithms ?? ['ES256'] },
      },
    } as OpenId4VciCreateIssuerOptions['credentialConfigurationsSupported'][string],
  }
}

/**
 * Flujo completo de creación de un credential offer SD-JWT (OID4VCI pre-authorized code).
 *
 * Internamente:
 * 1. Sincroniza `claims` en el issuer existente sin pisar `display` visual (POST/PATCH)
 * 2. Almacena `vct`, `claims` y `disclosureFrame` en `issuanceMetadata` para que
 *    el `credentialRequestToCredentialMapper` los recupere al firmar
 *
 * @param agent - Agente Credo del issuer con `OpenId4VcIssuerModule` activo
 * @param options - Datos de la credencial a ofrecer
 * @returns URI del offer y el ID de la sesión de emisión
 */
export async function createSdJwtOffer(
  agent: Agent,
  options: CreateSdJwtOfferOptions
): Promise<{ offerUri: string; issuanceSessionId: string }> {
  const issuerRecord = await ensureIssuer(
    agent,
    {
      credentialConfigurationsSupported: buildSdJwtCredentialConfiguration(
        options.configurationId,
        options.vct,
        options.claimsDisplay,
        options.supportedAlgorithms
      ),
    },
    options.issuerId
  )

  const { credentialOffer, issuanceSession } = await createCredentialOffer(agent, issuerRecord.issuerId, {
    credentialConfigurationIds: [options.configurationId],
    preAuthorizedCodeFlowConfig: {
      preAuthorizedCode: options.preAuthorizedCode,
    },
    issuanceMetadata: {
      vct: options.vct,
      claims: options.claims,
      disclosureFrame: options.disclosureFrame,
      ...(options.status && { status: options.status }),
    },
  })

  return { offerUri: credentialOffer, issuanceSessionId: issuanceSession.id }
}
