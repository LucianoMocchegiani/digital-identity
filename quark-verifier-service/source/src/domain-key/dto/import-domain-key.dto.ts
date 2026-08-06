import { IsObject, IsString } from 'class-validator'

export class ImportDomainKeyDto {
  @IsString()
  keyId!: string

  @IsObject()
  privateJwk!: Record<string, unknown>
}
