import type { ResolvedResource } from './protocol-resource'
import { getHolderSigningKey, saveCredential } from './wallet-storage'
import { verifySdJwtSignature } from './credential-verification'

const grantType = 'urn:ietf:params:oauth:grant-type:pre-authorized_code'
const maxResponseBytes = 512_000

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function base64url(value: Uint8Array): string {
  let binary = ''
  for (const byte of value) binary += String.fromCharCode(byte)
  return btoa(binary).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
}

function jsonBase64url(value: unknown): string {
  return base64url(new TextEncoder().encode(JSON.stringify(value)))
}

async function post(url: string, body: BodyInit, contentType: string, bearer?: string): Promise<Record<string, unknown>> {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': contentType,
      Accept: 'application/json',
      ...(bearer ? { Authorization: `Bearer ${bearer}` } : {}),
    },
    body,
    credentials: 'omit',
    cache: 'no-store',
    redirect: 'error',
  })
  const text = await response.text()
  if (new TextEncoder().encode(text).byteLength > maxResponseBytes) throw new Error('La respuesta del emisor supera el tamaño permitido.')
  if (!response.ok) throw new Error(`El emisor rechazó la emisión (HTTP ${response.status}).`)
  let value: unknown
  try {
    value = JSON.parse(text)
  } catch {
    throw new Error('El emisor devolvió una respuesta inválida.')
  }
  if (!isRecord(value)) throw new Error('El emisor devolvió una respuesta inválida.')
  return value
}

function assertSupportedConfiguration(resource: Extract<ResolvedResource, { kind: 'issue' }>, id: string): Record<string, unknown> {
  const configuration = resource.supportedConfigurations[id]
  if (!configuration || configuration.format !== 'dc+sd-jwt') throw new Error(`La configuración ${id} no es SD-JWT compatible.`)
  const proofTypes = configuration.proof_types_supported
  const jwtProof = isRecord(proofTypes) ? proofTypes.jwt : undefined
  const algorithms = isRecord(jwtProof) ? jwtProof.proof_signing_alg_values_supported : undefined
  if (!Array.isArray(algorithms) || !algorithms.includes('ES256')) throw new Error(`La configuración ${id} no admite proofs ES256.`)
  const bindingMethods = configuration.cryptographic_binding_methods_supported
  if (!Array.isArray(bindingMethods) || !bindingMethods.includes('jwk')) throw new Error(`La configuración ${id} no admite binding JWK.`)
  return configuration
}

function validSdJwt(value: unknown): value is string {
  if (typeof value !== 'string') return false
  const issuerJwt = value.split('~', 1)[0]
  const parts = issuerJwt.split('.')
  return parts.length === 3 && parts.every(Boolean)
}

export async function issuePreAuthorizedCredential(
  resource: Extract<ResolvedResource, { kind: 'issue' }>,
  txCode?: string,
): Promise<{ count: number; verifiedCount: number }> {
  if (!resource.hasPreAuthorizedCode || !resource.preAuthorizedCode || !resource.tokenEndpoint) {
    throw new Error('La oferta no tiene un grant preautorizado compatible.')
  }
  if (resource.txCode && !txCode) throw new Error('Ingresá el código de transacción requerido por el issuer.')

  for (const id of resource.credentialConfigurationIds) assertSupportedConfiguration(resource, id)
  const signingKey = await getHolderSigningKey()
  const form = new URLSearchParams({
    grant_type: grantType,
    'pre-authorized_code': resource.preAuthorizedCode,
    ...(txCode ? { tx_code: txCode } : {}),
  })
  const token = await post(resource.tokenEndpoint, form, 'application/x-www-form-urlencoded')
  if (typeof token.access_token !== 'string' || !token.access_token || typeof token.token_type !== 'string' || token.token_type.toLowerCase() !== 'bearer') {
    throw new Error('El token endpoint no devolvió un access token Bearer válido.')
  }

  let saved = 0
  let verified = 0
  for (const id of resource.credentialConfigurationIds) {
    const configuration = resource.supportedConfigurations[id]
    const payload = {
      aud: resource.credentialIssuer.replace(/\/$/, ''),
      iat: Math.floor(Date.now() / 1000),
      ...(typeof token.c_nonce === 'string' && token.c_nonce ? { nonce: token.c_nonce } : {}),
    }
    const header = { alg: 'ES256', typ: 'openid4vci-proof+jwt', jwk: signingKey.publicJwk }
    const signingInput = `${jsonBase64url(header)}.${jsonBase64url(payload)}`
    const signature = new Uint8Array(await crypto.subtle.sign(
      { name: 'ECDSA', hash: 'SHA-256' },
      signingKey.privateKey,
      new TextEncoder().encode(signingInput),
    ))
    const proof = `${signingInput}.${base64url(signature)}`
    const credentialResponse = await post(resource.credentialEndpoint, JSON.stringify({
      credential_configuration_id: id,
      format: configuration.format,
      proof: { proof_type: 'jwt', jwt: proof },
    }), 'application/json', token.access_token)

    if (typeof credentialResponse.credential !== 'string' || !validSdJwt(credentialResponse.credential)) {
      throw new Error('La respuesta no contiene una credencial SD-JWT válida para guardar.')
    }
    const vct = typeof configuration.vct === 'string' ? configuration.vct : undefined
    try {
      await verifySdJwtSignature(credentialResponse.credential, resource.credentialIssuer, vct)
      await saveCredential(credentialResponse.credential, `${id} · firma ES256 verificada`)
      verified++
    } catch (cause) {
      await saveCredential(credentialResponse.credential, `${id} · firma no verificada`)
      throw new Error(`La credencial se guardó cifrada, pero no se pudo verificar la firma: ${cause instanceof Error ? cause.message : 'error desconocido'}`)
    }
    saved++
  }
  return { count: saved, verifiedCount: verified }
}
