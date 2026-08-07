/**
 * Ruta legacy `/app/productos/nuevo` — redirige al listado (el alta es modal).
 */
import { redirect } from 'next/navigation'

export default function NuevoProductoPage() {
  redirect('/app/productos')
}
