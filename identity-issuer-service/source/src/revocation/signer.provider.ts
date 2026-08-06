import { Injectable } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import {
  type Agent,
  type SignerOptions,
  type SignerProvider,
  type SignerDerivationOptions,
  resolveSignerFromAgent,
} from '@identity/core'
import { withWallet } from '../agent/agent-store'

/** Opciones de firma que acepta el KMS del agente Credo (`alg` como unión cerrada). */
type CredoKmsSignOptions = Parameters<Agent['kms']['sign']>[0]

/**
 * Adapter de {@link SignerProvider} para el issuer de QuarkID.
 *
 * Delega toda la lógica de derivación (`alg`, `kid`, selección de clave) a
 * {@link resolveSignerFromAgent} del core. El provider solo se ocupa de:
 *
 *  1. Resolver el agente Credo del tenant a partir del `walletId` (vía
 *     `withWallet`).
 *  2. Leer los overrides opcionales del `ConfigService` del issuer.
 *  3. Pasar el control al helper del core.
 *  4. Exponer un KMS que abre su propia sesión de tenant en cada firma.
 *
 * El paso 4 es obligatorio: `withWallet` cierra la sesión del tenant al
 * retornar y con ella su contenedor de dependencias, mientras que el core firma
 * después de resolver el firmante. Capturar el `agent.kms` de la sesión de
 * derivación haría fallar la firma con `container has been disposed`.
 *
 * Los overrides disponibles son:
 *
 * | Variable                            | Efecto                                            |
 * |-------------------------------------|---------------------------------------------------|
 * | `REVOCATION_SIGNER_ALG`             | Fuerza el `alg` JWS.                              |
 * | `REVOCATION_SIGNER_KID`             | Fuerza el `kid` completo.                         |
 * | `REVOCATION_SIGNER_KEY_FRAGMENT`    | Fragmento a usar (ej. `key-ed25519`).             |
 * | `REVOCATION_SIGNER_DID_METHOD`      | Método DID a buscar (`web` o `key`).              |
 *
 * Si no se pasan, todo se deriva automáticamente del estado real del
 * agente (DID record + KMS público).
 */
@Injectable()
export class CredoWalletSignerProvider implements SignerProvider {
  constructor(private readonly config: ConfigService) {}

  async resolveSigner(walletId: string): Promise<SignerOptions> {
    const opts = this.readOptions()
    const metadata = await withWallet(walletId, (agent) => resolveSignerFromAgent(agent, opts))

    return {
      ...metadata,
      kms: {
        sign: (options) =>
          withWallet(walletId, (agent) => agent.kms.sign(options as CredoKmsSignOptions)),
      },
    }
  }

  /**
   * Lee los overrides del `ConfigService`. Los `*Override` se mantienen
   * `undefined` si no se pasan por env var, lo que activa la derivación
   * automática en el core.
   */
  private readOptions(): SignerDerivationOptions {
    const cfg = this.config.get<{
      algOverride?: string
      kidOverride?: string
      keyFragment?: string
      didMethod?: 'web' | 'key'
    }>('revocationSigner')

    return {
      algOverride: cfg?.algOverride,
      kidOverride: cfg?.kidOverride,
      keyFragment: cfg?.keyFragment,
      didMethod: cfg?.didMethod,
    }
  }
}
