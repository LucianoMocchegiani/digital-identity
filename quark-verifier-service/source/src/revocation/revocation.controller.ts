import { Controller, Get, Param, ParseIntPipe, Post, Query, Body } from '@nestjs/common';
import { RevocationVerifierService } from './revocation.service';
import {
  GetStatusListDto,
  GetStatusDto,
  VerifyCredentialDto,
  GetStatusListResponseDto,
  GetStatusResponseDto,
  VerifyCredentialResponseDto,
} from './dto/revocation.dto';

@Controller('revocation')
export class RevocationController {
  constructor(private readonly revocationService: RevocationVerifierService) {}

  @Get('status')
  async getStatusList(
    @Query() query: GetStatusListDto
  ): Promise<GetStatusListResponseDto> {
    const result = await this.revocationService.getStatusList(query.uri);
    return {
      jwt: result.jwt,
      cached: result.cached,
      expiresAt: result.expiresAt,
    };
  }

  @Get('status-check')
  async getStatusFromQuery(
    @Query('uri') uri: string,
    @Query('idx', ParseIntPipe) idx: number
  ): Promise<GetStatusResponseDto> {
    const result = await this.revocationService.getStatus(uri, idx);
    return {
      revoked: result.revoked,
      status: result.status,
      updatedAt: result.updatedAt,
    };
  }

  @Get('status/:uri/:idx')
  async getStatus(
    @Param('uri') uri: string,
    @Param('idx') idx: number
  ): Promise<GetStatusResponseDto> {
    const result = await this.revocationService.getStatus(uri, idx);
    return {
      revoked: result.revoked,
      status: result.status,
      updatedAt: result.updatedAt,
    };
  }

  @Post('verify')
  async verifyCredential(
    @Body() body: VerifyCredentialDto
  ): Promise<VerifyCredentialResponseDto> {
    return this.revocationService.verifyCredential(body.credentialJwt);
  }
}