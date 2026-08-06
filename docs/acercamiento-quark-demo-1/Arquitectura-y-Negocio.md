# QUARK ID 2.0 — SCI Arquitectura & Negocio

Vamos a explicar la Arquitectura e Impacto en Negocio del nuevo sistema de Quark ID 2.0 iniciando por el **SCI, Servicio Central de Identidad**, definiendo cómo funcionan cada una de sus partes, para qué sirven, cómo se interconectan y cómo está estructurado.

## ÍNDICE
1. Servicio Central de Identidad (SCI)  
2. DIDs & VCs  
3. CREDO + SCI  
4. Nuevo SDK Quark ID 2.0  
5. Nuevo Quark Explorer 2.0  
6. Nueva Documentación Quark 2.0  
7. Nueva Arquitectura SCI Quark 2.0  
8. Proceso de Registro de Identificador (DID)  
9. Flujo de Emisión de Documentos  
10. Flujo de Verificación de Documentos  
11. Microservicio Quark API Gateway  
12. Microservicio Quark Auth  
13. Microservicio Quark Credential Status  
14. Microservicio Quark Recovery  
15. Microservicio Quark Vault  
16. Microservicio Quark VCs Manager  
17. Microservicio Quark VCs Verifier  
18. Microservicio Quark VCs Emiter  
19. Microservicio Quark DIDs Resolver  
20. Microservicio Quark Index  
21. Microservicio Quark Operations  
22. Microservicio Quark Observer  
23. Microservicio Quark Block  
24. Microservicio Quark Web  
25. Microservicio Quark Batcher  
26. Microservicio Quark IPFS  
27. IPFS & NODOS BLOCKCHAIN

---

## 1. Servicio Central de Identidad (SCI)

El **Servicio Central de Identidad (SCI)** es el "cerebro" y el núcleo estructural de la nueva arquitectura de Quark ID 2.0. Evoluciona el sistema desde un modelo de librerías y SDKs distribuidos hacia una plataforma centralizada, robusta y basada en microservicios.

### ¿Para qué sirve?

El SCI actúa como el **único punto de contacto (Gateway de identidad)** para todas las operaciones de Identidad Auto-Soberana (SSI) dentro y fuera del Gobierno de la Ciudad.

**Sus propósitos principales son:**
- **Centralizar la lógica SSI:** encapsula toda la complejidad de la identidad descentralizada (basada en el motor Credo-TS), evitando que cada aplicación tenga que implementar su propia lógica.  
- **Eliminar la dependencia de SDKs:** transforma la plataforma en un modelo **API-first**; los integradores consumen una API estandarizada en lugar de embeber código complejo.  
- **Garantizar gobernanza y trazabilidad:** control estricto (API Keys, trazabilidad end-to-end) y alimentación de herramientas de auditoría como **Quark Explorer 2.0**.  
- **Asegurar independencia tecnológica:** opera como un "Nodo 2.0" agnóstico para que el GCBA sea dueño de su infraestructura y no dependa de proveedores externos.

### ¿Cómo funciona?

El SCI no es un único servidor monolítico, sino un **ecosistema de microservicios desacoplados** (Node/NestJS, Rust, Golang, TypeScript/JavaScript, Credo y estándar DID W3C). **Funciona mediante la especialización de tareas:**
1. **Modelo API-first:** toda solicitud entra por **Quark-API** (Gateway).  
2. **Seguridad obligatoria:** **Quark-Auth** valida permisos (RBAC/Scopes).  
3. **Delegación por dominios:** emisión → **Quark-VCs-Manager/Emitter**; identidades → **Quark-DIDs-Resolver**.  
4. **Procesamiento asincrónico:** colas (**Quark-Operations**) y lotes (**Quark-Batcher**) evitan bloqueos, especialmente con blockchain.

### ¿Con qué se conecta?

El SCI establece tres niveles de conexión:

**1) Entrantes (quién lo consume):**  
Sistemas Verificadores, Emisores y controles de Acceso; Wallets institucionales (miBA, Quark Wallet, BAX); a futuro Quark IoT (dispositivos) y Quark PoS (puntos de servicio).

**2) Internas (bases y colas):**  
**PostgreSQL** (índices, auditoría, catálogos), **Redis** (cachés), **RabbitMQ** (bus de eventos).

**3) Salientes (infra técnica y descentralizada):**  
- **Redes blockchain:** adaptadores **Quark-Block** / **Quark-Observer** hacia nodos (zKSync, Ethereum, RSK, Polygon) y nodo On-Prem GCBA.  
- **Red IPFS:** respaldo e indexación de documentos públicos.  
- **Bóveda (KMS/HSM):** gestión de claves (HashiCorp Vault) para firmas seguras; las privadas no se exponen.  
- **Infra Web institucional:** soporte did:web.

---

## 2. DIDs & VCs

Dentro del ecosistema, los **DIDs** (Identificadores Descentralizados) y las **VCs** (Credenciales Verificables) son los dos componentes fundamentales que habilitan confianza digital.

### A. DIDs (Identificadores Descentralizados)

**¿Para qué sirven?** Actúan como el **"DNS" de la red**. Representan identidades criptográficas (usuarios, instituciones, emisores o dispositivos). Permiten encontrar el **Documento DID** (claves públicas y endpoints seguros).

**¿Cómo funcionan dentro del SCI?**  
- **Quark-DIDs-Resolver:** búsqueda/traducción modular (did:quarkid, did:web) consistente y rápida.  
- **Quark-Index:** caché/indexador para evitar consultas lentas a blockchain/IPFS.  
- **Quark-Web:** hosting centralizado para did:web en infraestructura gubernamental.

### B. VCs (Credenciales Verificables)

**¿Para qué sirven?** Afirmaciones digitales verificables (licencia, permiso, Credencial Ciudadana) estándar **W3C JSON-LD**; prueban información de forma segura, auditable, sin intermediarios.

**¿Cómo funcionan dentro del SCI?**  
- **Quark-VCs-Manager:** orquestador del ciclo de vida.  
- **Quark-VCs-Emitter:** fabrica y firma; consulta **Quark-Credential-Status** (plantillas, esquemas, políticas).  
- **Quark-VCs-Verifier:** valida matemáticamente firmas e integridad; verifica revocación vía VDR.

**Conexiones clave (DIDs + VCs):**

**1) Exterior (Productos):** exposición exclusiva por **Quark-API**; integradores (Wallets, Verificadores, Emisores) consumen la API estándar del SCI.

**2) Seguridad y Criptografía internas:**  
**Quark-Auth** (tokens/permisos) y **Quark-Vault (KMS)** (operaciones criptográficas sin exponer claves privadas).

**3) Infra descentralizada:**  
**Quark-Block / Quark-Batcher** para escrituras a blockchain/IPFS (estado de revocación, info pública).

**Conclusión:** DIDs resuelven identidades ("quién es quién"); VCs son los atributos verificables que se intercambian. El **SCI** conecta ambos de forma centralizada, segura, **API-first**, auditable y escalable.

---

## 3. CREDO + SCI

A diferencia de implementaciones monolíticas, en Quark 2.0 **Credo** opera como **motor de protocolos** (credenciales JSON-LD, DIDComm) y delega responsabilidades a microservicios especializados del SCI.

### 1) ¿Cómo funciona Credo y con qué se conecta?

Los Agentes (Issuer, Holder, Verifier) **no guardan estado ni claves privadas localmente**. Usan **adaptadores (bridges)** HTTP hacia microservicios del SCI:

- **Quark-Vault (KMS Service):**  
  - *Conexión:* KeyManagementModule con **ExternalKeyManagementService**.  
  - *Función:* generar claves, firmar o cifrar **sin manipular la privada**; el KMS realiza la operación y devuelve resultado.

- **Quark-Wallet Service (Persistencia):**  
  - *Conexión:* **ExternalWalletStorageService**.  
  - *Función:* persistir estados internos de Credo (conexiones, credenciales en curso) vía REST en la Wallet (DB distribuida).

- **Quark-DIDs-Resolver / VDR Service:**  
  - *Conexión:* **CustomDidRegistrar** y **CustomDidResolver**.  
  - *Función:* registrar nuevos DIDs o resolver Documentos DID (el "DNS" para endpoints).

### 2) ¿Qué pasa con los SDKs en Quark 2.0?

**Problema v1.0:** ~30 librerías/SDKs embebidas en productos (acoplamiento, dependencias cruzadas, alto costo de mantenimiento).

**Solución v2.0 — “Menos SDK en productos, más SCI”:**  
1. **SDKs delgados consolidados:** paquetes mínimos (@quarkid/agent, @quarkid/vcs, @quarkid/did, @quarkid/signs). Wrappers que aplican perfiles GCBA; no duplican lógica de Credo.  
2. **Uso Interno:** estos SDKs **se usan dentro del SCI**, no se distribuyen a integradores.  
3. **Modelo API-first para productos:** productos satélite **no embeben** lógica SSI ni SDKs (salvo offline); **consumen Quark-API**.

**Resumen:** Credo JS aporta estándar/”cerebro”; microservicios aportan fuerza/seguridad/persistencia; SDKs 2.0 son el **pegamento institucional interno**. El exterior consume **APIs limpias**.

---

## 4. Nuevo SDK Quark ID 2.0

Reestructuración profunda para integrar SSI en el ecosistema del GCBA.

### ¿Para qué sirve?
- **Capa Quark institucional (wrapper):** aplica configuraciones oficiales, perfiles de seguridad y políticas de firma GCBA.  
- **Estandarizar integraciones:** librerías mínimas y estables (contratos/interfaces) para integraciones consistentes.

### ¿Cómo funciona? (Thin Quark Layer, Strong Credo Core)
Librerías especializadas:
1. **@quarkid/agent:** perfiles (issuer, verifier, holder), entornos y defaults de seguridad.  
2. **@quarkid/vcs:** ciclo de vida de VCs (emisión/verificación) con plantillas oficiales y retrocompatibilidad.  
3. **@quarkid/signs:** firmas y políticas criptográficas; integración con Vault/KMS y trazabilidad.  
