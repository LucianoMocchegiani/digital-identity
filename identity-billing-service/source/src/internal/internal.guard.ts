import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { environmentConfig } from '../config/environment.config'

/**
 * Guard de rutas internas: exige header `x-internal-token`
 * igual a `BILLING_INTERNAL_TOKEN`.
 */
@Injectable()
export class InternalTokenGuard implements CanActivate {
  /**
   * @returns true si el token coincide
   * @throws {UnauthorizedException} token ausente o incorrecto
   */
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest()
    const header = req.headers['x-internal-token']
    const token = Array.isArray(header) ? header[0] : header
    if (!token || token !== environmentConfig().billingInternalToken) {
      throw new UnauthorizedException('Token interno inválido')
    }
    return true
  }
}
