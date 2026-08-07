import { Body, Controller, Post } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { BillingService } from '../billing/billing.service'
import { environmentConfig } from '../config/environment.config'
import { LoginDto } from './dto/login.dto'
import { RegisterDto } from './dto/register.dto'

/**
 * Registro y login self-serve.
 * Auth: pública (sin JWT); emite Bearer JWT en la respuesta.
 */
@Controller('auth')
export class AuthController {
  constructor(
    private readonly billing: BillingService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Alta de cuenta free + JWT.
   * Side effect: crea Account + Subscription (sin productos).
   */
  @Post('register')
  async register(@Body() body: RegisterDto) {
    const result = await this.billing.register(body)
    const accessToken = await this.signToken(result.account.id, result.account.email)
    return {
      accessToken,
      account: result.account,
    }
  }

  /**
   * Login email/password → JWT + vista de cuenta.
   * @throws 401/403 vía BillingService
   */
  @Post('login')
  async login(@Body() body: LoginDto) {
    const account = await this.billing.login(body)
    const accessToken = await this.signToken(account.id, account.email)
    return {
      accessToken,
      account: this.billing.toAccountView(account),
    }
  }

  /** Firma JWT con `sub` = accountId. */
  private signToken(accountId: string, email: string | null): Promise<string> {
    const cfg = environmentConfig()
    return this.jwtService.signAsync(
      { sub: accountId, email },
      { secret: cfg.jwtSecret, expiresIn: cfg.jwtExpiresIn },
    )
  }
}
