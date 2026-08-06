import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator'

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
