import type { ReactNode } from 'react'

/**
 * Encabezado de página de consola: título, descripción y acción opcional.
 * @param action Slot derecho (ej. botón "Nuevo producto").
 */
export function PageHeader({
  title,
  description,
  action,
}: {
  title: string
  description?: ReactNode
  action?: ReactNode
}) {
  return (
    <div className="mb-6 flex flex-col gap-4 sm:mb-8 sm:flex-row sm:flex-wrap sm:items-start sm:justify-between">
      <div className="min-w-0">
        <h1 className="font-display text-3xl font-semibold tracking-tight sm:text-4xl">{title}</h1>
        {description ? (
          <p className="mt-2 max-w-2xl text-base text-[var(--kuatia-muted)] sm:text-lg">{description}</p>
        ) : null}
      </div>
      {action ? <div className="shrink-0">{action}</div> : null}
    </div>
  )
}
