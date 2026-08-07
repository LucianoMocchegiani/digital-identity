/**
 * Navegación de la documentación (sidebar estilo Docusaurus).
 */
export type DocsNavItem = {
  href: string
  label: string
}

export type DocsNavSection = {
  title: string
  items: DocsNavItem[]
}

export const DOCS_NAV: DocsNavSection[] = [
  {
    title: 'Fundamentos',
    items: [
      { href: '/docs/introduccion', label: 'Introducción' },
      { href: '/docs/glosario', label: 'Glosario' },
      { href: '/docs/como-funciona', label: 'Cómo funciona' },
      { href: '/docs/recomendaciones', label: 'Recomendaciones' },
    ],
  },
  {
    title: 'Empezar',
    items: [
      { href: '/docs/empezar', label: 'Primeros pasos' },
      { href: '/docs/autenticacion', label: 'Autenticación' },
    ],
  },
  {
    title: 'API',
    items: [
      { href: '/docs/health', label: 'Health' },
      { href: '/docs/did', label: 'DID Document' },
      { href: '/docs/metadata', label: 'Metadata' },
      { href: '/docs/branding', label: 'Branding' },
      { href: '/docs/emitir', label: 'Emitir' },
      { href: '/docs/verificar', label: 'Verificar' },
      { href: '/docs/errores', label: 'Errores' },
    ],
  },
]

/** Orden lineal para “Anterior / Siguiente”. */
export const DOCS_FLAT: DocsNavItem[] = DOCS_NAV.flatMap((s) => s.items)

export function docsNeighbors(pathname: string): {
  prev?: DocsNavItem
  next?: DocsNavItem
} {
  const i = DOCS_FLAT.findIndex((item) => item.href === pathname)
  if (i < 0) return {}
  return {
    prev: i > 0 ? DOCS_FLAT[i - 1] : undefined,
    next: i < DOCS_FLAT.length - 1 ? DOCS_FLAT[i + 1] : undefined,
  }
}
