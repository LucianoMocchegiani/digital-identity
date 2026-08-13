import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('recomendaciones')

export default function DocsRecomendacionesPage() {
  return (
    <>
      <DocsTitle>Recomendaciones</DocsTitle>
      <DocsLead>
        Cómo diseñar credenciales y flujos con menos datos expuestos y menos riesgo operativo.
      </DocsLead>

      <DocsH2>Mínimo de datos en la credencial</DocsH2>
      <DocsP>
        Emití solo lo que necesitás demostrar más adelante. Cada claim extra es superficie de
        privacidad. Preferí identificadores o flags de negocio (“socio activo”, “nivel gold”) frente
        a volcar historiales o documentos completos en la credencial.
      </DocsP>

      <DocsH2>Divulgación selectiva</DocsH2>
      <DocsP>
        Marcá en <code className="text-sm">disclosureFrame._sd</code> los claims que el titular
        debería poder ocultar. Al verificar, pedí únicamente los campos del caso de uso (p. ej.
        nombre + rol, no un email si no hace falta).
      </DocsP>

      <DocsH2>Datos sensibles</DocsH2>
      <DocsP>
        Si el uso es online, dejá el detalle sensible en tu backend (o en un almacenamiento que
        controles vos) y poné en la credencial un identificador, un flag o una referencia. Kuatia no
        ofrece un esquema de cifrado de claims con la clave del holder: ese patrón, si lo necesitás,
        es de tu aplicación.
      </DocsP>
      <DocsUl>
        <li>
          Online — la credencial demuestra el hecho firmado; el detalle sensible se resuelve en tu
          sistema tras una verificación exitosa.
        </li>
        <li>
          Offline — planificá qué mínimo tiene que viajar dentro de la credencial firmada (no habrá
          round-trip a tu servidor) y qué puede quedarse fuera.
        </li>
      </DocsUl>

      <DocsH2>Qué no poner en claims en claro</DocsH2>
      <DocsUl>
        <li>Contraseñas, tokens de sesión o secretos de API</li>
        <li>Datos de salud, financieros o documento completo si un flag o hash alcanza</li>
        <li>Datos personales que nunca vas a pedir en una presentación</li>
      </DocsUl>

      <DocsH2>Operación</DocsH2>
      <DocsUl>
        <li>Guardá la API key como secreto (no en el frontend público).</li>
        <li>Usá siempre HTTPS en las base URLs del issuer/verifier.</li>
        <li>
          Chequeá <code className="text-sm">/v1/health/ready</code> antes de picos de emisión.
        </li>
        <li>
          Cada offer/request consume cuota del plan: evitá crear ofertas que nadie va a escanear.
        </li>
        <li>
          Logo, colores y nombre de card:{' '}
          <Link href="/docs/branding" className="text-[var(--kuatia-accent)] hover:underline">
            Branding
          </Link>
          .
        </li>
      </DocsUl>
    </>
  )
}
