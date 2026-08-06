import { IsIn, IsInt, IsOptional, IsString, Matches, Max, Min } from 'class-validator'
import { WALLET_ID_REGEX } from '../../common/wallet-id.validation'

export class ValidateAndMeterDto {
  @IsString()
  apiKey!: string

  @IsIn(['issuer', 'verifier'])
  service!: 'issuer' | 'verifier'

  @IsOptional()
  @IsString()
  @Matches(WALLET_ID_REGEX)
  walletId?: string

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  count?: number
}
