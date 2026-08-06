import { IsIn, IsOptional, IsString, Matches, MaxLength, MinLength } from 'class-validator'
import { WALLET_ID_REGEX, WALLET_ID_VALIDATION_MESSAGE } from '../../common/wallet-id.validation'

/**
 * Un producto = un issuer o un verifier (con su API key).
 * No se crean en pares ni en el register.
 */
export class CreateProductDto {
  @IsString()
  @MinLength(2)
  @MaxLength(160)
  name!: string

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string

  @IsIn(['issuer', 'verifier'])
  service!: 'issuer' | 'verifier'

  @IsString()
  @Matches(WALLET_ID_REGEX, { message: WALLET_ID_VALIDATION_MESSAGE })
  walletId!: string
}
