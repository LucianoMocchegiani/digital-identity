import { Body, Controller, Get, Post, Req } from '@nestjs/common'
import type { Request } from 'express'
import { CreateIssuerDto } from './dto/create-issuer.dto'
import { IssuersService } from './issuers.service'

/**
 * Alta y listado de issuers bajo `/v1/issuers`.
 * Requiere `X-API-Key` del resource issuer (bound a `issuerId` / `:walletId`).
 */
@Controller('issuers')
export class IssuersController {
  constructor(private readonly issuersService: IssuersService) {}

  /**
   * Lista solo el issuer bound a la API key (no el catálogo global).
   */
  @Get()
  async list(@Req() req: Request) {
    const result = await this.issuersService.list()
    const walletId = req.billingAuth?.walletId
    if (!walletId) return result
    return {
      issuers: result.issuers.filter((item) => item.issuerId === walletId),
    }
  }

  @Post()
  create(@Body() body: CreateIssuerDto) {
    return this.issuersService.create(body)
  }
}
