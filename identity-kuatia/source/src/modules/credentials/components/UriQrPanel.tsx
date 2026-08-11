'use client'

/**
 * Muestra URI como QR + texto copiable (offer / request).
 */
import { Button } from '@/design-system'
import { useState } from 'react'
import { QRCodeSVG } from 'qrcode.react'

export function UriQrPanel({
  label,
  uri,
  sessionHint,
}: {
  label: string
  uri: string
  sessionHint?: string
}) {
  const [copied, setCopied] = useState(false)

  async function onCopy() {
    try {
      await navigator.clipboard.writeText(uri)
      setCopied(true)
      window.setTimeout(() => setCopied(false), 2000)
    } catch {
      /* ignore */
    }
  }

  return (
    <div className="space-y-4 rounded-2xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] p-4 sm:p-5">
      <div className="flex flex-col items-center gap-4 sm:flex-row sm:items-start">
        <div className="rounded-2xl bg-white p-3 shadow-sm">
          <QRCodeSVG value={uri} size={180} level="M" marginSize={1} />
        </div>
        <div className="min-w-0 flex-1 space-y-3">
          <p className="text-sm font-medium text-[var(--kuatia-muted)]">{label}</p>
          <code className="block break-all rounded-xl bg-[var(--kuatia-code-bg)] p-3 text-sm text-[var(--kuatia-accent)]">
            {uri}
          </code>
          {sessionHint ? (
            <p className="text-sm text-[var(--kuatia-muted)]">
              Sesión: <span className="font-mono text-[var(--kuatia-text)]">{sessionHint}</span>
            </p>
          ) : null}
          <Button type="button" variant="secondary" size="sm" onClick={() => void onCopy()}>
            {copied ? 'Copiado' : 'Copiar URI'}
          </Button>
        </div>
      </div>
      <p className="text-sm text-[var(--kuatia-muted)]">
        Escaneá el QR con la wallet o abrí el deep link en el dispositivo.
      </p>
    </div>
  )
}
