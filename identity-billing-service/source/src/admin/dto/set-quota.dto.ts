import { IsInt, IsOptional, Max, Min } from 'class-validator'

export class SetQuotaDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10_000)
  maxProducts?: number

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  rateLimitRpm?: number

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100_000_000)
  monthlyTxQuota?: number
}
