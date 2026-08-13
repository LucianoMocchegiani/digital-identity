import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('introduccion')

export default function DocsIntroPage() {
  return (
    <>
      <DocsTitle>Introducción</DocsTitle>
      <DocsLead>
        Kuatia es infraestructura para emitir y verificar{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          credenciales verificables
        </Link>{' '}
        con{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenID4VC
        </Link>
        . Issuer y verifier se integran por API; la credencial vive con el titular.
      </DocsLead>

      <DocsH2>Qué resuelve</DocsH2>
      <DocsUl>
        <li>Tu organización firma una afirmación (“es miembro”, “tiene acceso VIP”, “aprobó el curso”).</li>
        <li>El titular la guarda en su wallet.</li>
        <li>Al presentarla, tu sistema (u otro) verifica firma, vigencia y —si aplica— revocación.</li>
      </DocsUl>
      <DocsP>
        El núcleo es emisión y verificación. Kuatia también dispone de una{' '}
        <Link href="/docs/wallet" className="text-[var(--kuatia-accent)] hover:underline">
          wallet
        </Link>{' '}
        para titulares; no es un PDF reenviable ni un repositorio central de identidad.
      </DocsP>

      <DocsH2>Casos de uso</DocsH2>
      <DocsUl>
        <li>Membresías y acceso</li>
        <li>Eventos y control de entrada</li>
        <li>Acreditaciones (cursos, roles, habilitaciones)</li>
        <li>Constancias que el titular presenta sin reenviar un archivo</li>
      </DocsUl>

      <DocsH2>Modelo de confianza</DocsH2>
      <DocsP>
        Cadena típica: el hecho de negocio se confirma en tu organización → se emite la credencial →
        el titular la guarda → al presentar, el verifier comprueba firma, vigencia y revocación si
        aplica. Con divulgación selectiva el verificador puede pedir solo los atributos necesarios.
      </DocsP>

      <DocsH2>Estándares</DocsH2>
      <DocsP>
        OpenID4VC (OID4VCI / OID4VP), SD-JWT VC y DID. Kuatia aporta multi-tenant, API keys, planes y
        branding sobre ese protocolo abierto.
      </DocsP>
    </>
  )
}
