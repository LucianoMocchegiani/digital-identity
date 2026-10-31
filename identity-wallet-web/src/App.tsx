import { useEffect, useState } from 'react'
import { createHolderKey, hasHolderKey, listCredentials } from './wallet-storage'
import { parseCurrentPage, type WalletRequest } from './protocol-link'
import { resolveProtocolResource, type ResolvedResource } from './protocol-resource'

export default function App() {
  const [request, setRequest] = useState<WalletRequest | null>(null)
  const [resource, setResource] = useState<ResolvedResource | null>(null)
  const [error, setError] = useState('')
  const [hasKey, setHasKey] = useState(false)
  const [credentialCount, setCredentialCount] = useState(0)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    try {
      setRequest(parseCurrentPage(window.location.pathname, window.location.search))
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'El enlace no es válido.')
    } finally {
      if (window.location.search) window.history.replaceState({}, '', window.location.pathname)
    }
    void Promise.all([hasHolderKey(), listCredentials()]).then(([keyExists, credentials]) => {
      setHasKey(keyExists)
      setCredentialCount(credentials.length)
    }).catch(() => setError('No se pudo acceder al almacenamiento local de esta wallet.'))
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
    setResource(null)
    try {
      setResource(await resolveProtocolResource(request))
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo cargar el recurso del protocolo.')
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

      {request && <section className="card" aria-live="polite">
        <p className="eyebrow">{request.kind === 'issue' ? 'OFERTA DE EMISIÓN' : 'SOLICITUD DE PRESENTACIÓN'}</p>
        <h2>{request.kind === 'issue' ? 'Cargar oferta' : 'Cargar solicitud'}</h2>
        <p className="endpoint">{request.endpoint}</p>
        {request.kind === 'present' && <p className="endpoint">Client ID: {request.clientId}</p>}
        <button type="button" onClick={() => void loadResource()} disabled={busy}>
          {busy ? 'Cargando…' : resource ? 'Volver a cargar' : 'Descargar recurso'}
        </button>
        {resource?.kind === 'issue' && <>
          <p>Oferta y metadata recibidas. Todavía no se intercambiaron tokens ni se solicitó una credencial.</p>
          <p><strong>Issuer:</strong> <span className="endpoint">{resource.credentialIssuer}</span></p>
          <h3>Configuraciones ofrecidas</h3>
          <ul>{resource.credentialConfigurationIds.map(id => <li key={id}>
            <strong>{id}</strong>
            <pre className="resource-preview">{JSON.stringify(resource.supportedConfigurations[id], null, 2)}</pre>
          </li>)}</ul>
          {!resource.hasPreAuthorizedCode && <p className="warning">La oferta no contiene un código preautorizado reconocido; no se puede continuar con el flujo PoC preautorizado.</p>}
        </>}
        {resource?.kind === 'present' && <>
          <p className="warning">Request Object descargado, pero la firma y el emisor todavía no se verificaron. No compartas datos.</p>
          <pre className="resource-preview">{JSON.stringify(resource.payload, null, 2)}</pre>
        </>}
      </section>}

      <section className="card">
        <div className="row"><div><h2>Almacenamiento local</h2><p>{credentialCount} credenciales guardadas (cifradas con AES-GCM)</p></div><span className="status">{hasKey ? 'CLAVE LISTA' : 'SIN CLAVE'}</span></div>
        <p>La clave de holder P-256 se genera como CryptoKey no exportable y se persiste en IndexedDB.</p>
        <button type="button" onClick={() => void generateKey()} disabled={busy || hasKey}>
          {busy ? 'Generando…' : hasKey ? 'Clave creada' : 'Generar clave de holder'}
        </button>
      </section>

      <p className="warning">Esta PoC no ofrece protección de hardware ni recuperación. Borrar los datos del sitio puede eliminar definitivamente claves y credenciales.</p>
      <footer>Sin backend · Sin backup · No usar con credenciales reales</footer>
    </main>
  )
}
