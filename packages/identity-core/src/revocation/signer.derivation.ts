import type { Agent } from '@credo-ts/core'
import type { SignerMetadata } from './status-list.types'

/**
 * Subset de la entrada `keys` de un `DidRecord` de Credo que usamos para
 * derivar el firmante.
 *
 * El `kmsKeyId` es el ID interno de la clave en el KMS; `didDocumentRelativeKeyId`
 * es el fragmento del DID URL donde Credo la publicó (p. ej. `#key-p256`).
 */
export interface DidRecordKey {
  kmsKeyId: string
  didDocumentRelativeKeyId?: string
}

/**
 * Opciones para la derivación automática de un `SignerMetadata` a partir de un
 * agente Credo.
 *
 * Los `*Override` se aplican solo si están definidos; el resto se deriva del
 * estado real del agente (DID record + KMS público).
 */
export interface SignerDerivationOptions {
  /** Override del algoritmo JWS. Si está definido, se usa tal cual. */
  algOverride?: string
  /** Override del `kid` completo. Si está definido, se usa tal cual. */
  kidOverride?: string
  /** Fragmento del DID URL a usar (con o sin `#`; se normaliza). Default: `key-p256`. */
  keyFragment?: string
  /** Método DID a buscar en el agente. Default: `web`. */
  didMethod?: 'web' | 'key'
}

/**
 * Resuelve la identidad del firmante a partir de un agente Credo, derivando los
 * campos que no estén explícitamente sobreescritos.
 *
 * Estrategia por defecto (sin overrides):
 *  1. Toma el primer DID creado del método `web` (configurable vía `didMethod`).
 *  2. Selecciona la clave del DID según `keyFragment` (default `key-p256` →
 *     siempre la clave primaria P-256 que Credo crea en `did:web`).
 *  3. Deriva el `alg` JWS del JWK público de la clave (P-256 → `ES256`,
 *     Ed25519 → `EdDSA`, etc.); si el JWK ya trae `alg`, se respeta.
 *  4. Construye el `kid` como `${did}#${didDocumentRelativeKeyId}`.
 *
 * Devuelve solo metadata: el `kms` del `SignerOptions` lo completa el consumer,
 * porque el core firma después de que esta función retorna y el `agent.kms` de
 * un tenant deja de ser usable en cuanto se cierra su sesión.
 *
 * Es la implementación de referencia para un `SignerProvider` que trabaja con
 * un agente Credo: cualquier consumer con un agente puede invocarla sin tener
 * que reproducir la lógica de derivación.
 *
 * @param agent - Agente Credo (raíz o de un tenant) del que extraer el firmante.
 * @param options - Overrides opcionales. Si están vacíos, todo se deriva.
 * @returns `SignerMetadata` (DID, keyId, kid, alg) sin el KMS.
 * @throws Si el agente no tiene un DID del método pedido o no hay clave KMS
 *   coincidente con el fragmento.
 */
export async function resolveSignerFromAgent(
  agent: Agent,
  options: SignerDerivationOptions = {},
): Promise<SignerMetadata> {
  const didMethod = options.didMethod ?? 'web'

  const records = await agent.dids.getCreatedDids({ method: didMethod })
  const record = records[0]
  if (!record?.did) {
    throw new Error(`No DID found in agent (method=${didMethod})`)
  }

  const key = pickDidRecordKey(record.keys as DidRecordKey[] | undefined, options.keyFragment)
  if (!key?.kmsKeyId) {
    throw new Error(
      `No matching KMS key for DID ${record.did}` +
        (options.keyFragment ? ` (fragment=${options.keyFragment})` : ''),
    )
  }

  const alg = options.algOverride ?? (await deriveAlgFromKms(agent, key.kmsKeyId))
  const relativeKeyId = key.didDocumentRelativeKeyId ?? '#key-p256'
  const kid = options.kidOverride ?? `${record.did}${relativeKeyId}`

  return {
    did: record.did,
    keyId: key.kmsKeyId,
    kid,
    alg,
  }
}

/**
 * Elige la clave del `DidRecord` que matchea `fragment` (si se pasa) o
 * toma la primera si no se pasa.
 *
 * El fragment puede venir con o sin `#`; se normaliza para hacer match
 * exacto contra `didDocumentRelativeKeyId` (que Credo siempre guarda con `#`).
 * Si no hay match exacto, se hace fallback a la primera clave para no romper
 * tenants que no usan la convención de Credo (ej. DIDs creados con
 * registrars custom).
 *
 * Exportada para que un consumer pueda componer su propia lógica de
 * selección sin reimplementar el matching.
 */
export function pickDidRecordKey(
  keys: DidRecordKey[] | undefined,
  fragment: string | undefined,
): DidRecordKey | undefined {
  if (!keys?.length) return undefined

  if (!fragment) return keys[0]

  const normalized = fragment.startsWith('#') ? fragment : `#${fragment}`
  return keys.find((k) => k.didDocumentRelativeKeyId === normalized) ?? keys[0]
}

/**
 * Deriva el algoritmo JWS (`alg`) del JWK público de una clave KMS.
 *
 * Si el JWK ya trae `alg` (lo cual ocurre cuando se importó con un
 * algoritmo específico), se respeta. Si no, se mapea por `kty` + `crv`:
 *
 * | `kty` | `crv`       | `alg`    |
 * |-------|-------------|----------|
 * | `EC`  | `P-256`     | `ES256`  |
 * | `EC`  | `P-384`     | `ES384`  |
 * | `EC`  | `P-521`     | `ES512`  |
 * | `EC`  | `secp256k1` | `ES256K` |
 * | `OKP` | `Ed25519`   | `EdDSA`  |
 *
 * @throws Si la clave no existe en el KMS o su tipo no es soportado para
 *   firma (p. ej. `oct` o `OKP/X25519`).
 */
export async function deriveAlgFromKms(agent: Agent, keyId: string): Promise<string> {
  const publicJwk = await agent.kms.getPublicKey({ keyId })
  if (!publicJwk) {
    throw new Error(`No public key found in KMS for keyId=${keyId}`)
  }

  if ('alg' in publicJwk && typeof publicJwk.alg === 'string' && publicJwk.alg.length > 0) {
    return publicJwk.alg
  }

  const jwk = publicJwk as { kty: string; crv?: string }

  if (jwk.kty === 'EC') {
    if (jwk.crv === 'P-256') return 'ES256'
    if (jwk.crv === 'P-384') return 'ES384'
    if (jwk.crv === 'P-521') return 'ES512'
    if (jwk.crv === 'secp256k1') return 'ES256K'
  }
  if (jwk.kty === 'OKP' && jwk.crv === 'Ed25519') return 'EdDSA'

  throw new Error(
    `Cannot derive signing algorithm from keyId=${keyId}: unsupported kty=${jwk.kty}, crv=${jwk.crv}`,
  )
}
