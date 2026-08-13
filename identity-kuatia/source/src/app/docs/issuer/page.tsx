import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('issuer')

/**
 * Producto issuer: rol, multi-producto y qué persiste.
 */
export default function DocsIssuerPage() {
  return (
    <>
      <DocsTitle>Issuer</DocsTitle>
      <DocsLead>
        Producto Kuatia que firma y entrega credenciales (OID4VCI). En la consola y en el plan, cada
        issuer cuenta como un producto.
      </DocsLead>

      <DocsH2>Para qué sirve</DocsH2>
      <DocsP>
        Tu backend crea ofertas con la API key del issuer; la wallet del titular completa el flujo y
        guarda la credencial. Detalle del endpoint:{' '}
        <Link href="/docs/emitir" className="text-[var(--kuatia-accent)] hover:underline">
          Emitir
        </Link>
        .
      </DocsP>

      <DocsH2>Varios issuers</DocsH2>
      <DocsP>
        Una misma cuenta puede tener varios productos issuer (según el cupo del plan) para líneas de
        negocio distintas — por ejemplo membresía de un club y acreditaciones de un curso — cada uno
        con su <code className="text-sm">walletId</code>, API key, metadata y branding.
      </DocsP>

      <DocsH2>Qué queda guardado</DocsH2>
      <DocsP>
        El agente persiste estado en storage (records Credo), aislado por tenant. Lo habitual:
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">DidRecord</span> — identidad{' '}
          <code className="text-sm">did:web</code> del emisor
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">OpenId4VcIssuerRecord</span> — metadata OID4VCI
          (configs, display)
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">OpenId4VcIssuanceSessionRecord</span> — sesiones
          de oferta / emisión para seguimiento
        </li>
      </DocsUl>
      <DocsP>
        La credencial emitida vive en la wallet del titular, no como un vault central de VCs en
        Kuatia. Para listar o leer esos records desde tu backend:{' '}
        <Link href="/docs/records" className="text-[var(--kuatia-accent)] hover:underline">
          Records
        </Link>
        . Display y branding:{' '}
        <Link href="/docs/branding" className="text-[var(--kuatia-accent)] hover:underline">
          Branding
        </Link>
        ; well-known:{' '}
        <Link href="/docs/metadata" className="text-[var(--kuatia-accent)] hover:underline">
          Metadata
        </Link>
        .
      </DocsP>
    </>
  )
}
