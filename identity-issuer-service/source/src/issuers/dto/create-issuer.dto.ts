import { Type } from 'class-transformer'
import { IsArray, IsObject, IsOptional, IsString, Matches, ValidateNested } from 'class-validator'
import { WALLET_ID_REGEX, WALLET_ID_VALIDATION_MESSAGE } from '../../common/wallet-id.validation'

/**
 * Opciones OID4VCI iniciales al dar de alta un issuer.
 * Se persisten en el record Credo `OpenId4VcIssuerRecord`.
 */
export class CreateIssuerOid4vcDto {
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

/**
 * Body de `POST /issuers`.
 *
 * Crea el tenant y los records `DidRecord` + opcional `OpenId4VcIssuerRecord`.
 */
export class CreateIssuerDto {
  /** ID lógico del issuer (tenant label y `issuerId` en OID4VCI). */
  @IsString()
  @Matches(WALLET_ID_REGEX, { message: WALLET_ID_VALIDATION_MESSAGE })
  issuerId!: string

  /** Metadata OID4VCI inicial; si se omite, solo se crean tenant + DID web. */
  @IsOptional()
  @ValidateNested()
  @Type(() => CreateIssuerOid4vcDto)
  oid4vc?: CreateIssuerOid4vcDto
}
