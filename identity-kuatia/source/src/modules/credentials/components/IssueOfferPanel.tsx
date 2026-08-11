'use client'

/**
 * Formulario Emitir: POST offer → QR.
 */
import { Alert, Button, Field, Input, Panel } from '@/design-system'
import { ApiError } from '@/shared/api/client'
import { createOffer } from '@/shared/api/protocol'
import type { Product } from '@/shared/types/billing'
import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { ProductApiKeyFields } from './ProductApiKeyFields'
import { UriQrPanel } from './UriQrPanel'

const DEFAULT_CLAIMS = `{
  "name": "Ana Pérez",
  "email": "ana@ejemplo.com",
  "role": "member",
  "organization": "Club Norte",
  "validFrom": "2026-08-01"
}`

const DEFAULT_DISCLOSURE = `{
  "_sd": ["email", "role", "organization", "validFrom"]
}`

const textareaClass =
  'min-h-[140px] w-full rounded-xl border border-[var(--kuatia-border)] bg-[var(--kuatia-panel)] px-4 py-3 font-mono text-sm text-[var(--kuatia-text)] placeholder:text-[var(--kuatia-muted)] focus:border-[var(--kuatia-accent)]/60 focus:outline-none focus:ring-2 focus:ring-[var(--kuatia-accent)]/25'

function parseJsonObject(raw: string, label: string): Record<string, unknown> | undefined {
  const trimmed = raw.trim()
  if (!trimmed) return undefined
  let parsed: unknown
  try {
    parsed = JSON.parse(trimmed)
  } catch {
    throw new Error(`${label}: JSON inválido`)
  }
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error(`${label}: se espera un objeto JSON`)
  }
  return parsed as Record<string, unknown>
}

export function IssueOfferPanel({
  products,
  initialProductId = '',
}: {
  products: Product[]
  initialProductId?: string
}) {
  const issuers = useMemo(
    () => products.filter((p) => (p.service ?? p.resource?.service) === 'issuer'),
    [products],
  )

  const [productId, setProductId] = useState(initialProductId)
  const [apiKey, setApiKey] = useState('')

  useEffect(() => {
    if (initialProductId) setProductId(initialProductId)
  }, [initialProductId])
  const [configId, setConfigId] = useState('membership_card')
  const [vct, setVct] = useState('MembershipCredential')
  const [claimsJson, setClaimsJson] = useState(DEFAULT_CLAIMS)
  const [disclosureJson, setDisclosureJson] = useState(DEFAULT_DISCLOSURE)
  const [showAdvanced, setShowAdvanced] = useState(false)
  const [pending, setPending] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<{ offerUri: string; issuanceSessionId: string } | null>(
    null,
  )

  const selected = issuers.find((p) => p.id === productId)
  const walletId = selected?.walletId ?? selected?.resource?.walletId ?? null

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setResult(null)

    if (!walletId) {
      setError('Seleccioná un producto issuer con walletId.')
      return
    }
    if (!apiKey.trim()) {
      setError('Pegá la API key del issuer.')
      return
    }

    setPending(true)
    try {
      const claims = parseJsonObject(claimsJson, 'Claims')
      const disclosureFrame = showAdvanced
        ? parseJsonObject(disclosureJson, 'disclosureFrame')
        : parseJsonObject(DEFAULT_DISCLOSURE, 'disclosureFrame')

      const res = await createOffer(walletId, apiKey.trim(), {
        credentialConfigurationId: configId.trim(),
        vct: vct.trim() || undefined,
        claims,
        disclosureFrame,
      })
      setResult(res)
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        setError(
          'API key inválida. Si acabás de rotarla, usá la key nueva (o “Usar en Credenciales”) y borrá la anterior del campo.',
        )
      } else {
        setError(
          err instanceof ApiError || err instanceof Error
            ? err.message
            : 'No se pudo crear la oferta',
        )
      }
    } finally {
      setPending(false)
    }
  }

  return (
    <Panel className="max-w-3xl space-y-5">
      <div>
        <h2 className="font-display text-xl font-semibold">Emitir (OID4VCI)</h2>
        <p className="mt-1 text-base text-[var(--kuatia-muted)]">
          Generá una oferta pre-autorizada y mostrala como QR para la wallet.
        </p>
      </div>

      <form className="space-y-4" onSubmit={(e) => void onSubmit(e)}>
        {error ? <Alert>{error}</Alert> : null}

        <ProductApiKeyFields
          products={issuers}
          productId={productId}
          onProductIdChange={setProductId}
          apiKey={apiKey}
          onApiKeyChange={setApiKey}
          emptyHint="No hay productos issuer."
        />

        <Field label="credentialConfigurationId" htmlFor="config-id">
          <Input
            id="config-id"
            required
            value={configId}
            onChange={(e) => setConfigId(e.target.value)}
            placeholder="membership_card"
          />
        </Field>

        <Field label="vct" htmlFor="vct" hint="Tipo de credencial (SD-JWT).">
          <Input id="vct" value={vct} onChange={(e) => setVct(e.target.value)} />
        </Field>

        <Field label="Claims (JSON)" htmlFor="claims">
          <textarea
            id="claims"
            className={textareaClass}
            value={claimsJson}
            onChange={(e) => setClaimsJson(e.target.value)}
            spellCheck={false}
          />
        </Field>

        <button
          type="button"
          className="text-sm text-[var(--kuatia-accent)] hover:underline"
          onClick={() => setShowAdvanced((v) => !v)}
        >
          {showAdvanced ? 'Ocultar disclosureFrame' : 'Editar disclosureFrame'}
        </button>

        {showAdvanced ? (
          <Field label="disclosureFrame (JSON)" htmlFor="disclosure">
            <textarea
              id="disclosure"
              className={textareaClass}
              value={disclosureJson}
              onChange={(e) => setDisclosureJson(e.target.value)}
              spellCheck={false}
            />
          </Field>
        ) : null}

        <div className="flex justify-end pt-2">
          <Button type="submit" size="lg" disabled={pending || issuers.length === 0}>
            {pending ? 'Creando oferta…' : 'Crear oferta'}
          </Button>
        </div>
      </form>

      {result ? (
        <UriQrPanel
          label="offerUri"
          uri={result.offerUri}
          sessionHint={result.issuanceSessionId}
        />
      ) : null}
    </Panel>
  )
}
