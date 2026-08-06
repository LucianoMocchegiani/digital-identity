import {
  DidsModule,
  KeyDidResolver,
  KeyDidRegistrar,
  JwkDidResolver,
  JwkDidRegistrar,
  PeerDidResolver,
  PeerDidRegistrar,
} from '@credo-ts/core'
import { QuarkDidResolver } from '../did/resolver/quark.resolver'
import { QuarkDidRegistrar } from '../did/registrar/quark.registrar'
import type { QuarkDidRegistrarConfig } from '../did/registrar/quark.registrar'
import { WebDidRegistrar } from '../did/registrar/web.registrar'
import { buildWebDidResolver } from '../did/resolver/web.factory'

export interface BuildDidsModuleConfig extends QuarkDidRegistrarConfig {
  /** Usar HTTP en lugar de HTTPS para resolver did:web. Útil en dev local sin TLS. */
  useHttpForWebDid?: boolean
}

/**
 * Construye el DidsModule de Credo-TS con soporte completo de métodos DID.
 *
 * Registra resolvers y registrars para:
 * - `did:custom` — método propio de QuarkID, registrado en vdr-service
 * - `did:key` — clave pública codificada en el identificador
 * - `did:jwk` — clave pública en formato JWK
 * - `did:web` — documento DID publicado vía HTTP o HTTPS según `useHttpForWebDid`
 * - `did:peer` — DID efímero para conexiones DIDComm punto a punto
 *
 * @param config - URL del vdr-service, endpoint DIDComm y opciones de resolución
 * @returns Instancia de DidsModule lista para pasar al constructor de Agent
 */
export function buildDidsModule(config: BuildDidsModuleConfig): DidsModule {
  return new DidsModule({
    resolvers: [
      new QuarkDidResolver(config.vdrServiceUrl),
      new KeyDidResolver(),
      new JwkDidResolver(),
      buildWebDidResolver(config.useHttpForWebDid),
      new PeerDidResolver(),
    ],
    registrars: [
      new QuarkDidRegistrar(config),
      new WebDidRegistrar(),
      new KeyDidRegistrar(),
      new JwkDidRegistrar(),
      new PeerDidRegistrar(),
    ],
  })
}
