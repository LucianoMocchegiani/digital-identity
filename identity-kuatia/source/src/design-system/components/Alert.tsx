import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'

/**
 * Mensaje inline de feedback (error, info o éxito).
 * @param tone Estilo semántico del aviso.
 */
export function Alert({
  children,
  tone = 'error',
  className,
}: {
  children: ReactNode
  tone?: 'error' | 'info' | 'success'
  className?: string
}) {
  const tones = {
    error: 'border-red-500/40 bg-red-500/10 text-red-700',
    info: 'border-[var(--kuatia-accent)]/40 bg-[var(--kuatia-accent)]/10 text-[var(--kuatia-text)]',
    success: 'border-emerald-500/40 bg-emerald-500/10 text-emerald-800',
  }

  return (
    <div className={cn('rounded-xl border px-4 py-3 text-base', tones[tone], className)}>
      {children}
    </div>
  )
}
