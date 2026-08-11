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
        Cómo versionamos la API y qué implica para tu integración. La documentación del sitio describe
        la <span className="text-[var(--kuatia-text)]">API v1</span>.
      </DocsLead>

      <DocsH2>API v1</DocsH2>
      <DocsP>
        Las rutas de producto de issuer, verifier y billing que documentamos viven bajo el prefijo{' '}
        <code className="text-sm">/v1</code> (por ejemplo{' '}
        <code className="text-sm">POST /v1/issuers/…/openid4vc/offer</code>). No hay un{' '}
        <code className="text-sm">/v2</code> vacío ni paralelo: cuando exista una versión mayor, se
        anunciará con política clara de convivencia.
      </DocsP>
      <DocsP>
        Rutas de protocolo OpenID4VC (well-known, flujos de wallet) y{' '}
        <code className="text-sm">did.json</code> no usan el mismo prefijo de producto; se documentan
        en las páginas de API correspondientes.
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
        Si algo de v1 se retira, primero aparece como <span className="text-[var(--kuatia-text)]">deprecated</span>{' '}
        en el{' '}
        <Link href="/docs/changelog" className="text-[var(--kuatia-accent)] hover:underline">
          changelog
        </Link>{' '}
        y en estas docs, con un plazo de convivencia. No removemos contrato documentado de v1 sin
        aviso.
      </DocsP>

      <DocsH2>Documentación del sitio</DocsH2>
      <DocsP>
        Estas páginas describen la API v1 actual. Si en el futuro hubiera v2, marcaríamos la versión
        en la UI de docs (badge / banner) y mantendríamos v1 accesible mientras esté soportada. No
        versionamos hoy las URLs como <code className="text-sm">/docs/v1/…</code>.
      </DocsP>

      <DocsH2>Changelog</DocsH2>
      <DocsP>
        El historial público de API, docs y producto está en{' '}
        <Link href="/docs/changelog" className="text-[var(--kuatia-accent)] hover:underline">
          Changelog
        </Link>
        . En el monorepo: <code className="text-sm">CHANGELOG.md</code> (raíz).
      </DocsP>
    </>
  )
}
