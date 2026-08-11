import {
  DocsH2,
  DocsLead,
  DocsP,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import {
  CHANGELOG_ENTRIES,
  CHANGELOG_KIND_LABEL,
  type ChangelogKind,
} from '@/modules/docs/changelog'
import { docsPageMeta } from '@/shared/seo/docs'
import Link from 'next/link'

export const metadata = docsPageMeta('changelog')

const kindClass: Record<ChangelogKind, string> = {
  added: 'text-emerald-400',
  changed: 'text-sky-400',
  deprecated: 'text-amber-400',
  removed: 'text-rose-400',
}

export default function DocsChangelogPage() {
  return (
    <>
      <DocsTitle>Changelog</DocsTitle>
      <DocsLead>
        Cambios relevantes para integradores: API, documentación y producto. Política de versiones
        en{' '}
        <Link href="/docs/versionado" className="text-[var(--kuatia-accent)] hover:underline">
          Versionado
        </Link>
        .
      </DocsLead>

      <DocsP>
        Fuente en el monorepo: <code className="text-sm">CHANGELOG.md</code> (raíz del repo).
      </DocsP>

      {CHANGELOG_ENTRIES.map((entry) => (
        <section key={entry.id} className="mt-10">
          <DocsH2 id={entry.id}>
            {entry.id} — {entry.title}
          </DocsH2>
          {entry.summary ? <DocsP>{entry.summary}</DocsP> : null}
          {entry.sections.map((section) => (
            <div key={section.heading} className="mt-6">
              <h3 className="font-display text-lg font-semibold text-[var(--kuatia-text)]">
                {section.heading}
              </h3>
              <ul className="mt-3 space-y-2 text-base leading-relaxed text-[var(--kuatia-muted)]">
                {section.items.map((item) => (
                  <li key={item.text} className="flex gap-2">
                    <span
                      className={`shrink-0 font-mono text-xs font-semibold uppercase tracking-wide ${kindClass[item.kind]}`}
                    >
                      {CHANGELOG_KIND_LABEL[item.kind]}
                    </span>
                    <span>{item.text}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </section>
      ))}
    </>
  )
}
