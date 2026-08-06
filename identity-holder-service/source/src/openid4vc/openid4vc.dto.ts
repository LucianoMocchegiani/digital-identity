import { IsString, IsNotEmpty } from 'class-validator'

/** Parámetros para recibir un credential offer OID4VCI. */
export class ReceiveOfferDto {
  /**
   * URI del credential offer emitido por el issuer.
   * Formato: `openid-credential-offer://...` o URL HTTPS con `credential_offer` param.
   */
  @IsString()
  @IsNotEmpty()
  offerUri!: string
}

/** Parámetros para presentar credenciales en respuesta a un authorization request OID4VP. */
export class PresentCredentialDto {
  /**
   * URI del authorization request emitido por el verifier.
   * El holder resuelve esta URI para obtener las credenciales solicitadas.
   */
  @IsString()
  @IsNotEmpty()
  requestUri!: string
}
