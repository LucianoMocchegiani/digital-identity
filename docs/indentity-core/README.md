# Documentación @quarkid/identity-core

## Integración de la librería (principal)

**[guia-libreria.md](./guia-libreria.md)** — API del paquete npm:

- Configuración (`CredoAgentBaseConfig`, `buildCredoConfigFromEnv`)
- Modo **single-wallet** (`createIssuerAgent`, …)
- Modo **multi-tenant** (`createRoot*Agent`, `create*Wallet`, `withTenant`, `loadTenantMap`)
- OID4VCI / OID4VP / DIDComm
- Consulta de records (`listTenantRecords`, `getRecordTypeDescriptors`, …)
- Errores y tabla de exports

Código fuente: [`packages/identity-core/`](../../packages/identity-core/).

## Servicios HTTP de identidad (Nest)

| Documento | Contenido |
|-----------|-----------|
| [api-tenants-y-records.md](./api-tenants-y-records.md) | `GET/POST /issuers|holders|verifiers`, `GET /:walletId/records/*` |
| [postman-bodies.md](./postman-bodies.md) | Bodies JSON para Postman |

Implementación: `quark-issuer-service`, `quark-holder-service`, `quark-verifier-service`.  
Colecciones: [`postman/`](../../postman/).

## Otros

| Documento | Audiencia |
|-----------|-----------|
| [guia-integracion.md](./guia-integracion.md) | Resumen E2E, comparativa de modos, enlaces |
| [guia-integracion-mobile.md](./guia-integracion-mobile.md) | Holder en Dart/Flutter (`identity_core_dart`) |

Puertos Docker: issuer `9001`, verifier `9002`, holder `9005`.
