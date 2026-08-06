import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common'
import { BillingService } from '../billing/billing.service'
import { normalizePlanId } from '../billing/plans'
import { API_KEY_WARNING_SINGLE } from '../common/api-key-warning'
import { PlanBodyDto } from '../common/dto/plan-body.dto'
import { CreateProductDto } from '../products/dto/create-product.dto'
import { RotateKeyDto } from '../resources/dto/rotate-key.dto'
import { AdminApiKeyGuard } from './admin.guard'
import { SetQuotaDto } from './dto/set-quota.dto'
import { SetStatusDto } from './dto/set-status.dto'

@Controller('admin')
@UseGuards(AdminApiKeyGuard)
export class AdminController {
  constructor(private readonly billing: BillingService) {}

  @Get('accounts')
  listAccounts() {
    return this.billing.listAccounts().then((rows) => rows.map((a) => this.billing.toAccountView(a)))
  }

  @Get('accounts/:accountId')
  async getAccount(@Param('accountId', ParseUUIDPipe) accountId: string) {
    const account = await this.billing.getAccount(accountId)
    const usage = await this.billing.getUsage(accountId)
    return { ...this.billing.toAccountView(account), usage }
  }

  @Post('accounts/:accountId/plan')
  async setPlan(
    @Param('accountId', ParseUUIDPipe) accountId: string,
    @Body() body: PlanBodyDto,
  ) {
    const account = await this.billing.setPlan(accountId, normalizePlanId(body.plan))
    return this.billing.toAccountView(account)
  }

  @Post('accounts/:accountId/status')
  async setStatus(
    @Param('accountId', ParseUUIDPipe) accountId: string,
    @Body() body: SetStatusDto,
  ) {
    const account = await this.billing.setAccountStatus(accountId, body.status)
    return this.billing.toAccountView(account)
  }

  @Post('accounts/:accountId/quota')
  async setQuota(
    @Param('accountId', ParseUUIDPipe) accountId: string,
    @Body() body: SetQuotaDto,
  ) {
    const account = await this.billing.setQuota(accountId, body)
    return this.billing.toAccountView(account)
  }

  /** Pago manual: activa plan pro. */
  @Post('accounts/:accountId/activate-paid')
  async activatePaid(@Param('accountId', ParseUUIDPipe) accountId: string) {
    const account = await this.billing.activatePaid(accountId)
    return this.billing.toAccountView(account)
  }

  @Post('accounts/:accountId/checkout')
  checkout(
    @Param('accountId', ParseUUIDPipe) accountId: string,
    @Body() body: PlanBodyDto,
  ) {
    return this.billing.createCheckout(accountId, normalizePlanId(body.plan))
  }

  /** Crea un producto = un issuer o un verifier + key. */
  @Post('accounts/:accountId/products')
  async createProduct(
    @Param('accountId', ParseUUIDPipe) accountId: string,
    @Body() body: CreateProductDto,
  ) {
    const created = await this.billing.createProduct({
      accountId,
      name: body.name,
      description: body.description,
      service: body.service,
      walletId: body.walletId,
    })
    return this.billing.toProductCreateResponse(created)
  }

  @Get('accounts/:accountId/menu')
  menu(@Param('accountId', ParseUUIDPipe) accountId: string) {
    return this.billing.listProducts(accountId)
  }

  @Post('resources/:resourceId/keys/rotate')
  async rotateKey(
    @Param('resourceId', ParseUUIDPipe) resourceId: string,
    @Body() body: RotateKeyDto,
  ) {
    const result = await this.billing.rotateApiKey(resourceId, body.keyName)
    return {
      ...result,
      warning: API_KEY_WARNING_SINGLE,
    }
  }

  @Post('api-keys/:apiKeyId/revoke')
  async revokeKey(@Param('apiKeyId', ParseUUIDPipe) apiKeyId: string) {
    await this.billing.revokeApiKey(apiKeyId)
    return { ok: true }
  }
}
