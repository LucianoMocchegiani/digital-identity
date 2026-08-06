import { DidDocument, JsonTransformer } from '@credo-ts/core'
import type { AgentContext, DidResolutionResult, DidResolver, ParsedDid } from '@credo-ts/core'

/**
 * Resuelve DIDs `did:web` usando HTTP en lugar de HTTPS.
 *
 * Útil para entornos de desarrollo local donde los servicios se comunican
 * dentro de una red Docker sin TLS.
 *
 * Construcción de URL según la especificación did:web:
 * - `did:web:host` → `http://host/.well-known/did.json`
 * - `did:web:host%3Aport` → `http://host:port/.well-known/did.json`
 * - `did:web:host:path:to` → `http://host/path/to/did.json`
 *
 * Nota: el separador `:` se evalúa ANTES de decodificar percent-encoding,
 * por lo que `%3A` (puerto) y `:` literal (path) se distinguen correctamente.
 */
export class HttpWebDidResolver implements DidResolver {
  public readonly supportedMethods = ['web']
  public readonly allowsCaching = false
  public readonly allowsLocalDidRecord = false

  async resolve(
    _agentContext: AgentContext,
    did: string,
    _parsed: ParsedDid
  ): Promise<DidResolutionResult> {
    const url = didWebToHttpUrl(did)
    try {
      const res = await fetch(url)
      if (!res.ok) {
        return {
          didDocument: null,
          didDocumentMetadata: {},
          didResolutionMetadata: {
            error: 'notFound',
            message: `HTTP ${res.status} fetching ${url}`,
          },
        }
      }
      const json = (await res.json()) as Record<string, unknown>
      const didDocument = JsonTransformer.fromJSON(json, DidDocument)
      return {
        didDocument,
        didDocumentMetadata: {},
        didResolutionMetadata: { contentType: 'application/did+ld+json' },
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err)
      return {
        didDocument: null,
        didDocumentMetadata: {},
        didResolutionMetadata: {
          error: 'internalError',
          message: `HttpWebDidResolver: ${message}`,
        },
      }
    }
  }
}

/**
 * Convierte un DID `did:web:...` a su URL HTTP de resolución.
 *
 * El identificador se parte por `:` literal ANTES de decodificar, para
 * distinguir `%3A` (puerto) de `:` como separador de path según la spec.
 */
export function didWebToHttpUrl(did: string): string {
  const identifier = did.slice('did:web:'.length)
  const parts = identifier.split(':')
  const host = decodeURIComponent(parts[0])

  if (parts.length === 1) {
    return `http://${host}/.well-known/did.json`
  }

  const pathParts = parts.slice(1).map((p) => decodeURIComponent(p))
  return `http://${host}/${pathParts.join('/')}/did.json`
}
