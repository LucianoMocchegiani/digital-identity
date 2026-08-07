/**
 * Ruta `/app` — redirige al listado de productos (entrada por defecto de la consola).
 */
import { redirect } from 'next/navigation'

export default function AppIndexPage() {
  redirect('/app/productos')
}
