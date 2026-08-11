/**
 * Changelog público (sitio `/docs/changelog`).
 * Mantener alineado con `CHANGELOG.md` en la raíz del monorepo.
 */

export type ChangelogKind = 'added' | 'changed' | 'deprecated' | 'removed'

export type ChangelogItem = {
  kind: ChangelogKind
  text: string
}

export type ChangelogEntry = {
  /** Etiqueta visible, p. ej. "2026-08". */
  id: string
  title: string
  summary?: string
  sections: { heading: string; items: ChangelogItem[] }[]
}

export const CHANGELOG_ENTRIES: ChangelogEntry[] = [
  {
    id: '2026-08',
    title: 'API v1 estable · docs · planes',
    summary: 'Línea base pública: `/v1`, documentación del sitio y catálogo de planes.',
    sections: [
      {
        heading: 'API',
        items: [
          {
            kind: 'added',
            text: 'Prefijo público /v1 en issuer, verifier y billing (sin /v2).',
          },
          {
            kind: 'added',
            text: 'Endpoints documentados: health, DID, metadata, branding, offer, request/session y errores HTTP.',
          },
          {
            kind: 'added',
            text: 'Rate limit por IP en rutas públicas (health/discovery/OID4VC); el plan sigue mandando con API key.',
          },
        ],
      },
      {
        heading: 'Documentación',
        items: [
          {
            kind: 'added',
            text: 'Sitio /docs: introducción, glosario, flujos, recomendaciones y referencia API.',
          },
          {
            kind: 'added',
            text: 'Política de versionado y changelog público.',
          },
        ],
      },
      {
        heading: 'Producto',
        items: [
          {
            kind: 'added',
            text: 'Planes Free, Pro, Pro Double (×2 Pro) y Business a medida.',
          },
          {
            kind: 'added',
            text: 'Login consola con OAuth Google/GitHub (además de email/contraseña).',
          },
          {
            kind: 'added',
            text: 'Wallet Flutter con tema Kuatia (charcoal + teal) y modo claro/oscuro.',
          },
          {
            kind: 'added',
            text: 'Tema claro/oscuro, SEO técnico (sitemap, robots, OG) y config de sitio vía env.',
          },
        ],
      },
    ],
  },
]

export const CHANGELOG_KIND_LABEL: Record<ChangelogKind, string> = {
  added: 'Added',
  changed: 'Changed',
  deprecated: 'Deprecated',
  removed: 'Removed',
}
