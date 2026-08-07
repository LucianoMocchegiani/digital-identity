import {
  Body,
  Controller,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { BillingService } from '../billing/billing.service'
import { API_KEY_WARNING_SINGLE } from '../common/api-key-warning'
import { RotateKeyDto } from './dto/rotate-key.dto'

/**
 * Gestión de API keys de resources del usuario.
 * Auth: JWT Bearer ({@link JwtAuthGuard}); verifica ownership.
 */
@Controller()
@UseGuards(JwtAuthGuard)
export class ResourcesController {
  constructor(private readonly billing: BillingService) {}

  /**
   * Rota la API key de un resource propio.
   * Side effect: revoca keys previas; la nueva se muestra una sola vez.
   */
  @Post('resources/:resourceId/keys/rotate')
  async rotate(
    @Req() req: { user: { accountId: string } },
    @Param('resourceId', ParseUUIDPipe) resourceId: string,
    @Body() body: RotateKeyDto,
  ) {
    const result = await this.billing.rotateApiKeyForAccount(
      req.user.accountId,
      resourceId,
      body.keyName,
    )
    return {
      ...result,
      warning: API_KEY_WARNING_SINGLE,
    }
  }

  /** Revoca una API key propia. */
  @Post('api-keys/:apiKeyId/revoke')
  async revoke(
    @Req() req: { user: { accountId: string } },
    @Param('apiKeyId', ParseUUIDPipe) apiKeyId: string,
  ) {
    await this.billing.revokeApiKeyForAccount(req.user.accountId, apiKeyId)
    return { ok: true }
  }
}
