import { Controller, Post, Body, Param } from '@nestjs/common'
import { OpenId4VcService, type CreateOfferResult } from './openid4vc.service'
import { CreateOfferDto } from './openid4vc-offer.dto'

/**
 * Endpoints OID4VCI del issuer expuestos por NestJS.
 *
 * Credo registra adicionalmente los siguientes endpoints directamente en Express
 * (bajo el prefijo configurado en OpenId4VcIssuerModule, ej. /openid4vc-flow):
 *
 *   GET  /{issuerId}/.well-known/openid-credential-issuer  — metadata del issuer (OID4VCI)
 *   GET  /{issuerId}/.well-known/oauth-authorization-server — metadata OAuth AS (RFC 8414)
 *   GET  /{issuerId}/offers/{offerId}                       — resolve del credential offer por ID
 *   POST /{issuerId}/token                                  — intercambio pre-authorized code → access token
 *   POST /{issuerId}/credential                             — solicitud de credencial (llama al credentialMapper)
 *
 * Estos endpoints los consume directamente la wallet; no pasan por NestJS.
 */
@Controller('issuers/:walletId/openid4vc')
export class OpenId4VcController {
  constructor(private readonly openId4VcService: OpenId4VcService) {}

  /**
   * Crea un credential offer OID4VCI pre-authorized.
   *
   * Retorna la URI que la wallet del holder escanea para iniciar el flujo de issuance.
   * Ruta admin vía gateway: `POST /v1/issuers/:walletId/openid4vc/offer`.
   *
   * @param walletId - ID de la wallet del issuer
   * @param body - Configuración del offer
   * @returns URI del credential offer y el ID de sesión
   */
  @Post('offer')
  async createOffer(@Param('walletId') walletId: string, @Body() body: CreateOfferDto): Promise<CreateOfferResult> {
    return this.openId4VcService.createOffer(walletId, body)
  }
}
