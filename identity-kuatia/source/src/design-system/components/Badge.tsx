import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'

type Tone = 'accent' | 'neutral' | 'success' | 'warn'

const tones: Record<Tone, string> = {
  accent: 'bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)] border-[var(--kuatia-accent)]/30',
  neutral: 'bg-white/5 text-[var(--kuatia-muted)] border-white/10',
  success: 'bg-emerald-500/15 text-emerald-300 border-emerald-500/30',
  warn: 'bg-amber-500/15 text-amber-200 border-amber-500/30',
}

/**
 * Chip de estado o categoría (plan, servicio, status).
 * @param tone Paleta semántica: accent, neutral, success o warn.
 */
export function Badge({
  children,
  tone = 'neutral',
  className,
}: {
  children: ReactNode
  tone?: Tone
  className?: string
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-1 text-sm font-medium',
        tones[tone],
        className,
      )}
    >
      {children}
    </span>
  )
}
