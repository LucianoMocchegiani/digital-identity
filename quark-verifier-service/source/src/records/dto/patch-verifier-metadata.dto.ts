import { IsObject, IsOptional } from 'class-validator'

/**
 * Body de `PATCH /v1/verifiers/:walletId/records/metadata`.
 *
 * Actualiza el record Credo **`OpenId4VcVerifierRecord`** (`clientMetadata` con merge).
 */
export class PatchVerifierMetadataDto {
  @IsOptional()
  @IsObject()
  clientMetadata?: {
    client_name?: string
    logo_uri?: string
  }
}
