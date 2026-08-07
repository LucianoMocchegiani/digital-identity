'use client'

import { IconMoon, IconSun } from '@/design-system/icons'
import { useTheme } from '@/shared/theme/ThemeProvider'
import { useEffect, useState } from 'react'

/** Alterna tema claro / oscuro (persistido en localStorage). */
export function ThemeToggle({ className }: { className?: string }) {
  const { theme, toggleTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => setMounted(true), [])

  const isDark = theme === 'dark'
  const cls =
    className ??
    'grid h-10 w-10 place-items-center rounded-full text-[var(--kuatia-muted)] transition hover:bg-[var(--kuatia-hover)] hover:text-[var(--kuatia-text)]'

  if (!mounted) {
    return <span className={cls} aria-hidden />
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      className={cls}
      title={isDark ? 'Tema claro' : 'Tema oscuro'}
      aria-label={isDark ? 'Activar tema claro' : 'Activar tema oscuro'}
    >
      {isDark ? <IconSun size={20} /> : <IconMoon size={20} />}
    </button>
  )
}
