import type { ReactNode } from 'react'

/** Bloque de código en páginas de docs. */
export function DocsCode({ children }: { children: string }) {
  return (
    <pre className="mt-4 overflow-x-auto rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-code-bg)] p-4 text-[13px] leading-relaxed text-[var(--kuatia-text)]/90 sm:text-sm">
      <code>{children.trim()}</code>
    </pre>
  )
}

/** Párrafo de cuerpo. */
export function DocsP({ children }: { children: ReactNode }) {
  return <p className="mt-4 text-base leading-relaxed text-[var(--kuatia-muted)] sm:text-[17px]">{children}</p>
}

/** Título H1 de página. */
export function DocsTitle({ children }: { children: ReactNode }) {
  return (
    <h1 className="font-display text-3xl font-semibold tracking-tight text-[var(--kuatia-text)] sm:text-4xl">
      {children}
    </h1>
  )
}

/** Subtítulo bajo el H1. */
export function DocsLead({ children }: { children: ReactNode }) {
  return <p className="mt-3 text-lg leading-relaxed text-[var(--kuatia-muted)]">{children}</p>
}

/** H2 dentro de una página. */
export function DocsH2({ id, children }: { id?: string; children: ReactNode }) {
  return (
    <h2
      id={id}
      className="mt-10 scroll-mt-24 border-b border-[var(--kuatia-border)] pb-2 font-display text-xl font-semibold text-[var(--kuatia-text)] sm:text-2xl"
    >
      {children}
    </h2>
  )
}

function MethodBadge({ method }: { method: 'GET' | 'POST' | 'PATCH' }) {
  const color =
    method === 'GET'
      ? 'bg-emerald-500/15 text-emerald-300'
      : method === 'POST'
        ? 'bg-sky-500/15 text-sky-300'
        : 'bg-amber-500/15 text-amber-300'
  return (
    <span className={`inline-block rounded-md px-2 py-0.5 font-mono text-xs font-semibold ${color}`}>
      {method}
    </span>
  )
}

/** Card de endpoint (método + path + auth + cuerpo). */
export function DocsEndpoint({
  method,
  path,
  auth,
  children,
}: {
  method: 'GET' | 'POST' | 'PATCH'
  path: string
  auth: string
  children: ReactNode
}) {
  return (
    <article className="mt-6 rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)]/40 p-5 sm:p-6">
      <div className="flex flex-wrap items-center gap-3">
        <MethodBadge method={method} />
        <code className="break-all text-sm text-[var(--kuatia-text)] sm:text-base">{path}</code>
      </div>
      <p className="mt-2 text-sm text-[var(--kuatia-muted)]">Auth: {auth}</p>
      <div className="mt-3 space-y-2 text-base leading-relaxed text-[var(--kuatia-muted)]">
        {children}
      </div>
    </article>
  )
}

/** Lista con bullets. */
export function DocsUl({ children }: { children: ReactNode }) {
  return <ul className="mt-4 list-disc space-y-2 pl-5 text-base text-[var(--kuatia-muted)] sm:text-[17px]">{children}</ul>
}
