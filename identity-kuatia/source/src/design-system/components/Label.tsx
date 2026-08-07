import { cn } from '@/shared/lib/cn'
import type { LabelHTMLAttributes } from 'react'

/** Etiqueta de formulario alineada al tema Kuatia. */
export function Label({ className, ...rest }: LabelHTMLAttributes<HTMLLabelElement>) {
  return (
    <label
      className={cn('mb-2 block text-base font-medium text-[var(--kuatia-muted)]', className)}
      {...rest}
    />
  )
}
