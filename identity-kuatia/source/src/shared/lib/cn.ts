/**
 * Une clases CSS omitiendo valores falsy (`false`, `null`, `undefined`).
 * Utilidad liviana sin dependencias (alternativa mínima a clsx).
 */
export function cn(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ')
}
