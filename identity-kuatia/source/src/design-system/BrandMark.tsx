import { KuatiaMarkIcon } from '@/design-system/KuatiaMarkIcon'
import { cn } from '@/shared/lib/cn'
import Link from 'next/link'

/**
 * Marca Kuatia (ícono sin fondo + wordmark) — header, sidebar, footer.
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
  const icon = size === 'lg' ? 44 : size === 'sm' ? 32 : 36

  return (
    <Link
      href={href}
      className={cn('inline-flex items-center gap-2.5 font-display font-semibold tracking-tight', className)}
    >
      <KuatiaMarkIcon size={icon} className="shrink-0" />
      <span className={cn(text, 'text-[var(--kuatia-text)]')}>Kuatia</span>
    </Link>
  )
}
