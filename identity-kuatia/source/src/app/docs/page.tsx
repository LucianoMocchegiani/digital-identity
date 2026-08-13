import { redirect } from 'next/navigation'

/** `/docs` → introducción (punto de entrada). */
export default function DocsIndexPage() {
  redirect('/docs/introduccion')
}
