// Genera lib/src/crypto/ldp/ldp_contexts.dart en identity-core-dart a partir
// de los contextos JSON-LD bundled de Credo, para que la canonicalización
// URDNA2015 del wallet coincida con la del verifier.
import { writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import path from 'node:path'

const base = '../node_modules/@credo-ts/core/build/modules/vc/data-integrity/libraries/contexts'
const { CREDENTIALS_V1 } = await import(`${base}/credentials_v1.mjs`)
const { PRESENTATION_SUBMISSION } = await import(`${base}/submission.mjs`)
const { SCHEMA_ORG } = await import(`${base}/schema_org.mjs`)
const { SECURITY_V1 } = await import(`${base}/security_v1.mjs`)
const { SECURITY_V2 } = await import(`${base}/security_v2.mjs`)
const { ED25519_V1 } = await import(`${base}/ed25519_v1.mjs`)
const { DID_V1 } = await import(`${base}/did_v1.mjs`)

const contexts = {
  'https://www.w3.org/2018/credentials/v1': CREDENTIALS_V1,
  'https://identity.foundation/presentation-exchange/submission/v1': PRESENTATION_SUBMISSION,
  'http://schema.org/': SCHEMA_ORG,
  'https://schema.org/': SCHEMA_ORG,
  'https://w3id.org/security/v1': SECURITY_V1,
  'https://w3id.org/security/v2': SECURITY_V2,
  'https://w3id.org/security/suites/ed25519-2018/v1': ED25519_V1,
  'https://w3id.org/did/v1': DID_V1,
  'https://www.w3.org/ns/did/v1': DID_V1,
}

const entries = Object.entries(contexts)
  .map(([url, doc]) => {
    const json = JSON.stringify(doc)
    if (json.includes("'''")) throw new Error(`Context ${url} contiene comillas triples`)
    return `  '${url}': r'''${json}''',`
  })
  .join('\n')

const dart = `// GENERADO por packages/identity-core/scripts/export-ldp-contexts.mjs — NO editar a mano.
//
// Contextos JSON-LD estáticos (idénticos a los bundled en Credo-TS) usados por
// el document loader offline al canonicalizar con URDNA2015 para firmas LDP.

/// Mapa URL de contexto → JSON crudo del contexto.
const Map<String, String> kLdpContextsRaw = {
${entries}
};
`

const outPath = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../identity-core-dart/lib/src/crypto/ldp/ldp_contexts.dart',
)
writeFileSync(outPath, dart)
console.log(`OK -> ${outPath}`)
