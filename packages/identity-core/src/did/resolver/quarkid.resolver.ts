import { QuarkDidResolver } from './quark.resolver'

/**
 * Resuelve DIDs `did:quarkid` delegando al resolver upstream de QuarkID
 * (`GET {baseUrl}{pathPrefix}/:id`).
 *
 * Subclase liviana de {@link QuarkDidResolver} que solo cambia el método
 * declarado y el path HTTP — la lógica de `fetch`, parseo de la respuesta,
 * detección defensiva de errores envueltos en 200 OK y el mapeo de
 * errores (HTTP no-OK, fallo de red, JSON inválido) a
 * `didResolutionMetadata.error: 'notFound'` se hereda del padre.
 *
 * Se mantiene como subclase separada (no se renombra `did:custom` →
 * `did:quarkid` directamente) para preservar compatibilidad: el
 * `QuarkDidRegistrar` sigue creando DIDs `did:custom` y este resolver
 * no interfiere.
 *
 * @param baseUrl - URL base del servicio upstream (sin slash final obligatorio).
 * @param pathPrefix - Prefijo del path de resolución; default `/1.0/identifiers`
 *                     (shape estándar de un resolver W3C universal). Se
 *                     propaga al constructor del padre ({@link QuarkDidResolver})
 *                     como segundo argumento y queda disponible como
 *                     `pathPrefix` interno en la cadena de resolución.
 */
export class QuarkidDidResolver extends QuarkDidResolver {
  public override readonly supportedMethods = ['quarkid']

  constructor(baseUrl: string, pathPrefix: string = '/1.0/identifiers') {
    super(baseUrl, pathPrefix)
  }
}
