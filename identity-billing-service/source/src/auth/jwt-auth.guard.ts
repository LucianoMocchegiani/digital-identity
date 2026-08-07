import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { environmentConfig } from '../config/environment.config'

/** Claims esperados en el Bearer JWT de billing. */
export type JwtPayload = {
  /** accountId */
  sub: string
  email: string | null
}

/**
 * Guard JWT: exige `Authorization: Bearer <token>`.
 * Adjunta `req.user = { accountId, email }` si es válido.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  /**
   * @returns true si el token es válido
   * @throws {UnauthorizedException} ausente, inválido o expirado
   */
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest()
    const header = req.headers.authorization
    const value = Array.isArray(header) ? header[0] : header
    if (!value || typeof value !== 'string' || !value.startsWith('Bearer ')) {
      throw new UnauthorizedException('Falta Bearer token')
    }
    const token = value.slice('Bearer '.length).trim()
    try {
      const payload = this.jwtService.verify<JwtPayload>(token, {
        secret: environmentConfig().jwtSecret,
      })
      req.user = { accountId: payload.sub, email: payload.email }
      return true
    } catch {
      throw new UnauthorizedException('Token inválido o expirado')
    }
  }
}
