---
id: errors
title: Catálogo de errores
sidebar_position: 6
---

# Catálogo de errores

Este documento describe todos los errores y excepciones que puede encontrar al integrar `identity-core-dart`. Se distinguen dos familias:

- **Errores como valores**: APIs que devuelven un objeto resultado que contiene el error — nunca lanzan.
- **Excepciones lanzadas**: APIs que lanzan si detectan un estado inválido o un fallo de red.

Conocer esta distinción es clave para escribir un manejo de errores correcto en la wallet.

---

## Errores de wallet

Estas cuatro excepciones están definidas en `wallet_exceptions.dart` y cubren el ciclo de vida del wallet cifrado. Ver el flujo completo en [`../03-wallet-lifecycle.md`](../03-wallet-lifecycle.md).

| Excepción | Cuándo ocurre | Cómo manejarlo en la app |
|---|---|---|
| `WalletLockedError` | Cualquier operación que acceda a los stores internos cuando el wallet está bloqueado (p. ej., leer credenciales sin haber llamado a `unlock` antes). | Redirigir al usuario a la pantalla de PIN para desbloquear. |
| `WrongPinError` | Al llamar a `WalletService.unlock()` con un PIN incorrecto en una wallet que tiene `wallet_pin_hash_<walletId>` guardado. La verificación es por hash Argon2id en [PinVerifier](../../lib/src/crypto/pin_verifier.dart), **antes** de abrir Isar. | Mostrar mensaje de PIN incorrecto e incrementar el contador de intentos fallidos. |
| `WalletNotFoundError(walletId)` | Al llamar a `WalletService.unlock()` con un `walletId` que nunca fue creado (el salt no existe en secure storage). | Redirigir al flujo de creación o recuperación del wallet. |
| `WalletAlreadyExistsError(walletId)` | Al llamar a `WalletService.create()` con un `walletId` cuyo salt ya existe en secure storage. | Informar que el wallet ya existe y ofrecer la opción de abrirlo. |
| `FieldCipherError` | Al descifrar un campo con prefijo `enc:v1:` usando una clave distinta a la del cifrado, o con payload corrupto. Típico en lectura de stores sensibles (`credentialStore`, `keyStore`, `deferredStore`). | PIN/salt inconsistente con el archivo Isar → `reset()`; si persiste, reportar corrupción de datos. |

---

## Errores por flujo

### OID4VCI — Emisión de credenciales

Ver el flujo completo en [`../04-flows/02-oid4vci.md`](../04-flows/02-oid4vci.md).

| Tipo | Dónde se lanza | Cuándo ocurre | Qué hacer |
|---|---|---|---|
| `StateError` | `Oid4VciService.acquireCredentials()` | El offer no contiene un grant `pre-authorized_code` (se intentó el flujo pre-autorizado con un offer que solo tiene `authorization_code`). | Verificar que el QR/link corresponda al flujo correcto. |
| `StateError` | Interno — resolución del token endpoint | Los metadatos del issuer no incluyen `tokenEndpoint`. | Error de configuración del issuer; notificar al usuario que el emisor no está disponible. |
| `DioException` | `acquireCredentials()` → llamadas HTTP al token endpoint y al credential endpoint | Error de red o respuesta HTTP con error (4xx / 5xx) del issuer. | Inspeccionar `e.response?.statusCode` y `e.response?.data` para obtener el código de error OAuth2 (`error`, `error_description`). Mostrar mensaje apropiado. |
| `FormatException` | `Oid4VciService.resolveOffer()` — parsing del offer | La URL del offer tiene formato inválido o el payload descargado no es JSON válido. | Informar que el código QR o link es inválido. |
| `StateError` | `Oid4VciService.prepareAuthCodeFlow()` | El offer resuelto no es `Oid4VciFlow.authCode`. | Usar `acquireCredentials` o verificar el tipo de grant del offer. |

### OID4VP — Presentación de credenciales

Ver el flujo completo en [`../04-flows/03-oid4vp.md`](../04-flows/03-oid4vp.md).

| Tipo | Dónde se lanza | Cuándo ocurre | Qué hacer |
|---|---|---|---|
| `StateError` | `Oid4VpService.shareCredentials()` — validación de submission | Se llamó a `shareCredentials` pero no todas las credenciales requeridas por la presentation definition están satisfechas (`areAllSatisfied == false`). | Verificar el estado de `submission.areAllSatisfied` antes de llamar a `shareCredentials`. |
| `StateError` | `Oid4VpService.shareCredentials()` — validación del request | El authorization request no tiene `response_uri`. | Indica un authorization request malformado; notificar al usuario que el verificador no está configurado correctamente. |
| `StateError` | `Oid4VpService.shareCredentials()` — resolución de credencial seleccionada | Una de las credenciales seleccionadas por el usuario no se encuentra en el store (fue borrada entre la selección y el envío). | Refrescar la lista de credenciales disponibles y pedir al usuario que vuelva a seleccionar. |
| `SubmitPresentationResult(success: false)` | `shareCredentials()` → envío JARM | `response_mode: direct_post.jwt` pero `client_metadata.jwks` no contiene una clave ECDH-ES P-256. Mensaje: *"El verifier requiere respuesta cifrada pero no envió jwks."* | Verificar que el authorization request del verifier EUDI incluya `client_metadata` con `jwks`. |
| `SubmitPresentationResult(success: false)` | `shareCredentials()` → cifrado JARM | Algoritmo de cifrado no soportado o error al construir el JWE. Mensaje: *"Error al cifrar la respuesta: ..."* | Hoy solo `A128GCM` + `ECDH-ES` + `P-256`. Ver [OID4VP — Perfil EUDI](../04-flows/03-oid4vp.md#perfil-eudi-dcql--jarm). |
| `SubmitPresentationResult(success: false)` | `shareCredentials()` → envío HTTP | Error de red o respuesta HTTP con error al enviar al `response_uri` del verificador (incluye rechazo del verifier por `vp_token` inválido). | Inspeccionar `result.error` (p. ej. `error_description` del verifier). **No se lanza `DioException`** en esta fase. |
| `FormatException` | `Oid4VpService.resolveRequest()` — parsing del request JWT | El request JWT tiene un formato inválido (menos de 2 partes separadas por `.`). | Informar que el link de presentación es inválido. |

### Invitaciones

Ver el flujo completo en [`../04-flows/01-invitations.md`](../04-flows/01-invitations.md).

`InvitationResolver.resolve()` **nunca lanza**. Todos los errores se devuelven como `InvitationErrorResult` con un campo `type` de tipo `InvitationErrorType`:

| `InvitationErrorType` | Cuándo ocurre | Qué hacer |
|---|---|---|
| `unknownFormat` | La URL no corresponde a ningún formato reconocido (OID4VCI, OID4VP, DIDComm OOB). | Mostrar "código QR no reconocido". |
| `fetchFailed` | Falló el fetch del `request_uri` o `credential_offer_uri` (error de red). | Mostrar "no se pudo contactar al servidor" y ofrecer reintentar. |
| `invalidPayload` | El payload descargado no es parseable, o ocurrió un error interno inesperado durante el procesamiento. | Mostrar "el código QR contiene datos inválidos". |
| `noMatchingCredentials` | La solicitud OID4VP no pudo satisfacerse porque el wallet no tiene las credenciales requeridas. | Mostrar qué tipos de credenciales son necesarios. |

### Stores de bajo nivel

Ver la referencia de stores en [`01-stores.md`](01-stores.md).

`DuplicateRecordException` y `RecordNotFoundException` están definidas en `lib/src/record/record_service.dart` y solo aparecen al usar los stores directamente (p. ej., `CredentialRecordStore`, `KeyRecordStore`, etc.). **Los flujos de alto nivel (OID4VCI, OID4VP, DIDComm) no las propagan normalmente.**

| Excepción | Método que la lanza | Cuándo ocurre | Qué hacer |
|---|---|---|---|
| `DuplicateRecordException(id)` | `RecordService.save()` | Se intentó guardar un record con un ID que ya existe en el store. | Verificar que el record no fue guardado previamente, o usar `update()` si la intención es reemplazarlo. |
| `RecordNotFoundException(id)` | `RecordService.update()` y otras operaciones sobre ID inexistente | Se intentó actualizar (u operar sobre) un record cuyo ID no existe en el store. | Confirmar que el record fue guardado antes de intentar actualizarlo; considerar usar `getById()` primero. |

### DIDComm

Ver el flujo completo en [`../04-flows/04-didcomm.md`](../04-flows/04-didcomm.md).

| Tipo | Dónde se lanza | Cuándo ocurre | Qué hacer |
|---|---|---|---|
| `StateError` | `DidCommService.handleIncomingMessage` | No hay clave Ed25519 con `privateJwk` o ninguna coincide con el `kid` del envelope. | Verificar que el DID del wallet tiene clave Ed25519 activa en el store. |
| `UnsupportedError` | `DidCommEnvelopeV1.unpack` | `alg` del envelope distinto de `Anoncrypt` / `Authcrypt`. | Error de interoperabilidad; revisar el agente remoto. |
| `DioException` | `HttpTransport.sendEncrypted()` / `HttpTransport.send()` | Error de red o respuesta HTTP con error al enviar el mensaje DIDComm. | Capturar en el caller; inspeccionar `e.response` para mayor detalle. |

### KMS y DIDs

Ver referencia completa en [`04-kms.md`](04-kms.md) y [`03-dids.md`](03-dids.md).

| Tipo | Dónde se lanza | Cuándo ocurre | Qué hacer |
|---|---|---|---|
| `UnsupportedError` | `SoftwareKms.sign()` — clave hardware en software KMS | La clave tiene `isHardwareBacked == true` y se intenta firmar con `SoftwareKms`. Guard evaluado primero. | Usar `HardwareKmsService` para claves hardware-backed. |
| `ArgumentError` | `SoftwareKms.sign()` — clave sin privateJwk | La clave tiene `privateJwk == null`. Guard evaluado en segundo lugar. | Asegurarse de que la clave fue generada con acceso a la parte privada. |
| `UnsupportedError` | `SoftwareKms.sign()` — tipo de clave X25519 | La clave es X25519: ese tipo no soporta firma. Guard evaluado en tercer lugar. | Error de programación: verificar que `keyType != KeyType.x25519` antes de firmar. |
| `UnsupportedError` | `HardwareKmsService.generateKey()` | Se intentó generar una clave de tipo distinto a P-256 con el KMS de hardware. | El KMS de hardware solo soporta P-256; usar `SoftwareKms` para Ed25519 / X25519. |
| `ArgumentError` | `HardwareKmsService.sign()` — clave no hardware-backed | La clave tiene `isHardwareBacked == false`. Guard evaluado primero. | Usar `SoftwareKms` para claves software-backed. |
| `UnsupportedError` | `HardwareKmsService.sign()` — tipo de clave | La clave no es P-256. Guard evaluado en segundo lugar. | Solo firmar claves P-256 con `HardwareKmsService`. |
| `UnsupportedError` | `DidService.ensureDid()` / `resolveDid()` | Método DID distinto de `key` o `jwk`. El SDK solo soporta `did:key` y `did:jwk`. | Verificar que el método DID está soportado antes de llamar. |
| `UnsupportedError` | `DidKey.fromKeyRecord()` / `DidKey.resolve()` | Tipo de clave o prefijo multicodec no soportado para `did:key`. | Usar Ed25519 o P-256 para `did:key`. |
| `FormatException` | `DidKey.resolve()`, `DidJwk.resolve()`, `DidPeer.resolve()` | El DID tiene formato inválido. | Validar el DID antes de pasarlo al servicio. |

---

## Patrón: errores como valores vs excepciones

El SDK tiene dos familias bien diferenciadas para comunicar errores al caller.

### Errores como valores (resultado sellado)

Algunas APIs nunca lanzan y en cambio devuelven un objeto resultado tipado que puede o no contener un error. El caller debe inspeccionarlo con un `switch` exhaustivo.

| API | Tipo de resultado | Campo de error |
|---|---|---|
| `InvitationResolver.resolve()` | `InvitationResult` (sealed) | Caso `InvitationErrorResult` con `type: InvitationErrorType` y `message: String` |
| `Oid4VpService.shareCredentials()` → `submitPresentation()` | `SubmitPresentationResult` | `success: false` con `error: String?` |

### Excepciones lanzadas

Las demás APIs lanzan excepciones del SDK o estándar de Dart. La tabla a continuación resume todas las APIs públicas y el mecanismo de error de cada una.

| API / Método | Mecanismo | Tipos posibles |
|---|---|---|
| `WalletService.create()` | Lanza | `WalletAlreadyExistsError` |
| `WalletService.unlock()` | Lanza | `WalletNotFoundError`, `WrongPinError` |
| `WalletSession` (stores) | Lanza | `WalletLockedError` |
| `InvitationResolver.resolve()` | Valor | `InvitationErrorResult` |
| `Oid4VciService.resolveOffer()` | Lanza | `FormatException`, `DioException` |
| `Oid4VciService.acquireCredentials()` | Lanza | `StateError`, `DioException` |
| `Oid4VpService.resolveRequest()` | Lanza | `FormatException`, `DioException` |
| `Oid4VpService.shareCredentials()` — validaciones | Lanza | `StateError` |
| `Oid4VpService.shareCredentials()` — envío de red | Valor | `SubmitPresentationResult(success: false)` |
| `DidcommPack.authcrypt()` | Lanza | `ArgumentError` |
| `DidcommUnpack.unpack()` | Lanza | `StateError`, `UnsupportedError`, `ArgumentError` |
| `HttpTransport.sendEncrypted()` / `send()` | Lanza | `DioException` |
| `SoftwareKms.sign()` | Lanza | `UnsupportedError`, `ArgumentError` |
| `HardwareKmsService.generateKey()` / `sign()` | Lanza | `UnsupportedError`, `ArgumentError` |
| `DidService.ensureDid()` / `resolveDid()` | Lanza | `UnsupportedError`, `FormatException` |

---

## Patrón general de manejo

El siguiente ejemplo muestra cómo construir un método de servicio en la wallet que cubra los errores del flujo OID4VCI completo, mapeando cada tipo de error a un mensaje de UI.

```dart
/// Resultado de UI para el flujo de emisión de credenciales.
sealed class IssuanceUiResult {}

final class IssuanceSuccess implements IssuanceUiResult {
  final RetrieveCredentialsResult data;
  const IssuanceSuccess(this.data);
}

final class IssuanceFailure implements IssuanceUiResult {
  final String userMessage;
  const IssuanceFailure(this.userMessage);
}

/// Ejecuta el flujo OID4VCI completo con manejo de errores orientado a la UI.
Future<IssuanceUiResult> handleOid4VciFlow({
  required String offerUrl,
  required Oid4VciService service,
  String? txCode,
}) async {
  try {
    // Paso 1: resolver el offer (puede lanzar FormatException o DioException)
    final resolved = await service.resolveOffer(offerUrl);

    // Paso 2: adquirir credenciales (puede lanzar StateError o DioException)
    final result = await service.acquireCredentials(
      resolvedOffer: resolved,
      txCode: txCode,
    );

    return IssuanceSuccess(result);
  } on WalletLockedError {
    // Lanzado por los stores internos de la sesión cuando el wallet está bloqueado.
    return const IssuanceFailure(
      'El wallet está bloqueado. Ingresá tu PIN para continuar.',
    );
  } on FormatException catch (e) {
    return IssuanceFailure('El código QR es inválido: ${e.message}');
  } on StateError catch (e) {
    return IssuanceFailure('Error de configuración: ${e.message}');
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final oauthError = body is Map ? body['error'] : null;
    return IssuanceFailure(
      oauthError != null
          ? 'El emisor rechazó la solicitud: $oauthError'
          : 'Error de red (HTTP $status). Verificá tu conexión.',
    );
  } catch (e) {
    return IssuanceFailure('Error inesperado: $e');
  }
}
```

Aplicar el mismo patrón para los flujos OID4VP (capturando `StateError` por validaciones previas al envío, y verificando `SubmitPresentationResult.success` para errores de envío) y DIDComm (capturando `UnsupportedError`, `ArgumentError`, `StateError` y `DioException`).

---

## Ver también

- [`../03-wallet-lifecycle.md`](../03-wallet-lifecycle.md) — ciclo de vida del wallet, validación de PIN y cifrado en reposo
- [`../04-flows/01-invitations.md`](../04-flows/01-invitations.md) — errores como valores en el flujo de invitaciones
- [`../04-flows/02-oid4vci.md`](../04-flows/02-oid4vci.md) — flujo de emisión y errores OID4VCI
- [`../04-flows/03-oid4vp.md`](../04-flows/03-oid4vp.md) — flujo de presentación y errores OID4VP
