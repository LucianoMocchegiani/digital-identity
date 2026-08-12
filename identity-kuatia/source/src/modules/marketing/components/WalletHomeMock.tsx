import { CredentialCard } from '@/design-system'
import type { ReactNode } from 'react'

/** Mock del home de la wallet: header + categorías + nav (tema claro/oscuro). */
export function WalletHomeMock() {
  return (
    <div className="flex min-h-[520px] flex-col bg-[var(--kuatia-bg)] text-[var(--kuatia-text)]">
      <div className="flex items-center justify-between px-3.5 pb-2 pt-3">
        <h2 className="font-display text-base font-semibold tracking-tight text-[var(--kuatia-text)]">
          Credenciales
        </h2>
        <div className="flex items-center gap-2">
          <span
            aria-hidden
            className="grid h-7 w-7 place-items-center rounded-full border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] text-[var(--kuatia-muted)]"
          >
            <SearchIcon />
          </span>
          <span className="rounded-full border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-2.5 py-1 text-[10px] font-medium text-[var(--kuatia-accent)]">
            + Crear categoría
          </span>
        </div>
      </div>

      <div className="flex-1 space-y-2.5 overflow-hidden px-2.5 pb-2">
        <WalletCategory label="Membresias">
          <CredentialCard preset="membership" compact />
        </WalletCategory>
        <WalletCategory label="Recitales">
          <CredentialCard preset="ticket" compact />
        </WalletCategory>
        <WalletCategory label="Trabajo">
          <CredentialCard preset="operator" compact />
        </WalletCategory>
      </div>

      <WalletBottomNav />
    </div>
  )
}

function WalletCategory({
  label,
  children,
}: {
  label: string
  children: ReactNode
}) {
  return (
    <div className="overflow-hidden rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] shadow-sm shadow-[var(--kuatia-ink)]/5">
      <div className="flex items-center justify-between px-3 pt-2">
        <p className="text-xs font-semibold text-[var(--kuatia-text)]">{label}</p>
        <div className="flex items-center gap-2 text-[var(--kuatia-muted)]">
          <PencilIcon />
          <EyeIcon />
        </div>
      </div>
      <div className="p-1.5 pt-1">{children}</div>
    </div>
  )
}

function WalletBottomNav() {
  return (
    <div className="mt-auto border-t border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-2 py-2.5">
      <div className="flex items-center justify-around">
        <span className="grid h-10 w-10 place-items-center rounded-full bg-[var(--kuatia-accent)] text-[var(--kuatia-ink)] shadow-md shadow-[var(--kuatia-accent)]/30">
          <HomeIcon />
        </span>
        <span className="text-[var(--kuatia-muted)]">
          <QrIcon />
        </span>
        <span className="text-[var(--kuatia-muted)]">
          <MenuIcon />
        </span>
      </div>
    </div>
  )
}

function SearchIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden>
      <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2" />
      <path d="M20 20l-3.5-3.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
    </svg>
  )
}

function PencilIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M4 20h4.5L19 9.5 14.5 5 4 15.5V20z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function EyeIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"
        stroke="currentColor"
        strokeWidth="1.8"
      />
      <circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="1.8" />
    </svg>
  )
}

function HomeIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M12 3l9 8h-3v9h-5v-6H11v6H6v-9H3l9-8z" />
    </svg>
  )
}

function QrIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M4 4h6v6H4V4zm2 2v2h2V6H6zm8-2h6v6h-6V4zm2 2v2h2V6h-2zM4 14h6v6H4v-6zm2 2v2h2v-2H6zm10 0h2v2h-2v-2zm-2-2h2v2h-2v-2zm4 0h2v2h-2v-2zm-2 4h2v2h-2v-2zm4 0h2v4h-4v-2h2v-2z"
        fill="currentColor"
      />
    </svg>
  )
}

function MenuIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M4 7h16M4 12h16M4 17h16"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  )
}
