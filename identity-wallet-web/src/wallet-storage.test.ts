import 'fake-indexeddb/auto'
import { webcrypto } from 'node:crypto'
import { beforeEach, describe, expect, it } from 'vitest'
import { createHolderKey, hasHolderKey, listCredentials, saveCredential } from './wallet-storage'

Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true })

beforeEach(async () => {
  await new Promise<void>((resolve, reject) => {
    const request = indexedDB.deleteDatabase('kuatia-web-wallet')
    request.onsuccess = () => resolve()
    request.onerror = () => reject(request.error)
    request.onblocked = () => reject(new Error('IndexedDB quedó bloqueado por una conexión abierta.'))
  })
})

describe('local wallet storage', () => {
  it('persists a non-exportable P-256 holder key', async () => {
    await createHolderKey()
    await expect(hasHolderKey()).resolves.toBe(true)
  })

  it('encrypts credentials before storing and decrypts them on read', async () => {
    const sdJwt = 'header.payload.signature~disclosure'
    const id = await saveCredential(sdJwt, 'Credencial de prueba')
    const opening = indexedDB.open('kuatia-web-wallet', 1)
    const db = await new Promise<IDBDatabase>((resolve, reject) => {
      opening.onsuccess = () => resolve(opening.result)
      opening.onerror = () => reject(opening.error)
    })
    const stored = await new Promise<{ ciphertext: ArrayBuffer }>((resolve, reject) => {
      const request = db.transaction('credentials').objectStore('credentials').get(id)
      request.onsuccess = () => resolve(request.result as { ciphertext: ArrayBuffer })
      request.onerror = () => reject(request.error)
    })
    db.close()
    expect(new TextDecoder().decode(stored.ciphertext)).not.toContain(sdJwt)
    await expect(listCredentials()).resolves.toEqual([
      expect.objectContaining({ id, compactSdJwt: sdJwt, label: 'Credencial de prueba' }),
    ])
  })
})
