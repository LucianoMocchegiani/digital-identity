import type { AgentContext } from '@credo-ts/core'
import {
  ClaimFormat,
  JsonTransformer,
  W3cCredentialRecord,
  W3cJsonLdVerifiableCredential,
} from '@credo-ts/core'
import { deriveBbsProof, resolveBbsDocumentLoader, verifyBbsCredential } from './bbs-credential'
import { BBS_PROOF_TYPE, isBbsProofType } from './constants'
import {
  buildRevealFrame,
  extractRevealPathsFromPresentationDefinition,
} from './reveal-frame'

/** Suites LDP con las que el holder firma la VP (no la VC BBS). */
const HOLDER_VP_PROOF_TYPES = ['Ed25519Signature2018', 'Ed25519Signature2020'] as const

/** Entrada típica de `credentialsForInputDescriptor` en PEX Credo. */
export interface PexCredentialEntry {
  claimFormat?: string
  credentialRecord?:
    | W3cCredentialRecord
    | {
        encoded?: unknown
        firstCredential?: unknown
      }
  encoded?: unknown
}

function encodedFromPexEntry(entry: PexCredentialEntry): unknown {
  return (
    entry.encoded ??
    entry.credentialRecord?.encoded ??
    (entry.credentialRecord?.firstCredential
      ? JsonTransformer.toJSON(entry.credentialRecord.firstCredential)
      : undefined)
  )
}

function pexEntriesIncludeBbs(credentials: Record<string, PexCredentialEntry[]>): boolean {
  return Object.values(credentials)
    .flat()
    .some((entry) => {
      const encoded = encodedFromPexEntry(entry)
      if (!encoded || typeof encoded !== 'object') return false
      return isBbsProofType((encoded as { proof?: { type?: string } }).proof?.type)
    })
}

/**
 * Credo elige la suite de la VP con `ldp_vc.proof_type` del PD (no `ldp_vp`).
 * Si el PD solo lista suites BBS, falla con la clave Ed25519 del holder.
 * Tras seleccionar/derivar VCs BBS, reescribe el PD solo para firmar la VP.
 */
export function presentationDefinitionForHolderVpSigning(
  presentationDefinition: Record<string, unknown>,
  credentials: Record<string, PexCredentialEntry[]>
): Record<string, unknown> {
  if (!pexEntriesIncludeBbs(credentials)) return presentationDefinition

  const pd = structuredClone(presentationDefinition) as {
    format?: { ldp_vc?: { proof_type?: string[] }; [k: string]: unknown }
    input_descriptors?: Array<{
      format?: { ldp_vc?: { proof_type?: string[] }; [k: string]: unknown }
      [k: string]: unknown
    }>
    [k: string]: unknown
  }

  const mergeVpProofTypes = (proofTypes: string[] | undefined): string[] => {
    const next = [...(proofTypes ?? [])]
    for (const t of HOLDER_VP_PROOF_TYPES) {
      if (!next.includes(t)) next.push(t)
    }
    return next
  }

  if (pd.format?.ldp_vc) {
    pd.format.ldp_vc.proof_type = mergeVpProofTypes(pd.format.ldp_vc.proof_type)
  } else if (pd.format) {
    pd.format.ldp_vc = { proof_type: [...HOLDER_VP_PROOF_TYPES] }
  }

  for (const descriptor of pd.input_descriptors ?? []) {
    if (descriptor.format?.ldp_vc) {
      descriptor.format.ldp_vc.proof_type = mergeVpProofTypes(descriptor.format.ldp_vc.proof_type)
    } else if (descriptor.format) {
      descriptor.format.ldp_vc = { proof_type: [...HOLDER_VP_PROOF_TYPES] }
    }
  }

  return pd
}

/**
 * Si la VC tiene `BbsBlsSignature2020`, deriva un proof selectivo según paths del PD.
 *
 * Credo `getPresentationsToCreate` exige `credentialRecord.firstCredential`
 * (no alcanza con `{ encoded }`). El record es efímero: no se persiste en wallet.
 */
async function maybeDeriveBbsCredentialForPex(
  agentContext: AgentContext,
  entry: PexCredentialEntry,
  presentationDefinition: Record<string, unknown>,
  nonce?: string
): Promise<PexCredentialEntry> {
  const encoded = encodedFromPexEntry(entry)
  if (!encoded || typeof encoded !== 'object') return entry

  const vc = encoded as Record<string, unknown>
  const proofType = (vc.proof as { type?: string } | undefined)?.type
  if (proofType !== BBS_PROOF_TYPE) return entry

  const paths = extractRevealPathsFromPresentationDefinition(presentationDefinition)
  if (paths.length === 0) return entry

  const frame = buildRevealFrame(vc, paths)
  const documentLoader = resolveBbsDocumentLoader(agentContext)

  const derived = await deriveBbsProof({
    credential: vc,
    revealDocument: frame,
    nonce,
    documentLoader,
  })

  // Si el frame no preservó el subject id, lo restauramos para firmar la VP (holder binding).
  const originalSubjectId = (vc.credentialSubject as { id?: string } | undefined)?.id
  const derivedSubject = derived.credentialSubject as Record<string, unknown> | undefined
  if (originalSubjectId && derivedSubject && typeof derivedSubject.id !== 'string') {
    derived.credentialSubject = { ...derivedSubject, id: originalSubjectId }
  }

  const derivedCredential = W3cJsonLdVerifiableCredential.fromJson(derived)
  return {
    claimFormat: entry.claimFormat ?? ClaimFormat.LdpVc,
    credentialRecord: W3cCredentialRecord.fromCredential(derivedCredential),
  }
}

/**
 * Aplica derive BBS a un mapa descriptorId → credenciales PEX.
 */
export async function applyBbsDeriveToPexCredentials(
  agentContext: AgentContext,
  credentials: Record<string, PexCredentialEntry[]>,
  presentationDefinition: Record<string, unknown>,
  nonce?: string
): Promise<Record<string, PexCredentialEntry[]>> {
  const out: Record<string, PexCredentialEntry[]> = {}
  for (const [descriptorId, entries] of Object.entries(credentials)) {
    out[descriptorId] = []
    for (const entry of entries) {
      out[descriptorId].push(
        await maybeDeriveBbsCredentialForPex(agentContext, entry, presentationDefinition, nonce)
      )
    }
  }
  return out
}

/**
 * Verifica VCs BBS (Signature2020 o Proof2020) embebidas en una VP JSON-LD.
 *
 * @returns true si no hay VCs BBS o todas verifican; false si alguna falla
 */
export async function verifyBbsCredentialsInPresentation(
  agentContext: AgentContext,
  presentation: Record<string, unknown>
): Promise<{ ok: boolean; error?: string }> {
  const vcs = presentation.verifiableCredential
  const list = Array.isArray(vcs) ? vcs : vcs ? [vcs] : []
  const documentLoader = resolveBbsDocumentLoader(agentContext)

  for (const raw of list) {
    const vc =
      typeof raw === 'object' && raw !== null
        ? (raw as Record<string, unknown>)
        : JsonTransformer.toJSON(JsonTransformer.fromJSON(raw, W3cJsonLdVerifiableCredential))
    const proofType = (vc.proof as { type?: string } | undefined)?.type
    if (!isBbsProofType(proofType)) continue

    const result = await verifyBbsCredential(vc, { documentLoader })
    if (!result.verified) {
      return { ok: false, error: result.error ?? 'BBS credential verification failed' }
    }
  }
  return { ok: true }
}
