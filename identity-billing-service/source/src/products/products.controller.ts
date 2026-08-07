import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { BillingService } from '../billing/billing.service'
import { CreateProductDto } from './dto/create-product.dto'
import { PatchProductDto } from './dto/patch-product.dto'

/**
 * CRUD de productos del usuario autenticado.
 * Auth: JWT Bearer. Crear producto provisiona tenant en issuer/verifier.
 */
@Controller('products')
@UseGuards(JwtAuthGuard)
export class ProductsController {
  constructor(private readonly billing: BillingService) {}

  /** Lista productos activos de la cuenta. */
  @Get()
  list(@Req() req: { user: { accountId: string } }) {
    return this.billing.listProducts(req.user.accountId)
  }

  /**
   * Alta de producto (issuer o verifier) + API key.
   * Side effect: provision remoto del tenant.
   */
  @Post()
  async create(
    @Req() req: { user: { accountId: string } },
    @Body() body: CreateProductDto,
  ) {
    const created = await this.billing.createProduct({
      accountId: req.user.accountId,
      name: body.name,
      description: body.description,
      service: body.service,
      walletId: body.walletId,
    })
    return this.billing.toProductCreateResponse(created)
  }

  /** Detalle de un producto propio. */
  @Get(':productId')
  get(
    @Req() req: { user: { accountId: string } },
    @Param('productId', ParseUUIDPipe) productId: string,
  ) {
    return this.billing.getProduct(req.user.accountId, productId)
  }

  /** Actualiza nombre/descripción. */
  @Patch(':productId')
  patch(
    @Req() req: { user: { accountId: string } },
    @Param('productId', ParseUUIDPipe) productId: string,
    @Body() body: PatchProductDto,
  ) {
    return this.billing.patchProduct(req.user.accountId, productId, body)
  }

  /**
   * Soft-delete: archiva producto y suspende resources.
   * @returns 204 No Content
   */
  @Delete(':productId')
  @HttpCode(204)
  async remove(
    @Req() req: { user: { accountId: string } },
    @Param('productId', ParseUUIDPipe) productId: string,
  ) {
    await this.billing.archiveProduct(req.user.accountId, productId)
  }

  /** Resources (issuer/verifier) asociados al producto. */
  @Get(':productId/resources')
  resources(
    @Req() req: { user: { accountId: string } },
    @Param('productId', ParseUUIDPipe) productId: string,
  ) {
    return this.billing.listProductResources(req.user.accountId, productId)
  }
}
