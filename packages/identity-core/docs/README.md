---
id: indice
title: Documentación de @quarkid/identity-core
sidebar_position: 0
---

# Documentación de `@quarkid/identity-core`

`@quarkid/identity-core` es una librería TypeScript que envuelve **Credo-TS 0.7** para el ecosistema **QuarkID 2.0**: permite construir agentes **issuer**, **holder** y **verifier** con los protocolos SSI DIDComm v1, OID4VCI y OID4VP, y soporte multi-tenant.

Esta documentación está pensada para un **integrador del paquete npm**: un desarrollador que instala la librería en su propio servicio Node y necesita levantar y operar un agente.

## Contenido

### Empezar

| Documento | Contenido |
|-----------|-----------|
| [Overview](./01-overview.md) | Qué es la librería, arquitectura, ecosistema QuarkID y conceptos clave |
| [Instalación](./02-installation.md) | `npm install`, peer dependencies de Credo, requisitos y variables de entorno |
| [Bootstrap del agente](./03-agent-bootstrap.md) | `CredoAgentBaseConfig`, modos single-wallet (legacy) y multi-tenant, módulos y `fetchOverride` |

### Tenants y flujos

| Documento | Contenido |
|-----------|-----------|
| [Tenants y wallets](./04-tenants.md) | `ensureTenant`, `withTenant`, `loadTenantMap` y creación de wallets por rol |
| [Emisión OID4VCI](./05-flows/01-issuance-oid4vci.md) | Emisión de credenciales como issuer (OID4VCI + DIDComm) |
| [Verificación OID4VP](./05-flows/02-verification-oid4vp.md) | Solicitud y verificación de presentaciones como verifier |
| [Holder](./05-flows/03-holder.md) | Recibir credenciales y presentarlas como holder |
| [DIDComm](./05-flows/04-didcomm.md) | Invitaciones, conexiones, transporte y listeners |

### Referencia

| Documento | Contenido |
|-----------|-----------|
| [DIDs](./06-reference/01-dids.md) | `did:web`, `did:key`, registrars y resolvers |
| [KMS](./06-reference/02-kms.md) | Backends interno, externo y Vault; domain key |
| [Records](./06-reference/03-records.md) | Port `RecordStorage`, inyección `PostgresRecordStorage`, consulta por tenant |
| [Credenciales](./06-reference/04-credentials.md) | Builders de credenciales y presentaciones (W3C, SD-JWT) |
| [Revocación](./06-reference/05-revocation.md) | Token Status List: crear, asignar índices y revocar |

### Operación

| Documento | Contenido |
|-----------|-----------|
| [Troubleshooting](./07-troubleshooting.md) | Problemas comunes y soluciones |
| [Limitaciones](./08-limitations.md) | Limitaciones conocidas con evidencia y workarounds |

## ¿Por dónde empezar?

1. Leé el [Overview](./01-overview.md) para entender roles y conceptos.
2. Seguí con la [Instalación](./02-installation.md) y el [Bootstrap del agente](./03-agent-bootstrap.md).
3. Configurá tus wallets en [Tenants y wallets](./04-tenants.md).
4. Según tu rol, andá al flujo correspondiente: [emisión](./05-flows/01-issuance-oid4vci.md) (issuer), [verificación](./05-flows/02-verification-oid4vp.md) (verifier) o [holder](./05-flows/03-holder.md).
5. Consultá la **Referencia** para el detalle de cada módulo y las [Limitaciones](./08-limitations.md) antes de ir a producción.
