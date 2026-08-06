import {
  IsString,
  IsOptional,
  IsObject,
  IsDefined,
  Min,
  Max,
  IsInt,
} from 'class-validator'

/**
 * Body de `POST /v1/verifiers/:walletId/didcomm/request`.
 *
 * Crea invitación OOB + pending proof (espejo de issuer `didcomm/offer`).
 * Sin `connectionId`: el `request-presentation` se envía al conectar.
 */
export class CreateDidCommRequestDto {
  /**
   * Presentation Definition DIF PEX.
   * Define qué credenciales (y luego qué claims) debe presentar el holder.
   */
  @IsDefined()
  @IsObject()
  presentationDefinition!: Record<string, unknown>

  @IsOptional()
  @IsString()
  challenge?: string

  @IsOptional()
  @IsString()
  domain?: string

  /**
   * TTL del pending request en segundos (default 1800 = 30 min).
   */
  @IsOptional()
  @IsInt()
  @Min(60)
  @Max(86400)
  expiresInSeconds?: number
}

/** Parámetros internos para `requestProof` de Credo (auto-request al conectar). */
export type RequestProofParams = {
  connectionId: string
  presentationDefinition: Record<string, unknown>
  challenge?: string
  domain?: string
}
