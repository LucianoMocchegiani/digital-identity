import {
  KdfMethod,
  Store,
  StoreKeyMethod,
} from '@openwallet-foundation/askar-shared'

import type { QuarkAskarStoreOptions } from './askar.module'
import { parsePostgresUrlForAskar } from './askar.module'

/**
 * Asegura que el store Askar exista antes de `agent.initialize()`.
 *
 * Credo solo hace provision automático ante `AskarStoreNotFoundError`. Si la DB
 * Postgres ya existe pero aún no tiene el schema Askar (`config`, …), `Store.open`
 * falla con un error de backend y el bootstrap aborta. Este helper abre o provisiona.
 */
export async function ensureAskarStoreProvisioned(
  options: QuarkAskarStoreOptions,
): Promise<void> {
  // Side-effect: `options.askar` debe venir del import de askar-nodejs (Nest / identity-core).
  void options.askar

  const fromUrl = parsePostgresUrlForAskar(options.databaseUrl)
  const storeId = options.id || fromUrl.database
  const { host, account, password } = fromUrl
  const uri = `postgres://${encodeURIComponent(account)}:${encodeURIComponent(password)}@${host}/${encodeURIComponent(storeId)}`
  const keyMethod = new StoreKeyMethod(KdfMethod.Argon2IMod)

  try {
    const store = await Store.open({
      uri,
      keyMethod,
      passKey: options.key,
    })
    await store.close()
    return
  } catch {
    // Continúa a provision.
  }

  const store = await Store.provision({
    recreate: false,
    uri,
    profile: storeId,
    keyMethod,
    passKey: options.key,
  })
  await store.close()
}
