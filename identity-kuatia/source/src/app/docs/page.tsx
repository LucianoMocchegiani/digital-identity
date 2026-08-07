import { redirect } from 'next/navigation'

/** `/docs` → primera página de la guía. */
export default function DocsIndexPage() {
  redirect('/docs/introduccion')
}
