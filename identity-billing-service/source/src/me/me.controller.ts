import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { BillingService } from '../billing/billing.service'
import { normalizePlanId } from '../billing/plans'
import { PlanBodyDto } from '../common/dto/plan-body.dto'

@Controller('me')
@UseGuards(JwtAuthGuard)
export class MeController {
  constructor(private readonly billing: BillingService) {}

  @Get()
  me(@Req() req: { user: { accountId: string } }) {
    return this.billing.getAccountPublic(req.user.accountId)
  }

  @Get('usage')
  usage(@Req() req: { user: { accountId: string } }) {
    return this.billing.getUsage(req.user.accountId)
  }

  @Get('plans')
  plans() {
    return this.billing.listPlans()
  }

  @Post('checkout')
  checkout(
    @Req() req: { user: { accountId: string } },
    @Body() body: PlanBodyDto,
  ) {
    return this.billing.createCheckout(req.user.accountId, normalizePlanId(body.plan))
  }
}
