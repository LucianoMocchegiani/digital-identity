import { BadGatewayException, Injectable, Logger } from '@nestjs/common'
import { environmentConfig } from '../config/environment.config'
import type { ResourceService } from '../entities/resource.entity'

/**
 * Llama a issuer/verifier para crear el tenant Credo tras el alta del producto.
 * Side effect: HTTP POST a `/v1/issuers` o `/v1/verifiers` con la API key nueva.
 */
@Injectable()
export class TenantProvisioner {
  private readonly logger = new Logger(TenantProvisioner.name)

  /**
   * Provisiona el tenant remoto. No-op si `PROVISION_ON_CREATE=false`.
   * 409 (ya existe) se trata como éxito.
   *
   * @param input.service - issuer | verifier
   * @param input.walletId - issuerId / verifierId
   * @param input.apiKey - Key recién creada (header `x-api-key`)
   * @throws {BadGatewayException} si falta URL, no hay contacto o el remoto falla
   */
  async provision(input: {
    service: ResourceService
    walletId: string
    apiKey: string
  }): Promise<void> {
    const cfg = environmentConfig()
    if (!cfg.provisionOnCreate) {
      this.logger.warn('PROVISION_ON_CREATE=false — se omite el provision del tenant')
      return
    }

    const base =
      input.service === 'issuer' ? cfg.issuerUrl?.replace(/\/$/, '') : cfg.verifierUrl?.replace(/\/$/, '')
    if (!base) {
      throw new BadGatewayException(
        `Falta ${input.service === 'issuer' ? 'ISSUER_URL' : 'VERIFIER_URL'} para provisionar el tenant`,
      )
    }

    const path = input.service === 'issuer' ? '/v1/issuers' : '/v1/verifiers'
    const body =
      input.service === 'issuer'
        ? {
            issuerId: input.walletId,
            oid4vc: {
              display: [{ name: input.walletId, locale: 'es' }],
              dpopSigningAlgValuesSupported: ['ES256'],
              credentialConfigurationsSupported: {},
            },
          }
        : {
            verifierId: input.walletId,
            oid4vp: {
              clientMetadata: { client_name: input.walletId },
            },
          }

    let res: Response
    try {
      res = await fetch(`${base}${path}`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-api-key': input.apiKey,
        },
        body: JSON.stringify(body),
      })
    } catch (err) {
      this.logger.error(`No se pudo contactar ${input.service}`, err instanceof Error ? err.stack : err)
      throw new BadGatewayException(
        `No se pudo contactar ${input.service} para provisionar el tenant`,
      )
    }

    const text = await res.text()
    if (!res.ok && res.status !== 409) {
      this.logger.error(`Provision ${input.service} falló: ${res.status} ${text}`)
      throw new BadGatewayException(
        `Falló el provision del ${input.service} (${res.status}): ${text.slice(0, 300)}`,
      )
    }

    this.logger.log(
      `Tenant ${input.service}/${input.walletId} provisionado${res.status === 409 ? ' (ya existía)' : ''}`,
    )
  }
}
