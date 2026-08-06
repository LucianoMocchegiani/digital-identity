import { Type } from 'class-transformer'
import {
  IsString,
  IsOptional,
  IsArray,
  ValidateNested,
  IsObject,
  IsInt,
  Min,
  Max,
} from 'class-validator'

/** Payload JSON-LD de la credencial a ofrecer (sin firma). */
export class CredentialDto {
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  '@context'?: string[]

  /**
   * Claims del titular. Se tipa como objeto abierto (no nested DTO) porque
   * `ValidationPipe({ whitelist: true })` elimina propiedades sin decorador
   * y dejaría solo `id` si usáramos un `CredentialSubjectDto` con index signature.
   */
  @IsObject()
  credentialSubject!: Record<string, unknown>

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  type?: string[]
}

/**
 * Body de `POST /v1/issuers/:walletId/didcomm/offer`.
 *
 * Crea invitación OOB + pending offer (espejo de OID4VCI). Sin `connectionId`:
 * el `id` del subject se completa con el DID del holder al conectar.
 */
export class CreateDidCommOfferDto {
  @ValidateNested()
  @Type(() => CredentialDto)
  @IsObject()
  credential!: CredentialDto

  /** Tipo de proof JSON-LD. Default identity-core: `BbsBlsSignature2020` (QUARK-990). Override p. ej. `Ed25519Signature2018`. */
  @IsOptional()
  @IsString()
  proofType?: string

  /** DID del issuer firmante; si se omite, usa el primer `did:web` del agente. */
  @IsOptional()
  @IsString()
  issuerDid?: string

  /**
   * TTL del pending offer en segundos (default 1800 = 30 min).
   * Si nadie escanea antes, el offer se descarta.
   */
  @IsOptional()
  @IsInt()
  @Min(60)
  @Max(86400)
  expiresInSeconds?: number
}

/** Parámetros internos para `offerCredential` de Credo (auto-offer al conectar). */
export type OfferCredentialParams = {
  connectionId: string
  credential: CredentialDto
  proofType?: string
  issuerDid?: string
}
