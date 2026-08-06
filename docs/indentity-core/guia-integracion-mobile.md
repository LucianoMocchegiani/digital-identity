# Guía de integración OID4VC con `identity_core_dart`

Cómo integrar un **holder** (wallet) en **Dart / Flutter** usando el paquete `identity_core_dart`: resolución de ofertas y solicitudes, emisión OID4VCI, presentación OID4VP y aceptación de invitaciones DIDComm.

Para **issuer y verifier en Node** con `@quarkid/identity-core`, ver [guia-libreria.md](./guia-libreria.md). REST de servicios de identidad: [api-tenants-y-records.md](./api-tenants-y-records.md).

> En el ecosistema QuarkID 2.0, `identity_core_dart` es el SDK nativo Dart sobre la misma base conceptual que `@quarkid/identity-core`; la persistencia del holder suele ser **local** (directorio de la app + PIN), no Postgres del `quark-holder-service`.

Implementación de referencia en producto (Quark Wallet): [quark-wallet-uso-identity-core-dart.md](./quark-wallet-uso-identity-core-dart.md).

---

## Requisitos

- Dart ≥ 3.3 y Flutter ≥ 3.19 (si la app es Flutter)
- Acceso de red desde el dispositivo o emulador a los **issuers** y **verifiers** HTTP (URLs `https` o `http` en laboratorio, según política del SDK)

---

## Dependencia

En el `pubspec.yaml` del proyecto:

```yaml
dependencies:
  identity_core_dart:
    path: ../packages/identity-core-dart   # o la ruta Git/pub que corresponda
```

Import único típico:

```dart
import 'package:identity_core_dart/identity_core.dart';
```

---

## Wallet y sesión

### 1. Crear o desbloquear la wallet

El punto de entrada es [WalletService]: crea el almacén cifrado en un directorio de la app y deriva claves con un **PIN** (y opcionalmente bloquea la sesión al salir).

```dart
final service = WalletService();

// Primer arranque: crea wallet en disco
final session = await service.create(
  walletId: 'default',
  pin: pin6Digitos,
  directory: appDocumentsPath,
);

// Arranques posteriores
final session = await service.unlock(
  walletId: 'default',
  pin: pin6Digitos,
  directory: appDocumentsPath,
);

await session.lock();           // cifra y cierra sesión en memoria
await service.reset(walletId: 'default', directory: appDocumentsPath); // borra datos
```

Una vez obtenido [WalletSession], el resto de los flujos OID4VC se ejecutan **sobre esa sesión** (no hace falta Express ni WebSocket en el holder).

### 2. Servicios expuestos en la sesión

| Miembro | Rol |
|---|---|
| `session.invitation` | Resolver una **URL** (oferta OID4VCI, solicitud OID4VP o invitación DIDComm) y obtener un resultado discriminado. |
| `session.openid4vci` | Adquirir credenciales a partir de una oferta ya resuelta. |
| `session.openid4vp` | Resolver solicitudes de presentación y enviar la respuesta al verifier. |
| `session.didcomm` | Aceptar invitaciones out-of-band y persistir conexiones. |
| `session.credentialStore` | Listar, observar y borrar [CredentialRecord] en el wallet. |

---

## Clasificar URIs (QR o portapapeles)

Para decidir **qué pantalla** abrir antes de llamar a `invitation.resolve`, se puede usar el parser del SDK:

```dart
final raw = qrOrDeepLinkString;
final type = InvitationParser.detectType(raw);
switch (type) {
  case InvitationType.openid4vciOffer:
    // navegar a flujo OID4VCI con ?url=...
  case InvitationType.openid4vpRequest:
    // navegar a flujo OID4VP
  case InvitationType.didcommInvitation:
    // navegar a flujo DIDComm
  case null:
    // QR no reconocido
}
```

El URI completo debe pasarse luego a `resolve` (idealmente codificado en query si se usa enrutamiento web/deep link).

---

## OID4VCI (recibir credencial)

### 1. Resolver la oferta

```dart
final result = await session.invitation.resolve(offerUrlString);
switch (result) {
  case Oid4VciInvitationResult(:final offer):
    // offer: ResolvedCredentialOffer — metadata del issuer, display, flujo (pre-auth, tx_code, etc.)
  case InvitationErrorResult(:final message):
    // error de red o formato
  default:
    // URL no es una oferta OID4VCI
}
```

### 2. Adquirir credenciales

Cuando el usuario confirma en UI (y, si aplica, ingresa el **transaction code** para `Oid4VciFlow.preAuthWithTxCode`):

```dart
final result = await session.openid4vci.acquireCredentials(
  resolvedOffer: offer,
  txCode: codigoOpcional, // null si el flujo no lo exige
);
// result.credentials — lista de CredentialRecord persistidas
```

Flujo interno equivalente al de Node: resolución de metadata del issuer, token pre-autorizado, solicitud de credencial con key binding del holder y almacenamiento local.

---

## OID4VP (presentar credencial)

### 1. Resolver la solicitud

```dart
final request = await session.openid4vp.resolveRequest(requestUrlString);
// request: CredentialsForRequest — incluye submission con requisitos y credenciales candidatas

if (!request.submission.areAllSatisfied) {
  // el wallet no puede cumplir el pedido (faltan credenciales o formato)
}
```

### 2. Enviar la presentación

Tras que el usuario elija credencial y qué claims revelar (selective disclosure), según lo que exponga el modelo `submission`:

```dart
final result = await session.openid4vp.shareCredentials(
  resolvedRequest: request,
  selectedCredentials: {
    // inputDescriptorId -> id de CredentialRecord elegida
  },
  selectedDisclosures: {
    // inputDescriptorId -> lista de rutas de claims a revelar
  },
);

if (result.success) {
  // presentación aceptada
} else {
  // result.error — mensaje del verifier o capa HTTP
}
```

---

## DIDComm (invitación OOB)

### 1. Resolver

```dart
final result = await session.invitation.resolve(invitationUrlString);
switch (result) {
  case DidCommInvitationResult(:final invitation, :final flowType):
    // invitation: Map JSON; flowType: DidCommFlowType (emisión, verificación, conexión, etc.)
  case InvitationErrorResult(:final message):
    // ...
  default:
    // no es DIDComm
}
```

### 2. Aceptar conexión

```dart
final connection = await session.didcomm.acceptInvitation(invitation);
// connection: ConnectionRecord — etiqueta, DIDs, etc.
```

---

## Credenciales en el wallet

```dart
// Stream reactivo (p. ej. ListView en Flutter)
session.credentialStore.watch();

// Borrado por id
await session.credentialStore.delete(credentialId);
```

Los registros [CredentialRecord] son los que alimentan listas, detalle y la lógica de matching en OID4VP.

---

## Flujo completo (referencia)

```
Issuer (Node)                    Holder (Dart)                    Verifier (Node)
    │                                 │                                 │
    │  oferta SD-JWT / URI            │                                 │
    │────────────────────────────────►│ invitation.resolve +          │
    │                                 │ openid4vci.acquireCredentials   │
    │◀──────── HTTP OID4VCI ─────────│                                 │
    │                                 │ CredentialRecord en disco       │
    │                                 │                                 │
    │                                 │         solicitud OID4VP (URI)  │
    │                                 │◄────────────────────────────────│
    │                                 │ openid4vp.resolveRequest        │
    │                                 │ openid4vp.shareCredentials      │
    │                                 │────────────────────────────────►│
    │                                 │                                 │
```

DIDComm encaja en el mismo holder: `resolve` → si es DIDComm → `acceptInvitation` sin pasar por HTTP propio del dispositivo como servidor.

---

## Parámetros de entorno (holder móvil)

En **servidor Node**, las variables típicas son `BASE_URL`, `WALLET_DB`, etc. En **Dart**, el equivalente práctico es:

| Concepto | Dónde vive | Notas |
|---|---|---|
| Directorio de datos | `path_provider` + carpeta de documentos | Debe ser estable entre arranques. |
| PIN / biometría | UI + almacenamiento seguro opcional | El SDK recibe el PIN en `create` / `unlock`. |
| URLs de issuers/verifiers | Oferta o request embebidos en el QR/link | Deben ser alcanzables desde el dispositivo (cuidado con `localhost` vs IP de la máquina host). |

---

## Errores comunes

| Síntoma | Causa probable | Qué revisar |
|---|---|---|
| `InvitationErrorResult` al resolver | URL mal formada, red, o issuer inalcanzable. | Copiar el URI completo; en emulador Android usar `10.0.2.2` en vez de `localhost` hacia el host. |
| OID4VCI cae tras `acquireCredentials` | `tx_code` requerido y no enviado, o issuer rechaza el pedido. | Inspeccionar `ResolvedCredentialOffer.flow` y pasar `txCode` cuando corresponda. |
| `areAllSatisfied == false` en OID4VP | No hay credencial con el `vct` / formato pedido. | Emitir primero la credencial correcta; revisar el request del verifier (DCQL o definición equivalente). |
| `shareCredentials` con `success: false` | Verificador rechaza el VP (claims insuficientes, firma, etc.). | `result.error` y logs del verifier en Node. |
| Resolver devuelve tipo “equivocado” | Misma cadena interpretada como otro protocolo. | Usar `InvitationParser.detectType` solo para UX; la fuente de verdad del protocolo sigue siendo `invitation.resolve`. |

---

## Referencia en repo

La app **Quark Wallet** (`quark-wallet/`) implementa estos pasos con Riverpod; el desglose de archivos y rutas está en [quark-wallet-uso-identity-core-dart.md](./quark-wallet-uso-identity-core-dart.md).

Los cuerpos JSON de emisión y verificación **desde servicios HTTP** (no desde Dart) siguen documentados en [postman-bodies.md](./postman-bodies.md).
