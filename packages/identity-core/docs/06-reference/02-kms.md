---
id: kms
title: KMS
sidebar_position: 2
---

# KMS

El KMS (Key Management Service) es la capa que crea, almacena y usa las claves
criptográficas del agente: firma de credenciales y JWTs, cifrado/descifrado DIDComm,
acuerdo de clave para JARM y generación de bytes aleatorios.

En `@quarkid/identity-core` el **contrato Quark** es `KeyManagementService` (paridad con
`RecordStorage` / `StatusListStorage`). El **integrador inyecta** el/los adapters;
identity-core registra las instancias en Credo **sin** elegir backend por env.

Código: `packages/identity-core/src/kms/` y `packages/identity-core/src/agent/kms.module.ts`.

## Contrato e inyección (librería)

```ts
import type { KeyManagementService, QuarkAskarStoreOptions } from '@quarkid/identity-core'

createRootIssuerAgent(config, {
  recordStorage,                       // AskarRecordStorage | PostgresRecordStorage | …
  keyManagementService,                // primario → defaultBackend
  additionalKeyManagementServices,     // BBS, domain-key, futuros
  askarStore,                          // solo si usás adapters Askar
})

registerKmsConfig(dm, keyManagementService, additionalKeyManagementServices)
buildKeyManagementModule(keyManagementService, additionalKeyManagementServices)
```

| Adapter | Clase | `backend` | Almacenamiento |
| --- | --- | --- | --- |
| Askar | `AskarKeyManagementService()` | `'askar'` | Store Askar cifrado |
| Domain-key Askar | `AskarDomainKeyManagementService()` | `'askar-domain-key'` | Perfil Askar `domain-key` |
| BBS (sidecar) | `BbsKeyManagementService(pool)` | `'bbs-postgres'` | Tabla `keys` (solo Bls12381G2) |
| Postgres (full) | `PostgresKeyManagementService(pool, scope?)` | `'postgres'` | Tabla `keys` (KMS completo) |

Askar 0.7 **no** soporta Bls12381G2: el producto Quark registra `BbsKeyManagementService` en `additionalKeyManagementServices`. Un integrador sin Askar puede usar `PostgresKeyManagementService` como primario (incluye BLS).

## Producto Quark (issuer / verifier / holder)

Los servicios Nest **fijan** Askar + records Askar + sidecar `BbsKeyManagementService`. El verifier también registra `AskarDomainKeyManagementService`. No hay `KMS_DRIVER` / `RECORD_DRIVER`.

Variables Nest de producto:

| Variable | Obligatoria | Descripción |
|----------|-------------|-------------|
| `DATABASE_URL` | Sí | Postgres (Askar store, BBS, StatusList) |
| `ASKAR_STORE_KEY` | Sí | Passphrase del store |
| `ASKAR_STORE_ID` | No | Default: nombre de DB en `DATABASE_URL` |

### Alcance por clave (composición Askar de producto)

| Fragmento típico | Algoritmo | Uso | Dónde opera |
| --- | --- | --- | --- |
| `#key-p256` | P-256 / ES256 | OID4VC JWT, firmas JWS | Askar |
| `#key-ed25519-*` | Ed25519 / EdDSA | Firma DIDComm / LDP | Askar |
| (mismo Ed25519) | X25519 | Cifrado DIDComm | Askar |
| leaf x5c | P-256 | OID4VP `requestSignerMethod=x5c` | Askar domain-key |
| `#key-bbs-ldp` | Bls12381G2 | VC/VP BBS+ | Postgres `keys` + MATTR |

:::warning Advertencia de seguridad (`BbsKeyManagementService` / Postgres full)
Las claves BLS del sidecar se guardan **en texto plano** en la tabla `keys`.
Ed25519/P-256/X25519 del producto viven cifrados en Askar.
:::

## Claves de dominio (x5c)

- **Con Askar:** `importDomainKey(agent, keyId, privateJwk)` → backend `askar-domain-key`.
- **Con Postgres full como primario:** el fallback `wallet_id = domain-key` de `PostgresKeyManagementService` sigue disponible para integradores que no usen Askar.
