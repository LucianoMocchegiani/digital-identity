import { cn } from '@/shared/lib/cn'
import type { HTMLAttributes, ReactNode } from 'react'

type ShellTag = 'div' | 'section' | 'header' | 'footer' | 'main'

type Props = {
  children: ReactNode
  className?: string
  as?: ShellTag
} & Omit<HTMLAttributes<HTMLElement>, 'className' | 'children'>

/**
 * Contenedor de marketing: en mobile/tablet se ve compacto;
 * en pantallas grandes ocupa casi todo el ancho (no un “columnita” al centro).
 */
export function MarketingShell({ children, className, as: Tag = 'div', ...rest }: Props) {
  return (
    <Tag
      className={cn(
        'mx-auto w-full max-w-6xl px-6 md:px-10',
        'xl:max-w-[88rem] xl:px-14',
        '2xl:max-w-[100rem] 2xl:px-20',
        className,
      )}
      {...rest}
    >
      {children}
    </Tag>
  )
}
