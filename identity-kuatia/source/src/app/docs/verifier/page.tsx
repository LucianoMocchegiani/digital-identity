import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('verifier')

/**
 * Producto verifier: rol, multi-producto y qué persiste.
 */
export default function DocsVerifierPage() {
  return (
    <>
      <DocsTitle>Verifier</DocsTitle>
      <DocsLead>
        Producto Kuatia que pide y valida presentaciones (OID4VP). En la consola y en el plan, cada
        verifier cuenta como un producto.
      </DocsLead>

      <DocsH2>Para qué sirve</DocsH2>
      <DocsP>
        Tu backend crea un presentation request con la API key del verifier; la wallet presenta la
        prueba y consultás el resultado de la sesión. Detalle:{' '}
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          Verificar
        </Link>
        .
      </DocsP>

      <DocsH2>Varios verifiers</DocsH2>
      <DocsP>
        Podés provisionar varios verifiers (según el cupo del plan) para contextos distintos — control
        de acceso, onboarding, un evento — cada uno con su{' '}
        <code className="text-sm">walletId</code>, API key y{' '}
        <code className="text-sm">clientMetadata</code>.
      </DocsP>

      <DocsH2>Qué queda guardado</DocsH2>
      <DocsP>
        El agente persiste estado en storage (records Credo), aislado por tenant. Lo habitual:
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">DidRecord</span> — identidad{' '}
          <code className="text-sm">did:web</code> del verificador
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">OpenId4VcVerifierRecord</span> — metadata OID4VP
          (<code className="text-sm">clientMetadata</code>, etc.)
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">OpenId4VcVerificationSessionRecord</span> —
          sesiones de verificación (pedido, estado, resultado)
        </li>
      </DocsUl>
      <DocsP>
        Además del poll de sesión (
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          Verificar
        </Link>
        ), podés consultar records persistidos:{' '}
        <Link href="/docs/records" className="text-[var(--kuatia-accent)] hover:underline">
          Records
        </Link>
        . Branding del verificador:{' '}
        <Link href="/docs/branding" className="text-[var(--kuatia-accent)] hover:underline">
          Branding
        </Link>
        .
      </DocsP>
    </>
  )
}
