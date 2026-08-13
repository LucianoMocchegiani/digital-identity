import {
  DocsCode,
  DocsEndpoint,
  DocsH2,
  DocsLead,
  DocsP,
  DocsTitle,
  DocsUl,
} from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('records')

/**
 * Consulta de records Credo (issuer / verifier).
 */
export default function DocsRecordsPage() {
  return (
    <>
      <DocsTitle>Records</DocsTitle>
      <DocsLead>
        Lectura del estado persistido del agente (sesiones OID4VC, metadata, DID, etc.) por producto.
        Requiere API key del{' '}
        <Link href="/docs/issuer" className="text-[var(--kuatia-accent)] hover:underline">
          issuer
        </Link>{' '}
        o del{' '}
        <Link href="/docs/verifier" className="text-[var(--kuatia-accent)] hover:underline">
          verifier
        </Link>
        .
      </DocsLead>

      <DocsH2>Qué son</DocsH2>
      <DocsP>
        Cada producto tiene un tenant aislado. Al emitir u ofrecer, o al pedir una presentación, el
        agente guarda records en storage. Tu backend puede listarlos después — por ejemplo sesiones
        de emisión o de verificación — sin reinventar una base propia para el protocolo.
      </DocsP>
      <DocsUl>
        <li>
          Issuer — p. ej. <code className="text-sm">OpenId4VcIssuanceSessionRecord</code>,{' '}
          <code className="text-sm">OpenId4VcIssuerRecord</code>
        </li>
        <li>
          Verifier — p. ej. <code className="text-sm">OpenId4VcVerificationSessionRecord</code>,{' '}
          <code className="text-sm">OpenId4VcVerifierRecord</code>
        </li>
      </DocsUl>
      <DocsP>
        Los tipos exactos disponibles en tu producto: endpoint <code className="text-sm">/types</code>{' '}
        abajo. Actualizar display / metadata:{' '}
        <Link href="/docs/branding" className="text-[var(--kuatia-accent)] hover:underline">
          Branding
        </Link>{' '}
        (<code className="text-sm">PATCH …/records/metadata</code>).
      </DocsP>

      <DocsEndpoint
        method="GET"
        path="/v1/issuers/{walletId}/records/types"
        auth="X-API-Key (issuer)"
      >
        <p>Lista tipos consultables con descripción. En verifier: misma ruta bajo{' '}
          <code className="text-sm">/v1/verifiers/…</code>.
        </p>
        <DocsCode>{`GET {ISSUER_URL}/v1/issuers/{walletId}/records/types
X-API-Key: iss_live_…

→ { "role": "issuer", "types": [ { "className": "…", "storageType": "…", "description": "…" } ] }`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint
        method="GET"
        path="/v1/issuers/{walletId}/records"
        auth="X-API-Key (issuer)"
      >
        <p>
          Lista paginada. <code className="text-sm">type</code> obligatorio (clase Credo o{' '}
          <code className="text-sm">storageType</code>). Opcionales:{' '}
          <code className="text-sm">page</code>, <code className="text-sm">limit</code>,{' '}
          <code className="text-sm">query</code> (filtro por tags, JSON).
        </p>
        <DocsCode>{`GET {ISSUER_URL}/v1/issuers/{walletId}/records?type=OpenId4VcIssuanceSessionRecord&page=1&limit=20
X-API-Key: iss_live_…`}</DocsCode>
        <p>
          Verifier (sesiones de verificación):
        </p>
        <DocsCode>{`GET {VERIFIER_URL}/v1/verifiers/{walletId}/records?type=OpenId4VcVerificationSessionRecord&page=1&limit=20
X-API-Key: ver_live_…`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint
        method="GET"
        path="/v1/issuers/{walletId}/records/{recordType}/{recordId}"
        auth="X-API-Key (issuer)"
      >
        <p>Un record por tipo e id. Misma forma bajo <code className="text-sm">/v1/verifiers/…</code>.</p>
        <DocsCode>{`GET {ISSUER_URL}/v1/issuers/{walletId}/records/OpenId4VcIssuanceSessionRecord/{recordId}
X-API-Key: iss_live_…`}</DocsCode>
      </DocsEndpoint>
    </>
  )
}
