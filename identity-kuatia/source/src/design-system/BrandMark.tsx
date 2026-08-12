import { KuatiaMarkIcon } from '@/design-system/KuatiaMarkIcon'
import { cn } from '@/shared/lib/cn'
import Link from 'next/link'

/**
 * Marca Kuatia (ícono + wordmark) — header, sidebar, footer.
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
  const icon = size === 'lg' ? 44 : size === 'sm' ? 32 : 36

  return (
    <Link
      href={href}
      className={cn('inline-flex items-center gap-2.5 font-display font-semibold tracking-tight', className)}
    >
      <span
        aria-hidden
        className={cn('overflow-hidden rounded-lg', box)}
      >
        <KuatiaMarkIcon size={icon} className="h-full w-full" />
      </span>
      <span className={cn(text, 'text-[var(--kuatia-text)]')}>Kuatia</span>
    </Link>
  )
}
