import type { ReactNode } from 'react'
import { Label } from './Label'

/**
 * Agrupa label, control hijo y hint opcional en un campo de formulario.
 * @param htmlFor Id del control asociado al label.
 * @param hint Texto de ayuda bajo el control.
 */
export function Field({
  label,
  htmlFor,
  hint,
  children,
}: {
  label: string
  htmlFor?: string
  hint?: string
  children: ReactNode
}) {
  return (
    <div className="w-full">
      <Label htmlFor={htmlFor}>{label}</Label>
      {children}
      {hint ? <p className="mt-1.5 text-sm text-[var(--kuatia-muted)]">{hint}</p> : null}
    </div>
  )
}
