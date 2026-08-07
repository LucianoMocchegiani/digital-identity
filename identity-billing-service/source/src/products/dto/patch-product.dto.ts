import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator'

/** Actualización parcial de metadatos de producto (no cambia service/walletId). */
export class PatchProductDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(160)
  name?: string

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string
}
