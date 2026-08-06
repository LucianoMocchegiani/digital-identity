import type { Agent } from '@credo-ts/core'
import type {
  OpenId4VciCredentialRequestOptions,
  OpenId4VciCredentialResponse,
  OpenId4VciDeferredCredentialResponse,
  OpenId4VciTokenRequestOptions,
  OpenId4VpAcceptAuthorizationRequestOptions,
  OpenId4VpResolvedAuthorizationRequest,
} from '@credo-ts/openid4vc'

import { OpenId4VcHolderApi } from '@credo-ts/openid4vc'
import { SdJwtVcApi, W3cCredentialsApi, SdJwtVcRecord, W3cCredentialRecord, W3cV2CredentialRecord, W3cV2CredentialsApi } from '@credo-ts/core'
import { buildCredentialBindingResolver } from './binding.resolver'

/** Resultado de un flujo de recepción de credencial OID4VCI. */
export interface ReceiveCredentialResult {
  credentials: OpenId4VciCredentialResponse[]
  deferredCredentials: OpenId4VciDeferredCredentialResponse[]
}

type PresentationRequirementEntry = {
  inputDescriptorId: string
  verifiableCredentials: unknown[]
}

type PresentationRequirement = {
  submissionEntry: PresentationRequirementEntry[]
}

type ResolvedPresentationExchange = {
  credentialsForRequest?: {
    areRequirementsSatisfied?: boolean
    requirements: PresentationRequirement[]
  }
}

type ResolvedDcql = {
  queryResult?: Parameters<OpenId4VcHolderApi['selectCredentialsForDcqlRequest']>[0]
}

type ResolvedAuthorizationRequestLike = {
  authorizationRequestPayload: OpenId4VpResolvedAuthorizationRequest['authorizationRequestPayload']
  presentationExchange?: ResolvedPresentationExchange
  dcql?: ResolvedDcql
}

/**
 * Ejecuta el flujo OID4VCI pre-authorized completo desde el offer URI hasta la credencial almacenada.
 *
 * Pasos internos:
 * 1. Resuelve el credential offer (metadata del issuer + configuraciones de credencial)
 * 2. Solicita el access token (pre-authorized code flow)
 * 3. Solicita las credenciales con `credentialBindingResolver` automático (did:key/did:jwk/JWK)
 * 4. Persiste cada credencial recibida en la wallet del holder
 *
 * @param agent - Agente Credo del holder con `OpenId4VcHolderModule` activo
 * @param offerUri - URI del credential offer (openid-credential-offer://... o URL HTTPS)
 * @returns Credenciales recibidas y pendientes (deferred)
 */
export async function receiveCredentialOffer(
  agent: Agent,
  offerUri: string
): Promise<ReceiveCredentialResult> {
  const holderApi = agent.dependencyManager.resolve(OpenId4VcHolderApi)
  const sdJwtVcApi = agent.dependencyManager.resolve(SdJwtVcApi)
  const w3cCredentialsApi = agent.dependencyManager.resolve(W3cCredentialsApi)
  const w3cV2CredentialsApi = agent.dependencyManager.resolve(W3cV2CredentialsApi)

  const resolvedOffer = await holderApi.resolveCredentialOffer(offerUri)

  const tokenOptions: OpenId4VciTokenRequestOptions = {
    resolvedCredentialOffer: resolvedOffer,
  }

  const { accessToken, dpop } = await holderApi.requestToken(tokenOptions)

  const credentialOptions: OpenId4VciCredentialRequestOptions = {
    resolvedCredentialOffer: resolvedOffer,
    accessToken,
    dpop,
    credentialBindingResolver: buildCredentialBindingResolver(agent),
  }

  const { credentials, deferredCredentials } =
    await holderApi.requestCredentials(credentialOptions)

  for (const { record } of credentials) {
    if (record instanceof SdJwtVcRecord) {
      await sdJwtVcApi.store({ record })
    } else if (record instanceof W3cV2CredentialRecord) {
      await w3cV2CredentialsApi.store({ record })
    } else if (record instanceof W3cCredentialRecord) {
      await w3cCredentialsApi.store({ record })
    }
  }

  return { credentials, deferredCredentials }
}
/**
 * Resuelve un authorization request OID4VP (presentación de credencial).
 *
 * Retorna la request resuelta con las credenciales candidatas para satisfacerla.
 * Usar el resultado para llamar a `acceptPresentationRequest`.
 *
 * @param agent - Agente Credo del holder con `OpenId4VcHolderModule` activo
 * @param requestUri - URI del authorization request del verifier
 * @returns Request resuelta con credenciales candidatas (presentationExchange o dcql)
 */
export async function resolvePresentationRequest(
  agent: Agent,
  requestUri: string
): Promise<OpenId4VpResolvedAuthorizationRequest> {
  const holderApi = agent.dependencyManager.resolve(OpenId4VcHolderApi)

  return holderApi.resolveOpenId4VpAuthorizationRequest(requestUri)
}

/**
 * Acepta y envía una respuesta a un authorization request OID4VP.
 *
 * Debe llamarse tras `resolvePresentationRequest`. Las credenciales seleccionadas
 * deben satisfacer los requisitos del `presentationExchange` o `dcql` de la request resuelta.
 *
 * @param agent - Agente Credo del holder con `OpenId4VcHolderModule` activo
 * @param options - Opciones de aceptación incluyendo credenciales seleccionadas
 * @returns Respuesta del servidor verifier
 */
export async function acceptPresentationRequest(
  agent: Agent,
  options: OpenId4VpAcceptAuthorizationRequestOptions
) {
  const holderApi = agent.dependencyManager.resolve(OpenId4VcHolderApi)

  return holderApi.acceptOpenId4VpAuthorizationRequest(options)
}

/**
 * Selecciona automáticamente las credenciales almacenadas que satisfacen un authorization
 * request OID4VP resuelto, soportando tanto Presentation Exchange como DCQL.
 *
 * Política de selección:
 * - **PE**: toma la primera credencial disponible para cada input descriptor
 * - **DCQL**: usa el `queryResult` directamente (ya contiene las credenciales seleccionadas)
 *
 * @param resolved - Request resuelto retornado por `resolvePresentationRequest`
 * @returns Objeto de credenciales listo para pasar a `acceptPresentationRequest`, o `null`
 *          si ninguna credencial almacenada satisface el request
 */
export function selectCredentialsForRequest(resolved: ResolvedAuthorizationRequestLike):
  | { presentationExchange: { credentials: Record<string, unknown[]> } }
  | { dcql: { credentials: unknown } }
  | null {
  if (resolved.presentationExchange) {
    const credentialsForRequest = resolved.presentationExchange.credentialsForRequest
    if (!credentialsForRequest?.areRequirementsSatisfied) return null

    const credentials: Record<string, unknown[]> = {}
    for (const req of credentialsForRequest.requirements) {
      for (const entry of req.submissionEntry) {
        if (entry.verifiableCredentials.length > 0) {
          credentials[entry.inputDescriptorId] = [entry.verifiableCredentials[0]]
        }
      }
    }
    return { presentationExchange: { credentials } }
  }

  if (resolved.dcql) {
    // queryResult debe procesarse con selectCredentialsForDcqlRequest antes de pasarlo
    // a acceptOpenId4VpAuthorizationRequest — ver submitPresentation para el flujo correcto.
    return null
  }

  return null
}

/**
 * Flujo completo de presentación OID4VP: resolve → auto-selección → accept.
 *
 * Encapsula los tipos complejos de Credo-TS (`OpenId4VpResolvedAuthorizationRequest`,
 * `OpenId4VpAcceptAuthorizationRequestOptions`) que varían según el modo PE/DCQL.
 *
 * @param agent - Agente Credo del holder con `OpenId4VcHolderModule` activo
 * @param requestUri - URI del authorization request del verifier
 * @returns Respuesta del servidor verifier, o `null` si ninguna credencial satisface el request
 */
export async function submitPresentation(
  agent: Agent,
  requestUri: string
): Promise<Awaited<ReturnType<typeof acceptPresentationRequest>> | null> {
  const holderApi = agent.dependencyManager.resolve(OpenId4VcHolderApi)

  const resolved = (await resolvePresentationRequest(agent, requestUri)) as ResolvedAuthorizationRequestLike

  let selection: { presentationExchange: unknown } | { dcql: { credentials: unknown } } | null = null

  if (resolved.presentationExchange) {
    selection = selectCredentialsForRequest(resolved)
  } else if (resolved.dcql) {
    const queryResult = resolved.dcql.queryResult
    if (!queryResult?.can_be_satisfied) return null
    // selectCredentialsForDcqlRequest produce Record<string, DcqlCredentialForRequest[]>
    // que es lo que createPresentation espera como credentialQueryToCredential
    const credentials = holderApi.selectCredentialsForDcqlRequest(queryResult)
    selection = { dcql: { credentials } }
  }

  if (!selection) return null

  return acceptPresentationRequest(agent, {
    authorizationRequestPayload: resolved.authorizationRequestPayload,
    ...selection,
  } as OpenId4VpAcceptAuthorizationRequestOptions)
}

