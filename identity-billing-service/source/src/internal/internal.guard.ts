import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { environmentConfig } from '../config/environment.config'

@Injectable()
export class InternalTokenGuard implements CanActivate {
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
