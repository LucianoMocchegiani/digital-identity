import { X509Certificate, type Agent, type DidDocument } from '@credo-ts/core'
import { getOid4VpSigningDidUrl } from '../../did/did'
import type { VerifierOid4vcOptions } from '../../agent/create-agent-options.types'
import type {
  OpenId4VcUpdateVerifierRecordOptions,
  OpenId4VcVerificationSessionRecord,
  OpenId4VcVerifierRecord,
  OpenId4VpCreateAuthorizationRequestOptions,
  OpenId4VpCreateAuthorizationRequestReturn,
  OpenId4VpCreateVerifierOptions,
  OpenId4VpVerifiedAuthorizationResponse,
  OpenId4VpVerifyAuthorizationResponseOptions,
} from '@credo-ts/openid4vc'
import { OpenId4VcVerifierApi } from '@credo-ts/openid4vc'
/**
 * Retorna el primer verifier registrado, o crea uno nuevo si no existe ninguno.
 *
 * Útil para el bootstrap del servicio: garantiza que siempre exista al menos
 * un verifier listo antes de crear authorization requests.
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param options - Opciones de creación del verifier (clientMetadata, etc.)
 * @returns Registro del verifier existente o recién creado
 */
export async function ensureVerifier(
  agent: Agent,
  options?: OpenId4VpCreateVerifierOptions
): Promise<OpenId4VcVerifierRecord> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  if (options?.verifierId) {
    try {
      const existing = await verifierApi.getVerifierByVerifierId(options.verifierId)
      if (options.clientMetadata) {
        await verifierApi.updateVerifierMetadata({
          verifierId: existing.verifierId,
          clientMetadata: {
            ...existing.clientMetadata,
            ...options.clientMetadata,
          },
        })
        return verifierApi.getVerifierByVerifierId(options.verifierId)
      }
      return existing
    } catch {
      return verifierApi.createVerifier(options)
    }
  }

  const verifiers = await verifierApi.getAllVerifiers()

  if (verifiers.length > 0) {
    const existingVerifier = verifiers[0]
    const newClientMetadata = options?.clientMetadata

    if (newClientMetadata) {
      const existingClientMetadata = existingVerifier.clientMetadata ?? {}
      const hasDifferentMetadata =
        existingClientMetadata.client_name !== newClientMetadata.client_name ||
        existingClientMetadata.logo_uri !== newClientMetadata.logo_uri

      if (hasDifferentMetadata) {
        await verifierApi.updateVerifierMetadata({
          verifierId: existingVerifier.verifierId,
          clientMetadata: {
            ...existingClientMetadata,
            ...newClientMetadata,
          },
        })
        return verifierApi.getVerifierByVerifierId(existingVerifier.verifierId)
      }
    }

    return existingVerifier
  }

  return verifierApi.createVerifier(options)
}


/**
 * Crea un authorization request OID4VP (solicitud de presentación de credencial).
 *
 * El request resultante contiene la URL que el holder (EUDI Wallet u otra wallet OID4VP)
 * escanea para presentar las credenciales solicitadas.
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param verifierId - ID del verifier registrado (obtenido via `ensureVerifier`)
 * @param options - Opciones del request: presentationDefinition, dcqlQuery, responseMode, etc.
 * @returns URL del authorization request y registro de la sesión de verificación
 */
export async function createPresentationRequest(
  agent: Agent,
  verifierId: string,
  options: OpenId4VpCreateAuthorizationRequestOptions
): Promise<OpenId4VpCreateAuthorizationRequestReturn> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  return verifierApi.createAuthorizationRequest({
    ...options,
    verifierId,
  })
}

/**
 * Verifica una authorization response OID4VP recibida del holder.
 *
 * Valida la firma del VP Token, la estructura de la presentación y
 * que satisfaga los requisitos del presentation definition o DCQL query original.
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param verificationSessionId - ID de la sesión de verificación asociada al request
 * @param options - Opciones de verificación (authorizationResponse, etc.)
 * @returns Respuesta verificada con las credenciales presentadas
 */
export async function verifyPresentationResponse(
  agent: Agent,
  verificationSessionId: string,
  options: OpenId4VpVerifyAuthorizationResponseOptions
): Promise<OpenId4VpVerifiedAuthorizationResponse> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  return verifierApi.verifyAuthorizationResponse({
    ...options,
    verificationSessionId,
  })
}

/**
 * Retorna el resultado verificado de una sesión de verificación completada.
 *
 * Permite a los endpoints NestJS consultar el estado y las credenciales
 * presentadas en una sesión OID4VP ya procesada.
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param verificationSessionId - ID de la sesión de verificación
 * @returns Respuesta verificada con credenciales y estado de la presentación
 */
export async function getVerificationResult(
  agent: Agent,
  verificationSessionId: string
): Promise<OpenId4VpVerifiedAuthorizationResponse> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  return verifierApi.getVerifiedAuthorizationResponse(
    verificationSessionId
  )
}

/**
 * Retorna el registro de una sesión de verificación por su ID.
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param verificationSessionId - ID de la sesión de verificación
 * @returns Registro de la sesión con su estado actual
 */
export async function getVerificationSession(
  agent: Agent,
  verificationSessionId: string
): Promise<OpenId4VcVerificationSessionRecord> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  return verifierApi.getVerificationSessionById(verificationSessionId)
}

/** Opciones para `createVerificationRequest`. */
export interface CreateVerificationRequestOptions {
  /** Presentation Exchange definition. Mutuamente exclusivo con `dcqlQuery`. */
  presentationDefinition?: Record<string, unknown>
  /** DCQL query (OID4VP v1). Mutuamente exclusivo con `presentationDefinition`. */
  dcqlQuery?: Record<string, unknown>
  /** Modo de respuesta del authorization request (ej. `direct_post`). */
  responseMode?: OpenId4VpCreateAuthorizationRequestOptions['responseMode']
  /** URI a la que la wallet redirige al usuario tras completar la presentación. */
  authorizationResponseRedirectUri?: string
  /**
   * Método de firma del authorization request OID4VP.
   * - `did`: request object firmado con DID URL (client_id suele resolverse como did:*).
   * - `none`: request sin firma (client_id prefix `redirect_uri`).
   * - `x5c`: request object firmado con cadena X.509 (client_id x509_*).
   */
  requestSignerMethod?: 'did' | 'none' | 'x5c'
  /**
   * Cadena x5c codificada en base64 (leaf primero), usada cuando `requestSignerMethod = 'x5c'`.
   */
  x5cCertificatesBase64?: string[]
  /**
   * KeyId del certificado leaf en KMS, usada cuando `requestSignerMethod = 'x5c'`.
   */
  x5cLeafCertificateKeyId?: string
  /**
   * Prefijo de client_id para requests firmados con x5c.
   */
  x5cClientIdPrefix?: 'x509_hash' | 'x509_san_dns'
}

async function resolveSigningDidUrl(agent: Agent): Promise<string> {
  const dids = await agent.dids.getCreatedDids({ method: 'web' })
  const didDocument = dids[0]?.didDocument as DidDocument | undefined
  if (!didDocument) throw new Error('No se encontró did:web en el agente verifier')
  return getOid4VpSigningDidUrl(didDocument)
}

/**
 * Registra o actualiza el verifier OID4VP con las opciones dadas.
 * Debe llamarse durante el arranque del agente, después de inicializarlo.
 *
 * @param options - Incluir `verifierId` en multi-tenant para alinear con el ID lógico del tenant
 * @returns Registro **`OpenId4VcVerifierRecord`** creado o actualizado
 */
export async function initializeVerifierOid4vc(
  agent: Agent,
  options?: VerifierOid4vcOptions & { verifierId?: string },
): Promise<OpenId4VcVerifierRecord> {
  return ensureVerifier(agent, options)
}

/** Campos de metadata OID4VP actualizables vía {@link patchVerifierOid4vpMetadata}. */
export type VerifierOid4vpMetadataPatch = Partial<Pick<OpenId4VcUpdateVerifierRecordOptions, 'clientMetadata'>>

/**
 * Actualiza metadata OID4VP del verifier (merge de `clientMetadata`).
 *
 * Si aún no hay `OpenId4VcVerifierRecord`, lo crea con el patch (upsert).
 */
export async function patchVerifierOid4vpMetadata(
  agent: Agent,
  verifierId: string,
  patch: VerifierOid4vpMetadataPatch,
): Promise<OpenId4VcVerifierRecord> {
  const verifierApi = agent.dependencyManager.resolve(OpenId4VcVerifierApi)

  let existing: OpenId4VcVerifierRecord | undefined
  try {
    existing = await verifierApi.getVerifierByVerifierId(verifierId)
  } catch {
    existing = undefined
  }

  if (!existing) {
    return initializeVerifierOid4vc(agent, {
      verifierId,
      clientMetadata: patch.clientMetadata,
    })
  }

  if (patch.clientMetadata) {
    await verifierApi.updateVerifierMetadata({
      verifierId: existing.verifierId,
      clientMetadata: {
        ...existing.clientMetadata,
        ...patch.clientMetadata,
      },
    })
  }

  return verifierApi.getVerifierByVerifierId(verifierId)
}

type PresentationExchangeOption = NonNullable<OpenId4VpCreateAuthorizationRequestOptions['presentationExchange']>
type DcqlOption = NonNullable<OpenId4VpCreateAuthorizationRequestOptions['dcql']>

/**
 * Flujo completo de creación de un authorization request OID4VP.
 *
 * Encapsula:
 * - La estructura `requestSigner` con el método `did`
 * - La selección del modo PE (`version: 'v1.draft24'`) vs DCQL
 * - La llamada a `ensureVerifier` + `createPresentationRequest`
 *
 * @param agent - Agente Credo del verifier con `OpenId4VcVerifierModule` activo
 * @param signingDidUrl - DID URL con fragment para firmar el request (ej. `did:web:host#key-1`)
 * @param options - Presentation definition, DCQL query y modo de respuesta
 * @returns URI del authorization request y el ID de la sesión de verificación
 */
export async function createVerificationRequest(
  agent: Agent,
  options: CreateVerificationRequestOptions
): Promise<{ requestUri: string; verificationSessionId: string }> {
  const verifierRecord = await ensureVerifier(agent)

  const requestSignerMethod = options.requestSignerMethod ?? 'did'
  const requestSigner = await (async () => {
    if (requestSignerMethod === 'none') {
      return { method: 'none' } as const
    }

    if (requestSignerMethod === 'x5c') {
      if (!options.x5cCertificatesBase64?.length) {
        throw new Error('x5cCertificatesBase64 es requerido cuando requestSignerMethod es x5c')
      }
      const x5cLeafCertificateKeyId = options.x5cLeafCertificateKeyId
      if (!x5cLeafCertificateKeyId) {
        throw new Error('x5cLeafCertificateKeyId es requerido cuando requestSignerMethod es x5c')
      }

      const x5cCertificates = options.x5cCertificatesBase64.map((encodedCertificate, index) => {
        const certificate = X509Certificate.fromEncodedCertificate(encodedCertificate)
        if (index === 0) {
          certificate.publicJwk.keyId = x5cLeafCertificateKeyId
        }
        return certificate
      })

      return {
        method: 'x5c',
        x5c: x5cCertificates,
        clientIdPrefix: options.x5cClientIdPrefix,
      } as const
    }

    const signingDidUrl = await resolveSigningDidUrl(agent)
    return { method: 'did', didUrl: signingDidUrl } as const
  })()

  const requestOptions: OpenId4VpCreateAuthorizationRequestOptions = {
    requestSigner,
  }

  if (options.presentationDefinition) {
    requestOptions.presentationExchange = {
      definition: options.presentationDefinition as unknown as PresentationExchangeOption['definition'],
    }
    // Decisión interna de librería: PEX => draft21.
    requestOptions.version = 'v1.draft21'
  } else if (options.dcqlQuery) {
    requestOptions.dcql = { query: options.dcqlQuery as DcqlOption['query'] }
    // Decisión interna de librería: DCQL => v1.
    requestOptions.version = 'v1'
  }

  // Si no se define explícitamente, usamos direct_post para compatibilidad amplia
  // entre wallets que aún no esperan respuesta JARM cifrada por defecto.
  requestOptions.responseMode = options.responseMode ?? 'direct_post'

  if (options.authorizationResponseRedirectUri) {
    requestOptions.authorizationResponseRedirectUri = options.authorizationResponseRedirectUri
  }

  const { authorizationRequest, verificationSession } = await createPresentationRequest(
    agent,
    verifierRecord.verifierId,
    requestOptions
  )

  return { requestUri: authorizationRequest, verificationSessionId: verificationSession.id }
}
