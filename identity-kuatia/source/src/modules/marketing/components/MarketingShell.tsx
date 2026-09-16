import { cn } from '@/shared/lib/cn'
import type { HTMLAttributes, ReactNode } from 'react'

type ShellTag = 'div' | 'section' | 'header' | 'footer' | 'main'

type Props = {
  children: ReactNode
  className?: string
  as?: ShellTag
} & Omit<HTMLAttributes<HTMLElement>, 'className' | 'children'>

/**
 * Contenedor de marketing: ancho estable (alineado a la escala de tipografía).
 */
export function MarketingShell({ children, className, as: Tag = 'div', ...rest }: Props) {
  return (
    <Tag
      className={cn(
        'mx-auto w-full max-w-6xl px-6 md:px-10 lg:px-12',
        className,
      )}
      {...rest}
    >
      {children}
    </Tag>
  )
}
