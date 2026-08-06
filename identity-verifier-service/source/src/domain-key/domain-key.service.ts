import {
  ConflictException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common'
import { importDomainKey } from '@identity/core'
import { rootAgent } from '../agent/agent-store'

@Injectable()
export class DomainKeyService {
  /**
   * Importa una clave al backend Askar de dominio (`askar-domain-key`).
   * Visible desde todos los tenants vía resolución multi-backend de Credo.
   */
  async importDomainKey(
    keyId: string,
    privateJwk: Record<string, unknown>,
  ): Promise<{ keyId: string }> {
    if (!rootAgent) {
      throw new ServiceUnavailableException('Agent not initialized')
    }

    try {
      return await importDomainKey(rootAgent, keyId, privateJwk)
    } catch (error) {
      if (
        error instanceof Error &&
        error.name === 'KeyManagementKeyExistsError'
      ) {
        throw new ConflictException(`Domain key '${keyId}' ya existe`)
      }
      throw error
    }
  }
}
