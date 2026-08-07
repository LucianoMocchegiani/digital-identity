import { DocsCode, DocsLead, DocsP, DocsTitle } from '@/modules/docs/components/DocsPrimitives'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Autenticación',
}

export default function DocsAuthPage() {
  return (
    <>
      <DocsTitle>Autenticación</DocsTitle>
      <DocsLead>
        Las rutas admin (offers, requests, branding) usan API key. Health, did.json y well-known son
        públicos para wallets y probes.
      </DocsLead>

      <DocsP>Header en rutas admin:</DocsP>
      <DocsCode>{`X-API-Key: iss_live_…`}</DocsCode>
      <DocsP>
        Usá la key del producto correcto (<code className="text-sm">iss_live_</code> en issuer,{' '}
        <code className="text-sm">ver_live_</code> en verifier). Nunca la expongas en un cliente
        público.
      </DocsP>
    </>
  )
}
