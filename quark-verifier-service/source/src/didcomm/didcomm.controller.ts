import { Controller, Get, Post, Body, Param } from '@nestjs/common'
import { DidCommService } from './didcomm.service'
import { CreateDidCommRequestDto } from './didcomm-request.dto'

@Controller('verifiers/:walletId/didcomm')
export class DidCommController {
  constructor(private readonly didCommService: DidCommService) {}

  /**
   * Crea invitación OOB + pending proof en un solo paso (análogo a issuer `didcomm/offer`).
   *
   * El `request-presentation` se envía automáticamente al completar o reusar la conexión.
   *
   * @param walletId - ID de la wallet del verifier
   * @param body - Parámetros PEX opcionales; sin `connectionId`
   * @returns `{ invitation }` short URL `/oob/:pendingRequestId`, `pendingRequestId`, `expiresAt`
   */
  @Post('request')
  async createRequest(
    @Param('walletId') walletId: string,
    @Body() body: CreateDidCommRequestDto,
  ) {
    return this.didCommService.createRequest(walletId, body)
  }

  /**
   * Consulta el progreso / resultado de un request DIDComm por `pendingRequestId`.
   *
   * @param walletId - ID de la wallet del verifier
   * @param pendingRequestId - ID público retornado por `POST .../didcomm/request`
   */
  @Get('request/:pendingRequestId')
  async getRequest(
    @Param('walletId') walletId: string,
    @Param('pendingRequestId') pendingRequestId: string,
  ) {
    return this.didCommService.getRequestByPendingId(
      walletId,
      pendingRequestId,
    )
  }

  /**
   * Retorna el resultado completo de una verificación DIDComm present-proof.
   *
   * @param walletId - ID de la wallet del verifier
   * @param proofExchangeRecordId - ID del exchange DIDComm de Credo-TS
   */
  @Get('proofs/:proofExchangeRecordId')
  async getProofDetails(
    @Param('walletId') walletId: string,
    @Param('proofExchangeRecordId') proofExchangeRecordId: string,
  ) {
    return this.didCommService.getProofDetails(
      walletId,
      proofExchangeRecordId,
    )
  }
}
