import {
  DocsH2,
  DocsLead,
  DocsP,
  DocsTitle,
  DocsUl,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('versionado')

export default function DocsVersionadoPage() {
  return (
    <>
      <DocsTitle>Versionado</DocsTitle>
      <DocsLead>
        Política de la API documentada en este sitio: <span className="text-[var(--kuatia-text)]">v1</span>.
      </DocsLead>

      <DocsH2>API v1</DocsH2>
      <DocsP>
        Las rutas de producto de issuer, verifier y billing viven bajo el prefijo{' '}
        <code className="text-sm">/v1</code> (por ejemplo{' '}
        <code className="text-sm">POST /v1/issuers/…/openid4vc/offer</code>). Una versión mayor
        nueva se anunciará con política de convivencia.
      </DocsP>
      <DocsP>
        Rutas de protocolo OpenID4VC (well-known, flujos de wallet) y{' '}
        <code className="text-sm">did.json</code> no usan el mismo prefijo de producto; se
        documentan en las páginas de API correspondientes.
      </DocsP>

      <DocsH2>Qué es un breaking change</DocsH2>
      <DocsP>Cambios que, en general, exigen una versión mayor nueva:</DocsP>
      <DocsUl>
        <li>Quitar o renombrar un endpoint o un campo obligatorio del contrato.</li>
        <li>Cambiar el significado de un status code o de un campo de forma incompatible.</li>
        <li>Exigir auth donde antes era público (salvo corrección de seguridad anunciada).</li>
      </DocsUl>
      <DocsP>
        Ampliaciones compatibles (campos opcionales nuevos, endpoints nuevos bajo{' '}
        <code className="text-sm">/v1</code>) no abren una versión mayor.
      </DocsP>

      <DocsH2>Deprecación</DocsH2>
      <DocsP>
        Si algo de v1 se retira, primero aparece como{' '}
        <span className="text-[var(--kuatia-text)]">deprecated</span> en el{' '}
        <Link href="/docs/changelog" className="text-[var(--kuatia-accent)] hover:underline">
          changelog
        </Link>{' '}
        y en la documentación, con un plazo de convivencia. Kuatia no retira contrato documentado de
        v1 sin aviso. Historial: <code className="text-sm">CHANGELOG.md</code> en la raíz del
        monorepo. Las URLs de docs no usan prefijo{' '}
        <code className="text-sm">/docs/v1/…</code>.
      </DocsP>
    </>
  )
}
