/**
 * Navegación de la consola autenticada.
 */
import {
  IconAccount,
  IconCredentials,
  IconPlan,
  IconProducts,
  IconUsage,
} from '@/design-system'
import type { ComponentType, SVGProps } from 'react'

type IconComp = ComponentType<SVGProps<SVGSVGElement> & { size?: number }>

/** Entrada del menú lateral de la consola. */
export type ConsoleNavItem = {
  href: string
  label: string
  module: 'products' | 'account' | 'credentials' | 'admin'
  Icon: IconComp
  /** Si true, se muestra pero aún no es la feature completa. */
  soon?: boolean
}

/** Items visibles en `AppSidebar`. */
export const consoleNav: ConsoleNavItem[] = [
  { href: '/app/productos', label: 'Productos', module: 'products', Icon: IconProducts },
  { href: '/app/uso', label: 'Uso', module: 'account', Icon: IconUsage },
  { href: '/app/plan', label: 'Plan', module: 'account', Icon: IconPlan },
  {
    href: '/app/credenciales',
    label: 'Credenciales',
    module: 'credentials',
    Icon: IconCredentials,
  },
  { href: '/app/cuenta', label: 'Cuenta', module: 'account', Icon: IconAccount },
]
