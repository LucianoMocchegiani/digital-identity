# Identity Wallet

Wallet móvil en Flutter para Identidad Auto-Soberana (SSI). Permite recibir, almacenar y presentar credenciales verificables usando los protocolos OpenID4VCI, OpenID4VP y DIDComm.

Construido sobre [`identity_core_dart`](../packages/identity-core-dart) — el SDK SSI nativo de Identity para Dart/Flutter.

## Funcionalidades

- Recibir credenciales por QR o deep link (OID4VCI)
- Presentar credenciales a verificadores con selective disclosure (OID4VP)
- Conexiones DIDComm, intercambio de credenciales y pruebas
- Desbloqueo de wallet por biometría y PIN
- Historial de actividad (emisiones y presentaciones)
- UI Material 3 con gestión de estado Riverpod

## Requisitos

- Flutter ≥ 3.19.0
- Dart ≥ 3.3.0
- Android ≥ 6.0 (API 23) o iOS ≥ 13

## Inicio

### 1. Clonar con submódulos

```sh
git clone --recurse-submodules <repo-url>
cd digital-identity
```

### 2. Instalar dependencias Flutter

```sh
cd identity-wallet
flutter pub get
```

### 3. Ejecutar

```sh
flutter run
```

Para un dispositivo específico:

```sh
flutter run -d <device-id>
```

## Deep linking

La app traduce enlaces entrantes (desde el SO o desde el escáner interno) a rutas de [go_router](lib/core/router/app_router.dart). El URI original se pasa codificado en el query `url`.

| Protocolo | Esquemas / heurística típica | Ruta en la app |
|-----------|-----------------------------|----------------|
| OID4VCI | `openid-credential-offer://`, o `https` con ruta que contiene `credential_offer` | `/notifications/oid4vci?url=...` |
| OID4VP | `openid4vp://`, `openid-vp://`, `openid://`, o `https` con `authorize` o `request_uri` en query | `/notifications/oid4vp?url=...` |
| DIDComm | `didcomm://` (p. ej. desde QR en [scan](lib/features/scan/scan_screen.dart)) | `/notifications/didcomm?url=...` |

[AppLinksHandler](lib/core/app_links_handler.dart) enruta hoy OID4VCI y OID4VP desde el sistema; DIDComm suele entrar por QR. Configurar dominio asociado / app link en `android/app/src/main/AndroidManifest.xml` e `ios/Runner/Info.plist` según el entorno.

## Estructura del proyecto

```
lib/
├── main.dart                    Punto de entrada (Riverpod ProviderScope, AppLinksHandler)
├── shared/                      UI y utilidades transversales entre features
│   ├── identity_shared.dart        Barrel: un solo import para extensions, theme, layout, utils y widgets de flujo
│   ├── extensions/              p. ej. popOrGo / popOrGoHome sobre BuildContext
│   ├── layout/                  Padding común auth/onboarding
│   ├── theme/                   Estilos de botón, extensiones de TextTheme (títulos), tema PIN compartido
│   ├── utils/                   Snackbars de app
│   └── widgets/                 Flujos (error, progreso, éxito), AppBar con pasos, fila cancelar+primario, PIN 6 dígitos, logo remoto
├── core/
│   ├── router/                  go_router, redirect según WalletState
│   ├── providers/               Riverpod global (sesión de wallet)
│   ├── app_links_handler.dart   Deep links → push a rutas de notificación
│   ├── wallet_state.dart        Ciclo de vida de la wallet
│   └── theme/                   Tokens Material 3 de la app
└── features/
    ├── auth/                    Desbloqueo (biometría + PIN), pantalla PIN bloqueado
    ├── onboarding/              Primer uso: bienvenida, PIN, biometría opcional, datos
    ├── home/                    Dashboard y accesos rápidos
    ├── credentials/             Lista, detalle y borrado de credenciales
    ├── scan/                    QR: clasifica URI y abre el flujo correspondiente
    ├── protocol_flows/          Flujos modales OID4VCI, OID4VP y DIDComm (pantallas contenedor, providers, slides)
    ├── inbox/                   Conexiones DIDComm
    ├── activity/                Historial de emisiones y presentaciones
    └── menu/                    Menú, ajustes, acerca de, reset de wallet
```

Las pantallas contenedor de `protocol_flows` se registran bajo el prefijo de ruta **`/notifications/`** (compatibilidad con enlaces y documentación existente); el código fuente vive en `features/protocol_flows/`, no en una carpeta homónima al path.

## Código compartido (`shared`)

Desde features se recomienda un único import del barrel:

```dart
import 'package:identity_wallet/shared/identity_shared.dart';
```

Ahí se reexportan extensiones de navegación, `kAuthOnboardingScreenPadding`, estilos de botón y títulos (`identityPageTitle`, `identityHeroTitle`), snackbars, vistas de flujo (carga, error, éxito), `FlowStepAppBar`, `FlowActionRow`, `NetworkLogoOrPlaceholder`, `AppSixDigitPin`, etc. Algunos widgets internos de `shared` pueden seguir importando un archivo concreto (p. ej. tema PIN) para evitar dependencias circulares.

## Arquitectura

| Capa | Tecnología |
|------|-----------|
| Gestión de estado | Riverpod (`flutter_riverpod`) |
| Navegación | go_router |
| Protocolos SSI | `identity_core_dart` (SDK local) |
| Almacenamiento | Isar (cifrado) vía SDK |
| Cámara / QR | `mobile_scanner` |
| Biometría | `local_auth` |
| Deep linking | `app_links` |
| UI transversal | `lib/shared` + barrel `identity_shared.dart` |

Flujo típico:

```
Pantalla UI → Riverpod Notifier → identity_core_dart → Isar / red
```

Cada feature tiene subdirectorios `providers/`, `screens/` y, cuando aplica, `widgets/` o `slides/`. El estado compartido entre features (sesión de wallet, credenciales) vive en `core/providers/`.

## Análisis estático

```sh
dart analyze lib
```

## Tests

```sh
flutter test
```

## Publicación en stores

Backlog Play Store / App Store (dev + tramiterío): [`docs/kuatia/backlog-wallet-stores.md`](../docs/kuatia/backlog-wallet-stores.md).

## Licencia

Privado — FleetStudio / Phinx
