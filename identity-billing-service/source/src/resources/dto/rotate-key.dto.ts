import { IsOptional, IsString, MaxLength } from 'class-validator'

/** Body opcional al rotar una API key. */
export class RotateKeyDto {
  /** Nombre descriptivo de la key nueva (default generado). */
  @IsOptional()
  @IsString()
  @MaxLength(80)
  keyName?: string
}
