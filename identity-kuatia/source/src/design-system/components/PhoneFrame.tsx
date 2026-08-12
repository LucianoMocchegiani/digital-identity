import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'

/** Marco de teléfono para mockups de wallet (respeta tema claro/oscuro). */
export function PhoneFrame({
  children,
  className,
  /** Si false, el contenido va a pantalla completa dentro del bezel. */
  padded = true,
}: {
  children: ReactNode
  className?: string
  padded?: boolean
}) {
  return (
    <div className={cn('relative mx-auto w-full max-w-[300px]', className)}>
      <div
        aria-hidden
        className="absolute -inset-8 rounded-full bg-[var(--kuatia-accent)]/20 blur-3xl"
      />
      <div
        className={cn(
          'relative overflow-hidden rounded-[2.2rem] border border-[var(--kuatia-border)] p-2 shadow-2xl',
          'bg-gradient-to-b from-[var(--kuatia-panel)] to-[var(--kuatia-atmosphere-mid)]',
          'shadow-[var(--kuatia-ink)]/20',
        )}
      >
        <div className="mx-auto mb-2 h-1.5 w-16 rounded-full bg-[var(--kuatia-muted)]/35" />
        <div
          className={cn(
            'overflow-hidden rounded-[1.6rem] border border-[var(--kuatia-border)] bg-[var(--kuatia-bg)]',
            padded && 'p-3.5',
          )}
        >
          {children}
        </div>
      </div>
    </div>
  )
}
