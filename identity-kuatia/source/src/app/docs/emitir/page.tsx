import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('emitir')

export default function DocsEmitirPage() {
  return (
    <>
      <DocsTitle>Emitir</DocsTitle>
      <DocsLead>
        Creá una{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          oferta
        </Link>{' '}
        de emisión (
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OID4VCI
        </Link>
        ) pre-autorizada. En la consola, Kuatia genera el QR original y el QR para abrir la{' '}
        <Link href="/docs/wallet" className="text-[var(--kuatia-accent)] hover:underline">
          wallet web
        </Link>{' '}
        con la oferta lista para revisar. Cada offer consume cuota del plan.
      </DocsLead>

      <DocsEndpoint
        method="POST"
        path="/v1/issuers/{walletId}/openid4vc/offer"
        auth="X-API-Key (issuer)"
      >
        <DocsCode>{`POST {ISSUER_URL}/v1/issuers/{walletId}/openid4vc/offer
X-API-Key: iss_live_…

{
  "credentialConfigurationId": "membership_card",
  "vct": "MembershipCredential",
  "claims": {
    "name": "Ana Pérez",
    "role": "member",
    "organization": "Club Norte",
    "validFrom": "2026-08-01"
  },
  "disclosureFrame": {
    "_sd": ["role", "organization", "validFrom"]
  },
  "claimsDisplay": {
    "name": { "name": "Nombre completo", "locale": "es" },
    "role": { "name": "Rol", "locale": "es" }
  }
}

→ { "offerUri": "openid-credential-offer://…", "issuanceSessionId": "…" }`}</DocsCode>
        <p>
          La API devuelve una URI de protocolo. Para que un teléfono abra la wallet web al escanear,
          generá el QR con el enlace HTTPS de wallet, no con la URI original. Conservá todos sus
          parámetros de consulta:
        </p>
        <DocsCode>{`openid-credential-offer://...?PARAMS
  → https://wallet.kuatia.xyz/issue?PARAMS`}</DocsCode>
        <p>
          La consola de Kuatia genera ambos QR automáticamente. En la wallet web el titular revisa
          la oferta y confirma antes de recibir/guardar la credencial; escanear no la acepta por sí
          solo.
        </p>
        <p>
          Los claims son responsabilidad del emisor. Kuatia firma y entrega la credencial; no
          comprueba el hecho de negocio detrás del claim (por ejemplo, que Ana sea miembro de Club
          Norte). Eso lo valida tu organización al emitir.
        </p>
        <p>
          <code className="text-sm">credentialConfigurationId</code> debe existir en el well-known.{' '}
          <code className="text-sm">disclosureFrame._sd</code> marca claims ocultables al presentar.
          Tu backend no llama a /token ni /credential.
        </p>
      </DocsEndpoint>
    </>
  )
}
