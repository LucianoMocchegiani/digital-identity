import { IsOptional, IsString, MaxLength } from 'class-validator'

export class RotateKeyDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  keyName?: string
}
