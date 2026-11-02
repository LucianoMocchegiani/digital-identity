import { useEffect, useState } from 'react'
import { createHolderKey, getHolderSigningKey, hasHolderKey, listCredentials } from './wallet-storage'
import { parseCurrentPage, type WalletRequest } from './protocol-link'
import { resolveProtocolResource, type ResolvedResource } from './protocol-resource'
import { issuePreAuthorizedCredential } from './oid4vci'
import { verifyPresentationResource } from './oid4vp'
import { findPresentationOptions, inspectStoredCredentials, type PresentationOption, type StoredCredentialSummary } from './oid4vp-presentation'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

export default function App() {
  const [request, setRequest] = useState<WalletRequest | null>(null)
  const [resource, setResource] = useState<ResolvedResource | null>(null)
  const [verifiedPresentation, setVerifiedPresentation] = useState<VerifiedOid4vpRequest | null>(null)
  const [presentationOptions, setPresentationOptions] = useState<PresentationOption[]>([])
  const [credentialSummaries, setCredentialSummaries] = useState<StoredCredentialSummary[]>([])
  const [selectedOption, setSelectedOption] = useState('')
  const [consent, setConsent] = useState(false)
  const [consentConfirmed, setConsentConfirmed] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [txCode, setTxCode] = useState('')
  const [hasKey, setHasKey] = useState(false)
  const [credentialCount, setCredentialCount] = useState(0)
  const [verifiedCount, setVerifiedCount] = useState(0)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
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
      const summaries = await inspectStoredCredentials(credentials)
      setCredentialSummaries(summaries)
      setVerifiedCount(summaries.filter(credential => credential.verified).length)
    }).catch(() => setError('No se pudo acceder o verificar el almacenamiento local de esta wallet.'))
  }, [])

  async function generateKey() {
    setBusy(true)
    setError('')
    try {
      await createHolderKey()
      setHasKey(true)
    } catch {
      setError('El navegador no pudo generar o persistir una clave P-256.')
    } finally {
      setBusy(false)
    }
  }

  async function loadResource() {
    if (!request) return
    setBusy(true)
    setError('')
    setNotice('')
    setResource(null)
    setVerifiedPresentation(null)
    setPresentationOptions([])
    setSelectedOption('')
    setConsent(false)
    setConsentConfirmed(false)
    try {
      const resolved = await resolveProtocolResource(request)
      if (resolved.kind === 'present' && request.kind === 'present') {
        const verified = await verifyPresentationResource(resolved, request.clientId)
        setVerifiedPresentation(verified)
        const credentials = await listCredentials()
        if (hasKey) {
          const { publicJwk } = await getHolderSigningKey()
          setPresentationOptions(await findPresentationOptions(verified, credentials, publicJwk))
        }
      }
      setResource(resolved)
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo cargar o verificar el recurso del protocolo.')
    } finally {
      setBusy(false)
    }
  }

  async function issueCredential() {
    if (!resource || resource.kind !== 'issue') return
    setBusy(true)
    setError('')
    setNotice('')
    try {
      const result = await issuePreAuthorizedCredential(resource, txCode || undefined)
      const credentials = await listCredentials()
      const summaries = await inspectStoredCredentials(credentials)
      setCredentialCount(credentials.length)
      setCredentialSummaries(summaries)
      setVerifiedCount(summaries.filter(credential => credential.verified).length)
      setNotice(`${result.count} credencial(es) recibida(s) y cifrada(s); ${result.verifiedCount} con firma ES256 verificada.`)
    } catch (cause) {
      const credentials = await listCredentials().catch(() => [])
      const summaries = await inspectStoredCredentials(credentials)
      setCredentialCount(credentials.length)
      setCredentialSummaries(summaries)
      setVerifiedCount(summaries.filter(credential => credential.verified).length)
      setError(cause instanceof Error ? cause.message : 'No se pudo completar la emisión.')
    } finally {
      setBusy(false)
    }
  }

  function confirmPresentationConsent() {
    if (!selectedOption || !consent) return
    setConsentConfirmed(true)
    setNotice('Selección y consentimiento confirmados solo en esta pantalla. No se enviaron datos al verifier.')
  }

  const chosenOption = presentationOptions.find(option => `${option.queryId}:${option.credentialId}` === selectedOption)

  return (
    <main className="shell">
      <header><span className="mark">K</span><span>Kuatia <strong>Wallet PoC</strong></span></header>
      <section className="hero">
        <p className="eyebrow">PROTOTIPO WEB · SIN BACKUP</p>
        <h1>Tu identidad,<br />en tu navegador.</h1>
        <p>Prueba local de almacenamiento en IndexedDB y claves P-256 con Web Crypto.</p>
      </section>

      {error && <p className="notice error" role="alert">{error}</p>}
      {notice && <p className="notice" role="status">{notice}</p>}

      {request && <section className="card" aria-live="polite">
        <p className="eyebrow">{request.kind === 'issue' ? 'OFERTA DE EMISIÓN' : 'SOLICITUD DE PRESENTACIÓN'}</p>
        <h2>{request.kind === 'issue' ? 'Cargar oferta' : 'Cargar solicitud'}</h2>
        <p className="endpoint">{request.endpoint}</p>
        {request.kind === 'present' && <p className="endpoint">Client ID: {request.clientId}</p>}
        <button type="button" onClick={() => void loadResource()} disabled={busy}>
          {busy ? 'Cargando…' : resource ? 'Volver a cargar' : 'Descargar recurso'}
        </button>
        {resource?.kind === 'issue' && <>
          <p>Oferta y metadata recibidas. Revisá el issuer y la configuración antes de continuar.</p>
          <p><strong>Issuer:</strong> <span className="endpoint">{resource.credentialIssuer}</span></p>
          <h3>Configuraciones ofrecidas</h3>
          <ul>{resource.credentialConfigurationIds.map(id => <li key={id}>
            <strong>{id}</strong>
            <pre className="resource-preview">{JSON.stringify(resource.supportedConfigurations[id], null, 2)}</pre>
          </li>)}</ul>
          {!resource.hasPreAuthorizedCode && <p className="warning">Esta PoC solo completa ofertas preautorizadas; esta oferta no incluye un código compatible.</p>}
          {resource.hasPreAuthorizedCode && !resource.tokenEndpoint && <p className="warning">No se pudo resolver el token endpoint del issuer; no se puede continuar con esta oferta.</p>}
          {resource.hasPreAuthorizedCode && resource.tokenEndpoint && resource.txCode && <label className="field">
            {resource.txCode.description || 'Código de transacción requerido'}
            <input type="text" inputMode={resource.txCode.inputMode === 'numeric' ? 'numeric' : 'text'} maxLength={resource.txCode.length} value={txCode} onChange={event => setTxCode(event.target.value)} autoComplete="off" />
          </label>}
          {resource.hasPreAuthorizedCode && resource.tokenEndpoint && <>
            {!hasKey && <p className="warning">Generá primero una clave de holder para poder emitir.</p>}
            <p className="warning">Al continuar se consumirá el código de un solo uso de esta oferta. La credencial se guarda cifrada; se verifica la firma ES256 con el DID document del issuer.</p>
            <button type="button" onClick={() => void issueCredential()} disabled={busy || !hasKey || Boolean(resource.txCode && !txCode)}>
              {busy ? 'Emitiendo…' : 'Confirmar y emitir'}
            </button>
          </>}
        </>}
        {resource?.kind === 'present' && verifiedPresentation && <>
          <p className="notice" role="status">Request Object firmado verificado contra el DID del verifier. No se compartieron datos.</p>
          <p><strong>Verifier:</strong> <span className="endpoint">{verifiedPresentation.verifierDid}</span></p>
          <p><strong>Respuesta solicitada:</strong> {String(verifiedPresentation.payload.response_mode)} · DCQL</p>
          <h3>Credenciales que coinciden</h3>
          {!hasKey && <p className="warning">Necesitás la clave local de holder para comprobar el binding de las credenciales.</p>}
          {hasKey && !presentationOptions.length && <p>No se encontró una credencial que coincida con el formato, VCT, claims y clave de holder local.</p>}
          {presentationOptions.length > 0 && <fieldset className="credential-options">
            <legend>Elegí qué credencial usar (todavía no se comparte):</legend>
            {presentationOptions.map(option => {
              const id = `${option.queryId}:${option.credentialId}`
              return <label className="credential-option" key={id}>
                <input type="radio" name="presentation-credential" value={id} checked={selectedOption === id} onChange={() => { setSelectedOption(id); setConsent(false); setConsentConfirmed(false); setNotice('') }} />
                <span><strong>{option.label}</strong><small>Consulta: {option.queryId}</small></span>
              </label>
            })}
          </fieldset>}
          {chosenOption && <>
            <h3>Datos solicitados de esta credencial</h3>
            <dl className="claim-preview">{Object.entries(chosenOption.claims).map(([name, value]) => <div key={name}><dt>{name}</dt><dd>{typeof value === 'string' ? value : JSON.stringify(value)}</dd></div>)}</dl>
            <label className="consent-option"><input type="checkbox" checked={consent} onChange={event => { setConsent(event.target.checked); setConsentConfirmed(false); setNotice('') }} /> Entiendo qué datos solicita este verifier y confirmo esta selección.</label>
            <button type="button" onClick={confirmPresentationConsent} disabled={!consent || consentConfirmed}>Confirmar selección y consentimiento</button>
            <p className="warning">Esta confirmación solo queda en la pantalla. La wallet todavía no prueba posesión durante la presentación ni genera o envía la presentación; no transmite estos datos.</p>
          </>}
        </>}
      </section>}

      <section className="card">
        <div className="row"><div><h2>Almacenamiento local</h2><p>{credentialCount} credenciales cifradas; {verifiedCount} firmas ES256 verificadas</p></div><span className="status">{hasKey ? 'CLAVE LISTA' : 'SIN CLAVE'}</span></div>
        <p>La clave de holder P-256 se genera como CryptoKey no exportable y se persiste en IndexedDB.</p>
        <button type="button" onClick={() => void generateKey()} disabled={busy || hasKey}>
          {busy ? 'Procesando…' : hasKey ? 'Clave creada' : 'Generar clave de holder'}
        </button>
        <h3>Credenciales guardadas (solo metadatos)</h3>
        {!credentialSummaries.length && <p>No hay credenciales guardadas.</p>}
        <ul className="credential-inventory">
          {credentialSummaries.map(credential => <li key={credential.id}>
            <strong>{credential.label}</strong> · {credential.verified ? 'firma verificada' : 'firma no verificada'}
            <dl>
              <div><dt>Formato</dt><dd>{credential.format}</dd></div>
              <div><dt>VCT</dt><dd>{credential.vct}</dd></div>
              <div><dt>Claims disponibles</dt><dd>{credential.claims.join(', ') || 'ninguno legible'}</dd></div>
            </dl>
          </li>)}
        </ul>
        <p className="warning">Esta vista descifra localmente solo para mostrar metadatos y nombres de claims; no muestra valores personales ni transmite credenciales.</p>
      </section>

      <p className="warning">OID4VP comprueba la firma del issuer y la coincidencia de cnf.jwk con la clave local, pero todavía no demuestra posesión al verifier ni envía presentaciones. No compartas credenciales.</p>
      <footer>Sin backend · Sin backup · No usar con credenciales reales</footer>
    </main>
  )
}
