import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Cómo funciona',
}

export default function DocsComoFuncionaPage() {
  return (
    <>
      <DocsTitle>Cómo funciona</DocsTitle>
      <DocsLead>
        Flujo práctico entre emisor, titular y verificador. Si una palabra no te suena, mirá el{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          glosario
        </Link>
        .
      </DocsLead>

      <DocsH2>Los tres roles</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Issuer (emisor)</span> — tu organización
          firma y entrega una credencial (membresía, entrada, documento).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Holder (titular)</span> — la persona guarda la
          credencial en su wallet (app en el teléfono). Decide qué revelar al presentarla.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Verifier (verificador)</span> — tu sistema pide
          una prueba (“¿es miembro activo?”) y valida la respuesta sin contactar al emisor en cada
          chequeo en línea típico del flujo.
        </li>
      </DocsUl>

      <DocsH2>Emisión (OID4VCI)</DocsH2>
      <DocsP>
        Tu backend llama a la API del issuer con la API key y recibe una URI de oferta. La mostrás
        como QR o deep link. La wallet del usuario escanea, habla con el issuer y guarda la
        credencial. Tu servidor no implementa el protocolo de la wallet: solo crea la oferta.
      </DocsP>

      <DocsH2>Verificación (OID4VP)</DocsH2>
      <DocsP>
        Tu backend crea un pedido de presentación (qué credencial y qué campos necesitás). La
        wallet muestra al usuario qué se pide; el usuario acepta y envía la prueba. Consultás el
        estado de la sesión hasta obtener el resultado.
      </DocsP>

      <DocsH2>SD-JWT y divulgación selectiva</DocsH2>
      <DocsP>
        Kuatia usa credenciales SD-JWT VC: un token firmado donde algunos campos pueden marcarse
        como divulgables. Al presentar, el holder puede ocultar claims que no quiera compartir. Eso
        se controla en la emisión con <code className="text-sm">disclosureFrame</code> y en la
        verificación pidiendo solo lo necesario.
      </DocsP>

      <DocsH2>Qué hace Kuatia vs tu app</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Kuatia</span> — agentes issuer/verifier,
          firmas, metadata OID4VC, cupos y API keys.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Tu app</span> — lógica de negocio, UI del QR,
          claims a emitir, políticas de qué pedir al verificar, branding.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">La wallet</span> — guarda claves del usuario y
          completa los pasos del protocolo.
        </li>
      </DocsUl>
    </>
  )
}
