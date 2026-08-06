import { Type } from 'class-transformer'
import { IsObject, IsOptional, IsString, Matches, ValidateNested } from 'class-validator'
import { WALLET_ID_REGEX, WALLET_ID_VALIDATION_MESSAGE } from '../../common/wallet-id.validation'

/**
 * Metadata OID4VP inicial (`OpenId4VcVerifierRecord.clientMetadata`).
 */
export class CreateVerifierOid4vpDto {
  @IsOptional()
  @IsObject()
  clientMetadata?: {
    client_name?: string
    logo_uri?: string
  }
}

/**
 * Body de `POST /verifiers`.
 *
 * Crea tenant + `DidRecord` + opcional `OpenId4VcVerifierRecord`.
 */
export class CreateVerifierDto {
  @IsString()
  @Matches(WALLET_ID_REGEX, { message: WALLET_ID_VALIDATION_MESSAGE })
  verifierId!: string

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateVerifierOid4vpDto)
  oid4vp?: CreateVerifierOid4vpDto
}
