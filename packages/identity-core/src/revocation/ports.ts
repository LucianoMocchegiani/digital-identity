import type { SignerOptions } from './status-list.types';

/**
 * Puerto para resolver las opciones de firma de un tenant concreto.
 *
 * Encapsula *cómo* se obtiene el `SignerOptions` (DID, keyId, kid, alg, kms)
 * para un `walletId` dado. El core no necesita saber si el firmante vive en
 * un agente Credo multi-tenant, en un KMS externo o en una configuración
 * estática: solo invoca `resolveSigner(walletId)` cuando necesita firmar.
 *
 * Implementaciones de referencia:
 *  - Issuer de QuarkID: {@link import('@quarkid/issuer-service').CredoWalletSignerProvider}
 *    (consulta el primer `did:web` y su primera clave KMS del agente del tenant).
 *  - Tests o consumidores custom: cualquier clase que implemente el contrato.
 *
 * El `SignerOptions` resultante **no debe mutarse** entre llamadas: el core
 * lo cachea localmente durante una sola operación (create/allocate/revoke/jwt).
 */
export interface SignerProvider {
  /**
   * Devuelve las opciones de firma para el tenant indicado.
   *
   * @param walletId - Identificador lógico del tenant (en QuarkID, el `label` del tenant Credo).
   * @returns `SignerOptions` listo para usar en `StatusListService.signAsJwt`.
   * @throws Si el tenant no existe o no tiene un DID/clave configurados.
   */
  resolveSigner(walletId: string): Promise<SignerOptions>;
}

/**
 * Token NestJS para inyectar el adapter de {@link SignerProvider}.
 *
 * Espejo del patrón `MESSAGING_SERVICE` / `STATUS_LIST_STORAGE`: es un símbolo
 * (no string) para evitar colisiones con identificadores ajenos al módulo.
 */
export const SIGNER_PROVIDER = Symbol('SignerProvider');

/**
 * Puerto para construir la URI pública de una StatusList.
 *
 * Encapsula *cómo* se deriva la URI que se publica junto con la lista y se
 * inyecta en el claim `status.status_list.uri` de las credenciales SD-JWT VC.
 * El core no impone un esquema: el consumidor decide si quiere una URI DID-based
 * (`<did-sin-prefijo>/statuslist/<vct>`), una URI HTTP bajo su API pública, o
 * cualquier otro formato compatible con la spec TSL.
 *
 * La firma incluye el `issuerDid` para que implementaciones DID-based no
 * necesiten re-resolver el firmante; los adapters que solo usan HTTP pueden
 * ignorarlo (prefijo `_`).
 */
export interface StatusListUriBuilder {
  /**
   * Devuelve la URI pública para la StatusList de `(walletId, vct)`.
   *
   * @param walletId - Identificador lógico del tenant.
   * @param vct - Verifiable Credential Type de la lista.
   * @param issuerDid - DID del emisor (necesario para builders DID-based; ignorado por builders HTTP).
   * @returns URI absoluta o relativa válida para clientes TSL.
   */
  build(walletId: string, vct: string, issuerDid: string): string;
}

/**
 * Token NestJS para inyectar el adapter de {@link StatusListUriBuilder}.
 */
export const STATUS_LIST_URI_BUILDER = Symbol('StatusListUriBuilder');
