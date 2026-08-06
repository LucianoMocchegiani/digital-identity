import type { Agent, DidDocument } from '@credo-ts/core'
import { AgentContext, DidRepository, Kms } from '@credo-ts/core'
import { withRetry } from '../utils/retry'

export interface EnsureDidOptions {
  method: 'custom'
  vdrServiceUrl: string
  /** Número máximo de intentos para la creación del DID (default: 10). */
  attempts?: number
  /** Delay base en ms entre reintentos (default: 5000). */
  baseDelayMs?: number
  /** Delay máximo en ms entre reintentos (default: 30000). */
  maxDelayMs?: number
}

async function tryEnsureDid(agent: Agent, options: EnsureDidOptions): Promise<string> {
  const created = await agent.dids.getCreatedDids({ method: options.method })
  if (created.length > 0) {
    const rec = created[0]
    const keyId = rec.keys?.[0]?.kmsKeyId
    if (keyId) {
      try {
        await agent.kms.getPublicKey({ keyId })
        return rec.did
      } catch (e) {
        if (e instanceof Kms.KeyManagementKeyNotFoundError) {
          const ctx = agent.dependencyManager.resolve(AgentContext)
          const didRepo = agent.dependencyManager.resolve(DidRepository)
          await didRepo.deleteById(ctx, rec.id)
          await fetch(`${options.vdrServiceUrl.replace(/\/$/, '')}/did/delete`, {
            method: 'POST',
            headers: { 'content-type': 'application/json' },
            body: JSON.stringify({ id: rec.did }),
          }).catch(() => undefined)
        } else {
          throw e
        }
      }
    }
  }

  const result = await agent.dids.create({
    method: options.method,
    options: {},
  })
  const did = result.didState?.did ?? (result as { did?: string }).did
  if (!did) {
    const reason = (result.didState as { reason?: string })?.reason ?? 'unknown'
    throw new Error(`Failed to create DID: ${reason}`)
  }
  return did
}

/**
 * Retorna el DID URL de la clave de firma OID4VP.
 *
 * Prioriza `#key-p256` (P-256/ES256) para compatibilidad con EUDI.
 * Cae a `#key-ed25519` (Ed25519/EdDSA) y luego a `#key-didcomm` como fallback.
 *
 * @param didDocument - DID Document del agente verifier
 * @returns DID URL de la clave de firma OID4VP
 * @throws {Error} Si no existe ninguna clave soportada en el DID Document
 */
export function getOid4VpSigningDidUrl(didDocument: DidDocument): string {
  const assertionMethods = didDocument.assertionMethod ?? []

  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-p256')) return id
  }

  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-ed25519')) return id
  }

  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-didcomm')) return id
  }

  throw new Error(
    'No se encontró clave OID4VP compatible (#key-p256, #key-ed25519 o #key-didcomm) en DID Document.'
  )
}

/**
 * Retorna el DID URL de la clave Ed25519 opcional (`#key-ed25519`).
 *
 * Usada como fallback EdDSA cuando el issuer declara soporte para EdDSA además de ES256.
 *
 * @param didDocument - DID Document del agente issuer
 * @returns DID URL de la clave Ed25519
 * @throws {Error} Si `#key-ed25519` no existe — el agente fue inicializado sin `addEd25519Key: true`
 */
export function getOid4VcSigningDidUrl(didDocument: DidDocument): string {
  const assertionMethods = didDocument.assertionMethod ?? []
  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-ed25519')) return id
  }
  throw new Error(
    'Clave Ed25519 (#key-ed25519) no encontrada en el DID Document. ' +
    'Asegurate de inicializar el agente con addEd25519Key: true.'
  )
}

/**
 * Retorna el DID URL de la clave de firma OID4VC para el algoritmo indicado.
 *
 * - `ES256` → `#key-p256` (P-256)
 * - `EdDSA` → `#key-ed25519` (Ed25519)
 *
 * @param didDocument - DID Document del agente issuer
 * @param alg - Algoritmo de firma (`'EdDSA'` o `'ES256'`)
 * @returns DID URL de la clave correspondiente
 * @throws {Error} Si no existe la clave requerida en el DID Document
 */
export function getOid4VcSigningDidUrlForAlg(didDocument: DidDocument, alg: 'ES256' | 'EdDSA'): string {
  if (alg === 'EdDSA') return getOid4VcSigningDidUrl(didDocument)

  const assertionMethods = didDocument.assertionMethod ?? []
  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-p256')) return id
  }
  throw new Error(
    'Clave ES256 (#key-p256) no encontrada en el DID Document. ' +
    'Asegurate de que el agente está inicializado con una clave P-256 (#key-p256).'
  )
}

/**
 * Retorna el DID URL de la clave de firma DIDComm (`#key-didcomm`).
 *
 * Busca en `assertionMethod` la entrada con fragment `#key-didcomm`, que corresponde a la
 * clave Ed25519 en formato Ed25519VerificationKey2018 generada para firmar credenciales
 * JSON-LD en DIDComm.
 *
 * @param didDocument - DID Document del agente issuer
 * @returns DID URL de la clave DIDComm
 * @throws {Error} Si `#key-didcomm` no existe en el DID Document — indica que el agente fue
 *   inicializado sin `addDidCommKey: true`
 */
export function getDidCommSigningDidUrl(didDocument: DidDocument): string {
  const assertionMethods = didDocument.assertionMethod ?? []
  for (const method of assertionMethods) {
    const id = typeof method === 'string' ? method : method?.id
    if (id?.endsWith('#key-didcomm')) return id
  }
  throw new Error(
    'Clave DIDComm (#key-didcomm) no encontrada en el DID Document. ' +
    'Asegurate de inicializar el agente con addDidCommKey: true.'
  )
}

/**
 * Obtiene o crea el DID del agente para el método indicado, con reintentos y backoff exponencial.
 * Si el DID ya existe pero la clave KMS se perdió, elimina el registro local y en el VDR,
 * luego crea uno nuevo. Útil al reiniciar el agente con almacenamiento efímero.
 *
 * @param agent - Instancia del agente Credo-TS inicializado.
 * @param options - Opciones de método, VDR y configuración de reintentos.
 * @returns El DID del agente (ej. `did:custom:xxxx`).
 * @throws {Error} Si se agotan todos los intentos sin poder crear o recuperar el DID.
 */
export async function ensureDid(agent: Agent, options: EnsureDidOptions): Promise<string> {
  return withRetry(() => tryEnsureDid(agent, options), {
    attempts: options.attempts ?? 10,
    baseDelayMs: options.baseDelayMs ?? 5_000,
    maxDelayMs: options.maxDelayMs ?? 30_000,
    label: '[EnsureDid]',
  })
}
