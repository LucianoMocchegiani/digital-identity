import {
  Body,
  Controller,
  Get,
  HttpException,
  HttpStatus,
  Param,
  Post,
  Res,
  UseGuards,
} from '@nestjs/common'
import type { Response } from 'express'
import { CredentialAlreadyRevokedError } from '@quarkid/identity-core'
import { RevocationIssuerService } from './revocation.service'
import {
  CreateStatusListDto,
  AllocateIndexDto,
  RevokeCredentialDto,
  CreateStatusListResponseDto,
  AllocateIndexResponseDto,
  RevokeCredentialResponseDto,
  GetStatusResponseDto,
} from './dto/revocation.dto'
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard'
import {
  IssuerScopesGuard,
  RequireScopes,
} from '../common/guards/issuer-scopes.guard'

/**
 * Controlador HTTP para gestión de StatusList y revocación de credenciales SD-JWT VC.
 *
 * Expone el flujo Token Status List (TSL) del core (`@quarkid/identity-core`)
 * bajo el prefijo `/v1/issuers/:walletId/revocation`:
 *
 * - `POST   /status-list`                 → crea (o recupera) la StatusList del par `(walletId, vct)`.
 * - `GET    /status-list/:vct`            → descarga el JWT firmado de la StatusList (`application/jwt`).
 * - `POST   /status-list/:vct/allocate`   → asigna un índice libre a una credencial emitida.
 * - `POST   /status-list/:vct/revoke`     → marca un índice como revocado.
 * - `GET    /status-list/:vct/:idx`       → consulta el estado de un índice.
 *
 * Los endpoints de mutación (`allocate`, `revoke`) requieren autenticación JWT
 * (`JwtAuthGuard`) y autorización por scope (`IssuerScopesGuard` con `@RequireScopes`).
 */
@Controller('issuers/:walletId/revocation')
export class RevocationController {
  constructor(private readonly revocationService: RevocationIssuerService) {}

  @Post('status-list')
  async createStatusList(
    @Param('walletId') walletId: string,
    @Body() dto: CreateStatusListDto,
  ): Promise<CreateStatusListResponseDto> {
    return this.revocationService.createStatusList(walletId, dto.vct, {
      bits: dto.bits,
      capacity: dto.capacity,
    })
  }

  @Get('status-list/:vct')
  async getStatusListJwt(
    @Param('walletId') walletId: string,
    @Param('vct') vct: string,
    @Res() res: Response,
  ): Promise<void> {
    const result = await this.revocationService.getStatusListJwt(walletId, vct)
    res.setHeader('Content-Type', 'application/jwt')
    res.send(result.jwt)
  }

  @Post('status-list/:vct/allocate')
  @UseGuards(JwtAuthGuard, IssuerScopesGuard)
  @RequireScopes('vcs:allocate')
  async allocateIndex(
    @Param('walletId') walletId: string,
    @Param('vct') vct: string,
    @Body() dto: AllocateIndexDto,
  ): Promise<AllocateIndexResponseDto> {
    return this.revocationService.allocateIndex(walletId, vct, {
      credentialId: dto.credentialId,
      preferredIndex: dto.preferredIndex,
    })
  }

  @Post('status-list/:vct/revoke')
  @UseGuards(JwtAuthGuard, IssuerScopesGuard)
  @RequireScopes('vcs:revoke')
  async revokeCredential(
    @Param('walletId') walletId: string,
    @Param('vct') vct: string,
    @Body() dto: RevokeCredentialDto,
  ): Promise<RevokeCredentialResponseDto> {
    try {
      const result = await this.revocationService.revoke(walletId, vct, dto.index, {
        reason: dto.reason,
        revokedBy: walletId,
      })
      return { revokedAt: result.revokedAt }
    } catch (error) {
      if (error instanceof CredentialAlreadyRevokedError) {
        throw new HttpException(
          { statusCode: HttpStatus.CONFLICT, message: error.message },
          HttpStatus.CONFLICT
        )
      }
      if (error instanceof Error && 'code' in error && error.code === 'CREDENTIAL_ALREADY_REVOKED') {
        throw new HttpException(
          { statusCode: HttpStatus.CONFLICT, message: error.message },
          HttpStatus.CONFLICT
        )
      }
      throw error
    }
  }

  @Get('status-list/:vct/:idx')
  async getStatus(
    @Param('walletId') walletId: string,
    @Param('vct') vct: string,
    @Param('idx') idx: number,
  ): Promise<GetStatusResponseDto> {
    const result = await this.revocationService.getStatus(walletId, vct, idx)
    return {
      status: result.status as 0 | 1,
      updatedAt: result.updatedAt,
    }
  }
}
