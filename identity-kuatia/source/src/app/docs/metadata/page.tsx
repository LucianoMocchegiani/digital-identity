import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsP,
  DocsTitle,
  DocsUl,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('metadata')

export default function DocsMetadataPage() {
  return (
    <>
      <DocsTitle>Metadata</DocsTitle>
      <DocsLead>
        El{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          well-known
        </Link>{' '}
        del issuer es la fuente de verdad de qué podés emitir y cómo se ve la credencial en la
        wallet.
      </DocsLead>

      <DocsP>Incluye dos capas:</DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Credenciales soportadas</span> (
          <code className="text-sm">credential_configurations_supported</code>) — cada clave es un{' '}
          <code className="text-sm">credentialConfigurationId</code>. La parte técnica (format, vct,
          algoritmos) la define Kuatia.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Display</span> — visual del emisor (raíz) y de
          cada credencial (nombre, colores, logo, imagen de fondo).
        </li>
      </DocsUl>

      <DocsEndpoint
        method="GET"
        path="/openid4vc-flow/{walletId}/.well-known/openid-credential-issuer"
        auth="Pública"
      >
        <p>
          Consultalo antes de crear offers y después de cambiar branding. Anotá el{' '}
          <code className="text-sm">credentialConfigurationId</code> y el{' '}
          <code className="text-sm">vct</code>.
        </p>
        <DocsCode>{`GET {ISSUER_URL}/openid4vc-flow/{walletId}/.well-known/openid-credential-issuer`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint
        method="GET"
        path="/openid4vc-flow/{walletId}/.well-known/oauth-authorization-server"
        auth="Pública"
      >
        <p>Metadata OAuth del issuer (la wallet la usa sola).</p>
      </DocsEndpoint>

      <DocsEndpoint
        method="GET"
        path="/openid4vc-auth/{walletId}/.well-known/oauth-authorization-server"
        auth="Pública"
      >
        <p>Equivalente en el verifier.</p>
        <DocsCode>{`GET {VERIFIER_URL}/openid4vc-auth/{walletId}/.well-known/oauth-authorization-server`}</DocsCode>
      </DocsEndpoint>
    </>
  )
}
