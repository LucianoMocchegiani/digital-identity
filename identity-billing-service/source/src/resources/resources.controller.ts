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

@Controller()
@UseGuards(JwtAuthGuard)
export class ResourcesController {
  constructor(private readonly billing: BillingService) {}

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

  @Post('api-keys/:apiKeyId/revoke')
  async revoke(
    @Req() req: { user: { accountId: string } },
    @Param('apiKeyId', ParseUUIDPipe) apiKeyId: string,
  ) {
    await this.billing.revokeApiKeyForAccount(req.user.accountId, apiKeyId)
    return { ok: true }
  }
}
