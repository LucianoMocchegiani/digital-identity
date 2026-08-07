'use client'

import { cn } from '@/shared/lib/cn'
import { useState, type InputHTMLAttributes } from 'react'
import { IconEye, IconEyeOff } from '../icons'

/** Input de password con toggle de visibilidad (login/register/cuenta). */
export function PasswordInput({
  className,
  ...rest
}: Omit<InputHTMLAttributes<HTMLInputElement>, 'type'>) {
  const [visible, setVisible] = useState(false)

  return (
    <div className="relative">
      <input
        type={visible ? 'text' : 'password'}
        className={cn(
          'h-12 w-full rounded-xl border border-white/10 bg-[var(--kuatia-panel)] px-4 pr-12 text-base text-[var(--kuatia-text)]',
          'placeholder:text-[var(--kuatia-muted)]',
          'focus:border-[var(--kuatia-accent)]/60 focus:outline-none focus:ring-2 focus:ring-[var(--kuatia-accent)]/25',
          'disabled:opacity-50',
          className,
        )}
        {...rest}
      />
      <button
        type="button"
        className="absolute inset-y-0 right-0 grid w-12 place-items-center text-[var(--kuatia-accent)]"
        onClick={() => setVisible((v) => !v)}
        aria-label={visible ? 'Ocultar contraseña' : 'Mostrar contraseña'}
      >
        {visible ? <IconEyeOff size={18} /> : <IconEye size={18} />}
      </button>
    </div>
  )
}
