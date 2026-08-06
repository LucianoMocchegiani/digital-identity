import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { createSdJwtOffer } from '@identity/core'
import { withWallet } from '../agent/agent-store'
import { RevocationIssuerService } from '../revocation/revocation.service'
import type { CreateOfferDto } from './openid4vc-offer.dto'

export interface CreateOfferResult {
  offerUri: string
  issuanceSessionId: string
}

@Injectable()
export class OpenId4VcService {
  private readonly logger = new Logger(OpenId4VcService.name)

  constructor(
    private readonly config: ConfigService,
    private readonly revocationService: RevocationIssuerService,
  ) {}

  /**
   * Crea un credential offer OID4VCI pre-authorized para la wallet del issuer indicada.
   *
   * Asigna un índice en la StatusList antes de delegar a `createSdJwtOffer` para que la
   * credencial emitida quede vinculada a una posición revocable.
   *
   * @param walletId - ID de la wallet del issuer
   * @param dto - Configuración del offer (credentialConfigurationId, vct, claims, etc.)
   * @returns URI del credential offer y el ID de sesión de issuance
   * @throws {ServiceUnavailableException} Si `OID4VC_BASE_URL` no está configurado
   */
  async createOffer(walletId: string, dto: CreateOfferDto): Promise<CreateOfferResult> {
    const oid4vcBaseUrl = this.config.get<string>('oid4vcBaseUrl')
    if (!oid4vcBaseUrl) {
      throw new ServiceUnavailableException('OID4VCI no está habilitado: falta OID4VC_BASE_URL')
    }

    const supportedAlgorithms = this.config.get<string[]>('oid4vcSupportedAlgs') ?? ['ES256']
    const { index, uri } = await this.revocationService.allocateIndex(walletId, dto.vct, {
      credentialId: `offer-${Date.now()}`,
    })

    const result = await withWallet(walletId, (agent) =>
      createSdJwtOffer(agent, {
        configurationId: dto.credentialConfigurationId,
        preAuthorizedCode: dto.preAuthorizedCode,
        vct: dto.vct,
        claims: dto.claims,
        claimsDisplay: dto.claimsDisplay,
        disclosureFrame: dto.disclosureFrame,
        issuerId: walletId,
        issuerDisplay: [{ name: walletId, locale: 'es' }],
        supportedAlgorithms,
        status: {
          status_list: { idx: index, uri },
        },
      }),
    )

    this.logger.log(
      `Offer creado: wallet=${walletId} session=${result.issuanceSessionId} config=${dto.credentialConfigurationId} statusIdx=${index}`,
    )

    return result
  }
}
