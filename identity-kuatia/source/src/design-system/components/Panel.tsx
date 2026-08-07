import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'

/**
 * Contenedor de interacción (formularios, filas de producto).
 * No usar en heroes de marketing.
 */
export function Panel({
  children,
  className,
}: {
  children: ReactNode
  className?: string
}) {
  return (
    <div
      className={cn(
        'rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/80 p-5 backdrop-blur-sm',
        className,
      )}
    >
      {children}
    </div>
  )
}
