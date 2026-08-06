import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest()
    const token = this.extractBearer(request.headers.authorization)

    if (!token) {
      throw new UnauthorizedException('Falta Bearer token')
    }

    try {
      const payload = await this.jwtService.verifyAsync(token)
      request.user = {
        ...payload,
        scopes: payload.scopes ?? [],
      }
      return true
    } catch {
      throw new UnauthorizedException('Token inválido o expirado')
    }
  }

  private extractBearer(auth?: string): string | undefined {
    const [type, token] = auth?.split(' ') ?? []
    return type === 'Bearer' ? token : undefined
  }
}
