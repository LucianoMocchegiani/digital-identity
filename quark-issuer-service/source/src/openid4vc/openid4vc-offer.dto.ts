import { IsString, IsNotEmpty, IsOptional, IsObject } from 'class-validator'

/** Payload de un credential offer OID4VCI. */
export class CreateOfferDto {
  /**
   * Identificador de la configuración de credencial a ofrecer.
   * Debe coincidir con una entrada de `credentialConfigurationsSupported` del issuer.
   */
  @IsString()
  @IsNotEmpty()
  credentialConfigurationId!: string

  /**
   * Tipo de credencial SD-JWT (Verifiable Credential Type).
   * Se almacena en el claim `vct` del SD-JWT resultante.
   */
  @IsString()
  @IsNotEmpty()
  vct!: string

  /**
   * Claims a incluir en la credencial (nombre, fecha, etc.).
   * Se insertan directamente en el payload SD-JWT.
   */
  @IsObject()
  claims!: Record<string, unknown>

  /**
   * Frame de divulgación selectiva SD-JWT.
   * `_sd` lista los nombres de los claims que serán divulgables selectivamente.
   */
  @IsOptional()
  @IsObject()
  disclosureFrame?: { _sd?: string[] }

  /**
   * Display labels por claim para que la wallet los muestre con nombres legibles.
   * Ej: `{ "given_name": { "name": "Nombre", "locale": "es" } }`
   */
  @IsOptional()
  @IsObject()
  claimsDisplay?: Record<string, { name: string; locale?: string }>

  /**
   * Pre-authorized code a usar en el flujo OID4VCI pre-authorized.
   * Si no se provee, Credo-TS generará uno automáticamente.
   */
  @IsOptional()
  @IsString()
  preAuthorizedCode?: string
}
