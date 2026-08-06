# Cómo usamos `identity_core_dart` en Quark Wallet

Documento **interno** de Phinx / QuarkID: integración real del SDK en la app Flutter **Quark Wallet** (`quark-wallet/`): Riverpod, rutas, flujos modales y convenciones.

- API del paquete de forma **genérica** (holder Dart): [guia-integracion.md](./guia-integracion.md)
- Issuer / verifier en **Node**: [guia-integracion-oid4vc.md](./guia-integracion-oid4vc.md)

---

## Rol del SDK en la app

`identity_core_dart` es la única capa que habla con Credo/SSI en el dispositivo. La app Flutter:

- Crea y desbloquea la wallet con [WalletService].
- Mantiene una sola [WalletSession] activa mientras el usuario está en [WalletUnlocked].
- Enruta ofertas OID4VCI, solicitudes OID4VP e invitaciones DIDComm a pantallas dedicadas.
- Lista credenciales, conexiones y actividad con streams del SDK.

No hay issuer ni verifier embebidos: el wallet es **solo holder**.

---

## Dependencia

Definida en [quark-wallet/pubspec.yaml](../../quark-wallet/pubspec.yaml):

```yaml
identity_core_dart:
  path: ../packages/identity-core-dart
```

El checkout del repo debe incluir `packages/identity-core-dart` para que `flutter pub get` resuelva el path.

---

## Ciclo de vida: `WalletNotifier` y `WalletState`

Archivo central: [quark-wallet/lib/core/providers/wallet_notifier.dart](../../quark-wallet/lib/core/providers/wallet_notifier.dart).

| Pieza | Responsabilidad |
|---|---|
| `FlutterSecureStorage` | Guarda solo la **clave** `wallet_salt_<walletId>` para saber si la wallet ya fue creada (no guarda el PIN). |
| `getApplicationDocumentsDirectory()` | Directorio estable donde `WalletService` persiste KMS + wallet cifrados. |
| `WalletService` | `create`, `unlock`, `lock` (vía sesión), `reset`. |
| `walletNotifierProvider` | `AsyncNotifierProvider` → `AsyncValue<WalletState>`. |

Estados ([wallet_state.dart](../../quark-wallet/lib/core/wallet_state.dart)):

- **WalletNotConfigured**: no hay salt en disco → onboarding hasta `create(pin)`.
- **WalletLocked**: hay wallet pero sesión cerrada → `/authenticate` (PIN); `WrongPinError` se traduce a `WalletLocked(error: ...)`.
- **WalletUnlocked**: contiene `WalletSession session` → toda feature que necesite el SDK debe leer este estado.

`WalletNotifier.session` obtiene la sesión o lanza `WalletLockedError` si el usuario no está desbloqueado (útil en notifiers que no quieren repetir el `if`).

**Constantes de producto:**

- `walletId`: siempre `'default'` (una wallet por instalación).
- El PIN es el que el usuario define en onboarding; se pasa a `create` / `unlock` sin persistirse en texto claro.

---

## Router y sesión

[app_router.dart](../../quark-wallet/lib/core/router/app_router.dart) observa `walletNotifierProvider` y redirige:

- Sin wallet → `/onboarding`.
- Wallet bloqueada → `/authenticate` o `/pin-locked`.
- Desbloqueada → si estaba en splash/onboarding/auth, manda a `/home`.

Las rutas de flujo de protocolo son **absolutas** (no hijas de `/home`):

| Ruta | Pantalla | Query |
|---|---|---|
| `/notifications/oid4vci` | `Oid4VciNotificationScreen` | `url` obligatorio (URI de oferta, codificado) |
| `/notifications/oid4vp` | `Oid4VpNotificationScreen` | idem |
| `/notifications/didcomm` | `DidCommNotificationScreen` | idem |

El prefijo `/notifications/` es histórico y estable para deep links; el código vive en `lib/features/protocol_flows/`.

---

## Riverpod: datos que salen de la sesión

Todos los `StreamProvider` siguen el mismo patrón: si `walletNotifierProvider` no está en `WalletUnlocked`, emiten `Stream.empty()`.

| Provider | Archivo | API del SDK |
|---|---|---|
| `credentialsProvider` | `features/credentials/providers/credentials_provider.dart` | `session.credentialStore.watch()` |
| `inboxProvider` | `features/inbox/providers/inbox_provider.dart` | `session.didcomm.connections` |
| `activityProvider` | `features/activity/providers/activity_provider.dart` | `session.activityStore.watch()` |

Borrado de credencial (detalle): `session.credentialStore.delete(id)` tras confirmación en UI.

---

## Flujos OID4VCI, OID4VP y DIDComm

Código bajo [quark-wallet/lib/features/protocol_flows/](../../quark-wallet/lib/features/protocol_flows/).

Cada flujo usa un **`FamilyAsyncNotifier<..., String>`** donde el parámetro de familia es la **URL cruda** (la misma cadena que viene en `?url=`). Así hay una instancia de notifier por oferta o por request, sin mezclar estado entre deep links distintos.

### OID4VCI

Archivo: `oid4vci/providers/oid4vci_provider.dart`.

1. `build(url)` → `session.invitation.resolve(url)` → solo `Oid4VciInvitationResult` continúa; resto → estado de error en UI.
2. Usuario confirma emisor → `confirmIssuer()` → estado vista previa.
3. `accept(txCode: ...)` → si el flujo es pre-auth con TX code y falta código, pasa a estado intermedio para pedirlo; si no, `session.openid4vci.acquireCredentials(resolvedOffer:, txCode:)`.
4. Éxito → lista de `CredentialRecord` en estado final.

### OID4VP

Archivo: `oid4vp/providers/oid4vp_provider.dart`.

1. `build(url)` → `session.openid4vp.resolve(url)`; si `!submission.areAllSatisfied` → error “no tenés las credenciales…”.
2. `confirmVerifier()` → construye mapas por defecto de credencial elegida y claims a revelar por `inputDescriptorId`.
3. `share()` → `session.openid4vp.shareCredentials(...)`; interpreta `result.success` y `result.error`.

### DIDComm

Archivo: `didcomm/providers/didcomm_provider.dart`.

1. `build(url)` → `invitation.resolve` → `DidCommInvitationResult` con `invitation` (mapa) y `DidCommFlowType`.
2. `acceptConnection()` → `session.didcomm.acceptInvitation(invitation)` → `ConnectionRecord`.

---

## Entrada: escáner y deep links

**QR** ([scan_screen.dart](../../quark-wallet/lib/features/scan/scan_screen.dart)): `InvitationParser.detectType(raw)` decide a qué ruta ir; el valor del QR se pasa como `Uri.encodeComponent` en `url`.

**Sistema** ([app_links_handler.dart](../../quark-wallet/lib/core/app_links_handler.dart)): enlaces OID4VCI y OID4VP hacen `push` a las mismas rutas con `url` codificado. DIDComm por app link puede añadirse allí si se define el esquema en Android/iOS.

**Arranque** ([main.dart](../../quark-wallet/lib/main.dart)): `AppLinksHandler` se crea con el mismo `GoRouter` que `MaterialApp.router` y vive en el `State` de `QuarkWalletApp`.

---

## UI transversal

Las pantallas de auth, onboarding y flujos de protocolo comparten padding, botones, snackbars y piezas de flujo vía el barrel [quark_shared.dart](../../quark-wallet/lib/shared/quark_shared.dart) (`import 'package:quark_wallet/shared/quark_shared.dart';`). No forma parte del SDK; solo evita duplicar UI.

---

## Convenciones de equipo

- Un solo import del SDK: `package:identity_core_dart/identity_core.dart`.
- No exponer `WalletSession` en widgets de forma suelta: preferir `ref.watch(walletNotifierProvider)` o providers derivados.
- Errores de red o del issuer: se muestran como string en estados de error de los notifiers de flujo; en unlock de wallet, `WrongPinError` tiene tratamiento dedicado.
- Cuerpos HTTP de servicios de identidad: [postman-bodies.md](./postman-bodies.md).

---

## Resumen de archivos

| Ruta en `quark-wallet/lib/` | Uso de Identity Core |
|---|---|
| `core/providers/wallet_notifier.dart` | Creación, unlock, lock, reset; acceso `session`. |
| `core/wallet_state.dart` | `WalletUnlocked` porta `WalletSession`. |
| `core/app_links_handler.dart` | Navegación a flujos con `url`. |
| `features/protocol_flows/**/providers/*.dart` | OID4VCI, OID4VP, DIDComm. |
| `features/credentials/providers/credentials_provider.dart` | Credenciales. |
| `features/inbox/providers/inbox_provider.dart` | Conexiones. |
| `features/activity/providers/activity_provider.dart` | Actividad. |
| `features/scan/scan_screen.dart` | `InvitationParser`. |

Más contexto de producto y comandos: [quark-wallet/README.md](../../quark-wallet/README.md).
