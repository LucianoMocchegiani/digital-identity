import { IsIn, IsObject, IsOptional, IsString } from 'class-validator'
import type { CreateVerificationRequestOptions } from '@quarkid/identity-core'

/** Parámetros para crear un authorization request OID4VP. */
export class CreatePresentationRequestDto {
  /**
   * Presentation definition que describe qué credenciales se solicitan al holder.
   * Sigue el formato de DIF Presentation Exchange 2.0.
   * Mutuamente excluyente con `dcqlQuery`.
   */
  @IsOptional()
  @IsObject()
  presentationDefinition?: Record<string, unknown>

  /**
   * DCQL query como alternativa al presentation definition.
   * Mutuamente excluyente con `presentationDefinition`.
   */
  @IsOptional()
  @IsObject()
  dcqlQuery?: Record<string, unknown>

  /**
   * Modo de respuesta OID4VP (direct_post, direct_post.jwt, etc.).
   * Por defecto usa `direct_post`.
   */
  @IsOptional()
  @IsString()
  @IsIn(['direct_post', 'direct_post.jwt'])
  responseMode?: CreateVerificationRequestOptions['responseMode']

  /**
   * URI a la que la wallet redirige al usuario tras completar la presentación.
   */
  @IsOptional()
  @IsString()
  authorizationResponseRedirectUri?: string

  /**
   * Método de signer para el request object OID4VP.
   * - `did`: firmado con DID (puede producir `client_id_scheme=did`)
   * - `none`: request sin firma (usa prefijo `redirect_uri`)
   * - `x5c`: firmado con cadena X.509 (usa prefijo x509_*)
   */
  @IsOptional()
  @IsString()
  @IsIn(['did', 'none', 'x5c'])
  requestSignerMethod?: 'did' | 'none' | 'x5c'

}
