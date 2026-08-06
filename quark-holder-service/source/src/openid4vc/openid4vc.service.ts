import {
  Injectable,
  Logger,
  UnprocessableEntityException,
} from '@nestjs/common'
import { receiveCredentialOffer, submitPresentation } from '@quarkid/identity-core'

import { withWallet } from '../agent/agent-store'
import type { ReceiveOfferDto, PresentCredentialDto } from './openid4vc.dto'
import { OpenId4VcErrorCode } from './openid4vc.errors'
import type { ReceiveOfferResponseDto, PresentResponseDto } from './openid4vc.response.dto'

@Injectable()
export class OpenId4VcService {
  private readonly logger = new Logger(OpenId4VcService.name)


  /**
   * Ejecuta el flujo OID4VCI completo para recibir credenciales desde un offer URI.
   *
   * @param walletId - ID de la wallet del holder
   * @param dto - URI del credential offer del issuer
   * @returns Credenciales recibidas y pendientes (deferred) con shape estable para el wallet
   */
  async receiveOffer(walletId: string, dto: ReceiveOfferDto): Promise<ReceiveOfferResponseDto> {
    const result = await withWallet(walletId, (agent) => receiveCredentialOffer(agent, dto.offerUri))
    this.logger.log(
      `Credenciales recibidas: ${result.credentials.length} inmediatas, ${result.deferredCredentials.length} diferidas`,
      OpenId4VcService.name,
    )
    return {
      credentials: result.credentials as unknown as ReceiveOfferResponseDto['credentials'],
      deferredCredentials:
        result.deferredCredentials as unknown as ReceiveOfferResponseDto['deferredCredentials'],
    }
  }

  /**
   * Resuelve un authorization request OID4VP y presenta automáticamente las credenciales
   * que lo satisfacen (PE: primera por descriptor, DCQL: queryResult directo).
   *
   * @param walletId - ID de la wallet del holder
   * @param dto - URI del authorization request del verifier
   * @returns Envelope con flag `ok` y respuesta cruda del verifier
   * @throws {UnprocessableEntityException} `NO_MATCHING_CREDENTIAL` si ninguna credencial satisface el request
   */
  async presentCredential(walletId: string, dto: PresentCredentialDto): Promise<PresentResponseDto> {
    const result = await withWallet(walletId, (agent) => submitPresentation(agent, dto.requestUri))
    if (!result) {
      throw new UnprocessableEntityException({
        message: 'Ninguna credencial almacenada satisface el request',
        errorCode: OpenId4VcErrorCode.NO_MATCHING_CREDENTIAL,
      })
    }
    return {
      ok: true,
      verifierResponse: result as unknown as Record<string, unknown>,
    }
  }
}
