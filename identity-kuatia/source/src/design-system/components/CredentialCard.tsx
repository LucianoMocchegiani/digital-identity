import { cn } from '@/shared/lib/cn'

type Variant = 'membership' | 'ticket' | 'document'

const styles: Record<Variant, string> = {
  membership: 'from-[var(--kuatia-accent)] to-[#043c38]',
  ticket: 'from-[#6b21a8] to-[#1e1030]',
  document: 'from-[#0e7490] to-[#0f172a]',
}

/**
 * Mini credencial visual para phones de marketing (reutilizable en hero y casos).
 */
export function CredentialCard({
  variant,
  eyebrow,
  title,
  meta,
  className,
}: {
  variant: Variant
  eyebrow: string
  title: string
  meta: string
  className?: string
}) {
  return (
    <div
      className={cn(
        'rounded-2xl bg-gradient-to-br p-4 text-white shadow-lg',
        styles[variant],
        className,
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-xs opacity-80">{eyebrow}</p>
          <p className="mt-1 font-display text-lg font-semibold leading-tight">{title}</p>
          <p className="mt-2 text-xs opacity-80">{meta}</p>
        </div>
        <div
          aria-hidden
          className="grid h-12 w-12 shrink-0 place-items-center rounded-md bg-white/90 p-1"
        >
          <div
            className="h-full w-full rounded-[2px]"
            style={{
              backgroundImage:
                'repeating-linear-gradient(0deg,#111 0 2px,transparent 2px 4px), repeating-linear-gradient(90deg,#111 0 2px,transparent 2px 4px)',
            }}
          />
        </div>
      </div>
    </div>
  )
}
