import { Controller, Get } from '@nestjs/common'

/**
 * Healthcheck público (sin auth).
 * Ruta: `GET /health` (excluida del prefijo `/v1`).
 */
@Controller()
export class HealthController {
  /**
   * Indica que el servicio está vivo.
   * @returns `{ ok, service }`
   */
  @Get('health')
  health() {
    return { ok: true, service: 'identity-billing' }
  }
}
