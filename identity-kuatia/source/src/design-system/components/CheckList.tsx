import type { ReactNode } from 'react'
import { IconCheck } from '../icons'

/** Lista con checks teal (casos de uso, planes). */
export function CheckList({ items }: { items: ReactNode[] }) {
  return (
    <ul className="mt-4 space-y-2.5">
      {items.map((item, i) => (
        <li key={i} className="flex items-start gap-2.5 text-base text-[var(--kuatia-muted)]">
          <span className="mt-0.5 grid h-5 w-5 shrink-0 place-items-center rounded-full bg-[var(--kuatia-accent)] text-[var(--kuatia-ink)]">
            <IconCheck size={12} />
          </span>
          <span>{item}</span>
        </li>
      ))}
    </ul>
  )
}
