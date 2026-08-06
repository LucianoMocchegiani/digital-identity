# Resumen: Qué hay que hacer para que QuarkID funcione con EUDI Wallet

## El problema en una línea

QuarkID 2.0 fue pensado en una fase inicial como un **ecosistema enfocado en sus propios flujos internos**: puede comunicarse consigo mismo pero aún no con wallets externas. Una wallet europea no puede recibir ni presentar credenciales con nuestro sistema porque hablan "idiomas" distintos.

---

## ¿Qué es EUDI Wallet?

Es el estándar de identidad digital de la Unión Europea. Cada ciudadano europeo tendrá una wallet en su celular con la que puede demostrar quién es, recibir documentos digitales (carnet de conducir, título universitario, etc.) y presentarlos ante cualquier organismo europeo.

Para que QuarkID pueda interoperar con ese ecosistema, hay que adoptar los mismos protocolos que ellos usan.

---

## ¿Qué usa EUDI que nosotros no usamos hoy?

### 1. Una forma diferente de identificar a las personas

Hoy en QuarkID cada persona tiene un identificador propio de nuestro sistema (`did:quark`). EUDI usa identificadores que viven **dentro del celular del usuario**, no en un servidor nuestro. Son auto-contenidos: el propio identificador lleva adentro la clave criptográfica del dueño.

**Qué hay que hacer:** Agregar soporte para tres tipos de identificadores estándar además del nuestro:
- Uno para el celular del usuario (muy liviano, sin red)
- Uno para la wallet cuando habla con issuers europeos
- Uno para leer los identificadores de organizaciones que publican su identidad en la web

Impacto: es un cambio relativamente pequeño en la configuración del agente.

---

### 2. Un protocolo de emisión y verificación distinto

Hoy emitimos y verificamos credenciales usando un protocolo de mensajería privada (como un chat cifrado entre partes). EUDI usa un protocolo web estándar basado en **OAuth2** (el mismo mecanismo que usás cuando hacés "Login con Google"), adaptado para credenciales digitales.

Tiene dos partes:
- **Emisión (OID4VCI):** La persona escanea un QR, la wallet pide la credencial al emisor y la recibe firmada digitalmente. Todo por HTTPS, como una API web normal.
- **Verificación (OID4VP):** El verificador pide mostrar una credencial, la wallet presenta solo los datos necesarios y el verificador los valida. También por HTTPS.

**Qué hay que hacer:** Agregar estos dos módulos al agente del holder, del issuer y del verifier. Son módulos que ya existen en la librería que usamos (Credo-TS), solo hay que activarlos.

---

### 3. Un formato de credencial diferente

Hoy las credenciales son documentos JSON con una firma adjunta (W3C JSON-LD). EUDI usa un formato llamado **SD-JWT**: credenciales en formato JWT donde el usuario puede elegir qué campos mostrar y cuáles ocultar (por ejemplo, mostrar que es mayor de edad sin revelar la fecha de nacimiento exacta).

**Qué hay que hacer:** Activar el módulo SD-JWT en los tres agentes (emisor, holder, verificador). También ya existe en la librería.

---

### 4. Un mecanismo de "vinculación" de credencial al dueño

Cuando el issuer emite una credencial, necesita asegurarse de que solo el dueño legítimo pueda presentarla. Para esto, embebe la clave pública del dueño dentro de la credencial. Al momento de presentarla, el holder firma con su clave privada para demostrar que es el mismo.

**Qué hay que hacer:** Crear un pequeño componente (unas 30 líneas de código) que decida qué tipo de clave usar según lo que soporte el issuer. Es lógica nueva pero acotada.

---

### 5. Cambio en cómo se usa el tipo de clave criptográfica

Hoy todo el sistema usa un solo tipo de clave criptográfica (Ed25519). EUDI exige también soporte para **P-256**, que es el estándar en el hardware de seguridad de los celulares modernos (tanto iOS como Android tienen soporte nativo).

**Qué hay que hacer:** Eliminar una restricción interna en el código que castea todo a Ed25519. Es una corrección puntual.

---

### 6. Nueva forma de exponer las funciones al resto del sistema

Los flujos actuales funcionan con eventos asíncronos (el sistema espera notificaciones). Los flujos EUDI son síncronos (como una llamada a una API: preguntás y esperás la respuesta en el momento).

**Qué hay que hacer:** Crear funciones auxiliares que encapsulen estos flujos síncronos para que los microservicios NestJS los puedan llamar. Los flujos actuales no se tocan.

---

## Lo que NO hay que cambiar

- El sistema de almacenamiento de claves (ya soporta P-256)
- El sistema de base de datos del wallet
- El transporte DIDComm existente (sigue funcionando para flujos actuales)
- Los listeners de issuer y verifier actuales

La idea es **sumar capacidades**, no reemplazar lo que existe.

---

## Resumen en tabla

| Qué hay que hacer | Dónde | Tamaño |
|---|---|---|
| Agregar soporte para identificadores estándar (did:key, did:jwk, did:web, did:peer) | Configuración del agente | Pequeño |
| Activar módulos de emisión/verificación EUDI (OID4VCI + OID4VP) | Agente holder, issuer, verifier | Medio |
| Activar módulo de credenciales con divulgación selectiva (SD-JWT) | Los tres agentes | Pequeño |
| Crear el componente de vinculación de credencial | Nuevo archivo utilitario | Pequeño |
| Corregir restricción de tipo de clave (P-256) | Un archivo existente | Mínimo |
| Crear funciones para flujos síncronos OID4VC | Nuevo módulo auxiliar | Medio |

---

## Estimación de tiempo

Tomando como referencia el componente Explorer 2.0 del roadmap actual — estimado en **28 Story Points / 2 semanas** con 5 desarrolladores — este trabajo de interoperabilidad EUDI es de complejidad y alcance similar:

| Componente | Story Points estimados |
|---|---|
| Soporte de identificadores adicionales (did:key, did:jwk, did:web, did:peer) | 5 SP |
| Activación módulos OID4VCI + OID4VP en los tres agentes | 10 SP |
| Activación módulo SD-JWT + integración en los tres agentes | 6 SP |
| Componente de vinculación de credencial (`credentialBindingResolver`) | 3 SP |
| Corrección restricción P-256 + tests | 3 SP |
| Módulo auxiliar flujos síncronos OID4VC | 6 SP |
| **Total estimado** | **~33 SP** |

**Tiempo estimado: 2 semanas** con el mismo equipo base, asumiendo que no hay ambigüedades funcionales al inicio y que la librería Credo-TS 0.6.x está disponible en el entorno. El riesgo principal es la integración con los flujos DIDComm existentes (asegurarse de que no rompan al agregar los módulos nuevos), que puede agregar 2–3 días de trabajo de testing.
