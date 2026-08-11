import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('introduccion')

export default function DocsIntroPage() {
  return (
    <>
      <DocsTitle>Introducción</DocsTitle>
      <DocsLead>
        Kuatia es la plataforma para emitir y verificar credenciales digitales con estándares
        abiertos. Documentos, entradas, membresías y acreditaciones: firmadas por tu organización,
        guardadas en la wallet del usuario y comprobables en segundos.
      </DocsLead>

      <DocsH2>De qué se trata</DocsH2>
      <DocsP>
        En lugar de PDFs fáciles de falsificar, capturas de pantalla o bases de datos centralizadas
        que hay que consultar en cada control, trabajás con{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          credenciales verificables
        </Link>
        : datos firmados criptográficamente que el usuario guarda en su teléfono y presenta cuando
        hace falta.
      </DocsP>
      <DocsP>
        El marco técnico se llama{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenID4VC
        </Link>{' '}
        (OpenID for Verifiable Credentials): estándares abiertos para emitir y presentar esas
        credenciales. Kuatia te da issuer y verifier listos para integrar por API — sin armar el
        protocolo desde cero.
      </DocsP>

      <DocsH2>Quién la usa</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Organizaciones e instituciones</span> —
          membresías, carnets, acreditaciones y acceso a instalaciones.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Eventos y venues</span> — entradas digitales
          difíciles de clonar y fáciles de validar en puerta.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Emisores de documentos</span> — constancias o
          certificados que el titular puede presentar sin reenviar un PDF.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Equipos de producto / backend</span> — integran
          Kuatia con su app o sistema interno vía API key.
        </li>
      </DocsUl>
      <DocsP>
        Gobiernos, bancos y ecosistemas europeos (p. ej. wallets alineadas a EUDI) impulsan el mismo
        tipo de estándares. Kuatia acerca ese modelo con una API pensada para negocio.
      </DocsP>

      <DocsH2>Por qué es antifraude por diseño</DocsH2>
      <DocsP>
        El valor no es “un QR bonito”: es la criptografía y el flujo estándar detrás.
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Firma del emisor</span> — la credencial la firma
          tu issuer. Un verificador comprueba esa firma; no alcanza con copiar una imagen.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Posesión del titular</span> — al presentar, la
          wallet demuestra que el usuario controla las claves (no solo que “vio” un código).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Sin repositorio único de secretos</span> — no
          dependés de un PDF compartido por WhatsApp ni de un listado fácil de reenviar.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Mínimo de datos al verificar</span> — con{' '}
          <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
            divulgación selectiva
          </Link>{' '}
          pedís solo lo necesario (“¿está vigente?”), no todo el documento.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Revocación</span> — cuando el caso lo requiere,
          podés invalidar credenciales emitidas (p. ej. membresía dada de baja).
        </li>
      </DocsUl>
      <DocsP>
        Eso no elimina fraude de procesos de negocio (identidad mal verificada al emitir), pero sí
        corta la falsificación trivial de tickets, carnets y capturas.
      </DocsP>

      <DocsH2>Tecnología de base (Credo y OpenWallet Foundation)</DocsH2>
      <DocsP>
        Kuatia no reinventó el protocolo desde cero. Los agentes issuer y verifier se construyen
        sobre{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          Credo
        </Link>{' '}
        (antes Hyperledger Aries / Credo TS), el stack open source de identidad descentralizada del
        ecosistema de la{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenWallet Foundation
        </Link>{' '}
        (Linux Foundation).
      </DocsP>
      <DocsP>
        Usamos esas librerías para OpenID4VC, firmas, wallets y metadata estándar. Kuatia aporta el
        producto: multi-tenant, API keys, planes, branding y una experiencia pensada para
        integradores que no viven del día a día de SSI.
      </DocsP>
      <DocsP>
        Elegir estándares y librerías de la comunidad reduce riesgo de vendor lock-in y mejora la
        interoperabilidad con wallets compatibles.
      </DocsP>

      <DocsH2>Esta documentación</DocsH2>
      <DocsP>
        Está escrita para backends de negocio. Si ves una sigla rara, mirá el{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          glosario
        </Link>
        .
      </DocsP>
      <DocsUl>
        <li>
          <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
            Glosario
          </Link>{' '}
          — SSI, OpenID4VC, issuer, holder, SD-JWT, etc.
        </li>
        <li>
          <Link href="/docs/como-funciona" className="text-[var(--kuatia-accent)] hover:underline">
            Cómo funciona
          </Link>{' '}
          — emisión, verificación y roles
        </li>
        <li>
          <Link href="/docs/recomendaciones" className="text-[var(--kuatia-accent)] hover:underline">
            Recomendaciones
          </Link>{' '}
          — privacidad y datos sensibles
        </li>
        <li>
          <Link href="/docs/seguridad" className="text-[var(--kuatia-accent)] hover:underline">
            Seguridad y confianza
          </Link>{' '}
          — API keys, tenants, cupos y qué guardamos
        </li>
        <li>
          <Link href="/docs/empezar" className="text-[var(--kuatia-accent)] hover:underline">
            Primeros pasos
          </Link>{' '}
          — API key y flujo de integración
        </li>
        <li>
          <Link href="/docs/versionado" className="text-[var(--kuatia-accent)] hover:underline">
            Versionado
          </Link>{' '}
          y{' '}
          <Link href="/docs/changelog" className="text-[var(--kuatia-accent)] hover:underline">
            Changelog
          </Link>{' '}
          — API v1 y historial de cambios
        </li>
      </DocsUl>
    </>
  )
}
