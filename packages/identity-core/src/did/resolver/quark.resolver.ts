import type {
  AgentContext,
  DidDocument,
  DidResolutionResult,
  DidResolver,
  ParsedDid,
} from '@credo-ts/core'

/**
 * Resuelve DIDs `did:custom` consultando vdr-service (`GET /did/:id`).
 *
 * El path del endpoint es parametrizable vía el segundo argumento del
 * constructor para permitir que subclases (ej. `QuarkidDidResolver` con
 * `did:quarkid` + `/resolve/:id`) reutilicen la lógica de fetch + parse
 * + mapeo de errores sin duplicar código.
 *
 * @param baseUrl - URL base del servicio upstream (sin slash final obligatorio).
 * @param pathPrefix - Prefijo del path de resolución; default `/did` para
 *                     mantener el comportamiento histórico de `did:custom`.
 */
export class QuarkDidResolver implements DidResolver {
  public readonly supportedMethods = ['custom']
  public readonly allowsCaching = true
  public readonly allowsLocalDidRecord = true

  constructor(
    private readonly baseUrl: string,
    private readonly pathPrefix: string = '/did'
  ) {}

  async resolve(
    _agentContext: AgentContext,
    did: string,
    _parsed: ParsedDid,
    _didResolutionOptions?: unknown
  ): Promise<DidResolutionResult> {
    const didDocumentMetadata: Record<string, unknown> = {}

    try {
      const encodedDid = encodeURIComponent(did)
      const url = `${this.baseUrl.replace(/\/$/, '')}${this.pathPrefix}/${encodedDid}`
      const res = await fetch(url)
      if (!res.ok) {
        return {
          didDocument: null,
          didDocumentMetadata,
          didResolutionMetadata: {
            error: 'notFound',
            message: `Unable to resolve did '${did}': not found in registry`,
          },
        }
      }
      const data = (await res.json()) as Record<string, unknown>
      // Defensive: algunos upstreams responden HTTP 200 con un body tipo
      // `AxiosError.response` (`{status: 4xx, statusText, data}`) cuando
      // una llamada interna falló. Si el body trae un campo `status` con
      // valor 4xx/5xx, lo tratamos como `notFound` para no propagar al
      // caller un documento inexistente envuelto en forma de error HTTP.
      const wrappedStatus =
        typeof data?.status === 'number' ? data.status : undefined
      if (wrappedStatus !== undefined && wrappedStatus >= 400 && wrappedStatus < 600) {
        const innerData = (data?.data ?? {}) as Record<string, unknown>
        const message =
          (typeof innerData.message === 'string' && innerData.message) ||
          (typeof data?.statusText === 'string' && data.statusText) ||
          `Upstream returned HTTP ${wrappedStatus} wrapped in 200 OK`
        return {
          didDocument: null,
          didDocumentMetadata,
          didResolutionMetadata: {
            error: 'notFound',
            message: `Unable to resolve did '${did}': ${message}`,
          },
        }
      }
      // El endpoint W3C `/1.0/identifiers/:did` retorna el envelope
      // completo de DID Resolution (`{didDocument, didDocumentMetadata,
      // didResolutionMetadata, @context}`), no solo el documento pelado.
      // Si el body trae un campo `didDocument` en el top level, lo
      // desenvolvemos: extraemos `didDocument` y `didDocumentMetadata`
      // tal cual, y mergeamos `didResolutionMetadata` del upstream con
      // nuestros defaults (`contentType`). Si no trae envelope (caso
      // `did:custom` con `/did/:id` que devuelve el doc pelado), caemos
      // al fallback que trata el body como documento bare.
      const wrappedDoc =
        typeof data?.didDocument === 'object' &&
        data.didDocument !== null &&
        !Array.isArray(data.didDocument)
          ? (data.didDocument as Record<string, unknown>)
          : undefined
      if (wrappedDoc !== undefined) {
        const upstreamDocMeta =
          (data?.didDocumentMetadata as Record<string, unknown>) ?? {}
        const upstreamResMeta =
          (data?.didResolutionMetadata as Record<string, unknown>) ?? {}
        return {
          didDocument: wrappedDoc as unknown as DidDocument,
          didDocumentMetadata: upstreamDocMeta,
          didResolutionMetadata: {
            contentType: 'application/did+ld+json',
            ...upstreamResMeta,
          },
        }
      }
      // Body pelado: el upstream devolvió directamente el DID Document
      // (caso `did:custom` con `/did/:id`). Lo pasamos sin validar contra
      // la clase `DidDocument` de Credo para tolerar `@context` extendido
      // (típico de did:webvh / JSON-LD). Cast a `DidDocument` solo para
      // satisfacer la firma W3C de `DidResolutionResult`.
      return {
        didDocument: data as unknown as DidDocument,
        didDocumentMetadata,
        didResolutionMetadata: { contentType: 'application/did+ld+json' },
      }
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error)
      return {
        didDocument: null,
        didDocumentMetadata,
        didResolutionMetadata: {
          error: 'notFound',
          message: `resolver_error: Unable to resolve did '${did}': ${message}`,
        },
      }
    }
  }
}
