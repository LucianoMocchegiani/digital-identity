import { cn } from '@/shared/lib/cn'
import type { InputHTMLAttributes } from 'react'

type Props = InputHTMLAttributes<HTMLInputElement>

/** Campo de texto estilizado del design system (16px+, touch-friendly). */
export function Input({ className, ...rest }: Props) {
  return (
    <input
      className={cn(
        'h-12 w-full rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-4 text-base text-[var(--kuatia-text)]',
        'placeholder:text-[var(--kuatia-muted)]',
        'focus:border-[var(--kuatia-accent)]/60 focus:outline-none focus:ring-2 focus:ring-[var(--kuatia-accent)]/25',
        'disabled:opacity-50',
        className,
      )}
      {...rest}
    />
  )
}
