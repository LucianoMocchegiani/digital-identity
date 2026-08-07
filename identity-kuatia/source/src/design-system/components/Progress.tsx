import { cn } from '@/shared/lib/cn'

/**
 * Barra de progreso valor/máximo (uso de cuota, etc.).
 * @param value Cantidad usada.
 * @param max Tope; si es ≤0 el porcentaje es 0.
 */
export function Progress({
  value,
  max,
  className,
}: {
  value: number
  max: number
  className?: string
}) {
  const pct = max <= 0 ? 0 : Math.min(100, Math.round((value / max) * 100))
  return (
    <div className={cn('h-2 w-full overflow-hidden rounded-full bg-[var(--kuatia-hover)]', className)}>
      <div
        className="h-full rounded-full bg-[var(--kuatia-accent)] transition-[width] duration-500"
        style={{ width: `${pct}%` }}
      />
    </div>
  )
}
