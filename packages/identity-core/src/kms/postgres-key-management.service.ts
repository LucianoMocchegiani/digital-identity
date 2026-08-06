import { AgentContext, Kms, utils } from '@credo-ts/core'
import type { KeyManagementService } from './key-management.interface'
import { DOMAIN_KEY_SCOPE } from '../constants'

import {
  randomBytes,
  generateKeyPairSync,
  createPrivateKey,
  createPublicKey,
  diffieHellman,
  createHash,
  sign,
  createCipheriv,
  createDecipheriv,
  type JsonWebKey,
} from 'crypto'
import nacl from 'tweetnacl'
import * as ed2curve from 'ed2curve'
import { Pool } from 'pg'
import { Bls12381G2KeyPair } from '@mattrglobal/bls12381-key-pair'
import { withRetry } from '../utils/retry'

interface Ed25519PublicJwk {
  kty: 'OKP'
  crv: 'Ed25519'
  x: string
  kid?: string
}

interface Ed25519PrivateJwk extends Ed25519PublicJwk {
  d: string
}

interface P256PublicJwk {
  kty: 'EC'
  crv: 'P-256'
  x: string
  y: string
  kid?: string
}

interface P256PrivateJwk extends P256PublicJwk {
  d: string
}

/** JWK interno para claves BLS12-381 G2 (no es un kty JWA estándar; solo storage Quark). */
interface Bls12381G2PublicJwk {
  kty: 'OKP'
  crv: 'Bls12381G2'
  x: string
  kid?: string
  /** Base58 de la clave pública (formato DID Bls12381G2Key2020). */
  publicKeyBase58?: string
}

interface Bls12381G2PrivateJwk extends Bls12381G2PublicJwk {
  d: string
  privateKeyBase58?: string
}

type AnyPublicJwk = Ed25519PublicJwk | P256PublicJwk | Bls12381G2PublicJwk
type AnyPrivateJwk = Ed25519PrivateJwk | P256PrivateJwk | Bls12381G2PrivateJwk

interface StoredKeyPair {
  publicJwk: AnyPublicJwk
  privateJwk: AnyPrivateJwk
}

interface SymmetricJwk {
  kty: 'oct'
  k: string
}

interface KeyAgreementParams {
  keyId?: string
  senderKeyId?: string
  /** Algoritmo de key agreement. 'ECDH-ES' indica JWE JARM; ausente indica DIDComm nacl.box. */
  algorithm?: string
  /** Party U Info para ConcatKDF (ECDH-ES) */
  apu?: Uint8Array
  /** Party V Info para ConcatKDF (ECDH-ES) */
  apv?: Uint8Array
  externalPublicJwk?: { x: string; [k: string]: unknown }
  recipientPublicKey?: { x: string; [k: string]: unknown }
  recipientKey?: { x: string; [k: string]: unknown }
}

interface EncryptDecryptKey {
  keyAgreement?: KeyAgreementParams
  privateJwk?: SymmetricJwk
}

interface EncryptionOptions {
  algorithm?: string
  aad?: string | Uint8Array
}

interface DecryptionOptions {
  algorithm?: string
  iv?: Uint8Array | string
  tag?: Uint8Array | string
  aad?: Uint8Array | string
}

/**
 * Backend de gestión de claves que almacena pares de claves en PostgreSQL.
 *
 * Soporta OKP Ed25519 (DIDComm, EdDSA), EC P-256 (did:web, OID4VC/EUDI) y
 * Bls12381G2 (BbsBlsSignature2020 / selective disclosure JSON-LD).
 * Las claves se persisten como JWK en una tabla `keys` creada automáticamente al primer uso.
 * El cifrado/descifrado usa acuerdo de clave X25519 derivado de la clave Ed25519 (DIDComm anoncrypt/authcrypt).
 *
 * Credo 0.7 valida `KeyManagementApi.createKey` con Zod (solo EC/OKP/RSA/oct estándar):
 * Bls12381G2 no pasa esa API. Usar `createBls12381G2Key` / `getBls12381G2KeyPair` de `./bbs-kms`.
 *
 * En producto Quark (Askar primario) usar `BbsKeyManagementService` como sidecar BBS;
 * este adapter queda como KMS primario completo para integradores sin Askar.
 */
export function resolvePostgresKeyManagementService(
  agentContext: AgentContext
): PostgresKeyManagementService {
  const backend = tryResolvePostgresKeyManagementService(agentContext)
  if (!backend) {
    throw new Error(
      'PostgresKeyManagementService is not registered. For BBS+ con Askar usá BbsKeyManagementService; ver createBls12381G2Key.',
    )
  }
  return backend
}

/**
 * Devuelve el backend Postgres del KMS si está registrado; si no, `null`.
 */
export function tryResolvePostgresKeyManagementService(
  agentContext: AgentContext
): PostgresKeyManagementService | null {
  const config = agentContext.dependencyManager.resolve(Kms.KeyManagementModuleConfig)
  const backend = config.backends.find((b) => b instanceof PostgresKeyManagementService)
  return backend ?? null
}

export class PostgresKeyManagementService implements KeyManagementService {
  public static readonly backend = 'postgres'
  public readonly backend = PostgresKeyManagementService.backend

  private ready: Promise<void>

  /**
   * @param pool - Pool Postgres gestionado por Nest (paridad con `PostgresRecordStorage`)
   * @param walletId - Scope legacy (no se usa: el scope real es `contextCorrelationId`)
   */
  constructor(
    private readonly pool: Pool,
    private readonly _walletId: string = 'default',
  ) {
    this.ready = withRetry(() => this.initialize(), {
      attempts: 10,
      baseDelayMs: 2_000,
      maxDelayMs: 15_000,
      label: '[PostgresKeyManagementService]',
      shouldRetry: (err) => {
        const pgErr = err as { code?: string }
        // No reintentar errores de objeto duplicado — se manejan dentro de initialize()
        return pgErr?.code !== '42P07' && pgErr?.code !== '23505'
      },
    }).catch((err) => {
      console.error('[PostgresKeyManagementService] initialization failed after all retries:', err?.message ?? err)
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
      // 42P07 = tabla duplicada, 23505 = violación de unicidad (race condition en pg_type)
      if (pgErr?.code === '42P07' || pgErr?.code === '23505') {
        console.warn('[PostgresKeyManagementService] table already exists (race condition) — continuing')
      } else {
        throw err
      }
    }
    await this.pool.query(`ALTER TABLE keys ADD COLUMN IF NOT EXISTS wallet_id TEXT NOT NULL DEFAULT ''`)
    await this.pool.query(`CREATE INDEX IF NOT EXISTS keys_wallet_id_idx ON keys(wallet_id)`)
  }

  private async getKey(walletId: string, keyId: string): Promise<StoredKeyPair | null> {
    await this.ready
    const { rows } = await this.pool.query<{ public_jwk: string; private_jwk: string }>(
      'SELECT public_jwk, private_jwk FROM keys WHERE id = $1 AND (wallet_id = $2 OR wallet_id = $3) LIMIT 1',
      [keyId, walletId, DOMAIN_KEY_SCOPE]
    )
    if (!rows.length) return null
    return {
      publicJwk: JSON.parse(rows[0].public_jwk) as AnyPublicJwk,
      privateJwk: JSON.parse(rows[0].private_jwk) as AnyPrivateJwk,
    }
  }

  private async saveKey(walletId: string, keyId: string, publicJwk: AnyPublicJwk, privateJwk: AnyPrivateJwk): Promise<void> {
    await this.ready
    await this.pool.query(
      'INSERT INTO keys (id, wallet_id, public_jwk, private_jwk) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO UPDATE SET wallet_id = EXCLUDED.wallet_id, public_jwk = EXCLUDED.public_jwk, private_jwk = EXCLUDED.private_jwk',
      [keyId, walletId, JSON.stringify(publicJwk), JSON.stringify(privateJwk)]
    )
  }

  /**
   * Retorna true si este backend maneja la operación KMS solicitada.
   *
   * OKP/Ed25519, EC/P-256 y Bls12381G2.
   * DIDComm v1 (`ECDH-HSALSA20` / `XSALSA20-POLY1305`) **no** se reclama:
   * el formato Postgres no es compatible con Askar (`CryptoBox.seal`/`sealOpen`).
   */
  public isOperationSupported(_agentContext: AgentContext, operation: Kms.KmsOperation): boolean {
    if (operation.operation === 'randomBytes') return true
    if (operation.operation === 'createKey') {
      const type = (operation as Record<string, unknown>).type as
        | { kty?: string; crv?: string; keyType?: string }
        | undefined
      if (!type) return true
      if (type.kty === 'OKP' && type.crv === 'Ed25519') return true
      if (type.kty === 'EC' && type.crv === 'P-256') return true
      if (type.keyType === 'Bls12381G2' || (type.kty === 'OKP' && type.crv === 'Bls12381G2')) return true
      return false
    }
    if (operation.operation === 'importKey') return true
    if (operation.operation === 'deleteKey') return true
    if (operation.operation === 'encrypt' || operation.operation === 'decrypt') {
      const op = operation as {
        encryption?: { algorithm?: string }
        decryption?: { algorithm?: string }
        keyAgreement?: { algorithm?: string }
      }
      const alg = op.encryption?.algorithm ?? op.decryption?.algorithm
      const ka = op.keyAgreement?.algorithm
      // DIDComm v1: solo Askar (Libsodium seal/box), no este adapter.
      if (alg === 'XSALSA20-POLY1305' || ka === 'ECDH-HSALSA20') {
        return false
      }
      return true
    }
    if (operation.operation === 'sign' || operation.operation === 'verify') return true
    return false
  }

  public async getPublicKey(agentContext: AgentContext, keyId: string): Promise<Kms.KmsJwkPublic | null> {
    const entry = await this.getKey(agentContext.contextCorrelationId, keyId)
    // Bls12381G2 se almacena como JWK extendido; Credo tipa solo EC/OKP/RSA estándar.
    return entry ? (entry.publicJwk as unknown as Kms.KmsJwkPublic) : null
  }

  /**
   * Genera un nuevo par de claves y lo persiste en PostgreSQL.
   *
   * Soporta `{ kty: 'OKP', crv: 'Ed25519' }` (DIDComm / EdDSA),
   * `{ kty: 'EC', crv: 'P-256' }` (did:web / ES256 / OID4VC) y
   * `{ keyType: 'Bls12381G2' }` o `{ kty: 'OKP', crv: 'Bls12381G2' }` (BBS+).
   *
   * @throws {Error} Si se solicita un tipo de clave no soportado
   */
  public async createKey<Type extends Kms.KmsCreateKeyType>(
    agentContext: AgentContext,
    options: Kms.KmsCreateKeyOptions<Type>
  ): Promise<Kms.KmsCreateKeyReturn<Type>> {
    const type = options.type as { kty?: string; crv?: string; keyType?: string }
    const kid = options.keyId ?? utils.uuid()
    const wid = agentContext.contextCorrelationId

    if (type.keyType === 'Bls12381G2' || (type.kty === 'OKP' && type.crv === 'Bls12381G2')) {
      const keyPair = await Bls12381G2KeyPair.generate()
      const publicKeyBase58 = keyPair.publicKey
      const privateKeyBase58 = keyPair.privateKey
      if (!privateKeyBase58) {
        throw new Error('Bls12381G2KeyPair.generate did not return a private key')
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

    if (type.kty === 'EC' && type.crv === 'P-256') {
      const { publicKey, privateKey } = generateKeyPairSync('ec', { namedCurve: 'P-256' })
      const publicJwk = publicKey.export({ format: 'jwk' }) as unknown as P256PublicJwk
      const privateJwk = privateKey.export({ format: 'jwk' }) as unknown as P256PrivateJwk
      publicJwk.kid = kid
      privateJwk.kid = kid
      await this.saveKey(wid, kid, publicJwk, privateJwk)
      return { keyId: kid, publicJwk } as unknown as Kms.KmsCreateKeyReturn<Type>
    }

    if (type.kty !== 'OKP' || type.crv !== 'Ed25519') {
      throw new Error('Only OKP Ed25519, EC P-256 and Bls12381G2 supported in PostgresKeyManagementService')
    }
    const { publicKey, privateKey } = generateKeyPairSync('ed25519')
    const publicJwk = publicKey.export({ format: 'jwk' }) as unknown as Ed25519PublicJwk
    const privateJwk = privateKey.export({ format: 'jwk' }) as unknown as Ed25519PrivateJwk
    publicJwk.kid = kid
    privateJwk.kid = kid
    await this.saveKey(wid, kid, publicJwk, privateJwk)
    return { keyId: kid, publicJwk } as unknown as Kms.KmsCreateKeyReturn<Type>
  }

  /**
   * Reconstruye un `Bls12381G2KeyPair` MATTR desde material almacenado (solo claves BLS).
   *
   * Usado por la capa BBS de identity-core: Credo 0.7 no modela BLS en `PublicJwk`,
   * así que la firma LD usa el key pair MATTR con privada leída del KMS.
   *
   * @throws {KeyManagementError} Si la clave no existe o no es Bls12381G2
   */
  public async getBls12381G2KeyPair(agentContext: AgentContext, keyId: string): Promise<Bls12381G2KeyPair> {
    const entry = await this.getKey(agentContext.contextCorrelationId, keyId)
    if (!entry) throw new Kms.KeyManagementError(`Key ${keyId} not found`)
    const priv = entry.privateJwk as Bls12381G2PrivateJwk
    if (priv.crv !== 'Bls12381G2') {
      throw new Kms.KeyManagementError(`Key ${keyId} is not Bls12381G2`)
    }
    const publicKeyBase58 =
      priv.publicKeyBase58 ??
      (entry.publicJwk as Bls12381G2PublicJwk).publicKeyBase58
    const privateKeyBase58 = priv.privateKeyBase58
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
    agentContext: AgentContext,
    options: Kms.KmsImportKeyOptions<Jwk>
  ): Promise<Kms.KmsImportKeyReturn<Jwk>> {
    const kid = options.privateJwk.kid ?? utils.uuid()
    const publicJwk = Kms.publicJwkFromPrivateJwk(options.privateJwk as Kms.KmsJwkPrivate)
    publicJwk.kid = kid
    await this.saveKey(agentContext.contextCorrelationId, kid, publicJwk as unknown as AnyPublicJwk, options.privateJwk as unknown as AnyPrivateJwk)
    return { keyId: kid, publicJwk } as unknown as Kms.KmsImportKeyReturn<Jwk>
  }

  public async deleteKey(agentContext: AgentContext, options: Kms.KmsDeleteKeyOptions): Promise<boolean> {
    await this.ready
    const { rowCount } = await this.pool.query('DELETE FROM keys WHERE id = $1 AND wallet_id = $2', [options.keyId, agentContext.contextCorrelationId])
    return (rowCount ?? 0) > 0
  }

  /**
   * Firma datos usando la clave privada almacenada.
   *
   * Soporta `EdDSA`/`Ed25519` (claves OKP) y `ES256` (claves EC P-256).
   *
   * @throws {KeyManagementError} Si la clave no existe o el algoritmo no está soportado
   */
  public async sign(agentContext: AgentContext, options: Kms.KmsSignOptions): Promise<Kms.KmsSignReturn> {
    const entry = await this.getKey(agentContext.contextCorrelationId, options.keyId)
    if (!entry) throw new Kms.KeyManagementError(`Key ${options.keyId} not found`)
    const { algorithm } = options
    const data = options.data instanceof Uint8Array ? options.data : Buffer.from(options.data as unknown as ArrayBuffer)
    const privateKey = createPrivateKey({ key: entry.privateJwk as unknown as JsonWebKey, format: 'jwk' })
    if (algorithm === 'EdDSA' || algorithm === 'Ed25519') {
      const signature = sign(null, data, privateKey)
      return { signature: signature as unknown as Uint8Array }
    }
    if (algorithm === 'ES256') {
      const signature = sign('SHA256', data, { key: privateKey, dsaEncoding: 'ieee-p1363' })
      return { signature: signature as Uint8Array }
    }
    throw new Kms.KeyManagementError(`Unsupported algorithm: ${algorithm}`)
  }

  /**
   * Verifica una firma contra la clave pública obtenida por `keyId` o provista inline.
   *
   * Soporta los algoritmos `EdDSA`/`Ed25519` y `ES256`.
   *
   * @throws {KeyManagementError} Si la clave pública no existe o el algoritmo no está soportado
   */
  public async verify(agentContext: AgentContext, options: Kms.KmsVerifyOptions): Promise<Kms.KmsVerifyReturn> {
    const { key, algorithm, data, signature } = options
    const publicJwk: AnyPublicJwk | null =
      'keyId' in key && key.keyId
        ? ((await this.getKey(agentContext.contextCorrelationId, key.keyId))?.publicJwk ?? null)
        : ((key as { publicJwk: AnyPublicJwk }).publicJwk ?? null)
    if (!publicJwk) throw new Kms.KeyManagementError('Public key not found for verify')
    const { createPublicKey, verify } = await import('crypto')
    const pubKey = createPublicKey({ key: publicJwk as unknown as JsonWebKey, format: 'jwk' })
    const dataBuf = data instanceof Uint8Array ? data : Buffer.from(data as unknown as ArrayBuffer)
    const sigBuf = signature instanceof Uint8Array ? signature : Buffer.from(signature as unknown as ArrayBuffer)
    if (algorithm === 'EdDSA' || algorithm === 'Ed25519') {
      const valid = verify(null, dataBuf, pubKey, sigBuf)
      return valid ? { verified: true, publicJwk: publicJwk as unknown as Kms.KmsJwkPublic } : { verified: false }
    }
    if (algorithm === 'ES256') {
      const valid = verify('SHA256', dataBuf, { key: pubKey, dsaEncoding: 'ieee-p1363' }, sigBuf)
      return valid ? { verified: true, publicJwk: publicJwk as unknown as Kms.KmsJwkPublic } : { verified: false }
    }
    throw new Kms.KeyManagementError(`Unsupported algorithm: ${algorithm}`)
  }

  /**
   * Concat KDF (RFC 7518 §4.6.2) para derivar el CEK en ECDH-ES.
   *
   * Hash = SHA-256(round || Z || len(alg) || alg || len(apu) || apu || len(apv) || apv || keydatalen)
   */
  private concatKdf(
    sharedSecret: Buffer,
    algorithm: string,
    keyLengthBits: number,
    apu?: Uint8Array,
    apv?: Uint8Array
  ): Buffer {
    const lenPrefix = (buf: Buffer): Buffer => {
      const len = Buffer.alloc(4)
      len.writeUInt32BE(buf.length)
      return Buffer.concat([len, buf])
    }
    const round = Buffer.alloc(4)
    round.writeUInt32BE(1)
    const keydatalenBuf = Buffer.alloc(4)
    keydatalenBuf.writeUInt32BE(keyLengthBits)

    const hash = createHash('sha256')
    hash.update(round)
    hash.update(sharedSecret)
    hash.update(lenPrefix(Buffer.from(algorithm, 'utf8')))
    hash.update(lenPrefix(apu ? Buffer.from(apu) : Buffer.alloc(0)))
    hash.update(lenPrefix(apv ? Buffer.from(apv) : Buffer.alloc(0)))
    hash.update(keydatalenBuf)
    return hash.digest().subarray(0, keyLengthBits / 8)
  }

  /**
   * ECDH-ES encrypt para JARM (RFC 7518 §4.6 + AES-GCM).
   * Devuelve `{ encrypted, iv, tag }` que arma el compact JWE.
   */
  private async encryptEcdhEs(
    walletId: string,
    ka: KeyAgreementParams,
    data: Uint8Array,
    encryption: { algorithm?: string; aad?: string | Uint8Array } | undefined
  ): Promise<Kms.KmsEncryptReturn> {
    if (!ka.keyId) throw new Kms.KeyManagementError('ECDH-ES encrypt: keyId required')
    const extPub = ka.externalPublicJwk
    if (!extPub) throw new Kms.KeyManagementError('ECDH-ES encrypt: externalPublicJwk required')

    const encAlg = encryption?.algorithm ?? 'A256GCM'
    const keyLengthBits = encAlg === 'A128GCM' ? 128 : 256

    const entry = await this.getKey(walletId, ka.keyId)
    if (!entry) throw new Kms.KeyManagementError(`ECDH-ES encrypt: key ${ka.keyId} not found`)

    const ephPrivKey = createPrivateKey({ key: entry.privateJwk as unknown as JsonWebKey, format: 'jwk' })
    const recipientPubKey = createPublicKey({ key: extPub as unknown as JsonWebKey, format: 'jwk' })
    const sharedSecret = diffieHellman({ privateKey: ephPrivKey, publicKey: recipientPubKey })

    const cek = this.concatKdf(sharedSecret, encAlg, keyLengthBits, ka.apu, ka.apv)

    const iv = randomBytes(12)
    const cipherAlg = encAlg === 'A128GCM' ? 'aes-128-gcm' : 'aes-256-gcm'
    const cipher = createCipheriv(cipherAlg, cek, iv, { authTagLength: 16 } as Parameters<typeof createCipheriv>[3])

    const aadRaw = encryption?.aad
    const aadBuf = aadRaw instanceof Uint8Array
      ? Buffer.from(aadRaw)
      : typeof aadRaw === 'string'
      ? Buffer.from(aadRaw, 'base64')
      : undefined
    if (aadBuf) (cipher as unknown as { setAAD(b: Buffer): void }).setAAD(aadBuf)

    const encrypted = Buffer.concat([cipher.update(data), cipher.final()])
    const tag = (cipher as unknown as { getAuthTag(): Buffer }).getAuthTag()

    return {
      encrypted: encrypted as unknown as Uint8Array,
      iv: iv as unknown as Uint8Array,
      tag: tag as unknown as Uint8Array,
    }
  }

  /**
   * ECDH-ES decrypt para JARM (RFC 7518 §4.6 + AES-GCM).
   * Usa la clave privada local + la clave pública efímera del JWE header.
   */
  private async decryptEcdhEs(
    walletId: string,
    ka: KeyAgreementParams,
    encrypted: Uint8Array,
    dec: DecryptionOptions
  ): Promise<Kms.KmsDecryptReturn> {
    if (!ka.keyId) throw new Kms.KeyManagementError('ECDH-ES decrypt: keyId required')
    const extPub = ka.externalPublicJwk
    if (!extPub) throw new Kms.KeyManagementError('ECDH-ES decrypt: externalPublicJwk (epk) required')

    const encAlg = dec.algorithm ?? 'A256GCM'
    const keyLengthBits = encAlg === 'A128GCM' ? 128 : 256

    const entry = await this.getKey(walletId, ka.keyId)
    if (!entry) throw new Kms.KeyManagementError(`ECDH-ES decrypt: key ${ka.keyId} not found`)

    const recipientPrivKey = createPrivateKey({ key: entry.privateJwk as unknown as JsonWebKey, format: 'jwk' })
    const ephemeralPubKey = createPublicKey({ key: extPub as unknown as JsonWebKey, format: 'jwk' })
    const sharedSecret = diffieHellman({ privateKey: recipientPrivKey, publicKey: ephemeralPubKey })

    const cek = this.concatKdf(sharedSecret, encAlg, keyLengthBits, ka.apu, ka.apv)

    const iv = dec.iv instanceof Uint8Array ? Buffer.from(dec.iv) : typeof dec.iv === 'string' ? Buffer.from(dec.iv, 'base64') : null
    if (!iv || iv.length !== 12) throw new Kms.KeyManagementError('ECDH-ES decrypt: iv (12 bytes) required')

    const tag = dec.tag instanceof Uint8Array ? Buffer.from(dec.tag) : typeof dec.tag === 'string' ? Buffer.from(dec.tag, 'base64') : null
    if (!tag) throw new Kms.KeyManagementError('ECDH-ES decrypt: tag required')

    const cipherAlg = encAlg === 'A128GCM' ? 'aes-128-gcm' : 'aes-256-gcm'
    const decipher = createDecipheriv(cipherAlg, cek, iv, { authTagLength: 16 } as Parameters<typeof createDecipheriv>[3])

    const aadRaw = dec.aad
    const aadBuf = aadRaw instanceof Uint8Array
      ? Buffer.from(aadRaw)
      : typeof aadRaw === 'string'
      ? Buffer.from(aadRaw, 'utf8')
      : undefined
    if (aadBuf) (decipher as unknown as { setAAD(b: Buffer): void }).setAAD(aadBuf)
    ;(decipher as unknown as { setAuthTag(b: Buffer): void }).setAuthTag(tag)

    const data = Buffer.concat([decipher.update(Buffer.from(encrypted)), decipher.final()])
    return { data: data as unknown as Uint8Array }
  }

  private async ed25519ToX25519Secret(walletId: string, keyId: string): Promise<Uint8Array> {
    const entry = await this.getKey(walletId, keyId)
    if (!entry) throw new Kms.KeyManagementError(`Key ${keyId} not found`)
    const ed25519Secret = Buffer.concat([
      Buffer.from(entry.privateJwk.d, 'base64url'),
      Buffer.from(entry.publicJwk.x, 'base64url'),
    ])
    if (ed25519Secret.length !== 64) throw new Kms.KeyManagementError('Invalid Ed25519 key format (expected 64 bytes)')
    const x25519Secret = ed2curve.convertSecretKey(new Uint8Array(ed25519Secret))
    if (!x25519Secret) throw new Kms.KeyManagementError('Failed to convert Ed25519 to X25519')
    return x25519Secret
  }

  public async encrypt(agentContext: AgentContext, _options: Kms.KmsEncryptOptions): Promise<Kms.KmsEncryptReturn> {
    const opts = _options as unknown as {
      data?: Uint8Array
      plaintext?: Uint8Array
      key: EncryptDecryptKey
      encryption?: EncryptionOptions
    }
    if (opts.data === undefined && opts.plaintext !== undefined) opts.data = opts.plaintext
    const data =
      opts.data instanceof Uint8Array ? opts.data : Uint8Array.from(Buffer.from(opts.data as unknown as ArrayBuffer))
    const key = opts.key
    if (key?.keyAgreement) {
      const ka = key.keyAgreement
      // ECDH-ES (JARM JWE): delegar a encryptEcdhEs
      if (ka.algorithm === 'ECDH-ES') {
        return this.encryptEcdhEs(agentContext.contextCorrelationId, ka, data, opts.encryption)
      }
      const keyId = ka.keyId ?? ka.senderKeyId
      const externalPublicJwk = ka.externalPublicJwk ?? ka.recipientPublicKey ?? ka.recipientKey
      if (!externalPublicJwk?.x) throw new Kms.KeyManagementError('encrypt: keyAgreement.externalPublicJwk required')
      const theirX25519Pub = Buffer.from(externalPublicJwk.x, 'base64url')
      if (theirX25519Pub.length !== 32) throw new Kms.KeyManagementError('encrypt: externalPublicJwk.x must be 32 bytes')
      let x25519Secret: Uint8Array
      let ephemeralPub: Buffer | undefined
      if (keyId) {
        x25519Secret = await this.ed25519ToX25519Secret(agentContext.contextCorrelationId, keyId)
      } else {
        const ephemeral = nacl.box.keyPair()
        x25519Secret = ephemeral.secretKey
        ephemeralPub = Buffer.from(ephemeral.publicKey)
      }
      const nonce = randomBytes(24)
      const boxed = nacl.box(new Uint8Array(data), new Uint8Array(nonce), new Uint8Array(theirX25519Pub), x25519Secret)
      if (!boxed) throw new Kms.KeyManagementError('encrypt: nacl.box failed')
      if (ephemeralPub) {
        const encrypted = Buffer.concat([ephemeralPub, nonce, Buffer.from(boxed)])
        return { encrypted: encrypted as unknown as Uint8Array, iv: undefined as unknown as Uint8Array, tag: undefined as unknown as Uint8Array }
      }
      return { encrypted: Buffer.from(boxed) as unknown as Uint8Array, iv: nonce as unknown as Uint8Array, tag: undefined as unknown as Uint8Array }
    }
    if (key?.privateJwk?.kty === 'oct') {
      const symKey = Buffer.from(key.privateJwk.k, 'base64url')
      if (symKey.length !== 32) throw new Kms.KeyManagementError('encrypt: symmetric key must be 32 bytes')
      const iv = randomBytes(12)
      const encOpts: EncryptionOptions = opts.encryption ?? {}
      const aad = encOpts.aad ? (typeof encOpts.aad === 'string' ? Buffer.from(encOpts.aad, 'base64') : Buffer.from(encOpts.aad)) : undefined
      const cipher = createCipheriv('chacha20-poly1305', symKey, iv, { authTagLength: 16 } as Parameters<typeof createCipheriv>[3])
      if (aad) (cipher as unknown as { setAAD(buf: Buffer): void }).setAAD(aad)
      const encrypted = Buffer.concat([cipher.update(data), cipher.final()])
      const tag = (cipher as unknown as { getAuthTag(): Buffer }).getAuthTag()
      return { encrypted: encrypted as unknown as Uint8Array, iv: iv as unknown as Uint8Array, tag: tag as unknown as Uint8Array }
    }
    throw new Kms.KeyManagementError('encrypt: key.keyAgreement or key.privateJwk (oct) required')
  }

  public async decrypt(agentContext: AgentContext, _options: Kms.KmsDecryptOptions): Promise<Kms.KmsDecryptReturn> {
    const opts = _options as unknown as { encrypted: Uint8Array; key: EncryptDecryptKey; decryption?: DecryptionOptions }
    const encrypted =
      opts.encrypted instanceof Uint8Array ? opts.encrypted : Uint8Array.from(Buffer.from(opts.encrypted as unknown as ArrayBuffer))
    const dec: DecryptionOptions = opts.decryption ?? {}
    const key = opts.key
    if (key?.keyAgreement) {
      const ka = key.keyAgreement
      // ECDH-ES (JARM JWE): delegar a decryptEcdhEs
      if (ka.algorithm === 'ECDH-ES') {
        return this.decryptEcdhEs(agentContext.contextCorrelationId, ka, encrypted, dec)
      }
      const keyId = ka.keyId
      if (!keyId) throw new Kms.KeyManagementError('decrypt: keyAgreement.keyId required')
      const x25519Secret = await this.ed25519ToX25519Secret(agentContext.contextCorrelationId, keyId)
      const externalPublicJwk = ka.externalPublicJwk
      const iv =
        dec.iv instanceof Uint8Array ? Buffer.from(dec.iv) : typeof dec.iv === 'string' ? Buffer.from(dec.iv, 'base64') : null
      if (externalPublicJwk?.x && iv && iv.length === 24) {
        const theirX25519Pub = Buffer.from(externalPublicJwk.x, 'base64url')
        const opened = nacl.box.open(new Uint8Array(encrypted), new Uint8Array(iv), new Uint8Array(theirX25519Pub), x25519Secret)
        if (!opened) throw new Kms.KeyManagementError('decrypt: nacl.box.open failed (authcrypt)')
        return { data: Buffer.from(opened) as unknown as Uint8Array }
      }
      if (encrypted.length <= 56) throw new Kms.KeyManagementError('decrypt: encrypted too short for anoncrypt (need 32+24+data)')
      const ephemeralPub = encrypted.subarray(0, 32)
      const extractedNonce = encrypted.subarray(32, 56)
      const boxed = encrypted.subarray(56)
      const opened = nacl.box.open(new Uint8Array(boxed), new Uint8Array(extractedNonce), new Uint8Array(ephemeralPub), x25519Secret)
      if (!opened) throw new Kms.KeyManagementError('decrypt: nacl.box.open failed (anoncrypt)')
      return { data: Buffer.from(opened) as unknown as Uint8Array }
    }
    if (key?.privateJwk?.kty === 'oct') {
      const symKey = Buffer.from(key.privateJwk.k, 'base64url')
      const iv =
        dec.iv instanceof Uint8Array ? Buffer.from(dec.iv) : typeof dec.iv === 'string' ? Buffer.from(dec.iv, 'base64') : null
      if (!iv || iv.length !== 12) throw new Kms.KeyManagementError('decrypt: iv (12 bytes) required for symmetric')
      const tag =
        dec.tag instanceof Uint8Array ? Buffer.from(dec.tag) : typeof dec.tag === 'string' ? Buffer.from(dec.tag, 'base64') : null
      const aad =
        dec.aad instanceof Uint8Array ? Buffer.from(dec.aad) : typeof dec.aad === 'string' ? Buffer.from(dec.aad) : undefined
      const decipher = createDecipheriv('chacha20-poly1305', symKey, iv, { authTagLength: 16 } as Parameters<typeof createDecipheriv>[3])
      if (aad) (decipher as unknown as { setAAD(buf: Buffer): void }).setAAD(aad)
      if (tag) (decipher as unknown as { setAuthTag(buf: Buffer): void }).setAuthTag(tag)
      const data = Buffer.concat([decipher.update(encrypted), decipher.final()])
      return { data: data as unknown as Uint8Array }
    }
    throw new Kms.KeyManagementError('decrypt: key.keyAgreement or key.privateJwk (oct) required')
  }

  public randomBytes(_agentContext: AgentContext, options: Kms.KmsRandomBytesOptions): Buffer {
    return randomBytes(options.length)
  }
}
