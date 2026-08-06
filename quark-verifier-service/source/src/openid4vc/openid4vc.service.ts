import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { createVerificationRequest, getVerificationSession } from '@quarkid/identity-core'

import { withWallet } from '../agent/agent-store'
import type { CreatePresentationRequestDto } from './openid4vc-request.dto'

/** Resultado de la creación de un authorization request OID4VP. */
export interface CreateRequestResult {
  requestUri: string
  verificationSessionId: string
}

@Injectable()
export class OpenId4VcService {
  private readonly logger = new Logger(OpenId4VcService.name)

  constructor(private readonly config: ConfigService) {}

  async createRequest(walletId: string, dto: CreatePresentationRequestDto): Promise<CreateRequestResult> {
    const oid4vcBaseUrl = this.config.get<string>('oid4vcBaseUrl')
    if (!oid4vcBaseUrl) {
      throw new ServiceUnavailableException('OID4VP no está habilitado: falta OID4VC_BASE_URL')
    }

    const x5cCertificatesBase64 = this.config.get<string[]>('oid4vpX5cCertificatesBase64') ?? []
    const x5cLeafCertificateKeyId = this.config.get<string>('oid4vpX5cLeafCertificateKeyId') ?? ''
    const x5cClientIdPrefix = (this.config.get<string>('oid4vpX5cClientIdPrefix') ?? 'x509_hash') as 'x509_hash' | 'x509_san_dns'

    if (
      dto.requestSignerMethod === 'x5c' &&
      (!x5cCertificatesBase64.length || !x5cLeafCertificateKeyId)
    ) {
      throw new ServiceUnavailableException(
        'OID4VP x5c no está configurado: definir OID4VP_X5C_CERTIFICATES_BASE64 y OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID',
      )
    }

    const result = await withWallet(walletId, (agent) => createVerificationRequest(agent, {
      presentationDefinition: dto.presentationDefinition,
      dcqlQuery: dto.dcqlQuery,
      responseMode: dto.responseMode,
      authorizationResponseRedirectUri: dto.authorizationResponseRedirectUri,
      requestSignerMethod: dto.requestSignerMethod ?? 'did',
      ...(dto.requestSignerMethod === 'x5c'
        ? {
            x5cCertificatesBase64,
            x5cLeafCertificateKeyId,
            x5cClientIdPrefix,
          }
        : {}),
    }))

    this.logger.log(
      `Presentation request creado: wallet=${walletId} session=${result.verificationSessionId}`,
      OpenId4VcService.name,
    )

    return result
  }

  /**
   * Retorna el estado actual de una sesión de verificación OID4VP.
   *
   * @param walletId - ID de la wallet del verifier
   * @param verificationSessionId - ID de la sesión de verificación
   * @returns Registro de la sesión con su estado (created, request-sent, response-received, done, error)
   */
  async getSession(walletId: string, verificationSessionId: string) {
    return withWallet(walletId, (agent) => getVerificationSession(agent, verificationSessionId))
  }
}
