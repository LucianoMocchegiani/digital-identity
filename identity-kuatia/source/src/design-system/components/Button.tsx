import { cn } from '@/shared/lib/cn'
import type { ButtonHTMLAttributes, ReactNode } from 'react'

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger'
type Size = 'md' | 'sm' | 'lg'

const variants: Record<Variant, string> = {
  primary:
    'bg-[var(--kuatia-accent)] text-[var(--kuatia-ink)] hover:brightness-110 disabled:opacity-50',
  secondary:
    'border border-[var(--kuatia-accent)]/70 text-[var(--kuatia-text)] hover:bg-[var(--kuatia-accent)]/10 disabled:opacity-50',
  ghost: 'text-[var(--kuatia-muted)] hover:text-[var(--kuatia-text)] hover:bg-white/5',
  danger: 'bg-red-500/15 text-red-300 border border-red-500/40 hover:bg-red-500/25',
}

/**
 * Escala SaaS ~16–18px. `lg` un poco más compacto en mobile para no romper filas.
 */
const sizes: Record<Size, string> = {
  sm: 'h-10 px-4 text-base rounded-xl md:h-11',
  md: 'h-12 px-5 text-base rounded-xl md:px-6',
  lg: 'h-12 px-6 text-base font-semibold rounded-xl md:h-14 md:px-8 md:text-lg md:rounded-2xl',
}

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant
  size?: Size
  children: ReactNode
}

/**
 * Botón del design system con variantes y tamaños.
 * @param variant Estilo visual (primary, secondary, ghost, danger).
 * @param size Tamaño del control.
 */
export function Button({
  variant = 'primary',
  size = 'md',
  className,
  children,
  type = 'button',
  ...rest
}: Props) {
  return (
    <button
      type={type}
      className={cn(
        'inline-flex items-center justify-center gap-2 font-medium transition duration-200',
        'focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--kuatia-accent)]',
        variants[variant],
        sizes[size],
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  )
}
