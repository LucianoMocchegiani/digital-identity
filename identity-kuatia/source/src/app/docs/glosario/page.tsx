import { DocsLead, DocsP, DocsTitle } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Glosario',
}

const TERMS: { term: string; def: string }[] = [
  {
    term: 'SSI',
    def: 'Self-Sovereign Identity (identidad soberana): modelo donde el usuario controla sus credenciales en su wallet, en lugar de que cada servicio guarde una copia central de su identidad.',
  },
  {
    term: 'Credencial verificable (VC)',
    def: 'Conjunto de datos firmados por un emisor (por ejemplo “Ana es socia hasta 2027”). Cualquier verificador puede comprobar la firma sin llamar necesariamente a una base de datos del emisor en cada control.',
  },
  {
    term: 'OpenID4VC',
    def: 'OpenID for Verifiable Credentials: familia de estándares abiertos para emitir y presentar credenciales usando patrones similares a OAuth/OpenID. Es el “idioma” que hablan issuer, wallet y verifier.',
  },
  {
    term: 'OID4VCI',
    def: 'OpenID for Verifiable Credential Issuance: la parte de OpenID4VC que cubre la emisión (cómo la wallet obtiene la credencial desde el issuer).',
  },
  {
    term: 'OID4VP',
    def: 'OpenID for Verifiable Presentations: la parte que cubre la presentación (cómo la wallet responde a un pedido del verifier).',
  },
  {
    term: 'Issuer (emisor)',
    def: 'Quién firma y entrega la credencial: tu organización vía el producto Issuer de Kuatia.',
  },
  {
    term: 'Holder (titular)',
    def: 'La persona (o entidad) que guarda la credencial en su wallet y decide cuándo y qué revelar.',
  },
  {
    term: 'Verifier (verificador)',
    def: 'Quién pide una prueba y valida la presentación: tu organización vía el producto Verifier de Kuatia.',
  },
  {
    term: 'Wallet',
    def: 'App en el teléfono (u otro dispositivo) que guarda claves y credenciales del holder y ejecuta los flujos OpenID4VC al escanear un QR.',
  },
  {
    term: 'DID',
    def: 'Decentralized Identifier: identificador que apunta a claves públicas (en Kuatia, típicamente did:web expuesto en did.json). Sirve para firmar y verificar sin un usuario/contraseña clásico.',
  },
  {
    term: 'SD-JWT / SD-JWT VC',
    def: 'Formato de credencial (JWT con divulgaciones selectivas). Permite que algunos campos se puedan ocultar al presentar, en lugar de mandar siempre todo el documento.',
  },
  {
    term: 'Claim',
    def: 'Un dato dentro de la credencial: nombre, email, rol, “válido hasta”, etc.',
  },
  {
    term: 'Divulgación selectiva',
    def: 'Capacidad del holder de revelar solo algunos claims al verifier. En la emisión se prepara con disclosureFrame; en la verificación pedís solo lo necesario.',
  },
  {
    term: 'Oferta (credential offer)',
    def: 'URI/QR que el issuer genera para que la wallet inicie la emisión. En la API: POST …/openid4vc/offer → offerUri.',
  },
  {
    term: 'Presentation request',
    def: 'Pedido del verifier (“mostrame una membresía vigente”). En la API: POST …/openid4vc/request → requestUri.',
  },
  {
    term: 'Well-known / metadata',
    def: 'Documento público del issuer que describe qué tipos de credencial emite y cómo se ven (display). La wallet lo lee sola; tu backend lo usa para saber los configuration ids.',
  },
  {
    term: 'credentialConfigurationId',
    def: 'Identificador del tipo de credencial en la metadata (ej. membership_card). Lo usás al crear un offer.',
  },
  {
    term: 'vct',
    def: 'Verifiable Credential Type: tipo semántico de la credencial en SD-JWT (ej. MembershipCredential). Debe alinearse con la configuración del issuer.',
  },
  {
    term: 'API key',
    def: 'Secreto iss_live_… / ver_live_… de tu producto Kuatia. Autentica las llamadas admin de tu backend (no va en el frontend público).',
  },
  {
    term: 'Credo',
    def: 'Framework open source (TypeScript) para agentes de identidad descentralizada. Kuatia lo usa bajo el issuer y el verifier.',
  },
  {
    term: 'OpenWallet Foundation (OWF)',
    def: 'Fundación (Linux Foundation) que impulsa software y estándares de wallets e identidad abierta. Credo forma parte de ese ecosistema.',
  },
  {
    term: 'EUDI',
    def: 'European Digital Identity: iniciativa europea de billetera e identidad digital. Muchas wallets y emisores alinean OpenID4VC / SD-JWT a ese contexto.',
  },
]

export default function DocsGlosarioPage() {
  return (
    <>
      <DocsTitle>Glosario</DocsTitle>
      <DocsLead>
        Palabras que aparecen en esta documentación y en la API. Pensado para quien no vive de SSI
        día a día. Para el “por qué” del producto, volvé a la{' '}
        <Link href="/docs/introduccion" className="text-[var(--kuatia-accent)] hover:underline">
          introducción
        </Link>
        .
      </DocsLead>

      <DocsP>
        Tip: si en otra página ves una sigla en negrita o código, buscala acá.
      </DocsP>

      <dl className="mt-10 space-y-8">
        {TERMS.map(({ term, def }) => (
          <div key={term} className="border-b border-[var(--kuatia-border)] pb-6 last:border-0">
            <dt className="font-display text-lg font-semibold text-[var(--kuatia-accent)] sm:text-xl">
              {term}
            </dt>
            <dd className="mt-2 text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-[17px]">
              {def}
            </dd>
          </div>
        ))}
      </dl>
    </>
  )
}
