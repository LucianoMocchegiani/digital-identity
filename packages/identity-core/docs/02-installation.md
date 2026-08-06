---
id: installation
title: Instalación
sidebar_position: 2
---

# Instalación

Esta guía cubre cómo instalar `@quarkid/identity-core`, qué *peer dependencies* de Credo-TS debés añadir vos como integrador, los requisitos del entorno y las variables de configuración que consume la librería.

## Instalar el paquete

El paquete se publica con el nombre **`@quarkid/identity-core`** (versión actual `0.1.0`):

```bash
npm install @quarkid/identity-core
```

El `package.json` declara `publishConfig.access: "public"` y no tiene `private: true`, por lo que está pensado para publicarse en un registry público. Tené en cuenta que se trata de un *scoped package* (`@quarkid/...`): si tu organización aloja el paquete en un registry privado o en GitHub Packages, configurá previamente tu `.npmrc` para resolver el scope `@quarkid`.

## Peer dependencies de Credo

`@quarkid/identity-core` declara Credo-TS y Express como **`peerDependencies`**. Esto significa que **vos, como integrador, debés instalarlos explícitamente** en tu proyecto; `npm install @quarkid/identity-core` no los trae automáticamente (npm 7+ avisará si falta alguno).

Las versiones exactas declaradas en el `package.json` de la librería son:

| Paquete | Versión requerida | Para qué se usa |
| --- | --- | --- |
| `@credo-ts/core` | `0.7.0` | Núcleo del agente: `Agent`, `DependencyManager`, KMS, DIDs, credenciales W3C y SD-JWT VC. |
| `@credo-ts/node` | `0.7.0` | Dependencias de runtime Node (`agentDependencies`) y transporte WebSocket de entrada (`DidCommWsInboundTransport`). |
| `@credo-ts/didcomm` | `0.7.0` | Mensajería DIDComm y módulos asociados. |
| `@credo-ts/openid4vc` | `0.7.0` | Flujos OID4VCI (issuer/holder) y OID4VP (verifier). |
| `@credo-ts/tenants` | `0.7.0` | Multi-tenancy (`TenantsModule`, `TenantsApi`). |
| `express` | `^4.18.0` | Servidor HTTP que expone los endpoints OID4VC. |

Los cinco paquetes `@credo-ts/*` son requeridos: todos se importan en el código de los agentes (`issuer.agent.ts`, `holder.agent.ts`, `verifier.agent.ts` y módulos relacionados). Instalalos en bloque, fijando las versiones de Credo a `0.7.0` para garantizar compatibilidad:

```bash
npm install \
  @credo-ts/core@0.7.0 \
  @credo-ts/node@0.7.0 \
  @credo-ts/didcomm@0.7.0 \
  @credo-ts/openid4vc@0.7.0 \
  @credo-ts/tenants@0.7.0 \
  express@^4.18.0
```

> **Nota sobre versiones de Credo.** La librería fija Credo-TS en `0.7.0` (no usa un rango). Mantené esa versión exacta en tu proyecto para evitar conflictos de tipos y de API entre la librería y tu instalación de Credo.

## Requisitos del entorno

| Requisito | Detalle |
| --- | --- |
| **Node.js** | El `package.json` **no declara** un campo `engines`, por lo que la librería no impone una versión mínima de forma explícita. Las `devDependencies` usan `@types/node@^18`, lo que sugiere que se desarrolla y prueba sobre **Node 18 LTS**. Recomendamos Node 18 o superior. |
| **TypeScript** | La librería se compila con TypeScript (`typescript@^5.3.0` en `devDependencies`). Para consumir los tipos publicados (`dist/index.d.ts`) usá **TypeScript 5.3 o superior**. |
| **PostgreSQL** | Usado por adapters Postgres (records / BLS / StatusList) y como backend del store Askar. identity-core no abre la conexión sola: Nest/integrador pasa `Pool` o `askarStore`. |

## Variables de entorno

La librería expone la interface `CredoEnvConfig` y la función `buildCredoConfigFromEnv(env)` (en `src/agent/config.ts`) para construir la configuración del agente a partir de variables de entorno. La función toma un objeto `CredoEnvConfig` y devuelve un `CredoAgentBaseConfig` listo para inicializar el agente.

Campos de `CredoEnvConfig` (solo config del agente; **no** incluyen KMS ni records):

| Campo | Tipo | Obligatorio | Descripción |
| --- | --- | --- | --- |
| `vdrServiceUrl` | `string` | Sí | URL del servicio VDR (Verifiable Data Registry) usado para resolver DIDs. |
| `didcommEndpoint` | `string` | Sí | Endpoint público DIDComm del agente. |
| `didcommPort` | `number` | No | Puerto en el que escucha el transporte DIDComm. |
| `useHttpForWebDid` | `boolean` | No | Usar HTTP en lugar de HTTPS para resolver `did:web`. Útil en dev local sin TLS. Por defecto `false`. |
| `oid4vcBaseUrl` | `string` | No | URL base pública para los endpoints OID4VCI. Si se omite, OID4VCI **no se activa**. |

Variables Nest del **producto** Quark (fuera de `CredoEnvConfig`):

| Variable | Obligatoria | Descripción |
| --- | --- | --- |
| `DATABASE_URL` | Sí | Postgres del servicio (Askar / BBS / StatusList) |
| `ASKAR_STORE_KEY` | Sí | Passphrase del store |
| `ASKAR_STORE_ID` | No | Default: nombre de DB en `DATABASE_URL` |

> **Records / KMS.** `buildCredoConfigFromEnv` no incluye storage. El integrador inyecta `RecordStorage` + `KeyManagementService` (+ `additionalKeyManagementServices`, `askarStore`). Ver [KMS](./06-reference/02-kms.md).

### Ejemplo de uso

```typescript
import { buildCredoConfigFromEnv } from '@quarkid/identity-core'
import type { CredoEnvConfig } from '@quarkid/identity-core'

const env: CredoEnvConfig = {
  vdrServiceUrl: process.env.VDR_SERVICE_URL!,
  didcommEndpoint: process.env.DIDCOMM_ENDPOINT!,
  didcommPort: process.env.DIDCOMM_PORT ? Number(process.env.DIDCOMM_PORT) : undefined,
  useHttpForWebDid: process.env.USE_HTTP_FOR_WEB_DID === 'true',
  oid4vcBaseUrl: process.env.OID4VC_BASE_URL,
}

const config = buildCredoConfigFromEnv(env)
// Inyectar recordStorage + keyManagementService (+ askarStore / additional) al crear el agente
```

El `CredoAgentBaseConfig` resultante es el objeto que se pasa a la creación del agente (issuer, holder o verifier), tema que se cubre en la siguiente sección.

## Ver también

- [Bootstrap del agente](./03-agent-bootstrap.md)
- [Overview](./01-overview.md)
