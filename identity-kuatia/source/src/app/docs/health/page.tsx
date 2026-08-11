import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsP,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import { docsPageMeta } from '@/shared/seo/docs'

export const metadata = docsPageMeta('health')

export default function DocsHealthPage() {
  return (
    <>
      <DocsTitle>Health</DocsTitle>
      <DocsLead>
        Comprobá que el servicio está vivo y listo antes de emitir o verificar. Rutas públicas (sin
        API key).
      </DocsLead>

      <DocsEndpoint method="GET" path="/v1/health" auth="Pública">
        <p>Liveness: el proceso HTTP responde.</p>
        <DocsCode>{`GET {ISSUER_URL}/v1/health

{ "ok": true }`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint method="GET" path="/v1/health/ready" auth="Pública">
        <p>
          Readiness: el agente issuer/verifier terminó de inicializar. No emitas ni verifiques si
          esto falla.
        </p>
        <DocsCode>{`GET {ISSUER_URL}/v1/health/ready

{ "ready": true, "timestamp": "…" }`}</DocsCode>
      </DocsEndpoint>

      <DocsP>Las mismas rutas existen en el verifier.</DocsP>
    </>
  )
}
