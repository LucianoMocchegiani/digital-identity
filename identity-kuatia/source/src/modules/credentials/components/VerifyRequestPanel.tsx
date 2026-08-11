'use client'

/**
 * Formulario Verificar: POST request → QR → poll session.
 */
import { Alert, Badge, Button, Field, Panel } from '@/design-system'
import { ApiError } from '@/shared/api/client'
import {
  createRequest,
  getVerificationSession,
  isSuccessfulVerificationState,
  isTerminalVerificationState,
  type VerificationSession,
} from '@/shared/api/protocol'
import type { Product } from '@/shared/types/billing'
import { useEffect, useMemo, useRef, useState, type FormEvent } from 'react'
import { ProductApiKeyFields } from './ProductApiKeyFields'
import { UriQrPanel } from './UriQrPanel'

const DEFAULT_DCQL = `{
  "credentials": [{
    "id": "membership",
    "format": "dc+sd-jwt",
    "meta": { "vct_values": ["MembershipCredential"] },
    "claims": [
      { "path": ["name"] },
      { "path": ["email"] },
      { "path": ["role"] }
    ]
  }]
}`

const textareaClass =
  'min-h-[180px] w-full rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-4 py-3 font-mono text-sm text-[var(--kuatia-text)] placeholder:text-[var(--kuatia-muted)] focus:border-[var(--kuatia-accent)]/60 focus:outline-none focus:ring-2 focus:ring-[var(--kuatia-accent)]/25'

const POLL_MS = 2000

export function VerifyRequestPanel({
  products,
  initialProductId = '',
}: {
  products: Product[]
  initialProductId?: string
}) {
  const verifiers = useMemo(
    () => products.filter((p) => (p.service ?? p.resource?.service) === 'verifier'),
    [products],
  )

  const [productId, setProductId] = useState(initialProductId)
  const [apiKey, setApiKey] = useState('')

  useEffect(() => {
    if (initialProductId) setProductId(initialProductId)
  }, [initialProductId])
  const [dcqlJson, setDcqlJson] = useState(DEFAULT_DCQL)
  const [pending, setPending] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [requestUri, setRequestUri] = useState<string | null>(null)
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [session, setSession] = useState<VerificationSession | null>(null)
  const [polling, setPolling] = useState(false)

  const pollRef = useRef<number | null>(null)
  const selected = verifiers.find((p) => p.id === productId)
  const walletId = selected?.walletId ?? selected?.resource?.walletId ?? null

  function stopPoll() {
    if (pollRef.current != null) {
      window.clearInterval(pollRef.current)
      pollRef.current = null
    }
    setPolling(false)
  }

  useEffect(() => () => stopPoll(), [])

  async function pollOnce(wid: string, sid: string, key: string) {
    try {
      const next = await getVerificationSession(wid, sid, key)
      setSession(next)
      const state = String(next.state ?? next.status ?? '')
      if (isTerminalVerificationState(state)) stopPoll()
    } catch (err) {
      setError(
        err instanceof ApiError || err instanceof Error
          ? err.message
          : 'Error al consultar la sesión',
      )
      stopPoll()
    }
  }

  function startPoll(wid: string, sid: string, key: string) {
    stopPoll()
    setPolling(true)
    void pollOnce(wid, sid, key)
    pollRef.current = window.setInterval(() => {
      void pollOnce(wid, sid, key)
    }, POLL_MS)
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setRequestUri(null)
    setSessionId(null)
    setSession(null)
    stopPoll()

    if (!walletId) {
      setError('Seleccioná un producto verifier con walletId.')
      return
    }
    if (!apiKey.trim()) {
      setError('Pegá la API key del verifier.')
      return
    }

    let dcqlQuery: unknown
    try {
      dcqlQuery = JSON.parse(dcqlJson)
    } catch {
      setError('dcqlQuery: JSON inválido')
      return
    }

    setPending(true)
    try {
      const res = await createRequest(walletId, apiKey.trim(), {
        dcqlQuery,
        responseMode: 'direct_post',
        requestSignerMethod: 'did',
      })
      setRequestUri(res.requestUri)
      setSessionId(res.verificationSessionId)
      startPoll(walletId, res.verificationSessionId, apiKey.trim())
    } catch (err) {
      setError(
        err instanceof ApiError || err instanceof Error
          ? err.message
          : 'No se pudo crear la solicitud',
      )
    } finally {
      setPending(false)
    }
  }

  const state = String(session?.state ?? session?.status ?? '')
  const success = isSuccessfulVerificationState(state)
  const terminal = isTerminalVerificationState(state)

  return (
    <Panel className="max-w-3xl space-y-5">
      <div>
        <h2 className="font-display text-xl font-semibold">Verificar (OID4VP)</h2>
        <p className="mt-1 text-base text-[var(--kuatia-muted)]">
          Pedí una presentación, mostrá el QR y esperá el resultado de la sesión.
        </p>
      </div>

      <form className="space-y-4" onSubmit={(e) => void onSubmit(e)}>
        {error ? <Alert>{error}</Alert> : null}

        <ProductApiKeyFields
          products={verifiers}
          productId={productId}
          onProductIdChange={setProductId}
          apiKey={apiKey}
          onApiKeyChange={setApiKey}
          emptyHint="No hay productos verifier."
        />

        <Field label="dcqlQuery (JSON)" htmlFor="dcql">
          <textarea
            id="dcql"
            className={textareaClass}
            value={dcqlJson}
            onChange={(e) => setDcqlJson(e.target.value)}
            spellCheck={false}
          />
        </Field>

        <div className="flex flex-wrap justify-end gap-2 pt-2">
          {polling ? (
            <Button type="button" variant="ghost" onClick={stopPoll}>
              Detener poll
            </Button>
          ) : null}
          <Button type="submit" size="lg" disabled={pending || verifiers.length === 0}>
            {pending ? 'Creando request…' : 'Crear request'}
          </Button>
        </div>
      </form>

      {requestUri ? (
        <UriQrPanel label="requestUri" uri={requestUri} sessionHint={sessionId ?? undefined} />
      ) : null}

      {sessionId ? (
        <div className="space-y-3 rounded-2xl border border-[var(--kuatia-border)] p-4">
          <div className="flex flex-wrap items-center gap-2">
            <p className="text-sm font-medium text-[var(--kuatia-muted)]">Sesión</p>
            {polling ? <Badge tone="accent">Polling…</Badge> : null}
            {state ? (
              <Badge tone={success ? 'success' : terminal ? 'neutral' : 'accent'}>{state}</Badge>
            ) : (
              <Badge tone="neutral">esperando…</Badge>
            )}
          </div>
          {session?.authorizationResponsePayload != null ? (
            <pre className="max-h-64 overflow-auto rounded-xl bg-[var(--kuatia-code-bg)] p-3 text-xs text-[var(--kuatia-text)]">
              {JSON.stringify(session.authorizationResponsePayload, null, 2)}
            </pre>
          ) : session ? (
            <pre className="max-h-64 overflow-auto rounded-xl bg-[var(--kuatia-code-bg)] p-3 text-xs text-[var(--kuatia-muted)]">
              {JSON.stringify(session, null, 2)}
            </pre>
          ) : null}
        </div>
      ) : null}
    </Panel>
  )
}
