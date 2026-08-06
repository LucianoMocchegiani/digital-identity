# identity_core_dart

SDK holder de QuarkID para Flutter — implementación nativa en Dart de protocolos de Identidad Auto-Soberana (SSI). Permite que una wallet reciba y presente credenciales verificables, administre DIDs y claves criptográficas, y se comunique con agentes Credo (Quark issuer/verifier) vía **DIDComm v1** (envelope Authcrypt compatible), todo desde almacenamiento local embebido.

> **Distribución privada.** El paquete se consume vía git dependency desde el repositorio Bitbucket de FleetStudio. No está publicado en pub.dev.

---

## Capacidades

| Capacidad | Estado | Notas |
|-----------|--------|-------|
| OID4VCI — pre-auth (con y sin txCode) | ✅ Completo | |
| OID4VCI — authorization code flow | ✅ Completo | |
| OID4VCI — credenciales diferidas | ✅ Completo | `retryDeferred` parcial: no persiste la credencial (el caller debe re-procesar) |
| OID4VP — matching PEX + selective disclosure | ✅ Completo | |
| OID4VP — holder binding | ✅ Completo | |
| DIDs locales (did:key, did:jwk, did:peer) | ✅ Completo | API de bajo nivel |
| Resolución did:web | ✅ Completo | |
| Framework de trust (DID, X.509, EUDI RP) | ✅ Completo | Verificación de firmas con limitaciones — ver docs |
| DIDComm — emisión / verificación con Quark | ✅ Funcional | Handshake + `DidCommFlowSession` (WS) + Envelope V1; ver [limitaciones](docs/07-limitations.md) |
| Hardware KMS (Android Keystore / iOS Secure Enclave) | ⚠️ Parcial | Solo P-256; Ed25519 usa backend de software |
| Almacenamiento local Isar | ⚠️ Parcial | Cifrado por campo `enc:v1:` en claves y credenciales; archivo `.isar` sin cifrar; validación PIN por hash |
| mDoc ISO 18013-5 | ⏳ Pendiente | Modelo de datos presente; parsing CBOR sin implementar |
| Backup / recovery de wallet | ❌ No implementado | |

Ver detalles completos en [Limitaciones](docs/07-limitations.md).

---

## Requisitos

- Dart ≥ 3.0.0 < 4.0.0
- Flutter ≥ 3.10.0
- Android `minSdk` 23
- iOS 13+

---

## Instalación

Agregar en `pubspec.yaml` (repo privado — requiere acceso a Bitbucket):

```yaml
dependencies:
  identity_core_dart:
    git:
      url: https://bitbucket.org/fleetstudio/quarkid-identity-core-dart.git
      ref: main
# Nota: para builds reproducibles conviene fijar un tag o commit en `ref:`.
```

Ver configuración completa de dependencias nativas Android/iOS y deep links en [docs/02-installation.md](docs/02-installation.md).

---

## Inicio rápido

```dart
import 'package:identity_core_dart/identity_core.dart';
import 'package:path_provider/path_provider.dart';

final dir = await getApplicationDocumentsDirectory();
final walletService = WalletService();

// Crear la wallet (primera vez) — para abrir una existente: walletService.unlock(...)
final session = await walletService.create(
  walletId: 'mi-wallet',
  pin: '123456',
  directory: dir.path,
);

// Recibir una credencial (OID4VCI)
final offer = await session.openid4vci.resolveOffer(offerUri);
await session.openid4vci.acquireCredentials(resolvedOffer: offer);

// Presentar credenciales (OID4VP)
final request = await session.openid4vp.resolveRequest(requestUri);
final result = await session.openid4vp.shareCredentials(
  resolvedRequest: request,
  selectedCredentials: {'descriptor-id': 'credential-id'},
  selectedDisclosures: <String, List<String>>{}, // vacío = revelar todos los claims
);
```

---

## Documentación

Índice completo: [docs/README.md](docs/README.md)

### Empezar

| Documento | |
|-----------|--|
| [Overview](docs/01-overview.md) | Arquitectura general, actores del ecosistema SSI y casos de uso soportados |
| [Instalación](docs/02-installation.md) | Git dependency, dependencias nativas Android/iOS y deep links |
| [Ciclo de vida de la wallet](docs/03-wallet-lifecycle.md) | Inicialización, apertura, bloqueo y destrucción de la wallet |

### Flujos

| Documento | |
|-----------|--|
| [Invitaciones](docs/04-flows/01-invitations.md) | Escaneo y enrutamiento de URLs de invitación |
| [OID4VCI — Recepción de credenciales](docs/04-flows/02-oid4vci.md) | Flujo completo de emisión desde un issuer |
| [OID4VP — Presentación de credenciales](docs/04-flows/03-oid4vp.md) | Flujo completo de presentación a un verifier |
| [DIDComm](docs/04-flows/04-didcomm.md) | Mensajería cifrada con agentes Credo (Quark) |

### Referencia

| Documento | |
|-----------|--|
| [Stores](docs/05-reference/01-stores.md) | Almacenamiento local: tipos de store y ciclo de vida de los datos |
| [Credenciales](docs/05-reference/02-credentials.md) | Modelo de datos, estados y operaciones sobre credenciales |
| [DIDs](docs/05-reference/03-dids.md) | Creación y resolución de DIDs, métodos soportados |
| [KMS](docs/05-reference/04-kms.md) | Gestión de claves: generación, almacenamiento y uso |
| [Trust](docs/05-reference/05-trust.md) | Trust registries, validación de issuers y políticas de aceptación |
| [Errores](docs/05-reference/06-errors.md) | Catálogo de excepciones, códigos de error y estrategias de manejo |

### Operación

| Documento | |
|-----------|--|
| [Troubleshooting](docs/06-troubleshooting.md) | Diagnóstico de errores de red, inicialización y compatibilidad nativa |
| [Limitaciones](docs/07-limitations.md) | Restricciones conocidas, funcionalidades no soportadas y consideraciones de seguridad |

---

## Generación de código

El paquete usa `build_runner` para los esquemas Isar y los modelos Freezed. Los archivos generados (`.g.dart`, `.freezed.dart`) se commitean al repositorio para que los consumidores no necesiten ejecutar la generación de código.

Para regenerar después de modificar modelos (solo mantenedores del paquete):

```sh
dart run build_runner build --delete-conflicting-outputs
```

---

## Licencia

Privado — FleetStudio / Phinx
