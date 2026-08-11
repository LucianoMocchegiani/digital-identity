import { DocsH2, DocsLead, DocsP, DocsTitle, DocsUl } from '@/modules/docs/components/DocsPrimitives'
import Link from 'next/link'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('recomendaciones')

export default function DocsRecomendacionesPage() {
  return (
    <>
      <DocsTitle>Recomendaciones de uso</DocsTitle>
      <DocsLead>
        Guías prácticas para diseñar credenciales y flujos sin ser experto en SSI. Objetivo: menos
        datos expuestos, menos riesgo y mejor experiencia para el usuario.
      </DocsLead>

      <DocsH2>Mínimo de datos en la credencial</DocsH2>
      <DocsP>
        Emití solo lo que necesitás demostrar más adelante. Cada{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          claim
        </Link>{' '}
        extra es superficie de privacidad. Preferí identificadores o flags de negocio (“socio
        activo”, “nivel gold”) frente a volcar historiales o documentos completos en la credencial.
      </DocsP>

      <DocsH2>Divulgación selectiva</DocsH2>
      <DocsP>
        Marcá en <code className="text-sm">disclosureFrame._sd</code> los claims que el titular
        debería poder ocultar. Al verificar, pedí únicamente los campos del caso de uso (p. ej.
        nombre + estado, no el email si no hace falta). Más contexto en el{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          glosario
        </Link>
        .
      </DocsP>

      <DocsH2>Datos sensibles y uso online</DocsH2>
      <DocsP>
        Si tu aplicación (la que consume o complementa las credenciales) va a manejar información
        sensible del usuario y el uso es <span className="text-[var(--kuatia-text)]">online</span>,
        no la dejes en claro en tus servidores ni en claims de la credencial si no es imprescindible.
      </DocsP>
      <DocsUl>
        <li>
          Preferí cifrar esa información sensible con la{' '}
          <span className="text-[var(--kuatia-text)]">clave pública del usuario</span> (la de su
          identidad / wallet), de modo que solo el titular pueda descifrarla con su clave privada.
        </li>
        <li>
          En la credencial podés guardar un identificador, un hash o una referencia cifrada, y
          mantener el detalle sensible en tu backend o en un blob cifrado para el holder.
        </li>
        <li>
          Si el flujo debe funcionar <span className="text-[var(--kuatia-text)]">offline</span>,
          planificá qué datos mínimos tienen que viajar dentro de la credencial firmada (porque no
          habrá round-trip a tu servidor) y qué puede quedarse fuera.
        </li>
      </DocsUl>
      <DocsP>
        En resumen: la credencial demuestra hechos firmados por vos; el cifrado con clave pública
        del usuario protege secretos que solo él debería leer cuando el canal es online.
      </DocsP>

      <DocsH2>Qué no poner en claims en claro</DocsH2>
      <DocsUl>
        <li>Contraseñas, tokens de sesión o secretos de API</li>
        <li>Datos de salud, financieros o documento completo si un flag o hash alcanza</li>
        <li>Datos personales que nunca vas a pedir en una presentación</li>
      </DocsUl>

      <DocsH2>Branding vs configuración técnica</DocsH2>
      <DocsP>
        Personalizá nombre, logo y colores de la card. Dejá format,{' '}
        <code className="text-sm">vct</code> y algoritmos como los provisionó Kuatia. Tipos de
        credencial nuevos: pedilos al equipo Kuatia.
      </DocsP>

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
      </DocsUl>
    </>
  )
}
