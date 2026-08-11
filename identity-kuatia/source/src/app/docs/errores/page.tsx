import { DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('errores')

export default function DocsErroresPage() {
  return (
    <>
      <DocsTitle>Errores</DocsTitle>
      <DocsLead>Códigos HTTP habituales al integrar issuer y verifier.</DocsLead>

      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">400</span> — body inválido o parámetros
          incompatibles
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">401 / 403</span> — API key ausente, inválida o
          de otro producto
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">402</span> — cuota mensual del plan agotada
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">404</span> — walletId o sesión inexistente
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">429</span> — rate limit (solicitudes por minuto)
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">503</span> — servicio no listo (revisá{' '}
          <code className="text-sm">/v1/health/ready</code>)
        </li>
      </DocsUl>

      <DocsP>
        Fuera de alcance de esta guía: DIDComm, alta manual de tenants y APIs admin de billing.
      </DocsP>
    </>
  )
}
