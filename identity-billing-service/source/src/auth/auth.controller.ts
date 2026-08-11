import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Redirect,
  Res,
} from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import type { Response } from 'express'
import { BillingService } from '../billing/billing.service'
import { environmentConfig } from '../config/environment.config'
import { LoginDto } from './dto/login.dto'
import { RegisterDto } from './dto/register.dto'
import { OAuthService } from './oauth.service'

/**
 * Registro y login self-serve (+ OAuth Google/GitHub).
 * Auth: pública (sin JWT); emite Bearer JWT en la respuesta o redirect.
 */
@Controller('auth')
export class AuthController {
  constructor(
    private readonly billing: BillingService,
    private readonly jwtService: JwtService,
    private readonly oauth: OAuthService,
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

  /** Providers OAuth habilitados (client id/secret presentes). */
  @Get('oauth/providers')
  oauthProviders() {
    return this.oauth.configuredProviders()
  }

  /** Redirect al IdP (Google/GitHub). */
  @Get('oauth/:provider')
  @Redirect()
  startOAuth(@Param('provider') providerParam: string) {
    const provider = this.oauth.assertProvider(providerParam)
    return { url: this.oauth.buildAuthorizeUrl(provider), statusCode: 302 }
  }

  /** Callback OAuth → JWT → redirect al frontend. */
  @Get('oauth/:provider/callback')
  async oauthCallback(
    @Param('provider') providerParam: string,
    @Query('code') code: string | undefined,
    @Query('state') state: string | undefined,
    @Query('error') error: string | undefined,
    @Res() res: Response,
  ) {
    try {
      if (error) {
        return res.redirect(302, this.oauth.frontendErrorUrl(error))
      }
      const provider = this.oauth.assertProvider(providerParam)
      if (!code || !state) {
        return res.redirect(302, this.oauth.frontendErrorUrl('missing_code'))
      }
      this.oauth.verifyState(state, provider)
      const profile = await this.oauth.exchangeCode(provider, code)
      const result = await this.oauth.loginOrRegister(profile)
      const accessToken = await this.signToken(result.account.id, result.account.email)
      return res.redirect(302, this.oauth.frontendSuccessUrl(accessToken))
    } catch (err) {
      const message =
        err && typeof err === 'object' && 'message' in err
          ? String((err as { message: unknown }).message)
          : 'oauth_failed'
      return res.redirect(302, this.oauth.frontendErrorUrl(message.slice(0, 200)))
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
