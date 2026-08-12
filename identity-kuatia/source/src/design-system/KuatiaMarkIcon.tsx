import { cn } from '@/shared/lib/cn'

/** Asset de marca (K + credencial). */
export const KUATIA_MARK_SRC = '/kuatia-mark.png'

/** Ícono de marca Kuatia (PNG). */
export function KuatiaMarkIcon({
  className,
  size = 20,
}: {
  className?: string
  size?: number
}) {
  return (
    // eslint-disable-next-line @next/next/no-img-element -- marca estática local
    <img
      src={KUATIA_MARK_SRC}
      alt=""
      width={size}
      height={size}
      className={cn('object-cover', className)}
      aria-hidden
    />
  )
}
