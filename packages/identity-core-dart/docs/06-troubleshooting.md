---
id: troubleshooting
title: Resolución de problemas
sidebar_position: 6
---

# Resolución de problemas

Esta guía cubre los problemas más frecuentes al integrar `identity_core_dart` en la wallet. Cada ítem sigue la estructura **Problema → Causa → Solución**.

---

### 1. El PIN incorrecto no rechaza el desbloqueo

**Problema.** La app llama a `WalletService.unlock()` con un PIN equivocado y la sesión se abre sin lanzar `WrongPinError`.

**Causas posibles.**

| Causa | Cómo detectarla |
|-------|-----------------|
| **Wallet legacy sin hash de PIN** | No existe `wallet_pin_hash_<walletId>` en secure storage (wallet creada antes de esta versión). `unlock()` abre sin validar PIN. |
| **Integración que evita `WalletService`** | Se usa `WalletSession.fromRecordStore()` sin pasar por `create`/`unlock` del servicio. |
| **App que no captura `WrongPinError`** | El SDK lanza el error pero la UI no lo muestra. |

**Solución.**

1. Usá siempre `WalletService.create()` y `WalletService.unlock()` — no abras la sesión saltando el servicio.
2. Capturá `WrongPinError` en `unlock()`:

   ```dart
   try {
     await walletService.unlock(walletId: id, pin: pin, directory: dir);
   } on WrongPinError {
     // mostrar error al usuario
   }
   ```

3. **Contador de intentos / bloqueo:** responsabilidad de la app; el SDK no bloquea tras N fallos.
4. **Wallet sin hash de PIN:** pedir `reset()` + onboarding para obtener validación de PIN y cifrado por campo en datos nuevos. Ver [Ciclo de vida — wallets legacy](03-wallet-lifecycle.md#wallets-creadas-antes-de-la-validación-por-hash).

---

### 2. `WalletAlreadyExistsError` en una app recién instalada (iOS)

**Problema.** La app fue desinstalada y vuelta a instalar en iOS. Al llamar a `WalletService.create()`, se lanza `WalletAlreadyExistsError` aunque no haya ningún dato de wallet visible.

**Causa.** En iOS, el Keychain **no se borra al desinstalar la app** por defecto. El salt del wallet (`wallet_salt_<walletId>`) almacenado mediante `flutter_secure_storage` sobrevive a la desinstalación. Los archivos Isar en el sistema de archivos sí se eliminan. Al reinstalar, `WalletService.create()` encuentra el salt en el Keychain y concluye que el wallet ya existe, lanzando el error.

**Solución.**

1. Al detectar `WalletAlreadyExistsError` en el flujo de onboarding, llamá a `WalletService.reset()` para limpiar el salt huérfano y los archivos Isar residuales:

   ```dart
   try {
     session = await walletService.create(
       walletId: walletId,
       pin: pin,
       directory: directory,
     );
   } on WalletAlreadyExistsError {
     // Salt huérfano de una instalación anterior — limpiar y reintentar.
     await walletService.reset(walletId: walletId, directory: directory);
     session = await walletService.create(
       walletId: walletId,
       pin: pin,
       directory: directory,
     );
   }
   ```

2. Informá al usuario que sus datos previos no están disponibles (la base de datos fue eliminada con la desinstalación) y que debe comenzar el flujo de onboarding desde cero.

> **Nota Android.** En Android, el Keystore se borra junto con la app al desinstalar. Este problema es exclusivo de iOS.

---

### 3. Errores de build en Android por `minSdk` insuficiente

**Problema.** Al compilar para Android, aparece un error similar a:

```
uses-sdk:minSdkVersion 21 cannot be smaller than version 23 declared in library
[:isar_flutter_libs]
```

o bien el build falla con mensajes de incompatibilidad de API nativa de Isar.

**Causa.** `isar_flutter_libs` requiere Android API level 23 como mínimo. Si el `android/app/build.gradle` de la app consumidora declara un `minSdkVersion` inferior, el merge del manifest falla.

**Solución.** En `android/app/build.gradle`, establecé `minSdkVersion` en 23 o superior:

```groovy
android {
    defaultConfig {
        minSdkVersion 23   // requerido por isar_flutter_libs
        // ...
    }
}
```

Ver la tabla de requisitos completa en [`02-installation.md`](02-installation.md#1-requisitos).

> **ProGuard / R8.** El paquete no incluye reglas de ProGuard propias. Si usás ProGuard/R8 en el build de release y encontrás problemas de ofuscación con las clases de Isar o `flutter_secure_storage`, consultá las reglas recomendadas en la documentación oficial de esos paquetes.

---

### 4. Deep links que no llegan a la app

**Problema.** El usuario escanea un QR o abre una URL desde el navegador y el SO no enruta el link a la wallet — la app no recibe la URL.

**Causa.** El registro de esquemas en `AndroidManifest.xml` (Android) o `Info.plist` (iOS) está ausente o incompleto. Los esquemas soportados por el SDK (`openid-credential-offer://`, `openid4vp://`, `didcomm://`, etc.) deben estar explícitamente declarados por la app consumidora; el SDK no los registra automáticamente.

**Diagnóstico en Android.**

Usá `adb` para disparar el intent manualmente y verificar si la app lo recibe:

```bash
adb shell am start \
  -a android.intent.action.VIEW \
  -d "openid-credential-offer://..." \
  com.tu.app/.MainActivity
```

Si el sistema responde con "No activity found to handle intent", el `intent-filter` está ausente o mal configurado.

**Diagnóstico en iOS.**

Desde Safari en el device, abrí la URL directamente. Si el sistema no pregunta "¿Abrir en [tu app]?" o no redirige, el esquema no está registrado en `CFBundleURLTypes`.

**Solución.** Seguí las instrucciones de configuración de deep links en [`02-installation.md`](02-installation.md#7-deep-links--app-links), que incluye los snippets completos de `AndroidManifest.xml` y `Info.plist` para todos los esquemas del SDK. Recordá que la **captura del link entrante es responsabilidad de la app** (usando paquetes como `app_links` o `uni_links`); el SDK solo procesa la URL una vez que la app la recibe.

---

### 5. `DioException` con backends de desarrollo (TLS self-signed / proxy)

**Problema.** Al conectarse a un issuer o verifier de desarrollo que usa un certificado TLS auto-firmado o un proxy de inspección, todas las llamadas HTTP fallan con `DioException` (handshake error o certificate verification failed).

**Causa.** La API pública del SDK — `WalletService` y `WalletSession.fromRecordStore` — **no expone ningún parámetro `Dio`**. `WalletSession.fromRecordStore` construye internamente las instancias de `Oid4VciService` y `Oid4VpService` sin dar acceso a ese parámetro, y `WalletService` tampoco lo acepta. Aunque los constructores internos de `Oid4VciService` y `Oid4VpService` sí declaran un parámetro `Dio? dio`, no son alcanzables por la vía pública.

Esto significa que **configurar TLS custom (certificados self-signed, anchoring personalizado, proxy de inspección) no es posible hoy a través de la API de alto nivel del SDK.**

**Lo que se puede hacer hoy.**

- En entornos de desarrollo con certificados válidos (Let's Encrypt u otra CA pública), no se requiere ninguna configuración adicional.
- Si el backend de desarrollo necesita TLS auto-firmado, la alternativa más práctica es configurar el server con un certificado de una CA de desarrollo de confianza (como [mkcert](https://github.com/FiloSottile/mkcert)) e instalarlo en el device/emulador como CA raíz de confianza del SO.
- Para inspección de tráfico HTTP con un proxy (Charles, mitmproxy, etc.), instalá el certificado del proxy como CA de confianza en el device/emulador; el SDK usará las CAs del sistema operativo automáticamente.

Esta es una limitación conocida. Ver [`07-limitations.md`](07-limitations.md) para el seguimiento de su resolución.

---

### 6. `WalletLockedError` inesperado

**Problema.** La wallet está desbloqueada pero al intentar acceder a los stores o servicios se lanza `WalletLockedError`.

**Causas frecuentes.**

1. **Referencia cacheada a una sesión vieja.** La app guardó la instancia de `WalletSession` en una variable y luego llamó a `WalletService.lock()` (o la sesión se bloqueó automáticamente). La referencia sigue apuntando a la sesión anterior, ya marcada como bloqueada.

2. **Acceso desde un contexto incorrecto.** Un widget o servicio accede al store antes de que el flujo de unlock haya completado.

**Solución.**

- **Nunca caches los stores ni los servicios individualmente.** Siempre obtenelos desde la `WalletSession` activa en el momento del uso.
- Mantené la referencia a la sesión en el controlador de tu app. La API pública no expone un getter de sesión activa; la sesión la devuelve `unlock()` o `create()` y es responsabilidad de la app conservarla:

  ```dart
  // Ejemplo: controlador de wallet que mantiene la sesión en un campo propio.
  class WalletController {
    WalletSession? _session;

    Future<void> unlock(String pin) async {
      _session = await walletService.unlock(walletId: walletId, pin: pin);
    }

    Future<void> loadCredentials() async {
      final session = _session;
      if (session == null || session.isLocked) {
        // redirigir a pantalla de PIN
        return;
      }
      final credentials = await session.credentialStore.getAll();
    }
  }
  ```

- Ante un `WalletLockedError` no esperado en producción, redirigí al usuario a la pantalla de desbloqueo (PIN) sin mostrar el error técnico. Ver [`05-reference/06-errors.md`](05-reference/06-errors.md#errores-de-wallet) para el contexto completo de este error.

---

### 7. Errores de `.g.dart` o `.freezed.dart` faltantes

**Problema.** Al clonar el repositorio del SDK o usarlo como path dependency, el compilador reporta errores como "Target of URI doesn't exist: '*.g.dart'" o "*.freezed.dart not found".

**Causa.** Los archivos generados por `build_runner` (`.g.dart`, `.freezed.dart`) están commiteados en el repositorio del SDK. Si aparecen faltantes, generalmente se debe a una de estas situaciones:

- El repositorio fue clonado de forma incompleta (shallow clone o error de red).
- Alguien modificó los modelos fuente (`.dart` con anotaciones `@freezed`, `@JsonSerializable`) sin regenerar los archivos.
- Un merge/rebase dejó conflictos no resueltos en los archivos generados.

**Solución para integradores.**

La app consumidora **no necesita ejecutar `build_runner`**. Si ves estos errores usando el SDK como dependencia git o path, verificá:

1. Que el clone del SDK esté completo: `git status` no debe mostrar archivos faltantes.
2. Que la rama/commit que estás usando tenga los archivos generados commiteados (`git log --oneline -- lib/src/**/*.g.dart`).
3. Que no hayas modificado accidentalmente archivos de modelos del SDK.

**Solución para contributors del SDK.**

Si modificaste modelos del SDK (archivos con `@freezed` o `@JsonSerializable`), regenerá los archivos antes de commitear:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### 8. La invitación no se reconoce (`unknownFormat`)

**Problema.** `InvitationResolver.resolve()` devuelve `InvitationErrorResult` con `type == InvitationErrorType.unknownFormat` aunque la URL parezca válida.

**Causa.** El parser de invitaciones (`InvitationParser.detectType()`) reconoce un conjunto fijo de esquemas y query params. Si la URL usa un esquema no listado o le falta el query param esperado, el parser no la identifica y devuelve `null`, lo que produce el error `unknownFormat`.

**Diagnóstico.**

Verificá que la URL cumple con alguno de los formatos reconocidos por el SDK:

| Formato | Esquema / query param |
|---|---|
| OID4VCI — offer directo | `openid-credential-offer://` |
| OID4VCI — legacy | `openid-initiate-issuance://` |
| OID4VCI — HAIP / EUDI | `haip-vci://` |
| OID4VCI — offer por referencia | `https://...?credential_offer_uri=...` |
| OID4VP — request directo | `openid4vp://` |
| OID4VP — EUDI | `eudi-openid4vp://` |
| OID4VP — mDoc | `mdoc-openid4vp://` |
| OID4VP — HAIP | `haip://` |
| OID4VP — request por referencia | `https://...?request_uri=...` |
| DIDComm OOB | `didcomm://` o `https://...?oob=...` / `?_oobid=...` |

**Solución.**

- Confirmar con el emisor o verificador que la URL generada usa uno de los esquemas anteriores.
- Si el esquema está registrado en el SO pero la app no lo captura correctamente antes de pasarlo al SDK, revisá la configuración de deep links en [`02-installation.md`](02-installation.md#7-deep-links--app-links).
- Si el formato es nuevo o experimental, consultá la tabla completa de esquemas y el detalle del parser en [`04-flows/01-invitations.md`](04-flows/01-invitations.md).
- Si el QR fue copiado con caracteres extra al final o con una sola barra tras el esquema, el SDK intenta normalizarlo con `normalizeInvitationUrl()` antes de parsear; si aún falla, revisá el string crudo.

---

### 9. `FieldCipherError` al leer credenciales o claves

**Problema.** Tras desbloquear la wallet, `getById`, `getAll` o `watch()` fallan con `FieldCipherError: No se pudo descifrar el campo.`

**Causas posibles.**

| Causa | Cómo detectarla |
|-------|-----------------|
| **PIN correcto pero datos corruptos** | Archivo `.isar` alterado o truncado. |
| **Mezcla de claves** | Salt de una wallet con archivo Isar de otra (mismo `walletId`, distinto dispositivo/backup parcial). |
| **Registro cifrado con otra clave** | Datos migrados manualmente sin re-cifrar. |

**Solución.**

1. Confirmar que `walletId` y `directory` son los mismos usados en `create()`.
2. Si el error persiste con PIN conocido correcto, `reset()` y nuevo onboarding (no hay recovery).
3. Evitar restaurar solo el `.isar` sin el salt de secure storage.

---

## Ver también

- [`02-installation.md`](02-installation.md) — configuración de deep links y requisitos nativos
- [`03-wallet-lifecycle.md`](03-wallet-lifecycle.md) — ciclo de vida del wallet y limitación de cifrado en reposo
- [`04-flows/01-invitations.md`](04-flows/01-invitations.md) — tabla completa de esquemas de invitación
- [`05-reference/06-errors.md`](05-reference/06-errors.md) — catálogo completo de errores y excepciones
- [`07-limitations.md`](07-limitations.md) — limitaciones conocidas del SDK (cifrado en reposo, Dio custom)
