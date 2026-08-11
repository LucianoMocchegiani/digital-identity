import {
  DocsH2,
  DocsLead,
  DocsP,
  DocsTitle,
  DocsUl,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('seguridad')

export default function DocsSeguridadPage() {
  return (
    <>
      <DocsTitle>Seguridad y confianza</DocsTitle>
      <DocsLead>
        Cómo autentica Kuatia, cómo aísla tenants, qué cupos aplican y qué datos entran en juego —
        sin claims de certificaciones que no tenemos (SOC 2, ISO, eIDAS, etc.).
      </DocsLead>

      <DocsH2>Autenticación (API key)</DocsH2>
      <DocsP>
        Las rutas de administración del issuer/verifier (offers, requests, branding, revocación
        mutante) exigen API key. Detalle operativo en{' '}
        <Link href="/docs/autenticacion" className="text-[var(--kuatia-accent)] hover:underline">
          Autenticación
        </Link>
        .
      </DocsP>
      <DocsUl>
        <li>
          Prefijos: <code className="text-sm">iss_live_…</code> (issuer) y{' '}
          <code className="text-sm">ver_live_…</code> (verifier).
        </li>
        <li>
          Header: <code className="text-sm">X-API-Key</code> (también se acepta Bearer con el mismo
          secreto).
        </li>
        <li>
          En billing guardamos el <span className="text-[var(--kuatia-text)]">hash</span> de la key
          (SHA-256), un prefijo visible y metadatos (revocada, último uso). El secreto en claro se
          muestra <span className="text-[var(--kuatia-text)]">una sola vez</span> al crear o rotar.
        </li>
        <li>
          La key debe vivir en tu <span className="text-[var(--kuatia-text)]">backend</span>, nunca
          en un cliente público ni en un repo.
        </li>
        <li>
          La key está ligada al producto / <code className="text-sm">walletId</code>: usarla en otro
          tenant → 403.
        </li>
      </DocsUl>
      <DocsP>
        La consola Kuatia se autentica a billing con JWT de cuenta. Eso es independiente de la API
        key del producto que usa tu integración OpenID4VC.
      </DocsP>

      <DocsH2>Multi-tenant</DocsH2>
      <DocsP>Modelo de aislamiento:</DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Cuenta</span> — plan, cupos, login.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Producto</span> — un issuer <em>o</em> un
          verifier.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">walletId</span> — id del tenant en el agente
          (aparece en las URLs de la API).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">API key</span> — credencial de ese producto.
        </li>
      </DocsUl>
      <DocsP>
        Cada producto se provisiona en su propio espacio de agente. No mezclamos claves ni cupos
        entre cuentas.
      </DocsP>

      <DocsH2>Rate limits y cuotas</DocsH2>
      <DocsP>
        Cada llamada autenticada relevante a issuer/verifier se valida y cuenta contra el plan
        (solicitudes por minuto y transacciones del mes UTC). Planes actuales: Free, Pro, Pro Double
        y Business a medida — ver precios en la landing o el panel Plan de la consola.
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">429</span> — rate limit (solicitudes / min).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">402</span> — cuota mensual de transacciones
          agotada.
        </li>
      </DocsUl>
      <DocsP>
        Health, well-known y <code className="text-sm">did.json</code> son públicos (wallets y
        probes). Los límites específicos de esos endpoints públicos se irán documentando a medida
        que se endurezcan en edge/producto; no asumas el mismo RPM del plan ahí.
      </DocsP>
      <DocsP>
        Códigos HTTP habituales:{' '}
        <Link href="/docs/errores" className="text-[var(--kuatia-accent)] hover:underline">
          Errores
        </Link>
        .
      </DocsP>

      <DocsH2>Qué guardamos y qué no</DocsH2>
      <DocsP>
        Kuatia <span className="text-[var(--kuatia-text)]">no</span> es un repositorio central de la
        identidad del usuario final. La credencial emitida vive en la{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          wallet
        </Link>{' '}
        del titular.
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Billing</span> — cuenta, productos, hashes de
          API keys, uso del período. Contraseñas de consola con hash (scrypt). No corre Credo.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Issuer / verifier</span> — estado del agente
          (claves del emisor/verificador, metadata, sesiones de protocolo). El issuer puede mantener
          listas de estado para{' '}
          <span className="text-[var(--kuatia-text)]">revocación</span> cuando el caso lo usa.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Claims del offer</span> — los enviás vos al
          emitir; no operamos un “vault” de VCs del holder aparte de lo que el protocolo y el agente
          necesitan para completar el flujo.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Tu app</span> — sigue siendo responsable de PII
          de negocio, KYC al emitir y de no meter secretos en claims. Ver{' '}
          <Link href="/docs/recomendaciones" className="text-[var(--kuatia-accent)] hover:underline">
            Recomendaciones
          </Link>
          .
        </li>
      </DocsUl>

      <DocsH2>Estándares y stack (sin lavado de compliance)</DocsH2>
      <DocsP>
        Los agentes se construyen sobre{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          Credo
        </Link>{' '}
        (TypeScript; ecosistema de la{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenWallet Foundation
        </Link>
        ) y hablan{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenID4VC
        </Link>{' '}
        / SD-JWT VC. Eso mejora interoperabilidad y reduce reinventar criptografía de protocolo;{' '}
        <span className="text-[var(--kuatia-text)]">
          no equivale a una certificación SOC 2, ISO, eIDAS u otra auditoría que no hayamos
          publicado
        </span>
        .
      </DocsP>
      <DocsP>
        Contexto más amplio (antifraude por diseño, roles):{' '}
        <Link href="/docs/introduccion" className="text-[var(--kuatia-accent)] hover:underline">
          Introducción
        </Link>{' '}
        y{' '}
        <Link href="/docs/como-funciona" className="text-[var(--kuatia-accent)] hover:underline">
          Cómo funciona
        </Link>
        .
      </DocsP>

      <DocsH2>HTTPS, salud y revocación</DocsH2>
      <DocsUl>
        <li>
          Usá siempre <span className="text-[var(--kuatia-text)]">HTTPS</span> en las base URLs
          públicas del issuer/verifier (TLS en el edge / proxy).
        </li>
        <li>
          <Link href="/docs/health" className="text-[var(--kuatia-accent)] hover:underline">
            Health
          </Link>{' '}
          — liveness y readiness públicos sin API key.
        </li>
        <li>
          Cuando el producto lo habilita, la revocación se apoya en status lists del issuer (consultas
          públicas de estado; mutaciones con API key).
        </li>
      </DocsUl>

      <DocsH2>Responsabilidad compartida</DocsH2>
      <DocsP>
        Kuatia cubre el plano de emisión/verificación con estándar abierto y controles de cuenta
        (keys, cupos, aislamiento). Vos cubrís la lógica de negocio, el cuidado de datos al emitir,
        el secreto de las API keys y el uso correcto de divulgación selectiva. Si algo no está
        certificado o auditado acá, no lo demos por hecho: pedilo al equipo o mirá el{' '}
        <Link href="/docs/changelog" className="text-[var(--kuatia-accent)] hover:underline">
          changelog
        </Link>
        .
      </DocsP>
    </>
  )
}
