import { IsInt, IsOptional, Max, Min } from 'class-validator'

/**
 * Override parcial de cupos de una cuenta (admin).
 * Campos omitidos no se modifican.
 */
export class SetQuotaDto {
  /** Máximo de productos activos. */
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10_000)
  maxProducts?: number

  /** Rate limit requests/minuto. */
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  rateLimitRpm?: number

  /** Cuota mensual de transacciones. */
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100_000_000)
  monthlyTxQuota?: number
}
