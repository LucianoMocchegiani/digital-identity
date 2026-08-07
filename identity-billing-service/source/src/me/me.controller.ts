import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { BillingService } from '../billing/billing.service'
import { normalizePlanId } from '../billing/plans'
import { PlanBodyDto } from '../common/dto/plan-body.dto'

/**
 * Perfil y uso de la cuenta autenticada.
 * Auth: JWT Bearer ({@link JwtAuthGuard}).
 */
@Controller('me')
@UseGuards(JwtAuthGuard)
export class MeController {
  constructor(private readonly billing: BillingService) {}

  /** Datos públicos de la cuenta del token. */
  @Get()
  me(@Req() req: { user: { accountId: string } }) {
    return this.billing.getAccountPublic(req.user.accountId)
  }

  /** Uso/cuota del período UTC actual. */
  @Get('usage')
  usage(@Req() req: { user: { accountId: string } }) {
    return this.billing.getUsage(req.user.accountId)
  }

  /** Catálogo de planes (público para el usuario logueado). */
  @Get('plans')
  plans() {
    return this.billing.listPlans()
  }

  /** Inicia checkout para upgrade de plan. */
  @Post('checkout')
  checkout(
    @Req() req: { user: { accountId: string } },
    @Body() body: PlanBodyDto,
  ) {
    return this.billing.createCheckout(req.user.accountId, normalizePlanId(body.plan))
  }
}
