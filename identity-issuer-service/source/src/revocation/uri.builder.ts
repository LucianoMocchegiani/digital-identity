import { Injectable } from '@nestjs/common'
import type { StatusListUriBuilder } from '@identity/core'
import { environmentConfig } from '../config'

/**
 * Adapter de {@link StatusListUriBuilder} que devuelve una URI HTTP absoluta
 * bajo `PUBLIC_BASE_URL` del issuer.
 *
 * Esta es la URI que:
 *  - Se inyecta como `sub` en el JWT firmado de la StatusList.
 *  - Se publica como `status.status_list.uri` en las credenciales SD-JWT VC.
 *  - Los verificadores consumen (vía HTTP) para descargar la lista y validar
 *    el bit de una credencial concreta.
 *
 * El parámetro `issuerDid` se ignora deliberadamente: como la URI no se
 * deriva del DID, el adapter HTTP no necesita resolver el firmante.
 *
 * El prefijo reproducido es el mismo que la constante local previa
 * `STATUS_LIST_URI_PREFIX` en `RevocationIssuerService` (versión anterior),
 * para que los endpoints HTTP y los `status_list.uri` emitidos no cambien.
 */
@Injectable()
export class HttpStatusListUriBuilder implements StatusListUriBuilder {
  build(walletId: string, vct: string, _issuerDid: string): string {
    return `${environmentConfig().publicBaseUrl}/v1/issuers/${walletId}/revocation/status-list/${vct}`
  }
}
