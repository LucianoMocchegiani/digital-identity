'use client'

/**
 * Cuenta: perfil, logout (UI de password lista para futuro endpoint).
 */
import { Badge, Button, Field, Panel, PasswordInput } from '@/design-system'
import { PageHeader } from '@/modules/console/components/PageHeader'
import { useAuth } from '@/shared/auth/AuthProvider'
import { useRouter } from 'next/navigation'

export function AccountPanel() {
  const { account, logout } = useAuth()
  const router = useRouter()

  if (!account) return null

  const initials = account.name
    .split(/\s+/)
    .map((p) => p[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <div>
      <PageHeader title="Mi cuenta" description="Administrá tu información personal." />

      <div className="grid max-w-3xl gap-4">
        <Panel className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-4">
            <span className="grid h-16 w-16 place-items-center rounded-full bg-[var(--kuatia-accent)] text-xl font-semibold text-[var(--kuatia-ink)]">
              {initials}
            </span>
            <div>
              <p className="text-base text-[var(--kuatia-muted)]">Nombre de cuenta</p>
              <p className="text-lg font-medium">{account.name}</p>
              <p className="mt-1 break-all text-base text-[var(--kuatia-muted)]">{account.email}</p>
              <div className="mt-2">
                <Badge tone="accent">{account.plan}</Badge>
              </div>
            </div>
          </div>
        </Panel>

        <Panel className="space-y-4">
          <h2 className="font-display text-xl font-semibold">Cambiar contraseña</h2>
          <p className="text-sm text-[var(--kuatia-muted)]">
            Pronto disponible vía API. Los campos ya siguen el diseño del mockup.
          </p>
          <Field label="Contraseña actual" htmlFor="current">
            <PasswordInput id="current" disabled placeholder="••••••••" />
          </Field>
          <Field label="Nueva contraseña" htmlFor="next">
            <PasswordInput id="next" disabled placeholder="Mínimo 8 caracteres" />
          </Field>
          <Button variant="secondary" disabled>
            Actualizar contraseña
          </Button>
        </Panel>

        <Panel className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-base text-[var(--kuatia-muted)]">
            Si cerrás sesión, vas a tener que volver a ingresar.
          </p>
          <Button
            variant="secondary"
            onClick={() => {
              logout()
              router.replace('/login')
            }}
          >
            Cerrar sesión
          </Button>
        </Panel>
      </div>
    </div>
  )
}
