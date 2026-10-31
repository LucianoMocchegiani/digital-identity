## 1. Objetivo

Desarrollar una PoC de una **wallet SSI web**, sin necesidad de instalar una aplicación nativa, que permita a un usuario:

1. Recibir credenciales digitales desde un issuer.
2. Almacenar las credenciales de forma local y segura.
3. Visualizar las credenciales almacenadas.
4. Presentar credenciales ante un verifier.
5. Leer QR de emisión y presentación desde el navegador.
6. Firmar pruebas criptográficas utilizando claves del holder.

La wallet debe integrarse con los servicios existentes de Kuatia. No se deben reimplementar los servicios issuer ni verifier: el objetivo es desarrollar el cliente wallet que consume sus protocolos.

La PoC debe priorizar interoperabilidad real sobre simulaciones. No asumir que un flujo funciona hasta probarlo contra los endpoints existentes.

---

## 2. Contexto de Kuatia

Kuatia es una plataforma multi-tenant de emisión y verificación de credenciales digitales basada en SSI.

Servicios existentes:

| Servicio | URL |
|---|---|
| Issuer | `https://issuer.kuatia.xyz/` |
| Verifier | `https://verifier.kuatia.xyz/` |
| Web Wallet (propuesta) | `https://wallet.kuatia.xyz/` |

Cada tenant tiene su propio DID `did:web`.

### Ejemplo de issuer

DID:

`did:web:issuer.kuatia.xyz:faciliter-issuer-2v-4ygb`

Documento:

`https://issuer.kuatia.xyz/faciliter-issuer-2v-4ygb/did.json`

### Ejemplo de verifier

DID:

`did:web:verifier.kuatia.xyz:faciliter-verifier-2v-urt0`

Documento:

`https://verifier.kuatia.xyz/faciliter-verifier-2v-urt0/did.json`

La wallet debe ser independiente del tenant. No debe tener DIDs, claves o identificadores de tenants hardcodeados.

---

## 3. Alcance de la primera versión

Implementar inicialmente:

- OpenID for Verifiable Credential Issuance (OpenID4VCI).
- OpenID for Verifiable Presentations (OpenID4VP).
- SD-JWT VC.
- ES256.
- Curva P-256.
- Holder binding mediante Key Binding JWT.
- QR cross-device.
- Response mode `direct_post`.
- Persistencia local con IndexedDB.
- Web Crypto API.

### Fuera del alcance inicial

No implementar todavía:

- BBS+.
- Ed25519.
- W3C Data Integrity.
- ISO mdoc / ISO 18013-5.
- BLE.
- NFC.
- DIDComm.
- Integración nativa con Android Keystore.
- Integración nativa con Apple Secure Enclave.

La arquitectura debe permitir incorporar estos mecanismos posteriormente sin tener que reescribir toda la aplicación.

---

## 4. Tecnologías y convenciones

Utilizar preferentemente:

- TypeScript.
- React.
- Vite.
- Material UI (MUI).
- Web Crypto API.
- IndexedDB.
- WebAuthn cuando corresponda.

Convenciones obligatorias:

- No utilizar `any`.
- Mantener tipado estricto.
- Separar UI, lógica de negocio, protocolos y criptografía.
- No mezclar lógica criptográfica dentro de componentes React.
- Utilizar interfaces y tipos explícitos.
- Manejar errores de protocolos y criptografía de manera diferenciada.
- No almacenar secretos en `localStorage`.
- No imprimir claves privadas, tokens completos ni secretos en logs.
- No utilizar mocks para ocultar fallos de integración real.

---

## 5. Arquitectura propuesta

Organizar el proyecto por responsabilidades.

```text
ssi-web-poc/
├── apps/
│   ├── web-holder/
│   │   ├── src/
│   │   │   ├── app/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── hooks/
│   │   │   └── routes/
│   │   └── package.json
│   │
│   └── web-adapter/
│       └── ...
│
├── packages/
│   ├── crypto-engine/
│   ├── secure-storage/
│   ├── webauthn/
│   ├── oid4vci-client/
│   ├── oid4vp-client/
│   ├── credential-models/
│   └── shared/
│
├── tests/
│   ├── crypto/
│   ├── storage/
│   ├── webauthn/
│   ├── issuance/
│   └── presentation/
│
└── docs/
    ├── architecture.md
    ├── compatibility-matrix.md
    ├── security.md
    └── test-results.md
```

Esta estructura es una propuesta inicial. Antes de crearla, inspeccionar el repositorio existente y adaptarse a sus convenciones si ya existe una estructura definida.

### Responsabilidades

**crypto-engine**

- Generación de claves P-256.
- Firma ECDSA.
- Verificación de firmas.
- Conversión entre formatos JOSE y Web Crypto.
- Operaciones criptográficas auxiliares.

**secure-storage**

- Persistencia de CryptoKey en IndexedDB.
- Persistencia de credenciales.
- Cifrado y descifrado de datos sensibles.
- Gestión de versiones y migraciones del almacenamiento.

**webauthn**

- Registro de credenciales WebAuthn.
- Autenticación.
- User Verification.
- Evaluación de soporte PRF.
- Derivación de claves cuando el autenticador lo permita.

**oid4vci-client**

- Lectura de Credential Offers.
- Descubrimiento de metadata.
- Obtención de tokens cuando corresponda.
- Generación de proofs.
- Recepción de credenciales.
- Validación y almacenamiento.

**oid4vp-client**

- Lectura de Authorization Requests.
- Validación de Request Objects.
- Interpretación de DCQL.
- Selección de credenciales.
- Gestión de disclosures.
- Generación de Key Binding JWT.
- Envío de respuestas `direct_post`.

**credential-models**

- Modelos tipados para credenciales.
- SD-JWT VC.
- Disclosures.
- Holder binding.
- Metadata y estados de credenciales.

---

## 6. Flujos funcionales

### 6.1. Emisión — OpenID4VCI

El QR de emisión debe abrir una URL HTTPS de la wallet.

Ejemplo:

```text
https://wallet.kuatia.xyz/issue?credential_offer_uri=<encoded-uri>
```

Flujo esperado:

1. El usuario escanea el QR.
2. El navegador abre la wallet.
3. La wallet recupera `credential_offer_uri`.
4. Realiza GET al endpoint de la oferta.
5. Interpreta la Credential Offer.
6. Descubre la metadata del issuer.
7. Identifica los formatos y algoritmos soportados.
8. Genera una clave P-256 para el holder.
9. Ejecuta el flujo de autorización requerido por el issuer.
10. Genera el proof of possession requerido.
11. Solicita la credencial.
12. Recibe el SD-JWT VC.
13. Valida la estructura y los datos criptográficos.
14. Persiste la credencial y su clave asociada.
15. Muestra la credencial al usuario.

No asumir que todos los issuers utilizan el mismo flujo de autorización. Implementar según la metadata y las respuestas reales del issuer.

### 6.2. Presentación — OpenID4VP

El QR de presentación debe abrir una URL HTTPS de la wallet.

Ejemplo:

```text
https://wallet.kuatia.xyz/present?client_id=<encoded>&request_uri=<encoded>
```

Flujo esperado:

1. El usuario escanea el QR.
2. El navegador abre la wallet.
3. La wallet obtiene `client_id` y `request_uri`.
4. Realiza GET a `request_uri`.
5. Recupera el Request Object.
6. Valida la firma del Request Object.
7. Resuelve el DID del verifier.
8. Valida `kid`, `alg`, `exp` y `aud`.
9. Interpreta el `dcql_query`.
10. Busca credenciales compatibles almacenadas.
11. Muestra al usuario qué credencial se solicita.
12. Muestra qué atributos serán compartidos.
13. El usuario autoriza la presentación.
14. La wallet construye el SD-JWT con los disclosures seleccionados.
15. Genera el Key Binding JWT.
16. Construye el `vp_token`.
17. Envía la respuesta al `response_uri` mediante `direct_post`.
18. Muestra el resultado de la operación.

La wallet nunca debe compartir atributos sin autorización explícita del usuario.

---

## 7. Integración real con el verifier

Endpoint conocido:

```http
POST https://verifier.kuatia.xyz/v1/verifiers/{verifierId}/openid4vc/request
```

Ejemplo de body:

```json
{
  "dcqlQuery": {
    "credentials": [
      {
        "id": "identity-credential",
        "format": "dc+sd-jwt",
        "meta": {
          "vct_values": ["IdentityCredential"]
        },
        "claims": [
          { "path": ["name"] },
          { "path": ["email"] },
          { "path": ["role"] }
        ]
      }
    ]
  }
}
```

El `dcqlQuery` es dinámico. No hardcodear tipos de credenciales ni claims.

La API devuelve un `requestUri` que puede tener esta estructura:

```text
openid4vp://?client_id=...&request_uri=https://verifier.kuatia.xyz/openid4vc-flow/{verifierId}/authorize/{requestId}
```

La wallet web debe utilizar el `request_uri` HTTPS original, no el custom scheme `openid4vp://`.

**Importante:** el endpoint real observado utiliza:

```text
/openid4vc-flow/
```

No utilizar `/openid4vc-auth/` ni inventar rutas alternativas.

### Request Object

Se observó un JWT con:

```json
{
  "alg": "ES256",
  "kid": "did:web:verifier.kuatia.xyz:faciliter-verifier-2v-urt0#key-p256",
  "typ": "oauth-authz-req+jwt"
}
```

El payload contiene, entre otros:

- `response_type`
- `client_id`
- `response_mode`
- `response_uri`
- `nonce`
- `state`
- `dcql_query`
- `client_metadata`
- `iat`
- `exp`
- `aud`

La wallet debe interpretar los valores del Request Object. No generar valores sustitutos para `nonce`, `state`, `response_uri` o `client_id`.

El Request Object observado utiliza:

```text
response_type = vp_token
response_mode = direct_post
```

La configuración del verifier también contempla `direct_post.jwt`, pero no es parte del MVP salvo que se confirme que es necesario.

---

## 8. DID y resolución de claves

Los tenants utilizan `did:web`.

Ejemplo:

```text
did:web:verifier.kuatia.xyz:faciliter-verifier-2v-urt0
```

Resolverlo mediante:

```text
https://verifier.kuatia.xyz/faciliter-verifier-2v-urt0/did.json
```

El DID Document observado contiene:

- `#key-p256`
- `#key-ed25519-ldp`
- `#key-bbs-ldp`

Para la primera versión utilizar únicamente `#key-p256`.

El `kid` del header JOSE:

```text
did:web:verifier.kuatia.xyz:faciliter-verifier-2v-urt0#key-p256
```

debe corresponder al `verificationMethod.id` del DID Document.

No confundirlo con el `kid` interno del JWK, que puede ser un UUID.

### Reglas de validación

- Resolver el DID del `client_id`.
- Verificar que el DID del documento coincida con el DID solicitado.
- Encontrar el `verificationMethod` indicado por `kid`.
- Confirmar que la clave es P-256.
- Confirmar que el algoritmo es ES256.
- Confirmar que la clave está autorizada para el propósito correspondiente.
- Verificar criptográficamente la firma del JWT.
- Validar expiración.
- Validar audiencia.
- Rechazar claves inexistentes o métodos no autorizados.

No considerar que una firma es válida solamente porque coincidan el DID, el `kid` y el algoritmo.

---

## 9. SD-JWT VC

El formato real observado en Kuatia es:

```text
typ: dc+sd-jwt
alg: ES256
vct: MembershipCredential
_sd_alg: sha-256
```

La credencial contiene:

- `iss`
- `cnf.jwk`
- `status.status_list`
- `_sd`
- disclosures
- Key Binding JWT

El `cnf.jwk` representa la clave pública del holder asociada a la credencial.

El Key Binding JWT observado utiliza:

```text
typ: kb+jwt
alg: ES256
```

Incluye claims como:

- `aud`
- `nonce`
- `sd_hash`

La wallet debe implementar correctamente el formato SD-JWT VC y no tratarlo como un JWT convencional.

### Requisitos

- Parsear el SD-JWT.
- Identificar disclosures.
- Calcular hashes según el estándar.
- Verificar disclosures.
- Construir presentaciones selectivas.
- Generar el Key Binding JWT.
- Calcular correctamente `sd_hash`.
- Validar el `aud` y `nonce` del KB-JWT.
- Asociar la clave privada del holder a la credencial.
- No compartir disclosures no seleccionados.

No implementar manualmente criptografía de bajo nivel si existe una biblioteca mantenida y compatible con los estándares. Evaluar las dependencias antes de adoptarlas.

---

## 10. Gestión de claves y seguridad

Este punto es crítico.

Una wallet web no tiene automáticamente el mismo nivel de protección que una wallet nativa.

### Nivel inicial: Web Crypto + IndexedDB

- Generar claves P-256 con Web Crypto.
- Persistir CryptoKey en IndexedDB cuando el navegador lo permita.
- Preferir claves no exportables.
- No guardar claves privadas en texto plano.
- No utilizar localStorage para secretos.

Una clave `extractable: false` no implica que esté protegida por hardware.

### Nivel siguiente: WebAuthn + PRF

Investigar la posibilidad de:

1. Registrar una credencial WebAuthn.
2. Solicitar autenticación con User Verification.
3. Utilizar PRF cuando esté soportado.
4. Derivar una clave AES-GCM.
5. Cifrar la clave SSI privada.
6. Guardar el material cifrado en IndexedDB.
7. Descifrarlo solamente cuando se necesite firmar.

Esto no convierte la clave SSI en una clave hardware-backed. La clave SSI descifrada puede quedar expuesta en la memoria del contexto JavaScript.

### Riesgos que deben documentarse

- XSS.
- Robo de sesión.
- Acceso físico al dispositivo.
- Compromiso del navegador.
- Robo de backups.
- Pérdida de IndexedDB.
- Recuperación de credenciales.
- Compromiso de dependencias.
- Phishing y URLs maliciosas.
- Reutilización de QR o request URIs.

Implementar medidas contra XSS, una política CSP adecuada y validación estricta de URLs y orígenes.

No afirmar que la wallet es segura a nivel hardware si no se ha demostrado.

---

## 11. Compatibilidad de dispositivos

Dispositivos de prueba:

| Dispositivo | Navegador |
|---|---|
| Motorola Moto E14 | Chrome Android |
| iPhone | Safari |
| PC Windows | Chrome |

El modelo y la versión de iOS del iPhone deben registrarse durante las pruebas.

Chrome en iOS utiliza WebKit, por lo que no debe considerarse equivalente a Chrome en Android.

### Pruebas obligatorias

- Web Crypto API disponible.
- Generación de claves P-256.
- Firma y verificación ECDSA.
- Persistencia de CryptoKey en IndexedDB.
- Recuperación después de recargar la página.
- Recuperación después de cerrar y abrir el navegador.
- WebAuthn.
- User Verification.
- PRF, si está disponible.
- AES-GCM.
- Lectura de QR.
- Apertura de links HTTPS desde QR.
- Flujo de emisión.
- Flujo de presentación.

Crear una matriz de compatibilidad con resultados reales. No inferir compatibilidad por documentación del navegador.

---

## 12. Plan de implementación

Trabajar por etapas. No implementar todo simultáneamente.

### Fase 0 — Auditoría

Antes de programar:

- Inspeccionar el repositorio.
- Identificar estructura, dependencias y convenciones.
- Revisar metadata del issuer.
- Revisar Credential Offer real.
- Revisar metadata del verifier.
- Revisar Request Object real.
- Identificar endpoints y requisitos de autenticación.
- Revisar CORS.
- Identificar algoritmos soportados.
- Documentar los contratos reales.

Entregable: `docs/audit.md`.

No asumir endpoints, formatos o parámetros que no hayan sido comprobados.

### Fase 1 — Crypto Lab

Crear una aplicación mínima para probar:

- Generación P-256.
- Firma ECDSA.
- Verificación.
- Persistencia IndexedDB.
- Recuperación de claves.
- WebAuthn.
- PRF.
- AES-GCM.

Entregable: resultados por dispositivo en `docs/compatibility-matrix.md`.

No avanzar con la integración completa hasta conocer las limitaciones reales de los dispositivos.

### Fase 2 — Wallet local

Implementar:

- Aplicación React.
- Gestión de claves.
- Almacenamiento local.
- Listado de credenciales.
- Detalle de credenciales.
- Visualización de atributos.
- Estado de credenciales.

Utilizar fixtures para probar la UI, pero mantener separados los datos de prueba y la integración real.

### Fase 3 — Adaptador HTTPS y QR

Implementar rutas:

```text
/issue
/present
```

El objetivo es reemplazar los custom schemes de las wallets nativas por URLs HTTPS que puedan abrirse directamente en el navegador.

Validar y normalizar los parámetros recibidos.

No aceptar URLs arbitrarias sin validación.

### Fase 4 — OpenID4VCI

Integrar el issuer real.

Completar una emisión end-to-end y verificar:

- Clave del holder.
- Proof of possession.
- Respuesta del issuer.
- Formato de credencial.
- Validación criptográfica.
- Persistencia.
- Recuperación de la credencial.

### Fase 5 — OpenID4VP

Integrar el verifier real.

Completar una presentación end-to-end y verificar:

- Resolución del DID.
- Firma del Request Object.
- Interpretación de DCQL.
- Selección de credencial.
- Disclosures.
- Key Binding JWT.
- `sd_hash`.
- `nonce`.
- `aud`.
- POST a `response_uri`.
- Resultado de la verificación.

### Fase 6 — Endurecimiento

- Seguridad de almacenamiento.
- Protección contra XSS.
- Validación de origen y URLs.
- Expiración de sesiones.
- Prevención de replay.
- Manejo de errores.
- Auditoría de dependencias.
- Pruebas en dispositivos reales.

---

## 13. Reglas de desarrollo para el agente

1. Antes de modificar código, entender el flujo existente.
2. No inventar endpoints ni contratos.
3. Consultar metadata y respuestas reales.
4. No cambiar los servicios issuer/verifier salvo que sea estrictamente necesario.
5. Si un endpoint falla, investigar la causa antes de agregar workarounds.
6. No simular una respuesta exitosa.
7. No considerar una presentación exitosa hasta recibir y validar la respuesta del verifier.
8. Mantener los secretos fuera del código fuente.
9. No dejar tokens, API keys, nonces o session IDs en logs.
10. No hardcodear DIDs de tenants.
11. No hardcodear claims ni tipos de credenciales.
12. No implementar formatos fuera del alcance inicial sin justificarlo.
13. Documentar decisiones técnicas y limitaciones.
14. Agregar tests para cada módulo.
15. Ejecutar tests y typecheck antes de cerrar una etapa.
16. No continuar automáticamente a la siguiente fase si hay fallos críticos en la actual.
17. Ante una incompatibilidad de navegador, documentar evidencia y proponer alternativas.
18. Priorizar estándares y bibliotecas mantenidas frente a implementaciones criptográficas propias.

---

## 14. Criterios de aceptación del MVP

La PoC se considera funcional cuando puede completar estos dos escenarios:

### Escenario A — Emisión

1. Se genera un QR desde Kuatia.
2. El usuario lo escanea con Android o iPhone.
3. Se abre la wallet web.
4. La wallet obtiene la Credential Offer.
5. Se completa OpenID4VCI.
6. Se recibe una SD-JWT VC.
7. La credencial queda almacenada.
8. Al cerrar y volver a abrir la wallet, la credencial sigue disponible.

### Escenario B — Presentación

1. Un verifier genera un QR.
2. El usuario lo escanea.
3. Se abre la wallet web.
4. La wallet obtiene el Request Object.
5. Verifica su firma.
6. Interpreta DCQL.
7. Encuentra la credencial compatible.
8. Muestra los atributos solicitados.
9. El usuario autoriza.
10. La wallet genera la presentación SD-JWT VC con Key Binding JWT.
11. Envía el `vp_token` mediante `direct_post`.
12. El verifier confirma la presentación.

Ambos escenarios deben probarse con los servicios reales de Kuatia.

---

## 15. Primera tarea del agente

**No comenzar implementando toda la wallet.**

Primero realizar la Fase 0 — Auditoría.

Inspeccionar el repositorio y documentar:

1. Qué endpoints reales utiliza el issuer.
2. Cómo es una Credential Offer real.
3. Qué mecanismos de autorización utiliza OpenID4VCI.
4. Qué proof types acepta el issuer.
5. Qué algoritmos y formatos soporta.
6. Qué endpoints reales utiliza el verifier.
7. Cómo se obtiene y valida el Request Object.
8. Qué metadata anuncia el verifier.
9. Qué parámetros necesita `direct_post`.
10. Qué restricciones CORS existen.
11. Qué bibliotecas actuales pueden reutilizarse.
12. Qué falta implementar en el cliente wallet.

Crear un informe con:

- Arquitectura actual.
- Flujos reales.
- Endpoints.
- Contratos y ejemplos anonimizados.
- Dependencias recomendadas.
- Riesgos técnicos.
- Bloqueos.
- Plan de implementación actualizado.

Al finalizar la auditoría, presentar los hallazgos y esperar aprobación antes de iniciar la implementación.

**Objetivo principal:** construir una wallet web interoperable con la infraestructura SSI existente de Kuatia, utilizando OpenID4VCI y OpenID4VP, con SD-JWT VC y ES256 como primera implementación funcional.


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

se agrego despues:

## Persistencia y recuperación de la Wallet

La wallet debe almacenar sus datos localmente en el navegador.
No debe depender de un backend propio para almacenar o recuperar
credenciales o claves privadas.

### Almacenamiento

- Utilizar IndexedDB como almacenamiento persistente principal.
- Guardar credenciales SD-JWT VC y sus metadatos.
- Persistir CryptoKey cuando el navegador lo soporte.
- Separar el almacenamiento de credenciales, claves y configuración.
- No utilizar localStorage para almacenar credenciales ni material criptográfico.
- No utilizar Cache API como almacenamiento de datos de la wallet.

### Seguridad de las claves

- Las claves privadas del holder deben permanecer bajo control del usuario.
- Utilizar Web Crypto API para generación y operaciones criptográficas.
- Preferir claves no exportables para el uso habitual.
- No asumir que una CryptoKey no exportable tiene protección de hardware.
- No implementar mecanismos de exportación de claves sin un diseño
  explícito de recuperación y protección criptográfica.

### Backup y recuperación

- Diseñar un mecanismo de backup cifrado de las credenciales.
- Evaluar cómo respaldar y recuperar las claves privadas del holder.
- La recuperación debe preservar el vínculo entre la credencial
  y la clave pública del holder (cnf.jwk).
- No asumir que recuperar una credencial implica recuperar su clave privada.
- No enviar claves privadas en claro a servicios externos.
- Documentar las limitaciones de recuperación y reemisión de credenciales.

### Pérdida de datos

- La wallet debe advertir que borrar los datos del sitio puede eliminar
  permanentemente credenciales y claves.
- Borrar la caché HTTP no debe afectar los datos de IndexedDB.
- Borrar los datos del sitio sí puede eliminar el almacenamiento local.
- Implementar pruebas de persistencia después de cerrar y reabrir el navegador.

### Compatibilidad

- Verificar persistencia de IndexedDB y CryptoKey en Chrome Android y Safari iOS.
- Evaluar navigator.storage.persist() cuando esté disponible.
- No garantizar persistencia absoluta: el navegador o el sistema operativo
  pueden eliminar datos bajo determinadas circunstancias.