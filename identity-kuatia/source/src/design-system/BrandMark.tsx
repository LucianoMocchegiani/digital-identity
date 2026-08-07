import { cn } from '@/shared/lib/cn'
import Link from 'next/link'

/**
 * Marca Kuatia (cruz/X geométrica del mockup + wordmark).
 */
export function BrandMark({
  href = '/',
  className,
  size = 'md',
}: {
  href?: string
  className?: string
  size?: 'sm' | 'md' | 'lg'
}) {
  const text = size === 'lg' ? 'text-4xl' : size === 'sm' ? 'text-xl' : 'text-2xl'
  const box = size === 'lg' ? 'h-11 w-11' : size === 'sm' ? 'h-8 w-8' : 'h-9 w-9'
  const icon = size === 'lg' ? 'h-6 w-6' : 'h-5 w-5'

  return (
    <Link
      href={href}
      className={cn('inline-flex items-center gap-2.5 font-display font-semibold tracking-tight', className)}
    >
      <span
        aria-hidden
        className={cn(
          'grid place-items-center rounded-lg bg-[var(--kuatia-accent)]/15 text-[var(--kuatia-accent)]',
          box,
        )}
      >
        <svg viewBox="0 0 24 24" className={icon} fill="currentColor">
          <path d="M7.2 4.2 12 9l4.8-4.8 2 2L14 11l4.8 4.8-2 2L12 13l-4.8 4.8-2-2L10 11 5.2 6.2l2-2Z" />
        </svg>
      </span>
      <span className={cn(text, 'text-[var(--kuatia-text)]')}>Kuatia</span>
    </Link>
  )
}
