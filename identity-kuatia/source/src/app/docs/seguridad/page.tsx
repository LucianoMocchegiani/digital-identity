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
        Cómo autentica Kuatia las rutas admin, cómo aísla tenants, qué cupos aplican y qué datos
        entran en juego en billing e issuer/verifier.
      </DocsLead>

      <DocsH2>Autenticación (API key)</DocsH2>
      <DocsP>
        Las rutas de administración (offers, requests, branding, revocación mutante) exigen API key.
        Prefijos y header:{' '}
        <Link href="/docs/autenticacion" className="text-[var(--kuatia-accent)] hover:underline">
          Autenticación
        </Link>
        .
      </DocsP>
      <DocsUl>
        <li>
          Billing guarda el <span className="text-[var(--kuatia-text)]">hash</span> de la key
          (SHA-256), un prefijo visible y metadatos (revocada, último uso). El secreto en claro se
          muestra <span className="text-[var(--kuatia-text)]">una sola vez</span> al crear o rotar.
        </li>
        <li>
          La key debe vivir en tu backend. Está ligada al producto /{' '}
          <code className="text-sm">walletId</code>: usarla en otro tenant → 403.
        </li>
        <li>
          La consola usa JWT de cuenta (email/contraseña u OAuth). Eso es independiente de la API
          key del producto.
        </li>
      </DocsUl>

      <DocsH2>Multi-tenant</DocsH2>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Cuenta</span> — plan, cupos, login.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Producto</span> — un issuer <em>o</em> un
          verifier.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">walletId</span> — id del tenant en las URLs de
          la API.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">API key</span> — credencial de ese producto.
        </li>
      </DocsUl>
      <DocsP>Cada producto se provisiona en su propio espacio de agente; claves y cupos no se comparten entre cuentas.</DocsP>

      <DocsH2>Rate limits y cuotas</DocsH2>
      <DocsP>
        <span className="text-[var(--kuatia-text)]">1) Autenticado (plan)</span> — llamadas con API
        key a issuer/verifier cuentan contra el plan (solicitudes / minuto y transacciones del mes
        UTC). Planes cloud: Free, Pro y Proveedores; despliegue dedicado vía ventas.
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">429</span> — rate limit del plan (solicitudes /
          min).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">402</span> — cuota mensual de transacciones
          agotada.
        </li>
      </DocsUl>
      <DocsP>
        <span className="text-[var(--kuatia-text)]">2) Público (por IP)</span> — health, discovery
        (did.json, well-known, status-list) y flujos de protocolo OpenID4VC llevan throttle en el
        proceso (memoria local, por IP), orientado a no romper wallets ni probes:
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">health</span> — 300 req/min por IP
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">discovery</span> — 120 req/min por IP
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">protocolo</span> — 180 req/min por IP
        </li>
      </DocsUl>
      <DocsP>
        Con API key de producto se omite el throttle público y mandan los cupos del plan. Ajustable
        con <code className="text-sm">PUBLIC_RATE_LIMIT_*</code>. Respuesta 429 con{' '}
        <code className="text-sm">Retry-After</code>. En multi-réplica el límite es por instancia
        hasta haber edge/Redis compartido. Códigos:{' '}
        <Link href="/docs/errores" className="text-[var(--kuatia-accent)] hover:underline">
          Errores
        </Link>
        .
      </DocsP>

      <DocsH2>Qué guardamos y qué no</DocsH2>
      <DocsP>
        Kuatia no es un repositorio central de la identidad del usuario final. La credencial emitida
        vive en la{' '}
        <Link href="/docs/wallet" className="text-[var(--kuatia-accent)] hover:underline">
          wallet
        </Link>{' '}
        del titular.
      </DocsP>
      <DocsUl>
        <li>
          <span className="text-[var(--kuatia-text)]">Billing</span> — cuenta, productos, hashes de
          API keys, uso del período. Contraseñas de consola con hash (scrypt).
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Issuer / verifier</span> — estado del agente
          (claves del emisor/verificador, metadata, sesiones de protocolo). El issuer puede mantener
          listas de estado para revocación cuando el caso lo usa.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Claims del offer</span> — los enviás al emitir;
          no hay un vault aparte de VCs del holder más allá de lo que el protocolo necesita para el
          flujo.
        </li>
        <li>
          <span className="text-[var(--kuatia-text)]">Tu app</span> — PII de negocio y secretos
          siguen siendo tu responsabilidad (
          <Link href="/docs/recomendaciones" className="text-[var(--kuatia-accent)] hover:underline">
            Recomendaciones
          </Link>
          ).
        </li>
      </DocsUl>

      <DocsH2>Estándares</DocsH2>
      <DocsP>
        Los agentes hablan{' '}
        <Link href="/docs/glosario" className="text-[var(--kuatia-accent)] hover:underline">
          OpenID4VC
        </Link>{' '}
        y SD-JWT VC.
      </DocsP>

      <DocsH2>HTTPS, salud y revocación</DocsH2>
      <DocsUl>
        <li>
          Usá siempre HTTPS en las base URLs públicas del issuer/verifier (TLS en el edge / proxy).
        </li>
        <li>
          <Link href="/docs/health" className="text-[var(--kuatia-accent)] hover:underline">
            Health
          </Link>{' '}
          — liveness y readiness públicos sin API key.
        </li>
        <li>
          Cuando el producto lo habilita, la revocación se apoya en status lists del issuer
          (consultas públicas de estado; mutaciones con API key).
        </li>
      </DocsUl>
    </>
  )
}
