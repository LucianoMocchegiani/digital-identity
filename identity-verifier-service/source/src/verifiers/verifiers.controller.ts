import { Body, Controller, Get, Post, Req } from '@nestjs/common'
import type { Request } from 'express'
import { CreateVerifierDto } from './dto/create-verifier.dto'
import { VerifiersService } from './verifiers.service'

/**
 * Alta de verifiers en `GET|POST /v1/verifiers`.
 * Requiere `X-API-Key` del resource verifier.
 */
@Controller('verifiers')
export class VerifiersController {
  constructor(private readonly verifiersService: VerifiersService) {}

  @Get()
  async list(@Req() req: Request) {
    const result = await this.verifiersService.list()
    const walletId = req.billingAuth?.walletId
    if (!walletId) return result
    return {
      verifiers: result.verifiers.filter((item) => item.verifierId === walletId),
    }
  }

  @Post()
  create(@Body() body: CreateVerifierDto) {
    return this.verifiersService.create(body)
  }
}
