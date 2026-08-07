import { IsIn, IsInt, IsOptional, IsString, Matches, Max, Min } from 'class-validator'
import { WALLET_ID_REGEX } from '../../common/wallet-id.validation'

/**
 * Body de `POST /internal/validate-and-meter`.
 * Usado por guards de issuer/verifier para auth + metering.
 */
export class ValidateAndMeterDto {
  /** API key en claro del resource. */
  @IsString()
  apiKey!: string

  @IsIn(['issuer', 'verifier'])
  service!: 'issuer' | 'verifier'

  /** Si se envía, debe coincidir con el walletId del resource. */
  @IsOptional()
  @IsString()
  @Matches(WALLET_ID_REGEX)
  walletId?: string

  /** Transacciones a consumir (default 1). */
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  count?: number
}
