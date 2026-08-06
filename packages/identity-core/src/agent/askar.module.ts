import '../askar-native'
import {
  AskarModule,
  AskarMultiWalletDatabaseScheme,
  type AskarModuleConfigStoreOptions,
  type AskarPostgresStorageConfig,
} from '@credo-ts/askar'
import type { Askar } from '@openwallet-foundation/askar-shared'

/**
 * Opciones del store Askar que Nest pasa al bootstrap del agente.
 *
 * `databaseUrl` es una URL Postgres estándar; Askar usa `id` como nombre de DB
 * (`postgres://user:pass@host:port/{id}`).
 *
 * `askar` lo provee Nest desde `@quarkid/identity-core` (`askarNodeJS`) para que
 * el binding nativo coincida con la misma `askar-shared` que Credo y se registre
 * antes de cargar `@credo-ts/askar`.
 */
export type QuarkAskarStoreOptions = {
  /** Binding nativo Askar (`askarNodeJS` vía `@quarkid/identity-core`). */
  askar: Askar
  /** Nombre de la base Askar (y perfil root). */
  id: string
  /** Passphrase / raw key para abrir el store. */
  key: string
  /** URL Postgres (`postgresql://user:pass@host:port/db`). */
  databaseUrl: string
  /**
   * Método de derivación de la clave del store.
   * @default 'kdf:argon2i:mod'
   */
  keyDerivationMethod?: AskarModuleConfigStoreOptions['keyDerivationMethod']
}

/**
 * Parsea una connection string Postgres al formato Askar (`host`, credenciales, database).
 */
export function parsePostgresUrlForAskar(databaseUrl: string): {
  host: string
  account: string
  password: string
  database: string
} {
  let parsed: URL
  try {
    parsed = new URL(databaseUrl)
  } catch {
    throw new Error(
      `ASKAR_DATABASE_URL inválida: no es una URL parseable (${databaseUrl.slice(0, 32)}…)`,
    )
  }

  if (parsed.protocol !== 'postgres:' && parsed.protocol !== 'postgresql:') {
    throw new Error('ASKAR_DATABASE_URL debe usar el esquema postgres:// o postgresql://')
  }

  const database = decodeURIComponent(parsed.pathname.replace(/^\//, '').split('/')[0] ?? '')
  if (!database) {
    throw new Error('ASKAR_DATABASE_URL debe incluir el nombre de base en el path')
  }

  const host = parsed.port ? `${parsed.hostname}:${parsed.port}` : parsed.hostname
  return {
    host,
    account: decodeURIComponent(parsed.username),
    password: decodeURIComponent(parsed.password),
    database,
  }
}

/**
 * Construye la config `database` Postgres de Askar a partir de una URL.
 */
export function buildAskarPostgresDatabase(
  databaseUrl: string,
): AskarPostgresStorageConfig {
  const { host, account, password } = parsePostgresUrlForAskar(databaseUrl)
  return {
    type: 'postgres',
    config: { host },
    credentials: { account, password },
  }
}

/**
 * Crea el módulo Credo Askar en modo store-only.
 *
 * Nest inyecta KMS y records; aquí solo se registra `AskarStoreManager`
 * (`enableKms` / `enableStorage` en false) con `ProfilePerWallet` para tenants.
 */
export function buildAskarStoreOnlyModule(
  options: QuarkAskarStoreOptions,
): AskarModule {
  const fromUrl = parsePostgresUrlForAskar(options.databaseUrl)
  const storeId = options.id || fromUrl.database

  return new AskarModule({
    askar: options.askar,
    store: {
      id: storeId,
      key: options.key,
      keyDerivationMethod: options.keyDerivationMethod,
      database: buildAskarPostgresDatabase(options.databaseUrl),
    },
    multiWalletDatabaseScheme: AskarMultiWalletDatabaseScheme.ProfilePerWallet,
    enableKms: false,
    enableStorage: false,
  })
}
