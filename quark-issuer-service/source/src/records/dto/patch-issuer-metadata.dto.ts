import { IsArray, IsObject, IsOptional } from 'class-validator'

/**
 * Body de `PATCH /v1/issuers/:walletId/records/metadata`.
 *
 * Actualiza únicamente el record Credo **`OpenId4VcIssuerRecord`**
 * (merge de `credentialConfigurationsSupported` y demás campos vía Credo `updateIssuerMetadata`).
 */
export class PatchIssuerMetadataDto {
  @IsOptional()
  @IsArray()
  display?: Array<Record<string, unknown>>

  @IsOptional()
  @IsObject()
  credentialConfigurationsSupported?: Record<string, unknown>

  @IsOptional()
  @IsArray()
  dpopSigningAlgValuesSupported?: string[]

  @IsOptional()
  @IsObject()
  batchCredentialIssuance?: Record<string, unknown>

  @IsOptional()
  @IsArray()
  authorizationServerConfigs?: Array<Record<string, unknown>>
}
