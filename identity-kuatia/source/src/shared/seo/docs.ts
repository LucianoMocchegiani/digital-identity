import type { Metadata } from 'next'
import { buildPageMetadata } from './site'

/** Títulos y descripciones SEO de cada página de `/docs/*`. */
export const DOCS_PAGE_META = {
  introduccion: {
    title: 'Introducción',
    path: '/docs/introduccion',
    description:
      'Qué es Kuatia: infraestructura para emitir y verificar credenciales verificables con OpenID4VC.',
  },
  glosario: {
    title: 'Glosario',
    path: '/docs/glosario',
    description:
      'Glosario SSI: OpenID4VC, issuer, holder, verifier, wallet, SD-JWT, DID, API key y términos de la API Kuatia.',
  },
  'como-funciona': {
    title: 'Cómo funciona',
    path: '/docs/como-funciona',
    description:
      'Roles issuer, holder y verifier; flujos OID4VCI / OID4VP y divulgación selectiva con SD-JWT.',
  },
  issuer: {
    title: 'Issuer',
    path: '/docs/issuer',
    description:
      'Producto issuer Kuatia: emisión OID4VCI, varios emisores por cuenta y qué records persiste.',
  },
  verifier: {
    title: 'Verifier',
    path: '/docs/verifier',
    description:
      'Producto verifier Kuatia: verificación OID4VP, varios verificadores por cuenta y qué records persiste.',
  },
  records: {
    title: 'Records',
    path: '/docs/records',
    description:
      'GET de records Credo del issuer/verifier: tipos, listado paginado y lectura por id.',
  },
  recomendaciones: {
    title: 'Recomendaciones',
    path: '/docs/recomendaciones',
    description:
      'Mínimo de datos, divulgación selectiva, datos sensibles y operación segura de la API Kuatia.',
  },
  seguridad: {
    title: 'Seguridad y confianza',
    path: '/docs/seguridad',
    description:
      'API keys, multi-tenant, rate limits, qué datos guarda Kuatia y estándares OpenID4VC / SD-JWT.',
  },
  empezar: {
    title: 'Primera credencial',
    path: '/docs/empezar',
    description:
      'Quickstart: emití y verificá desde la consola Kuatia, o integrá la misma API con curl.',
  },
  wallet: {
    title: 'Wallet',
    path: '/docs/wallet',
    description:
      'Wallet Kuatia para titulares, o wallet en tu app con OpenID4VC — integración propia o con el equipo Kuatia.',
  },
  autenticacion: {
    title: 'Autenticación',
    path: '/docs/autenticacion',
    description:
      'Autenticación con X-API-Key (iss_live_ / ver_live_). Rutas admin vs endpoints públicos.',
  },
  versionado: {
    title: 'Versionado',
    path: '/docs/versionado',
    description:
      'Política de versionado de la API Kuatia: prefijo /v1, breaking changes, deprecación y docs.',
  },
  changelog: {
    title: 'Changelog',
    path: '/docs/changelog',
    description:
      'Changelog público de Kuatia: cambios de API v1, documentación y producto.',
  },
  health: {
    title: 'Health',
    path: '/docs/health',
    description: 'Endpoints públicos /v1/health y /v1/health/ready para liveness y readiness.',
  },
  did: {
    title: 'DID Document',
    path: '/docs/did',
    description: 'Documento DID (did:web) público del producto issuer o verifier.',
  },
  metadata: {
    title: 'Metadata',
    path: '/docs/metadata',
    description:
      'Well-known OpenID4VC del issuer: credential configurations, display y cómo leer vct / ids.',
  },
  branding: {
    title: 'Branding',
    path: '/docs/branding',
    description:
      'Personalizá logo, colores y nombre de la card. Qué podés cambiar y qué deja fijo Kuatia.',
  },
  emitir: {
    title: 'Emitir',
    path: '/docs/emitir',
    description:
      'POST offer OID4VCI: creá ofertas de credencial, claims, disclosureFrame y offerUri / QR.',
  },
  verificar: {
    title: 'Verificar',
    path: '/docs/verificar',
    description:
      'POST request OID4VP y consulta de sesión: dcqlQuery, presentationDefinition y resultado.',
  },
  errores: {
    title: 'Errores',
    path: '/docs/errores',
    description:
      'Códigos HTTP habituales al integrar issuer y verifier: 401, 402, 429, 503 y más.',
  },
} as const

export type DocsPageKey = keyof typeof DOCS_PAGE_META

/** Metadata SEO para una página de documentación. */
export function docsPageMeta(key: DocsPageKey): Metadata {
  const page = DOCS_PAGE_META[key]
  return buildPageMetadata({
    ...page,
    ogTitle: `${page.title} — Docs Kuatia`,
  })
}
