import { Body, Controller, Post, UseGuards } from '@nestjs/common'
import { BillingService } from '../billing/billing.service'
import { ValidateAndMeterDto } from './dto/validate-and-meter.dto'
import { InternalTokenGuard } from './internal.guard'

@Controller('internal')
@UseGuards(InternalTokenGuard)
export class InternalController {
  constructor(private readonly billing: BillingService) {}

  /** Path de issuer/verifier: auth + rate limit + cuota en un round-trip. */
  @Post('validate-and-meter')
  validateAndMeter(@Body() body: ValidateAndMeterDto) {
    return this.billing.validateAndMeter(body)
  }
}
