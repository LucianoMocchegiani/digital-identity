'use client'

import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'
import { IconClose } from '../icons'
import { Button } from './Button'

/**
 * Modal reutilizable (nuevo producto, confirmaciones).
 */
export function Modal({
  open,
  onClose,
  title,
  description,
  children,
  className,
}: {
  open: boolean
  onClose: () => void
  title: string
  description?: string
  children: ReactNode
  className?: string
}) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center p-0 sm:items-center sm:p-6">
      <button
        type="button"
        aria-label="Cerrar"
        className="absolute inset-0 bg-black/70 backdrop-blur-sm"
        onClick={onClose}
      />
      <div
        role="dialog"
        aria-modal
        className={cn(
          'relative z-10 max-h-[92vh] w-full overflow-y-auto rounded-t-2xl border border-[var(--kuatia-accent)]/35 bg-[var(--kuatia-panel)] shadow-2xl shadow-[var(--kuatia-accent)]/10 sm:max-w-xl sm:rounded-2xl',
          className,
        )}
      >
        <div className="flex items-start justify-between gap-4 border-b border-white/10 px-5 py-4 sm:px-6">
          <div>
            <h2 className="font-display text-2xl font-semibold">{title}</h2>
            {description ? <p className="mt-1 text-base text-[var(--kuatia-muted)]">{description}</p> : null}
          </div>
          <Button variant="ghost" size="sm" aria-label="Cerrar" onClick={onClose} className="!px-2">
            <IconClose size={18} />
          </Button>
        </div>
        <div className="px-5 py-5 sm:px-6">{children}</div>
      </div>
    </div>
  )
}
