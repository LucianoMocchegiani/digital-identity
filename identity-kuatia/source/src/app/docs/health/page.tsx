import {
  DocsCode,
  DocsEndpoint,
  DocsLead,
  DocsP,
  DocsTitle,
} from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Health',
}

export default function DocsHealthPage() {
  return (
    <>
      <DocsTitle>Health</DocsTitle>
      <DocsLead>Comprobá que el servicio está vivo antes de emitir o verificar.</DocsLead>

      <DocsEndpoint method="GET" path="/v1/health" auth="Pública">
        <p>Liveness: el proceso HTTP responde.</p>
        <DocsCode>{`GET {ISSUER_URL}/v1/health

{ "ok": true }`}</DocsCode>
      </DocsEndpoint>

      <DocsEndpoint method="GET" path="/v1/health/ready" auth="Pública">
        <p>Readiness: el agente SSI está inicializado. No emitas si esto falla.</p>
        <DocsCode>{`GET {ISSUER_URL}/v1/health/ready

{ "ready": true, "timestamp": "…" }`}</DocsCode>
      </DocsEndpoint>

      <DocsP>Las mismas rutas existen en el verifier.</DocsP>
    </>
  )
}
