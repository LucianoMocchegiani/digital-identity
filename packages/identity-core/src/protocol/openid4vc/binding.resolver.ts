import type { Agent } from '@credo-ts/core'
import type { OpenId4VciCredentialBindingResolver } from '@credo-ts/openid4vc'

/**
 * Construye el `credentialBindingResolver` para el holder en flujos OID4VCI.
 *
 * Este callback es invocado por Credo-TS al llamar a `agent.openId4VcHolder.requestCredentials()`.
 * Selecciona el key type según los algoritmos del issuer (`EdDSA` → Ed25519, otro → P-256)
 * y el método de binding en orden de preferencia:
 *
 * 1. `did:key` — si el issuer declara soporte explícito para `did:key`
 * 2. `did:jwk` — fallback universal, siempre disponible sin infraestructura externa
 *
 * El resultado queda embebido en el claim `cnf` de la credencial SD-JWT emitida,
 * vinculando criptográficamente la credencial a la clave privada del holder.
 *
 * @param agent - Agente Credo del holder, usado para crear claves y DIDs
 * @returns Resolver de binding listo para pasar a `requestCredentials()`
 */
export function buildCredentialBindingResolver(agent: Agent): OpenId4VciCredentialBindingResolver {
  return async ({ supportedDidMethods, proofTypes }) => {
    const algorithms = proofTypes.jwt?.supportedSignatureAlgorithms ?? []
    // Respeta el orden declarado por el issuer: usa el primer algoritmo de la lista.
    const keyType = algorithms[0] === 'EdDSA'
      ? { kty: 'OKP' as const, crv: 'Ed25519' as const }
      : { kty: 'EC' as const, crv: 'P-256' as const }

    if (supportedDidMethods?.includes('did:key')) {
      const result = await agent.dids.create({
        method: 'key',
        options: { createKey: { type: keyType } },
      })
      const verificationMethodId = result.didState.didDocument?.verificationMethod?.[0]?.id
      if (verificationMethodId) {
        return { method: 'did', didUrls: [verificationMethodId] }
      }
    }

    const result = await agent.dids.create({
      method: 'jwk',
      options: { createKey: { type: keyType } },
    })
    const did = result.didState?.did
    if (!did) throw new Error(`Failed to create did:jwk for credential binding: ${JSON.stringify(result.didState)}`)
    return { method: 'did', didUrls: [`${did}#0`] }
  }
}
