import { DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Errores',
}

export default function DocsErroresPage() {
  return (
    <>
      <DocsTitle>Errores</DocsTitle>
      <DocsLead>Códigos HTTP habituales al integrar issuer y verifier.</DocsLead>

      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">400</span> — body inválido
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">401 / 403</span> — API key
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">402</span> — cuota mensual agotada
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">404</span> — walletId o sesión inexistente
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">429</span> — rate limit
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">503</span> — servicio no listo
        </li>
      </DocsUl>

      <DocsP>
        Fuera de alcance de esta guía: DIDComm, alta manual de tenants y APIs admin de billing.
      </DocsP>
    </>
  )
}
