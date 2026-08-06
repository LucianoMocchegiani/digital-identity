import { AgentContext, Kms, utils } from '@credo-ts/core'
import { Bls12381G2KeyPair } from '@mattrglobal/bls12381-key-pair'
import { Pool } from 'pg'

import type { KeyManagementService } from './key-management.interface'
import { withRetry } from '../utils/retry'

/** JWK interno Quark para Bls12381G2 (no es kty JWA estándar). */
interface Bls12381G2PublicJwk {
  kty: 'OKP'
  crv: 'Bls12381G2'
  x: string
  kid?: string
  publicKeyBase58?: string
}

interface Bls12381G2PrivateJwk extends Bls12381G2PublicJwk {
  d: string
  privateKeyBase58?: string
}

interface StoredBbsKey {
  publicJwk: Bls12381G2PublicJwk
  privateJwk: Bls12381G2PrivateJwk
}

function isBls12381G2CreateType(type: {
  kty?: string
  crv?: string
  keyType?: string
}): boolean {
  return (
    type.keyType === 'Bls12381G2' ||
    (type.kty === 'OKP' && type.crv === 'Bls12381G2')
  )
}

/**
 * Sidecar KMS solo para Bls12381G2 (BBS+ / selective disclosure JSON-LD).
 *
 * Askar 0.7 no soporta BLS; Credo valida `createKey` con Zod y rechaza este tipo.
 * Usar vía `createBls12381G2Key` / `getBls12381G2KeyPair` (`bbs-kms.ts`), no
 * `agent.kms.createKey` genérico.
 *
 * Persiste en la tabla Postgres `keys` (texto plano). Producto Quark: registrar
 * en `additionalKeyManagementServices` junto a Askar primario.
 */
export class BbsKeyManagementService implements KeyManagementService {
  public static readonly backend = 'bbs-postgres'
  public readonly backend = BbsKeyManagementService.backend

  private ready: Promise<void>

  /**
   * @param pool - Pool Postgres del servicio (misma `DATABASE_URL` que Askar/StatusList)
   */
  constructor(private readonly pool: Pool) {
    this.ready = withRetry(() => this.initialize(), {
      attempts: 10,
      baseDelayMs: 2_000,
      maxDelayMs: 15_000,
      label: '[BbsKeyManagementService]',
      shouldRetry: (err) => {
        const pgErr = err as { code?: string }
        return pgErr?.code !== '42P07' && pgErr?.code !== '23505'
      },
    }).catch((err) => {
      console.error(
        '[BbsKeyManagementService] initialization failed after all retries:',
        err?.message ?? err,
      )
    })
  }

  private async initialize(): Promise<void> {
    try {
      await this.pool.query(`
        CREATE TABLE IF NOT EXISTS keys (
          id          TEXT PRIMARY KEY,
          public_jwk  TEXT NOT NULL,
          private_jwk TEXT NOT NULL
        )
      `)
    } catch (err: unknown) {
      const pgErr = err as { code?: string }
      if (pgErr?.code !== '42P07' && pgErr?.code !== '23505') {
        throw err
      }
    }
    await this.pool.query(
      `ALTER TABLE keys ADD COLUMN IF NOT EXISTS wallet_id TEXT NOT NULL DEFAULT ''`,
    )
    await this.pool.query(
      `CREATE INDEX IF NOT EXISTS keys_wallet_id_idx ON keys(wallet_id)`,
    )
  }

  private async getKey(walletId: string, keyId: string): Promise<StoredBbsKey | null> {
    await this.ready
    const { rows } = await this.pool.query<{ public_jwk: string; private_jwk: string }>(
      'SELECT public_jwk, private_jwk FROM keys WHERE id = $1 AND wallet_id = $2 LIMIT 1',
      [keyId, walletId],
    )
    if (!rows.length) return null
    return {
      publicJwk: JSON.parse(rows[0].public_jwk) as Bls12381G2PublicJwk,
      privateJwk: JSON.parse(rows[0].private_jwk) as Bls12381G2PrivateJwk,
    }
  }

  private async saveKey(
    walletId: string,
    keyId: string,
    publicJwk: Bls12381G2PublicJwk,
    privateJwk: Bls12381G2PrivateJwk,
  ): Promise<void> {
    await this.ready
    await this.pool.query(
      `INSERT INTO keys (id, wallet_id, public_jwk, private_jwk)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (id) DO UPDATE SET
         wallet_id = EXCLUDED.wallet_id,
         public_jwk = EXCLUDED.public_jwk,
         private_jwk = EXCLUDED.private_jwk`,
      [keyId, walletId, JSON.stringify(publicJwk), JSON.stringify(privateJwk)],
    )
  }

  /**
   * Solo createKey Bls12381G2 y deleteKey. El resto lo resuelve Askar (u otro primario).
   */
  public isOperationSupported(
    _agentContext: AgentContext,
    operation: Kms.KmsOperation,
  ): boolean {
    if (operation.operation === 'createKey') {
      const type = (operation as Record<string, unknown>).type as
        | { kty?: string; crv?: string; keyType?: string }
        | undefined
      return !!type && isBls12381G2CreateType(type)
    }
    if (operation.operation === 'deleteKey') return true
    return false
  }

  public async getPublicKey(
    agentContext: AgentContext,
    keyId: string,
  ): Promise<Kms.KmsJwkPublic | null> {
    const entry = await this.getKey(agentContext.contextCorrelationId, keyId)
    return entry ? (entry.publicJwk as unknown as Kms.KmsJwkPublic) : null
  }

  public async createKey<Type extends Kms.KmsCreateKeyType>(
    agentContext: AgentContext,
    options: Kms.KmsCreateKeyOptions<Type>,
  ): Promise<Kms.KmsCreateKeyReturn<Type>> {
    const type = options.type as { kty?: string; crv?: string; keyType?: string }
    if (!isBls12381G2CreateType(type)) {
      throw new Kms.KeyManagementAlgorithmNotSupportedError(
        `createKey ${type.keyType ?? type.crv ?? type.kty}`,
        this.backend,
      )
    }

    const kid = options.keyId ?? utils.uuid()
    const wid = agentContext.contextCorrelationId
    const keyPair = await Bls12381G2KeyPair.generate()
    const publicKeyBase58 = keyPair.publicKey
    const privateKeyBase58 = keyPair.privateKey
    if (!privateKeyBase58) {
      throw new Kms.KeyManagementError(
        'Bls12381G2KeyPair.generate did not return a private key',
      )
    }

    const publicJwk: Bls12381G2PublicJwk = {
      kty: 'OKP',
      crv: 'Bls12381G2',
      x: Buffer.from(keyPair.publicKeyBuffer).toString('base64url'),
      kid,
      publicKeyBase58,
    }
    const privateJwk: Bls12381G2PrivateJwk = {
      ...publicJwk,
      d: Buffer.from(keyPair.privateKeyBuffer ?? []).toString('base64url'),
      privateKeyBase58,
    }
    await this.saveKey(wid, kid, publicJwk, privateJwk)
    return {
      keyId: kid,
      publicJwk,
      publicKeyBase58,
    } as unknown as Kms.KmsCreateKeyReturn<Type>
  }

  /**
   * Reconstruye el key pair MATTR desde material en Postgres (firma LD BBS).
   *
   * @throws {KeyManagementError} Si la clave no existe o no es Bls12381G2
   */
  public async getBls12381G2KeyPair(
    agentContext: AgentContext,
    keyId: string,
  ): Promise<Bls12381G2KeyPair> {
    const entry = await this.getKey(agentContext.contextCorrelationId, keyId)
    if (!entry) throw new Kms.KeyManagementError(`Key ${keyId} not found`)
    if (entry.privateJwk.crv !== 'Bls12381G2') {
      throw new Kms.KeyManagementError(`Key ${keyId} is not Bls12381G2`)
    }
    const publicKeyBase58 =
      entry.privateJwk.publicKeyBase58 ?? entry.publicJwk.publicKeyBase58
    const privateKeyBase58 = entry.privateJwk.privateKeyBase58
    if (!publicKeyBase58 || !privateKeyBase58) {
      throw new Kms.KeyManagementError(`Key ${keyId} missing BLS Base58 material`)
    }
    return Bls12381G2KeyPair.from({
      id: keyId,
      publicKeyBase58,
      privateKeyBase58,
    })
  }

  public async importKey<Jwk extends Kms.KmsJwkPrivate>(
    _agentContext: AgentContext,
    _options: Kms.KmsImportKeyOptions<Jwk>,
  ): Promise<Kms.KmsImportKeyReturn<Jwk>> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('importKey', this.backend)
  }

  public async deleteKey(
    agentContext: AgentContext,
    options: Kms.KmsDeleteKeyOptions,
  ): Promise<boolean> {
    await this.ready
    const { rowCount } = await this.pool.query(
      'DELETE FROM keys WHERE id = $1 AND wallet_id = $2',
      [options.keyId, agentContext.contextCorrelationId],
    )
    return (rowCount ?? 0) > 0
  }

  public async sign(
    _agentContext: AgentContext,
    _options: Kms.KmsSignOptions,
  ): Promise<Kms.KmsSignReturn> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('sign', this.backend)
  }

  public async verify(
    _agentContext: AgentContext,
    _options: Kms.KmsVerifyOptions,
  ): Promise<Kms.KmsVerifyReturn> {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('verify', this.backend)
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

  public randomBytes(
    _agentContext: AgentContext,
    _options: Kms.KmsRandomBytesOptions,
  ): Kms.KmsRandomBytesReturn {
    throw new Kms.KeyManagementAlgorithmNotSupportedError('randomBytes', this.backend)
  }
}
