import { Controller, Post, Body, Param } from '@nestjs/common'

import { OpenId4VcService } from './openid4vc.service'
import { ReceiveOfferDto, PresentCredentialDto } from './openid4vc.dto'
import type { ReceiveOfferResponseDto, PresentResponseDto } from './openid4vc.response.dto'

/**
 * Endpoints OID4VCI/OID4VP del holder expuestos por NestJS.
 *
 * A diferencia del issuer y el verifier, `OpenId4VcHolderModule` de Credo NO registra
 * rutas HTTP propias en Express — actúa exclusivamente como cliente saliente.
 * Los flujos que ejecuta internamente son:
 *
 *   OID4VCI — receive-offer:
 *     GET  <issuerBaseUrl>/openid4vc-flow/{issuerId}/offers/{offerId}   — resolve del credential offer
 *     POST <issuerBaseUrl>/openid4vc-flow/{issuerId}/token              — intercambio pre-authorized code → access token
 *     POST <issuerBaseUrl>/openid4vc-flow/{issuerId}/credential         — solicitud de credencial
 *
 *   OID4VP — present:
 *     GET  <verifierBaseUrl>/openid4vc-auth/{verifierId}/authorize/{requestId} — resolve del authorization request
 *     POST <verifierBaseUrl>/openid4vc-auth/{verifierId}/authorize/{requestId} — envío de vp_token (direct_post)
 *
 * Todas estas llamadas las realiza Credo de forma transparente al invocar receiveCredentialOffer
 * y submitPresentation desde openid4vc.service.ts.
 */
@Controller('holders/:walletId/openid4vc')
export class OpenId4VcController {
  constructor(private readonly openId4VcService: OpenId4VcService) {}

  /**
   * Recibe un credential offer OID4VCI y almacena las credenciales en la wallet del holder.
   *
   * Ejecuta el flujo pre-authorized code completo: resolve offer → request token → request credentials.
   * Ruta: `POST /v1/holders/:walletId/openid4vc/receive-offer` (gateway :3000 o directo :9005).
   *
   * @param body - URI del credential offer del issuer
   * @returns Envelope estable con `credentials` y `deferredCredentials`
   */
  @Post('receive-offer')
  async receiveOffer(@Param('walletId') walletId: string, @Body() body: ReceiveOfferDto): Promise<ReceiveOfferResponseDto> {
    return this.openId4VcService.receiveOffer(walletId, body)
  }

  /**
   * Presenta credenciales en respuesta a un authorization request OID4VP del verifier.
   *
   * Selecciona automáticamente la primera credencial que satisfaga cada descriptor
   * del presentation exchange o DCQL query.
   *
   * Ruta: `POST /v1/holders/:walletId/openid4vc/present` (gateway :3000 o directo :9005).
   *
   * @param walletId - ID de la wallet del holder
   * @param body - URI del authorization request del verifier
   * @returns Envelope con `ok: true` y la respuesta cruda del verifier
   */
  @Post('present')
  async presentCredential(@Param('walletId') walletId: string, @Body() body: PresentCredentialDto): Promise<PresentResponseDto> {
    return this.openId4VcService.presentCredential(walletId, body)
  }
}
