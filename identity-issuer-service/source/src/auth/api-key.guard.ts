import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common'
import { Reflector } from '@nestjs/core'
import { IS_PUBLIC_KEY } from './public.decorator'
import type { BillingAuthContext } from './billing-auth.types'

@Injectable()
export class ApiKeyAuthGuard implements CanActivate {
  private readonly logger = new Logger(ApiKeyAuthGuard.name)

  constructor(private readonly reflector: Reflector) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (isPublic) return true

    const enabled = (process.env.API_KEY_AUTH_ENABLED ?? 'true').toLowerCase() !== 'false'
    if (!enabled) return true

    const billingUrl = process.env.BILLING_URL
    const internalToken = process.env.BILLING_INTERNAL_TOKEN
    if (!billingUrl || !internalToken) {
      throw new ServiceUnavailableException(
        'Auth por API key habilitada pero faltan BILLING_URL / BILLING_INTERNAL_TOKEN',
      )
    }

    const req = context.switchToHttp().getRequest()
    const apiKey = this.extractApiKey(req)
    if (!apiKey) {
      throw new UnauthorizedException('Falta header X-API-Key')
    }

    const walletId =
      (req.params?.walletId as string | undefined) ??
      (req.body?.issuerId as string | undefined)

    let auth: BillingAuthContext
    try {
      const res = await fetch(
        `${billingUrl.replace(/\/$/, '')}/v1/internal/validate-and-meter`,
        {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-internal-token': internalToken,
          },
          body: JSON.stringify({
            apiKey,
            service: 'issuer',
            walletId,
            count: 1,
          }),
        },
      )
      const text = await res.text()
      const body = text ? JSON.parse(text) : null
      if (res.status === 401) throw new UnauthorizedException(body?.message ?? 'API key inválida')
      if (res.status === 403) throw new ForbiddenException(body?.message ?? 'Prohibido')
      if (res.status === 402) {
        throw new HttpException(
          body ?? { message: 'Cuota mensual de transacciones agotada' },
          HttpStatus.PAYMENT_REQUIRED,
        )
      }
      if (res.status === 429) {
        throw new HttpException(
          body ?? { message: 'Rate limit excedido' },
          HttpStatus.TOO_MANY_REQUESTS,
        )
      }
      if (!res.ok) {
        this.logger.error(`Falló validate-and-meter billing: ${res.status} ${text}`)
        throw new ServiceUnavailableException('Falló la validación en billing')
      }
      auth = body as BillingAuthContext
    } catch (err) {
      if (
        err instanceof UnauthorizedException ||
        err instanceof ForbiddenException ||
        err instanceof ServiceUnavailableException ||
        err instanceof HttpException
      ) {
        throw err
      }
      this.logger.error('Error al validar con billing', err instanceof Error ? err.stack : err)
      throw new ServiceUnavailableException('Servicio de billing no disponible')
    }

    req.billingAuth = auth
    return true
  }

  private extractApiKey(req: {
    headers: Record<string, string | string[] | undefined>
  }): string | undefined {
    const header = req.headers['x-api-key']
    if (typeof header === 'string' && header.trim()) return header.trim()
    if (Array.isArray(header) && header[0]) return header[0].trim()

    const auth = req.headers.authorization
    const value = Array.isArray(auth) ? auth[0] : auth
    if (value?.startsWith('Bearer ')) {
      const token = value.slice('Bearer '.length).trim()
      if (token.startsWith('iss_') || token.startsWith('ver_')) return token
    }
    return undefined
  }
}
