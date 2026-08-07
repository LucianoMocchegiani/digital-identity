import { IconCredentials, IconShield } from '@/design-system'
import { cn } from '@/shared/lib/cn'
import type { ResourceService } from '@/shared/types/billing'

/** Selector visual Issuer | Verifier (modal y formularios). */
export function ServiceTypePicker({
  value,
  onChange,
}: {
  value: ResourceService
  onChange: (v: ResourceService) => void
}) {
  const options: { id: ResourceService; title: string; body: string; Icon: typeof IconShield }[] = [
    {
      id: 'issuer',
      title: 'Issuer',
      body: 'Emitir credenciales',
      Icon: IconCredentials,
    },
    {
      id: 'verifier',
      title: 'Verifier',
      body: 'Verificar credenciales',
      Icon: IconShield,
    },
  ]

  return (
    <div className="grid gap-3 sm:grid-cols-2">
      {options.map(({ id, title, body, Icon }) => {
        const active = value === id
        return (
          <button
            key={id}
            type="button"
            onClick={() => onChange(id)}
            className={cn(
              'rounded-xl border p-4 text-left transition',
              active
                ? 'border-[var(--kuatia-accent)] bg-[var(--kuatia-accent)]/10 shadow-[0_0_24px_rgba(0,168,157,0.15)]'
                : 'border-[var(--kuatia-border)] hover:border-[var(--kuatia-accent)]/40',
            )}
          >
            <Icon size={22} className="text-[var(--kuatia-accent)]" />
            <p className="mt-2 font-semibold">{title}</p>
            <p className="text-sm text-[var(--kuatia-muted)]">{body}</p>
          </button>
        )
      })}
    </div>
  )
}
