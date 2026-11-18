import { useEffect, useRef, useState, type CSSProperties } from 'react'
import { createHolderKey, getHolderSigningKey, hasHolderKey, listCredentials } from './wallet-storage'
import { parseCurrentPage, type WalletRequest } from './protocol-link'
import { resolveProtocolResource, type ResolvedResource } from './protocol-resource'
import { issuePreAuthorizedCredential } from './oid4vci'
import { verifyPresentationResource } from './oid4vp'
import { findPresentationOptions, inspectStoredCredentials, sendOid4vpPresentation, type PresentationOption, type StoredCredentialSummary } from './oid4vp-presentation'
import { credentialDisplayFromConfiguration } from './credential-display'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

const kuatiaMark = 'https://raw.githubusercontent.com/LucianoMocchegiani/digital-identity/20dd4c60ff4b71a4e65c9bbd419759ad5ddd827f/identity-kuatia/source/public/kuatia-mark.png'

function pendingCredentialSummaries(credentials: Awaited<ReturnType<typeof listCredentials>>): StoredCredentialSummary[] {
  return credentials.map(credential => {
    const display = credentialDisplayFromConfiguration(credential.display)
    return {
      id: credential.id,
      label: credential.label,
      format: 'dc+sd-jwt',
      vct: '',
      claims: [],
      verified: null,
      displayName: display?.name,
      backgroundColor: display?.backgroundColor,
      textColor: display?.textColor,
      backgroundImageUrl: display?.backgroundImageUrl,
      logoUrl: display?.logoUrl,
    }
  })
}

export default function App() {
  const [request, setRequest] = useState<WalletRequest | null>(null)
  const [resource, setResource] = useState<ResolvedResource | null>(null)
  const [verifiedPresentation, setVerifiedPresentation] = useState<VerifiedOid4vpRequest | null>(null)
  const [presentationOptions, setPresentationOptions] = useState<PresentationOption[]>([])
  const [credentialSummaries, setCredentialSummaries] = useState<StoredCredentialSummary[]>([])
  const [selectedOption, setSelectedOption] = useState('')
  const [consent, setConsent] = useState(false)
  const [consentConfirmed, setConsentConfirmed] = useState(false)
  const [presentationSent, setPresentationSent] = useState(false)
  const [issuanceComplete, setIssuanceComplete] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [txCode, setTxCode] = useState('')
  const [hasKey, setHasKey] = useState(false)
  const [credentialCount, setCredentialCount] = useState(0)
  const [busy, setBusy] = useState(false)
  const [progress, setProgress] = useState('')
  const issuanceStarted = useRef(false)
  const initialized = useRef(false)
  const flowDialog = useRef<HTMLDialogElement>(null)

  async function refreshCredentialSummaries(credentials: Awaited<ReturnType<typeof listCredentials>>) {
    setCredentialSummaries(pendingCredentialSummaries(credentials))
    try {
      setCredentialSummaries(await inspectStoredCredentials(credentials))
    } catch (cause) {
      setError(`No se pudieron inspeccionar las credenciales guardadas.${cause instanceof Error ? ` ${cause.message}` : ''}`)
    }
  }

  useEffect(() => {
    const dialog = flowDialog.current
    if (!dialog) return
    if (request && !dialog.open) dialog.showModal()
    else if (!request && dialog.open) dialog.close()
  }, [request])

  useEffect(() => {
    if (initialized.current) return
    initialized.current = true
    try {
      setRequest(parseCurrentPage(window.location.pathname, window.location.search))
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'El enlace no es válido.')
    } finally {
      if (window.location.search) window.history.replaceState({}, '', window.location.pathname)
    }
    void Promise.all([hasHolderKey(), listCredentials()]).then(async ([keyExists, credentials]) => {
      setHasKey(keyExists)
      setCredentialCount(credentials.length)
      await refreshCredentialSummaries(credentials)
    }).catch(cause => setError(`No se pudo leer la clave o las credenciales guardadas.${cause instanceof Error ? ` ${cause.message}` : ''}`))
  }, [])

  async function generateKey() {
    setBusy(true)
    setProgress('Inicializando wallet…')
    setError('')
    try {
      await createHolderKey()
      setHasKey(true)
    } catch {
      setError('El navegador no pudo generar o guardar la clave de esta wallet.')
    } finally {
      setProgress('')
      setBusy(false)
    }
  }

  async function loadResource() {
    if (!request) return
    setBusy(true)
    setProgress('')
    setError('')
    setNotice('')
    setResource(null)
    setVerifiedPresentation(null)
    setPresentationOptions([])
    setSelectedOption('')
    setConsent(false)
    setConsentConfirmed(false)
    setPresentationSent(false)
    try {
      if (!await hasHolderKey()) {
        setProgress('Inicializando wallet…')
        await createHolderKey()
      }
      setHasKey(true)
      setProgress(request.kind === 'issue' ? 'Revisando oferta…' : 'Verificando solicitud…')
      const resolved = await resolveProtocolResource(request)
      if (resolved.kind === 'present' && request.kind === 'present') {
        const verified = await verifyPresentationResource(resolved, request.clientId)
        setVerifiedPresentation(verified)
        const credentials = await listCredentials()
        const { publicJwk } = await getHolderSigningKey()
        setPresentationOptions(await findPresentationOptions(verified, credentials, publicJwk))
      }
      setResource(resolved)
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo cargar o verificar la solicitud.')
    } finally {
      setProgress('')
      setBusy(false)
    }
  }

  async function issueCredential() {
    if (!resource || resource.kind !== 'issue' || issuanceStarted.current || issuanceComplete) return
    issuanceStarted.current = true
    setBusy(true)
    setProgress('Recibiendo credencial…')
    setError('')
    setNotice('')
    try {
      const result = await issuePreAuthorizedCredential(resource, txCode || undefined)
      setIssuanceComplete(true)
      const credentials = await listCredentials()
      setCredentialCount(credentials.length)
      await refreshCredentialSummaries(credentials)
      setNotice(`${result.count} credencial(es) recibida(s) y guardada(s); ${result.verifiedCount} con firma verificada.`)
    } catch (cause) {
      const credentials = await listCredentials().catch(() => [])
      if (credentials.length > credentialCount) setIssuanceComplete(true)
      setCredentialCount(credentials.length)
      await refreshCredentialSummaries(credentials)
      setError(cause instanceof Error ? cause.message : 'No se pudo completar la emisión.')
    } finally {
      issuanceStarted.current = false
      setProgress('')
      setBusy(false)
    }
  }

  const chosenOption = presentationOptions.find(option => `${option.queryId}:${option.credentialId}` === selectedOption)

  async function sendPresentation() {
    if (!verifiedPresentation || !chosenOption || !consentConfirmed || presentationSent) return
    setBusy(true)
    setError('')
    setNotice('')
    try {
      const credential = (await listCredentials()).find(item => item.id === chosenOption.credentialId)
      if (!credential) throw new Error('La credencial seleccionada ya no está disponible.')
      const holderKey = await getHolderSigningKey()
      await sendOid4vpPresentation(verifiedPresentation, chosenOption, credential, holderKey)
      setPresentationSent(true)
      setNotice('Presentación enviada. El verificador aceptó la respuesta.')
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo enviar la presentación.')
    } finally {
      setBusy(false)
    }
  }

  function confirmPresentationConsent() {
    if (!selectedOption || !consent) return
    setConsentConfirmed(true)
    setNotice('Selección confirmada. Todavía no compartiste tus datos.')
  }

  function closeFlow() {
    setRequest(null)
  }

  return (
    <main className="shell">
      <header className="brand-header">
        <img className="brand-mark" src={kuatiaMark} alt="" width="36" height="36" aria-hidden="true" referrerPolicy="no-referrer" />
        <span className="brand-name">Kuatia <strong>Wallet</strong></span>
      </header>

      {!request && <section className="hero">
        <p className="eyebrow">TU IDENTIDAD DIGITAL</p>
        <h1>Tus credenciales,<br />en un solo lugar.</h1>
        <p>Consultá y compartí tus credenciales desde este dispositivo.</p>
      </section>}

      {!request && error && <p className="notice error" role="alert">{error}</p>}

      <dialog
        className="flow-dialog"
        ref={flowDialog}
        aria-labelledby="flow-title"
        onCancel={event => { event.preventDefault(); closeFlow() }}
      >
        {request && <section className="card flow-card" aria-live="polite">
          <button type="button" className="flow-close" onClick={closeFlow}>Ir a mi wallet</button>
          <p className="eyebrow">{request.kind === 'issue' ? 'NUEVA CREDENCIAL' : 'SOLICITUD DE PRESENTACIÓN'}</p>
          <h1 id="flow-title">{request.kind === 'issue' ? 'Recibir credencial' : 'Compartir credencial'}</h1>
          {error && <p className="notice error" role="alert">{error}</p>}
          {notice && <p className="notice" role="status">{notice}</p>}
          {!resource && <>
            <p>{request.kind === 'issue'
              ? 'Revisá la oferta del emisor antes de guardar una credencial.'
              : 'Revisá quién solicita tus datos antes de elegir qué compartir.'}</p>
            <button type="button" onClick={() => void loadResource()} disabled={busy}>
              {busy ? progress || 'Revisando…' : 'Revisar solicitud'}
            </button>
          </>}
          {resource?.kind === 'issue' && <>
            <div className="issuer-info"><span>Emisor</span><strong>{resource.credentialIssuer}</strong></div>
            <p>La oferta puede usarse una sola vez. Revisá el emisor antes de continuar.</p>
            {!resource.hasPreAuthorizedCode && <p className="warning">Este tipo de oferta todavía no se puede completar desde la wallet.</p>}
            {resource.hasPreAuthorizedCode && !resource.tokenEndpoint && <p className="warning">No se pudo confirmar la solicitud del emisor; no es posible continuar.</p>}
            {resource.hasPreAuthorizedCode && resource.tokenEndpoint && resource.txCode && <label className="field">
              {resource.txCode.description || 'Ingresá el código que te proporcionó el emisor'}
              <input type="text" inputMode={resource.txCode.inputMode === 'numeric' ? 'numeric' : 'text'} maxLength={resource.txCode.length} value={txCode} onChange={event => setTxCode(event.target.value)} autoComplete="off" />
            </label>}
            {resource.hasPreAuthorizedCode && resource.tokenEndpoint && <>
              <p className="privacy-note">Al continuar, la credencial se recibirá y guardará cifrada en este dispositivo.</p>
              <button type="button" onClick={() => void issueCredential()} disabled={busy || issuanceComplete || Boolean(resource.txCode && !txCode)}>
                {busy ? progress || 'Recibiendo…' : issuanceComplete ? 'Credencial guardada' : 'Aceptar y guardar'}
              </button>
            </>}
          </>}
          {resource?.kind === 'present' && verifiedPresentation && <>
            <div className="issuer-info"><span>Solicitado por</span><strong>{verifiedPresentation.verifierDid}</strong></div>
            <p className="verified-note" role="status">Solicitud verificada. Todavía no se compartieron datos.</p>
            {!presentationOptions.length && <p>No hay credenciales guardadas que coincidan con lo solicitado.</p>}
            {presentationOptions.length > 0 && <fieldset className="credential-options">
              <legend>Elegí qué credencial compartir</legend>
              {presentationOptions.map(option => {
                const id = `${option.queryId}:${option.credentialId}`
                return <label className="credential-option" key={id}>
                  <input type="radio" name="presentation-credential" value={id} checked={selectedOption === id} disabled={busy || presentationSent} onChange={() => { setSelectedOption(id); setConsent(false); setConsentConfirmed(false); setNotice('') }} />
                  <span><strong>{option.label}</strong></span>
                </label>
              })}
            </fieldset>}
            {chosenOption && <>
              <h2 className="subheading">Datos que se compartirán</h2>
              <dl className="claim-preview">{Object.entries(chosenOption.claims).map(([name, value]) => <div key={name}><dt>{name}</dt><dd>{typeof value === 'string' ? value : JSON.stringify(value)}</dd></div>)}</dl>
              <label className="consent-option"><input type="checkbox" checked={consent} disabled={busy || presentationSent} onChange={event => { setConsent(event.target.checked); setConsentConfirmed(false); setNotice('') }} /> Confirmo que quiero compartir los datos mostrados.</label>
              {!consentConfirmed && <button type="button" onClick={confirmPresentationConsent} disabled={!consent || busy}>Continuar</button>}
              {consentConfirmed && <button type="button" onClick={() => void sendPresentation()} disabled={busy || presentationSent}>
                {busy ? 'Enviando…' : presentationSent ? 'Presentación enviada' : 'Compartir datos'}
              </button>}
              <p className="privacy-note">Solo se compartirán los datos que aparecen arriba, después de tu confirmación.</p>
            </>}
          </>}
        </section>}
      </dialog>

      <section className="card wallet-card">
        <div className="section-heading">
          <div><p className="eyebrow">MI WALLET</p><h2>Mis credenciales</h2></div>
          <span className="status">{credentialCount} {credentialCount === 1 ? 'credencial' : 'credenciales'}</span>
        </div>
        {!request && !hasKey && <div className="setup-panel">
          <h3>Configurá tu wallet</h3>
          <p>Se creará una clave segura en este dispositivo para recibir y presentar credenciales.</p>
          <button type="button" onClick={() => void generateKey()} disabled={busy}>
            {busy ? progress || 'Inicializando wallet…' : 'Inicializar wallet'}
          </button>
        </div>}
        {hasKey && <p className="storage-note">Tu wallet está configurada en este dispositivo.</p>}
        {!credentialSummaries.length && <div className="empty-state">
          <span className="empty-mark" aria-hidden="true">＋</span>
          <p>Todavía no tenés credenciales guardadas.</p>
        </div>}
        {credentialSummaries.length > 0 && <ul className="credential-inventory">
          {credentialSummaries.map(credential => <li
            className={`credential-item${credential.backgroundImageUrl ? ' has-background-image' : ''}`}
            key={credential.id}
            style={{
              '--credential-background': credential.backgroundColor ?? '#0b1520',
              '--credential-foreground': credential.textColor ?? '#f3f7f8',
              '--credential-image': credential.backgroundImageUrl ? `url(${JSON.stringify(credential.backgroundImageUrl)})` : 'none',
            } as CSSProperties}
          >
            {credential.logoUrl
              ? <img className="credential-logo" src={credential.logoUrl} alt="" loading="lazy" referrerPolicy="no-referrer" />
              : <span className="credential-symbol" aria-hidden="true">▤</span>}
            <div className="credential-copy">
              <strong>{credential.displayName || credential.label}</strong>
              <span className={`credential-state${credential.verified === null ? ' pending' : credential.verified ? ' verified' : ' unverified'}`}>
                {credential.verified === null ? 'Verificando firma…' : credential.verified ? 'Firma verificada' : 'No se pudo verificar la firma'}
              </span>
            </div>
            <span className="claim-count">{credential.claims.length} {credential.claims.length === 1 ? 'dato' : 'datos'}</span>
          </li>)}
        </ul>}
        <p className="privacy-note">Las credenciales se guardan cifradas en este dispositivo. Si borrás los datos del sitio, podrías perderlas.</p>
      </section>

      <footer>Kuatia Wallet <span aria-label="versión 0.1.0">v0.1.0</span></footer>
    </main>
  )
}
