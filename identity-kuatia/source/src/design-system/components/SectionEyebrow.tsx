/** Label pequeño teal sobre títulos de sección (landing). */
export function SectionEyebrow({ children }: { children: string }) {
  return (
    <p className="mb-3 text-sm font-semibold uppercase tracking-[0.14em] text-[var(--kuatia-accent)]">
      {children}
    </p>
  )
}
