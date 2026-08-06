import { WebDidResolver } from '@credo-ts/core'
import type { DidResolver } from '@credo-ts/core'
import { HttpWebDidResolver } from './web-http.resolver'

/**
 * Devuelve el resolver de `did:web` adecuado según el esquema de transporte.
 *
 * - `useHttp = true` → {@link HttpWebDidResolver} (HTTP plano, dev local sin TLS).
 * - `useHttp = false | undefined` → `WebDidResolver` de Credo-TS (HTTPS, producción).
 *
 * Centraliza la decisión HTTP/HTTPS en un único punto para que tanto el
 * `DidsModule` de los agentes como consumidores externos (ej. quark-resolver)
 * usen exactamente el mismo criterio.
 */
export function buildWebDidResolver(useHttp?: boolean): DidResolver {
  return useHttp ? new HttpWebDidResolver() : new WebDidResolver()
}
