import {
  BadRequestException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common'
import { createHash, randomBytes } from 'crypto'
import { environmentConfig } from '../config/environment.config'
import type { OAuthProvider } from '../entities/account-identity.entity'
import { BillingService } from '../billing/billing.service'

export type OAuthProfile = {
  provider: OAuthProvider
  subject: string
  email: string | null
  name: string | null
  emailVerified?: boolean
}

/**
 * OAuth Google / GitHub (authorization code) sin Passport.
 */
@Injectable()
export class OAuthService {
  constructor(private readonly billing: BillingService) {}

  /** Qué providers tienen client id+secret configurados. */
  configuredProviders(): { google: boolean; github: boolean } {
    const cfg = environmentConfig()
    return {
      google: Boolean(cfg.oauth.googleClientId && cfg.oauth.googleClientSecret),
      github: Boolean(cfg.oauth.githubClientId && cfg.oauth.githubClientSecret),
    }
  }

  assertProvider(provider: string): OAuthProvider {
    if (provider !== 'google' && provider !== 'github') {
      throw new BadRequestException('Provider inválido (google|github)')
    }
    const configured = this.configuredProviders()
    if (!configured[provider]) {
      throw new ServiceUnavailableException(
        `OAuth ${provider} no configurado (faltan client id/secret en billing)`,
      )
    }
    return provider
  }

  /** URL de authorize + state firmado (HMAC). */
  buildAuthorizeUrl(provider: OAuthProvider): string {
    const cfg = environmentConfig()
    const state = this.signState(provider)
    const redirectUri = this.callbackUrl(provider)

    if (provider === 'google') {
      const u = new URL('https://accounts.google.com/o/oauth2/v2/auth')
      u.searchParams.set('client_id', cfg.oauth.googleClientId)
      u.searchParams.set('redirect_uri', redirectUri)
      u.searchParams.set('response_type', 'code')
      u.searchParams.set('scope', 'openid email profile')
      u.searchParams.set('state', state)
      u.searchParams.set('access_type', 'online')
      u.searchParams.set('prompt', 'select_account')
      return u.toString()
    }

    const u = new URL('https://github.com/login/oauth/authorize')
    u.searchParams.set('client_id', cfg.oauth.githubClientId)
    u.searchParams.set('redirect_uri', redirectUri)
    u.searchParams.set('scope', 'read:user user:email')
    u.searchParams.set('state', state)
    return u.toString()
  }

  verifyState(state: string, provider: OAuthProvider): void {
    const [payloadB64, sig] = state.split('.')
    if (!payloadB64 || !sig) throw new BadRequestException('state inválido')
    const expected = this.hmac(payloadB64)
    if (expected !== sig) throw new BadRequestException('state inválido')
    let parsed: { p: string; exp: number }
    try {
      parsed = JSON.parse(Buffer.from(payloadB64, 'base64url').toString('utf8'))
    } catch {
      throw new BadRequestException('state inválido')
    }
    if (parsed.p !== provider) throw new BadRequestException('state provider mismatch')
    if (Date.now() > parsed.exp) throw new BadRequestException('state expirado')
  }

  async exchangeCode(provider: OAuthProvider, code: string): Promise<OAuthProfile> {
    if (provider === 'google') return this.exchangeGoogle(code)
    return this.exchangeGithub(code)
  }

  /**
   * Login o alta free por identidad OAuth.
   * Si el email ya existe en otra cuenta, vincula la identidad (email verificado por el IdP).
   */
  async loginOrRegister(profile: OAuthProfile) {
    return this.billing.findOrCreateFromOAuth(profile)
  }

  callbackUrl(provider: OAuthProvider): string {
    const cfg = environmentConfig()
    const base = cfg.oauth.publicBaseUrl.replace(/\/$/, '')
    return `${base}/auth/oauth/${provider}/callback`
  }

  frontendSuccessUrl(accessToken: string): string {
    const cfg = environmentConfig()
    const u = new URL('/login/oauth/callback', cfg.oauth.frontendUrl)
    u.searchParams.set('accessToken', accessToken)
    return u.toString()
  }

  frontendErrorUrl(message: string): string {
    const cfg = environmentConfig()
    const u = new URL('/login', cfg.oauth.frontendUrl)
    u.searchParams.set('oauthError', message)
    return u.toString()
  }

  private signState(provider: OAuthProvider): string {
    const payload = Buffer.from(
      JSON.stringify({ p: provider, exp: Date.now() + 10 * 60 * 1000, n: randomBytes(8).toString('hex') }),
    ).toString('base64url')
    return `${payload}.${this.hmac(payload)}`
  }

  private hmac(payloadB64: string): string {
    const cfg = environmentConfig()
    return createHash('sha256')
      .update(`${cfg.jwtSecret}:oauth:${payloadB64}`)
      .digest('base64url')
  }

  private async exchangeGoogle(code: string): Promise<OAuthProfile> {
    const cfg = environmentConfig()
    const body = new URLSearchParams({
      code,
      client_id: cfg.oauth.googleClientId,
      client_secret: cfg.oauth.googleClientSecret,
      redirect_uri: this.callbackUrl('google'),
      grant_type: 'authorization_code',
    })
    const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    })
    if (!tokenRes.ok) {
      throw new BadRequestException('No se pudo intercambiar el code de Google')
    }
    const tokenJson = (await tokenRes.json()) as { access_token?: string }
    if (!tokenJson.access_token) {
      throw new BadRequestException('Token Google inválido')
    }
    const userRes = await fetch('https://openidconnect.googleapis.com/v1/userinfo', {
      headers: { Authorization: `Bearer ${tokenJson.access_token}` },
    })
    if (!userRes.ok) throw new BadRequestException('No se pudo leer el perfil de Google')
    const user = (await userRes.json()) as {
      sub?: string
      email?: string
      email_verified?: boolean
      name?: string
    }
    if (!user.sub) throw new BadRequestException('Perfil Google sin sub')
    return {
      provider: 'google',
      subject: user.sub,
      email: user.email?.toLowerCase() ?? null,
      name: user.name ?? null,
      emailVerified: user.email_verified === true,
    }
  }

  private async exchangeGithub(code: string): Promise<OAuthProfile> {
    const cfg = environmentConfig()
    const tokenRes = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        client_id: cfg.oauth.githubClientId,
        client_secret: cfg.oauth.githubClientSecret,
        code,
        redirect_uri: this.callbackUrl('github'),
      }),
    })
    if (!tokenRes.ok) throw new BadRequestException('No se pudo intercambiar el code de GitHub')
    const tokenJson = (await tokenRes.json()) as { access_token?: string; error?: string }
    if (!tokenJson.access_token) {
      throw new BadRequestException(tokenJson.error ?? 'Token GitHub inválido')
    }
    const userRes = await fetch('https://api.github.com/user', {
      headers: {
        Authorization: `Bearer ${tokenJson.access_token}`,
        Accept: 'application/vnd.github+json',
        'User-Agent': 'kuatia-billing',
      },
    })
    if (!userRes.ok) throw new BadRequestException('No se pudo leer el perfil de GitHub')
    const user = (await userRes.json()) as {
      id?: number
      login?: string
      name?: string
      email?: string | null
    }
    if (user.id == null) throw new BadRequestException('Perfil GitHub sin id')

    let email = user.email?.toLowerCase() ?? null
    if (!email) {
      const emailsRes = await fetch('https://api.github.com/user/emails', {
        headers: {
          Authorization: `Bearer ${tokenJson.access_token}`,
          Accept: 'application/vnd.github+json',
          'User-Agent': 'kuatia-billing',
        },
      })
      if (emailsRes.ok) {
        const emails = (await emailsRes.json()) as {
          email: string
          primary?: boolean
          verified?: boolean
        }[]
        const primary =
          emails.find((e) => e.primary && e.verified) ?? emails.find((e) => e.verified)
        email = primary?.email?.toLowerCase() ?? null
      }
    }

    return {
      provider: 'github',
      subject: String(user.id),
      email,
      name: user.name || user.login || null,
      emailVerified: Boolean(email),
    }
  }
}
