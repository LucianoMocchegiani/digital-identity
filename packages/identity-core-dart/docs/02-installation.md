---
id: installation
title: Instalación y configuración
sidebar_position: 2
---

# Instalación y configuración

Esta guía cubre todo lo necesario para agregar `identity_core_dart` a una app Flutter existente (como bax) y dejarla lista para operar con el SDK.

---

## 1. Requisitos

| Componente | Versión mínima | Fuente |
|---|---|---|
| Dart SDK | `>=3.0.0 <4.0.0` | `pubspec.yaml` |
| Flutter | `>=3.10.0` | `pubspec.yaml` |
| Android `minSdk` | **23** | `android/build.gradle` del paquete |
| Android `compileSdk` | 34 | `android/build.gradle` del paquete |
| Kotlin | 1.9.0 | `android/build.gradle` del paquete |
| iOS | **13.0** | `ios/identity_core_dart.podspec` |
| Swift | 5.9 | `ios/identity_core_dart.podspec` |

> **isar_flutter_libs** — la base de datos embebida del SDK — impone sus propios requisitos nativos. Al actualizar la versión de `isar_flutter_libs`, verificá que los requisitos nativos de la nueva versión no superen los de esta tabla.

---

## 2. Instalación como git dependency

El paquete reside en un repositorio Bitbucket privado y **no está publicado en pub.dev**. La vía oficial para bax es una git dependency.

### 2.1 Git dependency (producción / integración)

Agregá la siguiente entrada en el `pubspec.yaml` de la app consumidora:

```yaml
dependencies:
  identity_core_dart:
    git:
      url: https://bitbucket.org/fleetstudio/quarkid-identity-core-dart.git
      ref: main
```

Luego ejecutá:

```bash
flutter pub get
```

> **Repositorio privado** — bax necesita que el equipo de Phinx le otorgue acceso de lectura al repo antes de poder clonar la dependencia. Comunicarse con el equipo para solicitar el permiso correspondiente.

### 2.2 Path dependency (desarrollo local)

Si necesitás iterar sobre el SDK localmente (por ejemplo, para debuggear o probar cambios antes de hacer push), usá una path dependency:

```yaml
dependencies:
  identity_core_dart:
    path: ../identity-core-dart   # ajustar ruta relativa según la estructura del workspace
```

> **Advertencia** — Las path dependencies no funcionan en CI/CD ni para otros devs sin la misma estructura local. No commitear el `pubspec.yaml` con `path:`.

### 2.3 pub.dev

El paquete **no está disponible en pub.dev** aún. No usar `identity_core_dart: ^0.1.0` directo en el pubspec.

---

## 3. Dependencias transitivas relevantes

El SDK trae las siguientes dependencias que tienen impacto en la configuración nativa o en el bundle final:

| Paquete | Versión | Rol |
|---|---|---|
| `isar` + `isar_flutter_libs` | `^3.1.0` | Base de datos embebida; cifrado por campo en campos sensibles (archivo `.isar` sin cifrar — ver [Limitaciones](07-limitations.md)) |
| `flutter_secure_storage` | `^9.0.0` | Almacena el salt del PIN fuera de isar (Keychain/Keystore) |
| `cryptography` | `^2.7.0` | Primitivas criptográficas: Argon2id (derivación de clave del PIN), Ed25519, ECDSA P-256 |
| `pointycastle` | `^3.7.0` | Soporte criptográfico adicional (X.509, ASN.1) |
| `dio` | `^5.4.0` | Cliente HTTP para endpoints OID4VCI, OID4VP y resolución `did:web` |
| `dart_jsonwebtoken` | `^2.7.0` | Construcción y validación de JWT/JWS |
| `freezed_annotation` + `json_annotation` | `^2.4.0` / `^4.9.0` | Modelos inmutables y serialización JSON |

> **Build runner no requerido** — los archivos generados (`.g.dart`, `.freezed.dart`) están commiteados en el repositorio del SDK. El consumidor **no necesita ejecutar** `dart run build_runner build`.

---

## 4. Configuración Android

### 4.1 minSdk

En el `android/app/build.gradle` de la app consumidora (no del SDK), asegurate de declarar `minSdk` en 23 o superior:

```groovy
android {
    defaultConfig {
        minSdkVersion 23   // requerido por isar_flutter_libs
        // ...
    }
}
```

### 4.2 flutter_secure_storage

`flutter_secure_storage ^9.0.0` requiere `minSdk 18`. Como el SDK ya exige 23, este requisito queda cubierto automáticamente. No se necesita configuración adicional de Keystore.

---

## 5. Configuración iOS

### 5.1 Keychain (flutter_secure_storage)

`flutter_secure_storage` usa Keychain de iOS para persistir el salt del PIN. En la mayoría de las apps Flutter, **no se requieren entitlements adicionales** — el Keychain por defecto del app target es suficiente.

Si la app usa App Groups o comparte datos entre extensiones, revisá la documentación de `flutter_secure_storage` sobre configuración de grupos de Keychain.

### 5.2 Deployment target

El `.podspec` del SDK declara plataforma iOS `13.0`. Asegurate de que el `ios/Podfile` de la app consumidora no declare un deployment target inferior:

```ruby
platform :ios, '13.0'
```

---

## 6. Verificación de la instalación

Una vez completada la configuración, verificá que el SDK esté correctamente integrado con el siguiente snippet mínimo en la app:

```dart
import 'package:identity_core_dart/identity_core.dart';

// Creación del servicio principal — sin argumentos en el constructor.
final walletService = WalletService();
```

Si el import resuelve y el proyecto compila sin errores, el SDK está correctamente instalado.

La verificación real es compilar y correr en un device o emulador:

```bash
flutter run
# o bien
flutter build apk --debug
```

Señales de problema: errores de link de librerías nativas de Isar al arrancar, o crash al importar el paquete. En ese caso, revisá que `minSdkVersion` sea 23 o superior y que `isar_flutter_libs` esté incluido en las dependencias transitivas.

> La inicialización completa del wallet (crear, desbloquear, configurar DID) se cubre en [Ciclo de vida del wallet](03-wallet-lifecycle.md).

---

## 7. Deep links / App links

> **Opcional en la integración inicial** — esta sección es necesaria solo cuando la app procese invitaciones por deep link. Podés omitirla en una primera integración y volver cuando la app deba recibir URLs externas.

El SDK procesa URLs de invitación a través de `InvitationParser.detectType()` y `InvitationResolver`. Para que el sistema operativo enrute los links entrantes a la app, **la app consumidora es responsable de registrar los esquemas** en su propio `AndroidManifest.xml` e `Info.plist`.

### 7.1 Esquemas reconocidos por el SDK

`InvitationParser.detectType()` reconoce los siguientes esquemas de forma nativa (sin red):

| Esquema | Protocolo |
|---|---|
| `openid-credential-offer://` | OID4VCI — oferta de credencial |
| `openid-initiate-issuance://` | OID4VCI — emisión iniciada por issuer (legacy) |
| `haip-vci://` | OID4VCI — perfil HAIP / EUDI Wallet |
| `openid4vp://` | OID4VP — solicitud de presentación |
| `eudi-openid4vp://` | OID4VP — perfil EUDI Wallet |
| `mdoc-openid4vp://` | OID4VP — perfil mDoc (ISO 18013-7) |
| `haip://` | OID4VP — perfil HAIP |
| `didcomm://` | DIDComm — invitación out-of-band |

Adicionalmente, URLs `https://` son reconocidas si contienen los query params `credential_offer`, `credential_offer_uri`, `request_uri`, `request`, `presentation_definition`, `oob`, `c_i` o `_oobid`.

### 7.2 Registro Android (`AndroidManifest.xml`)

El ejemplo a continuación cubre los 5 esquemas más comunes. Los esquemas `mdoc-openid4vp` y `haip` siguen exactamente el mismo patrón: agregá un `intent-filter` adicional con el `android:scheme` correspondiente si la app necesita esos perfiles.

Dentro de la actividad principal de la app, agregá un `intent-filter` por cada esquema que la app deba recibir:

```xml
<!-- OID4VCI — oferta de credencial -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="openid-credential-offer" />
</intent-filter>

<!-- OID4VCI — legacy -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="openid-initiate-issuance" />
</intent-filter>

<!-- OID4VP -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="openid4vp" />
</intent-filter>

<!-- OID4VP — EUDI Wallet -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="eudi-openid4vp" />
</intent-filter>

<!-- DIDComm -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="didcomm" />
</intent-filter>
```

### 7.3 Registro iOS (`Info.plist`)

Agregá un array `CFBundleURLTypes` con los esquemas correspondientes:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>openid-credential-offer</string>
            <string>openid-initiate-issuance</string>
            <string>openid4vp</string>
            <string>eudi-openid4vp</string>
            <string>mdoc-openid4vp</string>
            <string>haip</string>
            <string>didcomm</string>
        </array>
    </dict>
</array>
```

### 7.4 Responsabilidad de la app vs. el SDK

El registro de esquemas y la captura del link entrante (usando paquetes como `app_links` o `uni_links`) son responsabilidad de la app consumidora. Una vez obtenida la URL, la app se la pasa al SDK mediante `InvitationResolver`, que realiza la resolución del payload. Ver [Flujo de invitaciones](04-flows/01-invitations.md) para el detalle completo.

---

## Ver también

- [Visión general del SDK](01-overview.md) — arquitectura y capacidades
- [Ciclo de vida del wallet](03-wallet-lifecycle.md) — creación e inicialización
- [Flujo de invitaciones](04-flows/01-invitations.md) — procesamiento de deep links con `InvitationResolver`
- [Limitaciones conocidas](07-limitations.md) — restricciones actuales del SDK
