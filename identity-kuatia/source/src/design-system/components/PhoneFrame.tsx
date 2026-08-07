import { cn } from '@/shared/lib/cn'
import type { ReactNode } from 'react'

/** Marco de teléfono reutilizable para mockups de wallet en la landing. */
export function PhoneFrame({
  children,
  className,
  label = 'Wallet',
}: {
  children: ReactNode
  className?: string
  label?: string
}) {
  return (
    <div className={cn('relative mx-auto w-full max-w-[280px]', className)}>
      <div
        aria-hidden
        className="absolute -inset-8 rounded-full bg-[var(--kuatia-accent)]/20 blur-3xl"
      />
      <div className="relative rounded-[2rem] border border-white/15 bg-gradient-to-b from-[#0d1a22] to-[#050a10] p-2.5 shadow-2xl shadow-black/50">
        <div className="mx-auto mb-2 h-1.5 w-16 rounded-full bg-white/15" />
        <div className="rounded-[1.4rem] border border-white/10 bg-[#071018] p-3.5">
          <p className="mb-3 text-xs font-medium uppercase tracking-wider text-[var(--kuatia-muted)]">
            {label}
          </p>
          {children}
        </div>
      </div>
    </div>
  )
}
