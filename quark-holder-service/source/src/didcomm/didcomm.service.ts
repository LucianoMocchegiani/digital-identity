import { Injectable, Logger } from '@nestjs/common'
import { receiveInvitation } from '@quarkid/identity-core'
import { withWallet } from '../agent/agent-store'

/**
 * DIDComm del holder: recibir invitaciones OOB del issuer/verifier.
 *
 * Offer/request y present-proof se completan vía listeners de identity-core
 * (`autoAcceptConnections`, acceptOffer, acceptCredential, present).
 */
@Injectable()
export class DidCommService {
  private readonly logger = new Logger(DidCommService.name)

  /**
   * Recibe una invitación OOB (short URL o URL con `oob=`).
   *
   * @param walletId - ID de la wallet del holder
   * @param invitationUrl - URL de invitación emitida por issuer/verifier
   * @returns Record OOB de Credo (o lo que exponga `receiveInvitation`)
   */
  async receiveInvitation(walletId: string, invitationUrl: string) {
    this.logger.log(`Receiving DIDComm invitation walletId=${walletId}`)
    return withWallet(walletId, (agent) => receiveInvitation(agent, invitationUrl))
  }
}
