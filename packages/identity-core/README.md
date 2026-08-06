# @quarkid/identity-core

Librería TypeScript (Credo-TS **0.7**) para agentes QuarkID: DID (`did:web`, `did:key`), OID4VCI/OID4VP, DIDComm v1, multi-tenant y consulta de records.

## Documentación

Guía de integración (modo single-wallet y multi-tenant, API del paquete):

**[docs/indentity-core/guia-libreria.md](../../docs/indentity-core/guia-libreria.md)**

También:

- [api-tenants-y-records.md](../../docs/indentity-core/api-tenants-y-records.md) — REST de servicios de identidad
- [guia-integracion.md](../../docs/indentity-core/guia-integracion.md) — índice general

## Uso mínimo (multi-tenant issuer)

```typescript
import {
  createRootIssuerAgent,
  loadTenantMap,
  createIssuerWallet,
  withTenant,
  createSdJwtOffer,
} from '@quarkid/identity-core'

// recordStorage: PostgresRecordStorage + Pool (ver docs/06-reference/03-records.md)
const rootAgent = await createRootIssuerAgent(config, { expressApp, wsServer, recordStorage })
const map = await loadTenantMap(rootAgent)

const tenantId = await createIssuerWallet(rootAgent, 'issuer-1', '', {
  didcommEndpoint: config.didcommEndpoint,
  oid4vcOptions: { /* ... */ },
})
map.set('issuer-1', tenantId)

const { offerUri } = await withTenant(rootAgent, tenantId, (agent) =>
  createSdJwtOffer(agent, { issuerId: 'issuer-1', configurationId: 'quarkid_demo', vct: 'QuarkCredential', claims: {} }),
)
```

## Estructura del paquete

```
src/
  agent/          # create*Agent, create*Wallet, tenant, config
  protocol/       # openid4vc, didcomm
  record/         # RecordStorage port, PostgresRecordStorage, tenant-records
  revocation/     # Token Status List: SignerProvider/UriBuilder ports, RevocationIssuer, PostgresStatusListStorage
  did/            # web-did, key-did, resolvers
  kms/            # internal / external KMS
```

## Build

```bash
npm install
npm run build
```
