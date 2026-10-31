const databaseName = 'kuatia-web-wallet'
const databaseVersion = 1
const keyStore = 'keys'
const credentialStore = 'credentials'
const masterKeyId = 'credential-encryption-key'
const holderPrivateKeyId = 'holder-p256-v2-private'
const holderPublicKeyId = 'holder-p256-v2-public'

interface EncryptedCredential {
  id: string
  iv: Uint8Array
  ciphertext: ArrayBuffer
  createdAt: string
}

interface CredentialPayload {
  compactSdJwt: string
  label: string
}

export interface HolderSigningKey {
  privateKey: CryptoKey
  publicJwk: JsonWebKey
}

function openDatabase(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(databaseName, databaseVersion)
    request.onupgradeneeded = () => {
      const db = request.result
      db.createObjectStore(keyStore)
      db.createObjectStore(credentialStore, { keyPath: 'id' })
    }
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error ?? new Error('No se pudo abrir IndexedDB.'))
  })
}

function transactionComplete(transaction: IDBTransaction): Promise<void> {
  return new Promise((resolve, reject) => {
    transaction.oncomplete = () => resolve()
    transaction.onabort = transaction.onerror = () => reject(transaction.error ?? new Error('Falló la transacción IndexedDB.'))
  })
}

function requestResult<T>(request: IDBRequest<T>): Promise<T> {
  return new Promise((resolve, reject) => {
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error ?? new Error('Falló la operación IndexedDB.'))
  })
}

async function readKey(db: IDBDatabase, id: string): Promise<CryptoKey | undefined> {
  const transaction = db.transaction(keyStore, 'readonly')
  const done = transactionComplete(transaction)
  try {
    const key = await requestResult(transaction.objectStore(keyStore).get(id)) as CryptoKey | undefined
    await done
    return key
  } catch (error) {
    await done.catch(() => undefined)
    throw error
  }
}

async function getEncryptionKey(db: IDBDatabase): Promise<CryptoKey> {
  const stored = await readKey(db, masterKeyId)
  if (stored) return stored

  const generated = await crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, false, ['encrypt', 'decrypt'])
  const transaction = db.transaction(keyStore, 'readwrite')
  const done = transactionComplete(transaction)
  try {
    await requestResult(transaction.objectStore(keyStore).add(generated, masterKeyId))
    await done
    return generated
  } catch {
    await done.catch(() => undefined)
    const winner = await readKey(db, masterKeyId)
    if (winner) return winner
    throw new Error('El navegador no pudo persistir la clave local de cifrado.')
  }
}

export async function createHolderKey(): Promise<void> {
  const db = await openDatabase()
  try {
    if (await readKey(db, holderPrivateKeyId) && await readKey(db, holderPublicKeyId)) return
    const pair = await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign', 'verify'])
    const transaction = db.transaction(keyStore, 'readwrite')
    const done = transactionComplete(transaction)
    const store = transaction.objectStore(keyStore)
    store.put(pair.privateKey, holderPrivateKeyId)
    store.put(pair.publicKey, holderPublicKeyId)
    await done
  } finally {
    db.close()
  }
}

export async function getHolderSigningKey(): Promise<HolderSigningKey> {
  const db = await openDatabase()
  try {
    const [privateKey, publicKey] = await Promise.all([
      readKey(db, holderPrivateKeyId),
      readKey(db, holderPublicKeyId),
    ])
    if (!privateKey || !publicKey) throw new Error('Generá una nueva clave P-256 de holder para emitir.')
    const publicJwk = await crypto.subtle.exportKey('jwk', publicKey)
    if (publicJwk.kty !== 'EC' || publicJwk.crv !== 'P-256' || !publicJwk.x || !publicJwk.y) {
      throw new Error('La clave pública de holder no es una JWK P-256 válida.')
    }
    return { privateKey, publicJwk: { kty: publicJwk.kty, crv: publicJwk.crv, x: publicJwk.x, y: publicJwk.y } }
  } finally {
    db.close()
  }
}

export async function hasHolderKey(): Promise<boolean> {
  const db = await openDatabase()
  try {
    return Boolean(await readKey(db, holderPrivateKeyId) && await readKey(db, holderPublicKeyId))
  } finally {
    db.close()
  }
}

export async function saveCredential(compactSdJwt: string, label: string): Promise<string> {
  const db = await openDatabase()
  try {
    const key = await getEncryptionKey(db)
    const iv = crypto.getRandomValues(new Uint8Array(12))
    const plaintext = new TextEncoder().encode(JSON.stringify({ compactSdJwt, label } satisfies CredentialPayload))
    const ciphertext = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, plaintext)
    const record: EncryptedCredential = { id: crypto.randomUUID(), iv, ciphertext, createdAt: new Date().toISOString() }
    const transaction = db.transaction(credentialStore, 'readwrite')
    const done = transactionComplete(transaction)
    try {
      await requestResult(transaction.objectStore(credentialStore).add(record))
      await done
      return record.id
    } catch (error) {
      await done.catch(() => undefined)
      throw error
    }
  } finally {
    db.close()
  }
}

export async function listCredentials(): Promise<Array<CredentialPayload & { id: string; createdAt: string }>> {
  const db = await openDatabase()
  try {
    const key = await getEncryptionKey(db)
    const transaction = db.transaction(credentialStore, 'readonly')
    const done = transactionComplete(transaction)
    let records: EncryptedCredential[]
    try {
      records = await requestResult(transaction.objectStore(credentialStore).getAll()) as EncryptedCredential[]
      await done
    } catch (error) {
      await done.catch(() => undefined)
      throw error
    }
    return await Promise.all(records.map(async ({ id, iv, ciphertext, createdAt }) => {
      const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, ciphertext)
      return { ...JSON.parse(new TextDecoder().decode(plaintext)) as CredentialPayload, id, createdAt }
    }))
  } finally {
    db.close()
  }
}
