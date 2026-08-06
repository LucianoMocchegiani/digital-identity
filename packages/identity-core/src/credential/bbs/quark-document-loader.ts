import type { AgentContext } from '@credo-ts/core'
import {
  CredoError,
  DidsApi,
  JsonTransformer,
  W3cCredentialsModuleConfig,
} from '@credo-ts/core'
import { absolutizeVerificationMethodForDid } from './absolutize-verification-method'

const credoDefaultDocumentLoader = new W3cCredentialsModuleConfig({}).documentLoader

type DocumentLoaderFn = ReturnType<typeof credoDefaultDocumentLoader>

/**
 * DocumentLoader Quark: para `did:…#fragment` devuelve la verification method como JSON plano
 * (id/type/controller string), sin `jsonld.frame`.
 *
 * Credo framea el DID Document y con did:peer (ids relativos `#key-…`) el nodo resultante
 * no valida como `VerificationMethod` al firmar la VP.
 *
 * El `@context` del DID Document se copia en la verification method porque las suites
 * Data Integrity de Credo lo exigen sobre la clave: `Ed25519Signature2018` rechaza una VM
 * cuyo `@context` no declare `https://w3id.org/security/suites/ed25519-2018/v1`. Las suites
 * BBS de MATTR no hacen esa validación, por eso su ausencia solo rompía el camino Ed25519.
 */
export function quarkDocumentLoader(agentContext: AgentContext): DocumentLoaderFn {
  const fallback = credoDefaultDocumentLoader(agentContext)
  const didsApi = agentContext.dependencyManager.resolve(DidsApi)

  return async (url: string) => {
    if (url.startsWith('did:') && url.includes('#')) {
      const did = url.split('#')[0] ?? url
      const didDocument = await didsApi.resolveDidDocument(did)

      let vm: { id: string; type?: string; controller?: string }
      try {
        vm = didDocument.dereferenceVerificationMethod(url)
      } catch {
        vm = didDocument.dereferenceKey(url, [
          'authentication',
          'assertionMethod',
          'verificationMethod',
          'capabilityInvocation',
          'capabilityDelegation',
          'keyAgreement',
        ])
      }

      const absolute = absolutizeVerificationMethodForDid(
        {
          id: vm.id,
          controller: vm.controller,
        },
        didDocument.id
      )

      const maybeToJson = vm as unknown as { toJSON?: () => Record<string, unknown> }
      const raw =
        typeof maybeToJson.toJSON === 'function'
          ? maybeToJson.toJSON()
          : (JsonTransformer.toJSON(vm) as Record<string, unknown>)

      const type = raw.type ?? vm.type
      if (typeof type !== 'string' || type.length === 0) {
        throw new CredoError(`Verification method ${url} has no string type`)
      }

      return {
        contextUrl: null,
        documentUrl: url,
        document: {
          ...raw,
          '@context': didDocument.context,
          id: absolute.id,
          type,
          controller: absolute.controller ?? didDocument.id,
        },
      }
    }

    return fallback(url)
  }
}
