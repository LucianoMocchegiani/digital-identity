import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('como-funciona')

export default function DocsComoFuncionaPage() {
  return (
    <>
      <DocsTitle>Cómo funciona</DocsTitle>
      <DocsLead>Flujo entre emisor, titular y verificador.</DocsLead>

      <DocsH2>Los tres roles</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Issuer (emisor)</span> — tu organización firma
          y entrega una credencial (membresía, entrada, constancia).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Holder (titular)</span> — guarda la credencial
          en su wallet y decide qué revelar al presentarla.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Verifier (verificador)</span> — pide una prueba
          (“¿es miembro activo?”) y valida la respuesta criptográfica y de protocolo.
        </li>
      </DocsUl>

      <DocsH2>Emisión (OID4VCI)</DocsH2>
      <DocsP>
        Tu backend llama a la API del issuer con la API key y recibe una URI de oferta. La mostrás
        como QR o deep link. La wallet escanea, habla con el issuer y guarda la credencial. Tu
        servidor no implementa el protocolo de la wallet: solo crea la oferta (
        <Link href="/docs/emitir" className="text-[var(--kuatia-accent)] hover:underline">
          Emitir
        </Link>
        ).
      </DocsP>

      <DocsH2>Verificación (OID4VP)</DocsH2>
      <DocsP>
        Tu backend crea un presentation request (qué credencial y qué campos). La wallet muestra al
        usuario qué se pide; el usuario acepta y envía la prueba. Consultás el estado de la sesión
        hasta el resultado (
        <Link href="/docs/verificar" className="text-[var(--kuatia-accent)] hover:underline">
          Verificar
        </Link>
        ).
      </DocsP>

      <DocsH2>SD-JWT y divulgación selectiva</DocsH2>
      <DocsP>
        Kuatia usa credenciales SD-JWT VC: un token firmado donde algunos campos pueden marcarse
        como divulgables. Al presentar, el holder puede ocultar claims. Se prepara en la emisión con{' '}
        <code className="text-sm">disclosureFrame</code> y en la verificación pidiendo solo lo
        necesario.
      </DocsP>

      <DocsH2>Qué hace Kuatia vs tu app</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Kuatia (cloud)</span> — agentes{' '}
          <Link href="/docs/issuer" className="text-[var(--kuatia-accent)] hover:underline">
            issuer
          </Link>{' '}
          /{' '}
          <Link href="/docs/verifier" className="text-[var(--kuatia-accent)] hover:underline">
            verifier
          </Link>
          , firmas, metadata OpenID4VC, cupos y API keys.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Wallet Kuatia</span> — app opcional para
          titulares (
          <Link href="/docs/wallet" className="text-[var(--kuatia-accent)] hover:underline">
            Wallet
          </Link>
          ).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Tu producto</span> — negocio, UX, UI del QR y,
          si aplica, wallet propia en tu app.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Tu backend</span> — claims a emitir, cuándo
          emitir y qué exigir al verificar.
        </li>
      </DocsUl>
    </>
  )
}
