import { AgentContext, DidRepository, Kms } from '@credo-ts/core'
import type { Agent, DidDocument } from '@credo-ts/core'
import {
  WEB_DID_KEY_BBS_LDP_FRAGMENT,
  WEB_DID_KEY_ED25519_JWK_FRAGMENT,
  WEB_DID_KEY_ED25519_LDP_FRAGMENT,
  type WebDidCreateOptions,
} from './registrar/web.registrar'
import { tryResolveBls12381G2KeyBackend } from '../kms/bbs-kms'

export interface EnsureWebDidOptions {
  /** Dominio público del agente (ej. `issuer.quarkid.com`). */
  domain: string
  /** Tipo de clave primaria (`#key-p256`). Por defecto P-256. */
  keyType?: WebDidCreateOptions['options']['keyType']
  /** Endpoint DIDComm (ws:// o https://) para el campo `service` del DID Document. */
  didcommEndpoint?: string
  /**
   * Agrega `#key-ed25519-jwk` (Ed25519 / JsonWebKey2020) para fallback EdDSA en formato JWK.
   * No requerido cuando OID4VC usa ES256 (default).
   */
  addEd25519Key?: boolean
  /**
   * Agrega `#key-ed25519-ldp` (Ed25519VerificationKey2018) para LDP / `Ed25519Signature2018`
   * y el servicio DIDComm (`recipientKeys`). El sufijo `-ldp` es por formato de credencial, no por el canal.
   */
  addDidCommKey?: boolean
  /**
   * Agrega `#key-bbs-ldp` (Bls12381G2Key2020) para `BbsBlsSignature2020` (QUARK-990).
   * Por defecto `true` en bootstrap de issuer.
   */
  addBbsKey?: boolean
}

export interface EnsureWebDidResult {
  did: string
  didDocument: DidDocument
}

/**
 * Obtiene o crea el DID `did:web:{domain}` del agente y retorna el DID Document almacenado.
 *
 * Si ya existe un DID `did:web` creado y su clave KMS es válida, lo retorna directamente.
 * Si la clave KMS se perdió (wallet efímero reiniciado), elimina el registro local y crea uno nuevo.
 * A diferencia de `ensureDid`, no usa reintentos — `did:web` no depende de servicios externos.
 *
 * @param agent - Instancia del agente Credo-TS inicializado
 * @param options - Dominio público y tipo de clave opcional
 * @returns DID y DID Document listos para servir en `/.well-known/did.json`
 * @throws {Error} Si la creación del DID falla
 */
export async function ensureWebDid(
  agent: Agent,
  options: EnsureWebDidOptions
): Promise<EnsureWebDidResult> {
  const targetDid = `did:web:${options.domain}`

  const created = await agent.dids.getCreatedDids({ method: 'web' })
  const existing = created.find((r) => r.did === targetDid)

  const hasMethodRef = (methods: unknown[] | undefined, fragment: string) =>
    (methods ?? []).some((method) => {
      const id = typeof method === 'string' ? method : (method as { id?: string } | undefined)?.id
      return id?.endsWith(fragment)
    })

  const hasDidCommV1Service = (doc: { service?: unknown[] } | undefined) =>
    (doc?.service ?? []).some(
      (svc) =>
        typeof svc === 'object' &&
        svc !== null &&
        (svc as { type?: string }).type === 'did-communication',
    )

  if (existing) {
    const keyId = existing.keys?.[0]?.kmsKeyId
    if (keyId) {
      try {
        await agent.kms.getPublicKey({ keyId })
        if (!existing.didDocument) {
          throw new Error(`DID ${targetDid} existe pero no tiene DID Document almacenado`)
        }

        const mustRecreateBecauseEd25519Missing =
          !!options.addEd25519Key &&
          !hasMethodRef(existing.didDocument.authentication, WEB_DID_KEY_ED25519_JWK_FRAGMENT)

        const mustRecreateBecauseDidCommAssertionMissing =
          !!options.addDidCommKey &&
          !hasMethodRef(existing.didDocument.assertionMethod, WEB_DID_KEY_ED25519_LDP_FRAGMENT)

        const mustRecreateBecauseDidCommServiceMissing =
          !!options.didcommEndpoint &&
          !!options.addDidCommKey &&
          !hasDidCommV1Service(existing.didDocument)

        const canAddBbsKey = !!tryResolveBls12381G2KeyBackend(agent.context)

        const mustRecreateBecauseBbsMissing =
          options.addBbsKey !== false &&
          canAddBbsKey &&
          !hasMethodRef(existing.didDocument.assertionMethod, WEB_DID_KEY_BBS_LDP_FRAGMENT)

        if (
          mustRecreateBecauseEd25519Missing ||
          mustRecreateBecauseDidCommAssertionMissing ||
          mustRecreateBecauseDidCommServiceMissing ||
          mustRecreateBecauseBbsMissing
        ) {
          const ctx = agent.dependencyManager.resolve(AgentContext)
          const didRepo = agent.dependencyManager.resolve(DidRepository)
          await didRepo.deleteById(ctx, existing.id)
        } else {
          return { did: existing.did, didDocument: existing.didDocument }
        }
      } catch (e) {
        if (e instanceof Kms.KeyManagementKeyNotFoundError) {
          const ctx = agent.dependencyManager.resolve(AgentContext)
          const didRepo = agent.dependencyManager.resolve(DidRepository)
          await didRepo.deleteById(ctx, existing.id)
        } else {
          throw e
        }
      }
    }
  }

  const result = await agent.dids.create<WebDidCreateOptions>({
    method: 'web',
    options: {
      domain: options.domain,
      keyType: options.keyType,
      didcommEndpoint: options.didcommEndpoint,
      addEd25519Key: options.addEd25519Key,
      addDidCommKey: options.addDidCommKey,
      addBbsKey: options.addBbsKey !== false,
    },
  })

  if (result.didState.state !== 'finished' || !result.didState.did || !result.didState.didDocument) {
    const reason = (result.didState as { reason?: string }).reason ?? 'unknown'
    throw new Error(`Error al crear did:web:${options.domain}: ${reason}`)
  }

  return {
    did: result.didState.did,
    didDocument: result.didState.didDocument,
  }
}
