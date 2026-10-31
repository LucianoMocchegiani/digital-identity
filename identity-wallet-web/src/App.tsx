import { useEffect, useState } from 'react'
import { createHolderKey, hasHolderKey, listCredentials } from './wallet-storage'
import { parseCurrentPage, type WalletRequest } from './protocol-link'
import { resolveProtocolResource, type ResolvedResource } from './protocol-resource'
import { issuePreAuthorizedCredential } from './oid4vci'
import { verifySdJwtSignature } from './credential-verification'

export default function App() {
  const [request, setRequest] = useState<WalletRequest | null>(null)
  const [resource, setResource] = useState<ResolvedResource | null>(null)
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
      const results = await Promise.all(credentials.map(credential =>
        verifySdJwtSignature(credential.compactSdJwt).then(() => true).catch(() => false),
      ))
      setVerifiedCount(results.filter(Boolean).length)
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
    try {
      setResource(await resolveProtocolResource(request))
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo cargar el recurso del protocolo.')
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
      setCredentialCount(credentials.length)
      setVerifiedCount(credentials.filter(credential => credential.label.includes('firma ES256 verificada')).length)
      setNotice(`${result.count} credencial(es) recibida(s) y cifrada(s); ${result.verifiedCount} con firma ES256 verificada.`)
    } catch (cause) {
      const credentials = await listCredentials().catch(() => [])
      setCredentialCount(credentials.length)
      const results = await Promise.all(credentials.map(credential =>
        verifySdJwtSignature(credential.compactSdJwt).then(() => true).catch(() => false),
      ))
      setVerifiedCount(results.filter(Boolean).length)
      setError(cause instanceof Error ? cause.message : 'No se pudo completar la emisión.')
    } finally {
      setBusy(false)
    }
  }

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
            <input
              type="text"
              inputMode={resource.txCode.inputMode === 'numeric' ? 'numeric' : 'text'}
              maxLength={resource.txCode.length}
              value={txCode}
              onChange={event => setTxCode(event.target.value)}
              autoComplete="off"
            />
          </label>}
          {resource.hasPreAuthorizedCode && resource.tokenEndpoint && <>
            {!hasKey && <p className="warning">Generá primero una clave de holder para poder emitir.</p>}
            <p className="warning">Al continuar se consumirá el código de un solo uso de esta oferta. La credencial se guarda cifrada; se verifica la firma ES256 con el DID document del issuer.</p>
            <button type="button" onClick={() => void issueCredential()} disabled={busy || !hasKey || Boolean(resource.txCode && !txCode)}>
              {busy ? 'Emitiendo…' : 'Confirmar y emitir'}
            </button>
          </>}
        </>}
        {resource?.kind === 'present' && <>
          <p className="warning">Request Object descargado, pero la firma y el emisor todavía no se verificaron. No compartas datos.</p>
          <pre className="resource-preview">{JSON.stringify(resource.payload, null, 2)}</pre>
        </>}
      </section>}

      <section className="card">
        <div className="row"><div><h2>Almacenamiento local</h2><p>{credentialCount} credenciales cifradas; {verifiedCount} firmas ES256 verificadas</p></div><span className="status">{hasKey ? 'CLAVE LISTA' : 'SIN CLAVE'}</span></div>
        <p>La clave de holder P-256 se genera como CryptoKey no exportable y se persiste en IndexedDB.</p>
        <button type="button" onClick={() => void generateKey()} disabled={busy || hasKey}>
          {busy ? 'Procesando…' : hasKey ? 'Clave creada' : 'Generar clave de holder'}
        </button>
      </section>

      <p className="warning">Se verifican la firma ES256 del issuer y los hashes de disclosures. Aún no se valida el binding del holder ni la revocación; OID4VP continúa deshabilitado. No presentes ni compartas credenciales desde esta PoC.</p>
      <footer>Sin backend · Sin backup · No usar con credenciales reales</footer>
    </main>
  )
}
