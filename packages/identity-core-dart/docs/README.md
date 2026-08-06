---
id: indice
title: Documentación de identity_core_dart
sidebar_position: 0
---

# Documentación de identity_core_dart

`identity_core_dart` es un SDK holder SSI nativo en Dart para aplicaciones Flutter. Permite recibir credenciales verificables mediante OID4VCI, presentarlas mediante OID4VP, comunicarse con agentes Credo (Quark) vía **DIDComm v1** (envelope Authcrypt) y persistir información sensible con cifrado por campo (`enc:v1:`) cuando se usa `WalletService` (ver [Limitaciones](07-limitations.md)).

Esta documentación está dirigida a integradores de wallets Flutter externas —como bax— que consumen el paquete publicado sin acceso al monorepo Quark. Cubre desde la instalación inicial hasta la referencia detallada de cada componente del SDK.

---

## Tabla de contenidos

### Empezar

| Documento | Descripción |
|-----------|-------------|
| [Overview](01-overview.md) | Arquitectura general del SDK, actores del ecosistema SSI y casos de uso soportados. |
| [Instalación](02-installation.md) | Cómo agregar el paquete a un proyecto Flutter vía git dependency, configurar dependencias nativas Android/iOS y registrar los esquemas de deep links. |
| [Ciclo de vida de la wallet](03-wallet-lifecycle.md) | Inicialización, apertura, bloqueo y destrucción de una instancia de wallet; gestión del estado de sesión. |

### Flujos

| Documento | Descripción |
|-----------|-------------|
| [Invitaciones](04-flows/01-invitations.md) | Escaneo y procesamiento de URLs de invitación: cómo el SDK determina qué flujo disparar a partir de una URL entrante. |
| [OID4VCI — Recepción de credenciales](04-flows/02-oid4vci.md) | Flujo completo de recepción de credenciales verificables desde un issuer mediante OpenID for Verifiable Credential Issuance (pre-authorized, `tx_code` y authorization code / EUDI). |
| [OID4VP — Presentación de credenciales](04-flows/03-oid4vp.md) | Flujo completo de presentación de credenciales a un verifier mediante OpenID for Verifiable Presentations, selective disclosure, DCQL y JARM (`direct_post.jwt`) para verifiers EUDI. |
| [DIDComm](04-flows/04-didcomm.md) | Handshake OOB, emisión y verificación JSON-LD con issuer/verifier Quark (Envelope V1 + `DidCommFlowSession`). |

### Referencia

| Documento | Descripción |
|-----------|-------------|
| [Stores](05-reference/01-stores.md) | Abstracción de almacenamiento local: tipos de store, configuración de backends y ciclo de vida de los datos. |
| [Credenciales](05-reference/02-credentials.md) | Modelo de datos de credenciales verificables, estados posibles y operaciones disponibles sobre ellas. |
| [DIDs](05-reference/03-dids.md) | Creación y resolución de Decentralized Identifiers, métodos DID soportados y rotación de claves. |
| [KMS](05-reference/04-kms.md) | Key Management Service embebido: generación, almacenamiento y uso de material criptográfico. |
| [Trust](05-reference/05-trust.md) | Configuración de trust registries, validación de issuers y políticas de aceptación de credenciales. |
| [Errores](05-reference/06-errors.md) | Catálogo completo de excepciones del SDK, códigos de error y estrategias de manejo recomendadas. |

### Operación

| Documento | Descripción |
|-----------|-------------|
| [Troubleshooting](06-troubleshooting.md) | Diagnóstico de problemas frecuentes: errores de red, fallos de inicialización, problemas de compatibilidad nativa. |
| [Limitaciones](07-limitations.md) | Restricciones conocidas del SDK, funcionalidades no soportadas y consideraciones de seguridad a tener en cuenta. |

---

## ¿Por dónde empezar?

Si es tu primera vez integrando el SDK, seguí este orden de lectura recomendado:

1. **[Overview](01-overview.md)** — Arquitectura general del SDK y conceptos SSI fundamentales: el punto de partida para entender el ecosistema antes de integrar.
2. **[Instalación](02-installation.md)** — Pasos para agregar el paquete vía git dependency, configurar dependencias nativas Android/iOS y registrar los esquemas de deep links.
3. **[Ciclo de vida de la wallet](03-wallet-lifecycle.md)** — Inicialización, apertura, bloqueo y destrucción de la instancia principal del SDK; gestión del estado de sesión.
4. **[OID4VCI](04-flows/02-oid4vci.md)** — Flujo de recepción de credenciales: el punto de entrada más frecuente para una integración real.
5. **[OID4VP](04-flows/03-oid4vp.md)** — Presentación a verifiers, incluido el perfil EUDI (DCQL + JARM) usado por `verifier.eudiw.dev`.

Una vez completados esos documentos, tendrás el contexto suficiente para explorar el resto de la documentación según las necesidades concretas de tu wallet.
