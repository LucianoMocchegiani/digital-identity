import { useEffect, useState } from 'react'
import { createHolderKey, hasHolderKey, listCredentials } from './wallet-storage'
import { parseCurrentPage, type WalletRequest } from './protocol-link'

export default function App() {
  const [request, setRequest] = useState<WalletRequest | null>(null)
  const [error, setError] = useState('')
  const [hasKey, setHasKey] = useState(false)
  const [credentialCount, setCredentialCount] = useState(0)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    try {
      setRequest(parseCurrentPage(window.location.pathname, window.location.search))
      if (window.location.search) window.history.replaceState({}, '', window.location.pathname)
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'El enlace no es válido.')
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
        <p className="eyebrow">SOLICITUD RECIBIDA</p>
        <h2>{request.kind === 'issue' ? 'Oferta de emisión' : 'Solicitud de presentación'}</h2>
        <p className="endpoint">{request.endpoint}</p>
        {request.kind === 'present' && <p className="endpoint">Client ID: {request.clientId}</p>}
        <p className="notice">El enlace se validó contra los dominios y rutas de Kuatia, pero todavía no se descargó ni verificó criptográficamente. No autorices ni compartas datos desde esta PoC.</p>
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
