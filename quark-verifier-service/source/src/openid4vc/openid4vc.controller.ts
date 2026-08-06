import { Controller, Post, Get, Body, Param } from '@nestjs/common'

import { OpenId4VcService, type CreateRequestResult } from './openid4vc.service'
import { CreatePresentationRequestDto } from './openid4vc-request.dto'

/**
 * Endpoints OID4VP del verifier expuestos por NestJS.
 *
 * Credo registra adicionalmente los siguientes endpoints directamente en Express
 * (bajo el prefijo configurado en OpenId4VcVerifierModule, ej. /openid4vc-auth):
 *
 *   GET  /{verifierId}/.well-known/oauth-authorization-server — metadata OAuth AS (RFC 8414)
 *   GET  /{verifierId}/authorization-requests/{requestId}    — resolve del request object JWT
 *   POST /{verifierId}/authorize                             — callback de la wallet con vp_token
 *
 * Estos endpoints los consume directamente la wallet; no pasan por NestJS.
 */
@Controller('verifiers/:walletId/openid4vc')
export class OpenId4VcController {
  constructor(private readonly openId4VcService: OpenId4VcService) {}

  /**
   * Crea un authorization request OID4VP.
   *
   * El holder (EUDI Wallet) resuelve la URI retornada para obtener las credenciales
   * solicitadas. La sesión de verificación queda pendiente hasta que el holder responda.
   * Ruta admin vía gateway: `POST /v1/verifiers/:walletId/openid4vc/request`.
   *
   * @param body - Presentation definition o DCQL query que define qué credenciales se solicitan
   * @returns URI del request y el ID de sesión para consultar el resultado posterior
   */
  @Post('request')
  async createRequest(@Param('walletId') walletId: string, @Body() body: CreatePresentationRequestDto): Promise<CreateRequestResult> {
    return this.openId4VcService.createRequest(walletId, body)
  }

  /**
   * Retorna el estado de una sesión de verificación OID4VP.
   *
   * Permite consultar si el holder ya respondió y si la presentación fue verificada.
   *
   * @param walletId - ID de la wallet del verifier
   * @param id - ID de la sesión de verificación
   * @returns Registro de la sesión con estado y credenciales presentadas (si disponibles)
   */
  @Get('session/:id')
  async getSession(@Param('walletId') walletId: string, @Param('id') id: string) {
    return this.openId4VcService.getSession(walletId, id)
  }
}
