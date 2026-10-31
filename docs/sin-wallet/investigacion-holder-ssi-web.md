# Investigación: holder SSI sin aplicación nativa

**Fecha de referencia:** 30 de octubre de 2026\
**Objetivo:** evaluar si un navegador móvil puede funcionar como holder
autónomo de credenciales verificables, sin instalar una aplicación
nativa y sin depender de Google Wallet o Apple Wallet.

------------------------------------------------------------------------

## 1. Objetivo y alcance

La investigación busca determinar si es posible ofrecer una experiencia
simple para el titular (*holder*):

1.  Escanea un QR del emisor.
2.  Se abre una web.
3.  Acepta la emisión de una credencial.
4.  La credencial queda guardada de forma persistente y protegida en el
    teléfono.
5.  Más adelante puede presentarla ante un verificador, idealmente
    mediante otro QR o un mecanismo de proximidad.

El usuario no debería necesitar conocer conceptos como SSI, DID, VC,
issuer, holder o verifier. La complejidad técnica debería quedar detrás
de una experiencia web sencilla.

El objetivo en esta etapa es **investigar capacidades y estándares
existentes**, no implementar todavía. La idea es agotar primero las
posibilidades de los estándares y APIs actuales antes de inventar una
extensión o protocolo propio.

### Pregunta central

> ¿Podemos convertir un navegador móvil en un holder SSI autónomo, con
> almacenamiento persistente cifrado y prueba de posesión criptográfica,
> sin instalar una aplicación nativa y sin depender de Google Wallet o
> Apple Wallet?

------------------------------------------------------------------------

## 2. Separar las capas del ecosistema

Es importante no mezclar conceptos que resuelven problemas distintos.

  -----------------------------------------------------------------------
  Capa                    Qué define              Ejemplos
  ----------------------- ----------------------- -----------------------
  Modelo de identidad     Quién emite, quién      SSI, DID, Issuer,
                          posee y quién verifica; Holder, Verifier
                          cómo se representa la   
                          identidad               

  Formato de credencial   Cómo se estructuran y   W3C Verifiable
                          protegen los datos de   Credentials 2.0, SD-JWT
                          la credencial           VC, ISO mdoc

  Protocolo               Cómo se solicita, emite OpenID4VCI, OpenID4VP,
                          o presenta una          ISO 18013-5, DIDComm
                          credencial              

  Medio de transporte     Cómo se inicia o        QR, HTTPS, NFC, BLE
                          transporta el           
                          intercambio             

  Wallet / plataforma     Dónde se guardan y      Wallet propia, Google
                          gestionan las           Wallet, Apple Wallet,
                          credenciales            wallet de terceros,
                                                  navegador

  Verificación            Cómo se comprueban      Validación
                          firma, emisor, titular, criptográfica,
                          atributos, vigencia y   estado/revocación,
                          estado                  prueba de posesión
  -----------------------------------------------------------------------

**Principio clave:** que un estándar permita una capacidad no significa
que Google, Apple o los navegadores la implementen. Hay que comprobar
por separado el estándar, la API y la implementación concreta de cada
plataforma.

------------------------------------------------------------------------

## 3. Estándares y tecnologías relevantes

### 3.1 W3C Verifiable Credentials (VC)

Define un modelo interoperable para representar credenciales
verificables. No define por sí solo cómo se emiten, almacenan o
presentan.

### 3.2 SD-JWT VC

Formato de credencial basado en JSON Web Token con soporte para
divulgación selectiva (*selective disclosure*). Puede ser una
alternativa práctica para una wallet web porque encaja naturalmente con
tecnologías web y flujos basados en HTTPS.

### 3.3 ISO/IEC 18013-5 --- mdoc

Estándar de documentos móviles, conocido por su uso en licencias de
conducir móviles. Define mecanismos de interacción de proximidad,
incluyendo QR de *Device Engagement*, BLE y NFC.

No es simplemente un QR que contiene una credencial. El QR inicia el
establecimiento de una conexión segura y el intercambio posterior.

### 3.4 OpenID4VCI

Protocolo para la **emisión** de credenciales verificables. Define cómo
un issuer ofrece y entrega una credencial a un wallet/holder.

No es un formato de credencial: puede trabajar con distintos formatos
compatibles.

### 3.5 OpenID4VP

Protocolo para la **presentación** de credenciales verificables ante un
verifier. Permite que el verificador solicite determinados datos y que
el holder responda con una presentación.

No define por sí solo el formato de la credencial ni exige que el QR sea
mostrado por el holder.

### 3.6 W3C Digital Credentials API

Es una interfaz para que un sitio web solicite credenciales a una wallet
o mecanismo de credenciales disponible en el dispositivo/navegador.

No es: - Un formato de credencial. - Un protocolo de emisión completo. -
Un almacén genérico de credenciales. - Una API que permita a cualquier
web escribir libremente en Google Wallet, Apple Wallet, Android Keystore
o Secure Enclave.

Su función es mediar la interacción entre sitios web y
wallets/plataformas compatibles. La disponibilidad concreta depende del
navegador, sistema operativo y wallet instalada.

------------------------------------------------------------------------

## 4. Presentación presencial: QR, NFC y BLE

Hay dos flujos de QR que parecen similares, pero no son equivalentes.

### 4.1 El verificador muestra el QR y el holder lo escanea

Flujo habitual de presentación *cross-device* con OpenID4VP:

1.  El verifier genera una solicitud de presentación.
2.  El verifier muestra un QR que contiene la solicitud o una referencia
    a ella.
3.  El holder escanea el QR.
4.  La wallet obtiene la solicitud y selecciona las credenciales
    correspondientes.
5.  El holder autoriza la presentación.
6.  La wallet envía la respuesta al verifier, normalmente por HTTPS.

Este flujo es natural cuando el holder tiene una wallet que puede leer
QR y procesar OpenID4VP.

### 4.2 El holder muestra el QR y el verificador lo escanea

Este flujo es habitual en mecanismos de proximidad como ISO 18013-5
mdoc:

1.  El holder inicia el mecanismo de proximidad.
2.  El holder muestra un QR de *Device Engagement*.
3.  El lector/verifier escanea el QR.
4.  El QR aporta información para establecer la conexión y obtener la
    clave pública efímera del dispositivo.
5.  Se establece una conexión, normalmente BLE.
6.  El lector solicita los atributos necesarios.
7.  El holder autoriza y entrega una respuesta protegida
    criptográficamente.

El QR no contiene necesariamente la credencial. Es principalmente un
mecanismo para iniciar el intercambio seguro.

### 4.3 OpenID4VP over BLE

Se ha identificado trabajo sobre perfiles/extensiones para transportar
OpenID4VP mediante BLE y permitir experiencias de proximidad. Hay que
distinguirlo del estándar OpenID4VP 1.0: no debe asumirse que todo el
flujo BLE forma parte del núcleo final de OpenID4VP 1.0.

Es una línea relevante para investigar si se busca que el holder muestre
un QR y el lector inicie el intercambio.

### 4.4 QR no es un protocolo

Un QR puede transportar: - Una URL. - Un identificador de sesión. - Una
referencia a una solicitud. - Información de conexión. - Una oferta de
emisión. - Incluso datos de una credencial, aunque no siempre sea una
buena decisión.

El QR es un contenedor de datos. El protocolo define qué significan esos
datos y qué ocurre después.

------------------------------------------------------------------------

## 5. QR general, QR por credencial y seguridad

Hay distintas estrategias posibles.

### QR general por sesión

Un QR puede identificar una sesión o un dispositivo, sin contener una
credencial específica.

Luego: 1. El lector escanea el QR. 2. Se establece una sesión. 3. El
verifier solicita los atributos o credenciales que necesita. 4. El
holder autoriza la presentación.

Ventajas: - No hace falta un QR diferente por cada credencial. - Permite
elegir qué atributos presentar en cada situación. - Reduce la exposición
de información en el QR. - Separa la identificación de la sesión de la
selección de credenciales.

### QR por credencial

También se puede diseñar un QR asociado a una credencial concreta. Puede
contener: - La credencial completa. - Un identificador. - Una URL o
referencia a la credencial. - Un identificador de sesión relacionado con
esa credencial.

Pero no hay que confundir este diseño con el mecanismo estándar de
*Device Engagement* de ISO 18013-5.

### Riesgos de QR estáticos

Un QR estático que contiene una credencial firmada puede ser copiado y
reutilizado. La firma permite detectar modificaciones, pero no impide
por sí sola la reproducción de una copia válida.

Un QR que contiene un ID o URL necesita que el backend resuelva esa
referencia y controle su vigencia.

Un QR permanente combinado con un desafío dinámico puede mejorar la
protección contra *replay*, pero requiere una interacción que permita al
holder demostrar posesión de la clave correspondiente.

**Recomendación de investigación:** evitar que el QR de emisión contenga
la credencial final. Es preferible que contenga una oferta o referencia
de emisión de un solo uso, con vencimiento corto.

------------------------------------------------------------------------

## 6. ¿Puede Android proteger las claves de una wallet web?

### Android Keystore

Android Keystore permite crear y utilizar claves criptográficas de forma
que la clave privada no tenga que salir del entorno seguro. Según el
dispositivo, la protección puede estar respaldada por TEE o StrongBox.

Una aplicación nativa puede solicitar operaciones criptográficas sin
extraer la clave privada.

Pero una página JavaScript común en Chrome no tiene acceso arbitrario y
directo a Android Keystore. Para aprovecharlo de forma directa
normalmente se necesita código nativo o una wallet/app que exponga una
interfaz controlada.

### Android Credential Manager

Credential Manager no debe interpretarse como un almacén genérico del
sistema donde cualquier web pueda guardar credenciales SSI.

La arquitectura de credenciales digitales de Android contempla holder
apps/wallets que gestionan las credenciales. Credential Manager puede
ayudar a descubrir y presentar credenciales mediante una API común, pero
no almacena directamente las credenciales en nombre de cualquier sitio
web.

Android documenta soporte para formatos como SD-JWT y mdoc y flujos de
presentación OpenID4VP, dependiendo de las aplicaciones y capacidades
disponibles.

Para emisión OpenID4VCI, la integración requiere una holder app
compatible; no alcanza con que el sitio web invoque Credential Manager.

------------------------------------------------------------------------

## 7. ¿Puede iOS proteger las claves de una wallet web?

### Secure Enclave y Keychain

Apple ofrece mecanismos de protección de claves mediante Secure Enclave
y Keychain. Una aplicación nativa puede crear claves protegidas por
hardware y solicitar operaciones criptográficas sin extraer la clave
privada.

Sin embargo, una página web en Safari no puede pedir directamente al
Secure Enclave que genere y gestione una clave SSI arbitraria para
firmar cualquier payload.

### IdentityDocumentServices y Digital Credentials

Apple dispone de mecanismos para que sitios web soliciten documentos
digitales mediante wallets compatibles. Eso no significa que cualquier
web pueda escribir credenciales arbitrarias en Apple Wallet o acceder
libremente a Secure Enclave.

La presencia de una API de solicitud/presentación tampoco implica que
exista una API web genérica de emisión y almacenamiento SSI.

------------------------------------------------------------------------

## 8. Qué puede hacer realmente una web

### 8.1 Web Crypto API

La Web Crypto API permite generar claves criptográficas, firmar,
verificar y cifrar datos desde JavaScript.

Por ejemplo, puede generarse una clave ECDSA P-256 no exportable
(`extractable: false`).

Pero hay una distinción importante:

**No exportable no significa necesariamente hardware-backed.**

La clave puede estar gestionada por el navegador y no ser extraíble
mediante la API, pero eso no garantiza el mismo nivel de protección que
Android Keystore o Apple Secure Enclave. Tampoco elimina el riesgo de
que código malicioso ejecutado en el mismo origen utilice la clave
mientras la wallet está abierta.

Las claves `CryptoKey` pueden persistirse en IndexedDB en navegadores
compatibles, pero la persistencia y las garantías de seguridad varían.

### 8.2 IndexedDB

IndexedDB permite almacenar datos de forma persistente en el navegador.
Puede servir para guardar: - Credenciales. - Metadatos. - Claves
cifradas. - Configuración de la wallet.

No debe tratarse como un almacén seguro equivalente al hardware seguro
del dispositivo. La protección depende del navegador, del sistema y de
las medidas adicionales que se implementen.

### 8.3 WebAuthn y Passkeys

WebAuthn permite crear y utilizar credenciales de autenticación
asociadas a un sitio (RP ID). La clave privada es gestionada por el
autenticador; el sitio recibe respuestas firmadas.

Una passkey no es automáticamente una clave SSI. Su clave privada está
destinada a la autenticación WebAuthn y no puede utilizarse libremente
para firmar cualquier JWT o payload de una credencial verificable.

Puede ser útil para: - Autenticar al usuario. - Proteger el acceso a la
wallet. - Requerir una acción del usuario antes de desbloquear una
operación.

### 8.4 WebAuthn PRF

La extensión PRF de WebAuthn puede producir un resultado pseudoaleatorio
asociado a una credencial WebAuthn.

Una posible aplicación es usar ese resultado como material para derivar
una clave AES y cifrar una clave privada SSI generada por la wallet web.

Flujo conceptual:

1.  El usuario crea una passkey.
2.  La wallet genera una clave SSI propia.
3.  La wallet solicita un resultado PRF mediante WebAuthn.
4.  Deriva una clave de cifrado a partir del resultado.
5.  Cifra la clave SSI.
6.  Guarda la clave SSI cifrada en IndexedDB.
7.  Para presentar una credencial, solicita nuevamente la operación
    WebAuthn/PRF.
8.  Deriva la clave de cifrado, descifra temporalmente la clave SSI y
    firma la presentación.

Limitaciones: - El soporte de PRF depende del autenticador, navegador y
plataforma. - Hay que comprobar compatibilidad real en Android, iOS,
Chrome y Safari. - La sincronización o migración de passkeys puede
afectar la recuperación de la wallet. - La clave SSI debe estar
disponible temporalmente para el motor criptográfico JavaScript si se
descifra en el navegador. En ese momento puede quedar expuesta a código
malicioso del mismo origen o a un XSS.

**PRF mejora el diseño de protección en reposo, pero no convierte
automáticamente una clave SSI en una clave hardware-backed que solo
pueda usarse dentro del Secure Enclave o Keystore.**

------------------------------------------------------------------------

## 9. Tres niveles de arquitectura posibles

  -----------------------------------------------------------------------
  Nivel             Tecnología        Ventaja           Limitación
  ----------------- ----------------- ----------------- -----------------
  A. Web Crypto     Web Crypto +      Sin instalación;  No garantiza
                    IndexedDB         control completo  protección
                                      de la experiencia hardware; riesgo
                                      web               durante el uso

  B. WebAuthn + PRF Passkey + PRF +   Mejor protección  Compatibilidad
                    cifrado de clave  en reposo y       variable; clave
                    SSI + IndexedDB   desbloqueo con    SSI puede quedar
                                      autenticador      en memoria
                                                        JavaScript al
                                                        usarla

  C. Wallet nativa  Android Keystore  Mejor integración Requiere app
                    / Apple Secure    con hardware      nativa o wallet
                    Enclave           seguro y APIs de  compatible
                                      proximidad        instalada
  -----------------------------------------------------------------------

La opción B es la más interesante para investigar si el requisito de no
instalar una app es prioritario. No debe presentarse como equivalente a
la opción C.

------------------------------------------------------------------------

## 10. Arquitectura hipotética: web holder / bridge

La arquitectura que se quiere evaluar puede dividirse en tres módulos.

### 10.1 Crypto Storage Engine

Responsabilidades: - Generación de claves del holder. - Gestión de
passkeys. - Uso de WebAuthn PRF cuando esté disponible. - Derivación de
claves de cifrado. - Cifrado y descifrado de claves SSI. - Persistencia
en IndexedDB. - Protección y recuperación de datos locales.

Tecnologías candidatas: - Web Crypto API. - WebAuthn. - WebAuthn PRF. -
IndexedDB.

### 10.2 Protocol Engine

Responsabilidades: - OpenID4VCI para emisión. - OpenID4VP para
presentación. - Gestión de formatos de credenciales. - SD-JWT VC. - W3C
VC, si corresponde. - ISO mdoc, si se requiere compatibilidad con ese
ecosistema.

Este módulo debería ser independiente del almacenamiento y de la
interfaz de usuario.

### 10.3 Web Holder / Bridge

Responsabilidades: - Experiencia de usuario. - Inicio de emisión desde
QR. - Aceptación de credenciales. - Selección de credenciales. -
Desbloqueo mediante passkey/biometría según soporte del dispositivo. -
Inicio y autorización de presentaciones. - Comunicación con issuer y
verifier.

La web es la interfaz y el coordinador del flujo; no debe confundirse
con una API del sistema operativo que almacena credenciales por ella.

------------------------------------------------------------------------

## 11. Flujo hipotético de emisión

Una posible secuencia, pendiente de validar en cada plataforma:

1.  El issuer crea una oferta de emisión compatible con OpenID4VCI.
2.  El issuer genera un QR con una URL o referencia a esa oferta.
3.  La referencia incluye un token de un solo uso y un vencimiento
    corto.
4.  El usuario escanea el QR y abre la web holder.
5.  La web valida la oferta con el issuer.
6.  La web crea o desbloquea una passkey.
7.  La web genera una clave criptográfica propia para el holder.
8.  La web almacena la clave de forma protegida, idealmente cifrada
    mediante material derivado de WebAuthn PRF.
9.  La web completa el flujo de emisión OpenID4VCI.
10. El issuer emite una credencial vinculada a la clave pública del
    holder, cuando el formato y perfil de emisión soporten esa
    vinculación y prueba de posesión.
11. La web guarda la credencial y sus metadatos localmente.

El QR inicial debería representar una oferta de emisión, no transportar
la credencial final.

------------------------------------------------------------------------

## 12. Flujo hipotético de presentación

1.  El verifier inicia una solicitud OpenID4VP.
2.  El holder abre la web wallet, por ejemplo escaneando el QR del
    verifier.
3.  La web obtiene los requisitos de presentación.
4.  El holder selecciona o confirma la credencial.
5.  La wallet desbloquea la clave SSI mediante el mecanismo disponible.
6.  La wallet genera la presentación y la prueba de posesión
    correspondiente.
7.  La respuesta se envía al verifier por el canal definido por el
    perfil, por ejemplo HTTPS.
8.  El verifier valida:
    -   Firma y formato.
    -   Emisor y confianza.
    -   Vinculación con el holder, si corresponde.
    -   Atributos solicitados.
    -   Vigencia.
    -   Estado o revocación, según el mecanismo adoptado.
    -   Nonce, audiencia y protección contra replay.

Para un flujo de proximidad en el que el holder muestra QR y el lector
inicia la conexión, hay que evaluar por separado ISO 18013-5 o perfiles
de OpenID4VP sobre BLE. No se debe asumir que una web móvil puede
implementar todas las capacidades BLE/NFC que tiene una app nativa.

------------------------------------------------------------------------

## 13. ¿Qué formato conviene investigar primero?

### SD-JWT VC

Parece un candidato razonable para la primera prueba conceptual de una
wallet web: - Se integra con tecnologías web. - Puede usarse en flujos
de presentación basados en OpenID4VP. - Permite divulgación selectiva. -
No obliga a implementar desde el inicio el modelo de proximidad BLE/NFC
de mdoc.

Esto no significa que sea siempre mejor que mdoc. Depende de los
verificadores, lectores, ecosistema y requisitos regulatorios.

### ISO mdoc

Es especialmente relevante si el objetivo exige: - Presentación
presencial de documentos móviles. - Interoperabilidad con lectores
mdoc. - Intercambio de proximidad mediante QR, BLE o NFC.

Pero su modelo de proximidad puede ser más complejo de implementar en
una wallet web debido a las restricciones y diferencias de las APIs de
navegador.

### OpenID4VP

Puede servir para presentar credenciales a través de un flujo web/HTTPS.
Para el caso concreto de holder-muestra-QR y lector-escanea, hace falta
comprobar el perfil de transporte elegido y su madurez.

------------------------------------------------------------------------

## 14. Qué no se puede afirmar todavía

Hay que evitar estas conclusiones incorrectas:

-   "Android permite que cualquier web use Keystore directamente".
-   "Safari permite que cualquier web use Secure Enclave".
-   "Credential Manager almacena las credenciales de cualquier sitio".
-   "Digital Credentials API es una wallet".
-   "Una passkey es una clave SSI".
-   "Una clave Web Crypto no exportable está protegida por hardware".
-   "Un QR de mdoc contiene la credencial".
-   "OpenID4VP siempre requiere que el verifier muestre el QR".
-   "OpenID4VP 1.0 incluye automáticamente cualquier transporte BLE".
-   "Una wallet web tiene las mismas garantías de seguridad que una
    wallet nativa".

La diferencia entre capacidad del estándar, API disponible y soporte
real de cada navegador/plataforma es central para esta investigación.

------------------------------------------------------------------------

## 15. Riesgos y preguntas pendientes

### Seguridad

-   ¿Cómo se protege la clave SSI en reposo?
-   ¿Qué ocurre si el dispositivo se pierde?
-   ¿Cómo se recupera una wallet si el usuario cambia de teléfono?
-   ¿Qué pasa si la passkey se sincroniza entre dispositivos?
-   ¿Cómo se protege la clave mientras está descifrada en memoria?
-   ¿Cómo se mitiga XSS y compromiso de la cadena de suministro
    JavaScript?
-   ¿Cómo se evita replay de presentaciones?
-   ¿Cómo se gestiona revocación o suspensión de credenciales?

### Compatibilidad

-   ¿Qué versiones de Chrome Android soportan WebAuthn PRF?
-   ¿Qué versiones de Safari iOS lo soportan?
-   ¿Qué autenticadores y passkeys ofrecen soporte efectivo?
-   ¿Se puede persistir y recuperar `CryptoKey` en IndexedDB en las
    plataformas objetivo?
-   ¿Qué APIs de BLE/NFC están disponibles en los navegadores móviles?
-   ¿Qué diferencias hay entre Android/Chrome y iOS/Safari?

### Interoperabilidad

-   ¿Qué wallets y verificadores reales soportan OpenID4VCI y OpenID4VP?
-   ¿Qué perfiles de SD-JWT VC están implementados?
-   ¿Qué lectores mdoc se espera soportar?
-   ¿Qué perfiles de transporte y QR utilizan los sistemas existentes?
-   ¿Qué requisitos impone el ecosistema de transporte público objetivo?

### Experiencia de usuario

-   ¿Se puede completar la emisión desde un QR sin crear una cuenta
    tradicional?
-   ¿Cómo se explica al usuario que debe guardar o proteger su wallet?
-   ¿Qué ocurre si borra los datos del navegador?
-   ¿Cómo se presenta una credencial rápidamente en un control
    presencial?
-   ¿Se puede evitar que el usuario tenga que abrir manualmente una web
    cada vez?

------------------------------------------------------------------------

## 16. Conclusión provisional

**Sí, es técnicamente posible construir una experiencia de emisión y
presentación de credenciales desde una web móvil, sin exigir una
aplicación nativa**, utilizando estándares existentes como OpenID4VCI,
OpenID4VP y formatos como SD-JWT VC, junto con Web Crypto, IndexedDB y
WebAuthn.

Pero hay una limitación importante:

> Una wallet web puede proteger datos y claves mediante mecanismos del
> navegador, y puede utilizar autenticadores del dispositivo para
> desbloquear operaciones. No puede garantizar por sí sola el mismo
> nivel de protección hardware y aislamiento que una wallet nativa que
> usa directamente Android Keystore o Apple Secure Enclave.

La opción WebAuthn + PRF merece investigación porque permite mejorar la
protección en reposo sin instalar una app. Sin embargo, la clave SSI
podría tener que estar disponible temporalmente en JavaScript para
firmar, y eso introduce riesgos que una implementación nativa puede
evitar o reducir.

Para proximidad presencial, mdoc/ISO 18013-5 ofrece un modelo
estandarizado de QR + BLE/NFC, pero la viabilidad de reproducirlo desde
un navegador móvil debe comprobarse por plataforma. OpenID4VP sobre
HTTPS puede ser una primera alternativa de presentación web, aunque no
resuelve automáticamente el caso de holder-muestra-QR.

### Conclusión en una frase

Podemos aspirar a una **wallet SSI web sin instalación**, con
almacenamiento cifrado y prueba de posesión; lo que no podemos prometer
todavía es seguridad hardware equivalente a una wallet nativa ni
compatibilidad universal con los flujos de proximidad.

------------------------------------------------------------------------

## 17. Fuentes y documentación para continuar

Las siguientes referencias son los puntos de partida documentales
identificados durante la investigación. Conviene revisar las versiones
vigentes y el soporte de cada plataforma antes de tomar decisiones de
arquitectura.

### Estándares

-   [OpenID for Verifiable Credential Issuance 1.0
    (OpenID4VCI)](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html)
-   [OpenID for Verifiable Presentations 1.0
    (OpenID4VP)](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html)
-   [W3C Verifiable Credentials Data Model
    2.0](https://www.w3.org/TR/vc-data-model-2.0/)
-   [W3C Digital Credentials
    API](https://www.w3.org/TR/digital-credentials/)
-   [W3C Web Authentication (WebAuthn)](https://www.w3.org/TR/webauthn/)
-   [WebAuthn PRF Extension
    Explainer](https://github.com/w3c/webauthn/wiki/Explainer:-PRF-extension)

### Android y Chrome

-   [Android Developers --- About storing digital
    credentials](https://developer.android.com/identity/digital-credentials)
-   [Android Developers --- Handle credential issuance with your holder
    app](https://developer.android.com/identity/digital-credentials/issuance)
-   [Chrome Developers --- Digital Credentials API
    issuance](https://developer.chrome.com/)
-   [Android Keystore
    system](https://developer.android.com/privacy-and-security/keystore)

### Apple

-   [Apple Developer --- Protecting keys with the Secure
    Enclave](https://developer.apple.com/documentation/security/protecting-keys-with-the-secure-enclave)
-   [Apple Developer ---
    IdentityDocumentServices](https://developer.apple.com/documentation/identitydocumentservices)

### Proximidad y mdoc

-   [ISO/IEC 18013-5 --- Personal identification --- ISO-compliant
    driving licence](https://www.iso.org/standard/69084.html)
-   [OpenID Foundation](https://openid.net/)

------------------------------------------------------------------------

## 18. Próximo paso de investigación recomendado

Antes de diseñar la arquitectura definitiva, conviene hacer una matriz
de compatibilidad con pruebas concretas en:

1.  Android + Chrome.
2.  Android + otro navegador relevante.
3.  iPhone + Safari.
4.  Passkeys sincronizadas y passkeys ligadas al dispositivo.
5.  WebAuthn PRF.
6.  Web Crypto + persistencia IndexedDB.
7.  Emisión OpenID4VCI.
8.  Presentación OpenID4VP.
9.  Presentación presencial con QR y BLE/NFC.

El resultado debería clasificar cada capacidad como: - **Estándar
definido:** existe una especificación. - **API disponible:** el
navegador o sistema expone una interfaz. - **Implementado:** hay soporte
real en una versión concreta. - **Probado:** funciona en dispositivos y
escenarios de prueba. - **Limitado/no soportado:** requiere wallet/app
nativa o un perfil alternativo.

Esa matriz permitirá decidir si la primera versión puede ser
completamente web o si el caso de proximidad obliga a incorporar una app
nativa o una wallet existente.
