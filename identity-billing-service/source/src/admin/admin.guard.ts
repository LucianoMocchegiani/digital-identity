import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { environmentConfig } from '../config/environment.config'

/**
 * Guard de rutas admin: exige header `x-admin-key` o `x-api-key`
 * igual a `ADMIN_API_KEY`.
 */
@Injectable()
export class AdminApiKeyGuard implements CanActivate {
  /**
   * @returns true si la key es válida
   * @throws {UnauthorizedException} key ausente o incorrecta
   */
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest()
    const header = req.headers['x-admin-key'] ?? req.headers['x-api-key']
    const key = Array.isArray(header) ? header[0] : header
    if (!key || key !== environmentConfig().adminApiKey) {
      throw new UnauthorizedException('API key de admin inválida')
    }
    return true
  }
}
