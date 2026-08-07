/**
 * Placeholder de la ruta `/app/credenciales` hasta OpenID4VC web.
 * Explica que reutilizará productos issuer/verifier ya provisionados.
 */
import { Panel } from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'

/** Vista temporal del módulo de credenciales. */
export function CredentialsPlaceholder() {
  return (
    <div>
      <PageHeader
        title="Credenciales"
        description="Próximamente: emitir y verificar desde la web con OpenID4VC (documentos, entradas y membresías)."
      />
      <Panel className="max-w-2xl">
        <p className="text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-lg">
          Este módulo usará tus productos <strong className="text-[var(--kuatia-text)]">issuer</strong> y{' '}
          <strong className="text-[var(--kuatia-text)]">verifier</strong> ya provisionados. La consola de
          productos y billing queda igual; acá se suma el flujo de negocio.
        </p>
      </Panel>
    </div>
  )
}
