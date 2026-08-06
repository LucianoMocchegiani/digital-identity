import '../askar-native'
import { AgentContext, JsonEncoder, Kms, utils } from '@credo-ts/core'
import { AskarStoreManager } from '@credo-ts/askar'
import {
  Jwk,
  Key,
  SignatureAlgorithm,
  askar,
  type Session,
} from '@openwallet-foundation/askar-shared'

import { DOMAIN_KEY_SCOPE } from '../constants'
import type { KeyManagementService } from './key-management.interface'

const ALG_TO_SIG: Record<string, SignatureAlgorithm> = {
  EdDSA: SignatureAlgorithm.EdDSA,
  Ed25519: SignatureAlgorithm.EdDSA,
  ES256: SignatureAlgorithm.ES256,
  ES256K: SignatureAlgorithm.ES256K,
  ES384: SignatureAlgorithm.ES384,
}

/** CredoError exige `cause?: Error`; el catch tipa `unknown`. */
function asErrorCause(error: unknown): Error | undefined {
  return error instanceof Error ? error : undefined
}

/** Domain-key solo guarda EC/OKP; excluye oct del union público de Credo. */
type DomainPublicJwk = Exclude<Kms.KmsJwkPublic, Kms.KmsJwkPublicOct>

/**
 * Backend Askar con perfil fijo {@link DOMAIN_KEY_SCOPE} para claves de dominio (x5c/EUDI).
 *
 * Una sola copia cifrada, visible desde cualquier tenant porque Credo itera backends
 * hasta que `getPublicKey` encuentra la clave. No usa el profile del `AgentContext`.
 *
 * Registrar como backend adicional junto a `AskarKeyManagementService` (primario).
 */
export class AskarDomainKeyManagementService implements KeyManagementService {
  public static readonly backend = 'askar-domain-key'
  public readonly backend = AskarDomainKeyManagementService.backend

  private profileReady = new WeakMap<object, Promise<void>>()

  /**
   * Solo import/getPublicKey/sign/verify/deleteKey (sin createKey genérico ni encrypt DIDComm).
   */
  public isOperationSupported(
    _agentContext: AgentContext,
    operation: Kms.KmsOperation,
  ): boolean {
    if (operation.operation === 'deleteKey') return true
    if (operation.operation === 'importKey') {
      const jwk = operation.privateJwk
      return jwk.kty === 'EC' || jwk.kty === 'OKP'
    }
    if (operation.operation === 'sign' || operation.operation === 'verify') {
      return ALG_TO_SIG[operation.algorithm] !== undefined
    }
    return false
  }

  public randomBytes(
    _agentContext: AgentContext,
    _options: Kms.KmsRandomBytesOptions,
  ): Kms.KmsRandomBytesReturn {
    throw new Kms.KeyManagementAlgorithmNotSupportedError(
      'randomBytes',
      this.backend,
    )
  }

  public async getPublicKey(
    agentContext: AgentContext,
    keyId: string,
  ): Promise<Kms.KmsJwkPublic | null> {
    const entry = await this.fetchKey(agentContext, keyId)
    if (!entry?.key) return null
    try {
      return this.domainPublicJwkFromKey(entry.key, { kid: keyId })
    } finally {
      entry.key.handle.free()
    }
  }

  public async importKey<JwkPrivate extends Kms.KmsJwkPrivate>(
    agentContext: AgentContext,
    options: Kms.KmsImportKeyOptions<JwkPrivate>,
  ): Promise<Kms.KmsImportKeyReturn<JwkPrivate>> {
    const kid = options.privateJwk.kid ?? utils.uuid()
    const privateJwk = { ...options.privateJwk, kid }
    let key: Key | undefined
    try {
      if (privateJwk.kty !== 'EC' && privateJwk.kty !== 'OKP') {
        throw new Kms.KeyManagementAlgorithmNotSupportedError(
          `kty '${privateJwk.kty}'`,
          this.backend,
        )
      }
      const existing = await this.fetchKey(agentContext, kid)
      if (existing?.key) {
        existing.key.handle.free()
        throw new Kms.KeyManagementKeyExistsError(kid, this.backend)
      }
      key = Key.fromJwk({ jwk: Jwk.fromJson(privateJwk) })
      await this.withDomainSession(agentContext, (session) =>
        session.insertKey({ name: kid, key: key! }),
      )
      const publicJwk = Kms.publicJwkFromPrivateJwk(privateJwk)
      return {
        keyId: kid,
        publicJwk: { ...publicJwk, kid } as Kms.KmsImportKeyReturn<JwkPrivate>['publicJwk'],
      }
    } catch (error) {
      if (error instanceof Kms.KeyManagementError) throw error
      throw new Kms.KeyManagementError('Error importing domain key', {
        cause: asErrorCause(error),
      })
    } finally {
      key?.handle.free()
    }
  }

  public async deleteKey(
    agentContext: AgentContext,
    options: Kms.KmsDeleteKeyOptions,
  ): Promise<boolean> {
    try {
      const existing = await this.fetchKey(agentContext, options.keyId)
      if (!existing) return false
      existing.key?.handle.free()
      await this.withDomainSession(agentContext, (session) =>
        session.removeKey({ name: options.keyId }),
      )
      return true
    } catch (error) {
      throw new Kms.KeyManagementError(
        `Error deleting domain key '${options.keyId}'`,
        { cause: asErrorCause(error) },
      )
    }
  }

  public async createKey(
    _agentContext: AgentContext,
    _options: Kms.KmsCreateKeyOptions,
  ): Promise<Kms.KmsCreateKeyReturn> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('createKey', this.backend)
  }

  public async sign(
    agentContext: AgentContext,
    options: Kms.KmsSignOptions,
  ): Promise<Kms.KmsSignReturn> {
    const { keyId, algorithm, data } = options
    const entry = await this.fetchKeyAsserted(agentContext, keyId)
    try {
      const sigType = this.sigTypeForAlg(algorithm)
      if (!entry.key) {
        throw new Kms.KeyManagementAlgorithmNotSupportedError(
          `algorithm ${algorithm}`,
          this.backend,
        )
      }
      const publicJwk = this.domainPublicJwkFromKey(entry.key, { kid: keyId })
      const privateJwk = this.privateJwkFromKey(entry.key, { kid: keyId })
      Kms.assertAllowedSigningAlgForKey(privateJwk, algorithm)
      Kms.assertKeyAllowsSign(publicJwk)
      const signature = entry.key.signMessage({
        message: new Uint8Array(data),
        sigType,
      })
      return { signature: new Uint8Array(signature) }
    } catch (error) {
      if (error instanceof Kms.KeyManagementError) throw error
      throw new Kms.KeyManagementError('Error signing with domain key', {
        cause: asErrorCause(error),
      })
    } finally {
      entry.key?.handle.free()
    }
  }

  public async verify(
    agentContext: AgentContext,
    options: Kms.KmsVerifyOptions,
  ): Promise<Kms.KmsVerifyReturn> {
    const { algorithm, data, signature, key: keyInput } = options
    const sigType = this.sigTypeForAlg(algorithm)
    let askarKey: Key | undefined
    try {
      if (keyInput.keyId) {
        askarKey = (await this.fetchKeyAsserted(agentContext, keyInput.keyId)).key
      } else if (
        keyInput.publicJwk?.kty === 'EC' ||
        keyInput.publicJwk?.kty === 'OKP'
      ) {
        askarKey = Key.fromJwk({ jwk: Jwk.fromJson(keyInput.publicJwk) })
      } else {
        throw new Kms.KeyManagementAlgorithmNotSupportedError(
          `kty ${keyInput.publicJwk?.kty}`,
          this.backend,
        )
      }
      if (!askarKey) {
        throw new Kms.KeyManagementAlgorithmNotSupportedError(
          `algorithm ${algorithm}`,
          this.backend,
        )
      }
      const keyId = keyInput.keyId ?? keyInput.publicJwk?.kid
      const publicJwk = this.domainPublicJwkFromKey(askarKey, { kid: keyId })
      Kms.assertAllowedSigningAlgForKey(publicJwk, algorithm)
      Kms.assertKeyAllowsVerify(publicJwk)
      if (
        askarKey.verifySignature({
          message: new Uint8Array(data),
          signature: new Uint8Array(signature),
          sigType,
        })
      ) {
        const resolvedPublicJwk = keyInput.keyId
          ? this.domainPublicJwkFromKey(askarKey, { kid: keyId })
          : keyInput.publicJwk
        if (!resolvedPublicJwk) {
          throw new Kms.KeyManagementError('Verify succeeded without a public JWK')
        }
        return { verified: true, publicJwk: resolvedPublicJwk }
      }
      return { verified: false }
    } catch (error) {
      if (error instanceof Kms.KeyManagementError) throw error
      throw new Kms.KeyManagementError('Error verifying with domain key', {
        cause: asErrorCause(error),
      })
    } finally {
      askarKey?.handle.free()
    }
  }

  public async encrypt(
    _agentContext: AgentContext,
    _options: Kms.KmsEncryptOptions,
  ): Promise<Kms.KmsEncryptReturn> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('encrypt', this.backend)
  }

  public async decrypt(
    _agentContext: AgentContext,
    _options: Kms.KmsDecryptOptions,
  ): Promise<Kms.KmsDecryptReturn> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('decrypt', this.backend)
  }

  private sigTypeForAlg(algorithm: string): SignatureAlgorithm {
    const sigType = ALG_TO_SIG[algorithm]
    if (!sigType) {
      throw new Kms.KeyManagementAlgorithmNotSupportedError(
        `algorithm ${algorithm}`,
        this.backend,
      )
    }
    return sigType
  }

  private domainPublicJwkFromKey(key: Key, partial?: { kid?: string }): DomainPublicJwk {
    const publicJwk = Kms.publicJwkFromPrivateJwk(this.privateJwkFromKey(key, partial))
    if (publicJwk.kty === 'oct') {
      throw new Kms.KeyManagementAlgorithmNotSupportedError('kty oct', this.backend)
    }
    return publicJwk
  }

  private privateJwkFromKey(key: Key, partial?: { kid?: string }): Kms.KmsJwkPrivate {
    const { alg: _alg, ...jwkSecret } = JsonEncoder.fromUint8Array(
      askar.keyGetJwkSecret({ localKeyHandle: key.handle }),
    )
    return { ...partial, ...jwkSecret } as Kms.KmsJwkPrivate
  }

  private async ensureDomainProfile(agentContext: AgentContext): Promise<void> {
    const storeManager = agentContext.dependencyManager.resolve(AskarStoreManager)
    let pending = this.profileReady.get(storeManager)
    if (!pending) {
      pending = (async () => {
        const { store } = await storeManager.getInitializedStoreWithProfile(agentContext)
        try {
          await store.createProfile(DOMAIN_KEY_SCOPE)
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error)
          if (!/already exists|duplicate/i.test(message)) {
            throw error
          }
        }
      })()
      this.profileReady.set(storeManager, pending)
    }
    await pending
  }

  private async withDomainSession<T>(
    agentContext: AgentContext,
    callback: (session: Session) => Promise<T> | T,
  ): Promise<T> {
    await this.ensureDomainProfile(agentContext)
    const storeManager = agentContext.dependencyManager.resolve(AskarStoreManager)
    const { store } = await storeManager.getInitializedStoreWithProfile(agentContext)
    const session = await store.session(DOMAIN_KEY_SCOPE).open()
    try {
      return await callback(session)
    } finally {
      if (session.handle) {
        await session.close()
      }
    }
  }

  private async fetchKey(agentContext: AgentContext, keyId: string) {
    return this.withDomainSession(agentContext, async (session) => {
      return session.fetchKey({ name: keyId, forUpdate: false })
    })
  }

  private async fetchKeyAsserted(agentContext: AgentContext, keyId: string) {
    const storageKey = await this.fetchKey(agentContext, keyId)
    if (!storageKey) {
      throw new Kms.KeyManagementKeyNotFoundError(keyId, [this.backend])
    }
    return storageKey
  }
}
