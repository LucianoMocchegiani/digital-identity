**QUARKID 2.0**
**Análisis de Project Management**  
Gobierno de la Ciudad de Buenos Aires  
_Roadmap • Sprints • Estimaciones • Riesgos • Checklist PM_  
Versión 1.0  
Marzo 2026

## **01. Resumen Funcional del Proyecto**

QuarkID 2.0 es la evolución estratégica del ecosistema de identidad digital descentralizada del GCBA. El objetivo central es transformar la infraestructura SSI actual — basada en SDKs distribuidos y dependencias externas — en una plataforma centralizada, soberana y reutilizable para todo el gobierno.

### **1.1 El Problema que Resuelve**

La arquitectura actual (Quark 1.0) presenta limitaciones estructurales que bloquean su escalabilidad:
- Dependencia de nodos externos (Thuxlab/Extrimian) para operaciones críticas de identidad.
- Lógica SSI duplicada dentro de cada aplicación, generando inconsistencias y overhead de mantenimiento.
- Falta de gobernanza centralizada sobre emisión, verificación y estado de credenciales.
- Observabilidad limitada: sin trazabilidad end-to-end de operaciones SSI.
- Dificultad para incorporar nuevas aplicaciones al ecosistema sin replicar complejidad técnica.

### **1.2 La Solución: SCI — Servicio Central de Identidad**

Quark 2.0 introduce el SCI como núcleo arquitectónico. El SCI es una plataforma de microservicios API-first que encapsula toda la lógica SSI y la expone mediante APIs estándar. Las aplicaciones del GCBA consumen identidad digital como un servicio, sin necesidad de implementar lógica criptográfica internamente.  
El motor interno del SCI es Credo-TS, que implementa los protocolos SSI estándar (DIDComm, JSON-LD, W3C VCs).

**Capa y microservicios del SCI**

| **Capa del SCI** | **Microservicios** |
|---|---|
| Gateway y Seguridad | Quark-API (entrada), Quark-Auth (autenticación/RBAC), Quark-Vault (custodia de claves) |
| Gestión de Credenciales | Quark-VCs-Manager (ciclo de vida), Quark-VCs-Emitter (emisión), Quark-VCs-Verifier (validación), Quark-Credential-Status (estado) |
| Gestión de Identidades | Quark-DIDs-Resolver, Quark-Index (caché profunda), Quark-Web (did:web institucional), Quark-Recovery |
| Operaciones | Quark-Operations (bus de eventos), Quark-Batcher (batch blockchain/IPFS), Quark-Observer, Quark-Block (escritor blockchain), Quark-IPFS |
| Observabilidad | Quark-Explorer 2.0 (auditoría y trazabilidad completa) |

### **1.3 Cambios Clave: 1.0 → 2.0**

| **Dimensión** | **Quark 1.0 → Quark 2.0** |
|---|---|
| Arquitectura | SDKs distribuidos en apps → API-first centralizada en SCI |
| Lógica SSI | Dentro de cada aplicación → Encapsulada en microservicios del SCI |
| Nodo SSI | Dependencia externa (Thuxlab) → Nodo On-Prem propio del GCBA |
| Custodia de claves | Distribuida por aplicación → Centralizada en Quark-Vault |
| Monitoreo | Limitado y parcial → Quark-Explorer 2.0 con auditoría completa |
| Integración de apps | Compleja, requiere implementar SSI → Simple, consumir APIs |

### **1.4 Alcance del MVP (Primer Entregable)**

El MVP del Primer Entregable tiene como objetivo demostrar el funcionamiento end-to-end del SCI mínimo con la funcionalidad de identidad DID:web. NO incluye el ciclo completo de Verifiable Credentials (eso viene en Fase 2).

 

Hito técnico principal del MVP: DID:web resoluble end-to-end (generación → publicación → resolución → verificación). Esto habilita la interoperabilidad futura con el ecosistema SSI internacional.

Explícitamente excluido del MVP: VCs completos (issuer/verifier flows), recovery avanzado, eventos asíncronos con colas, IPFS, alta disponibilidad multi-región.

## **02. Roadmap por Fases y Sprints**

### **2.1 Roadmap Completo (2026–2027)**

| **Fase** | **Período** | **Alcance y Estado** |
|---|---|---|
| **Fase 1 — Fundaciones de Plataforma** | **Mar – Jun 2026 (MVP)** | **SCI mínimo (Gateway, Auth, Resolver, Index, Web), DID:web end-to-end, Wallet básica, Explorer básico, SDK base, CI/CD. → 30–35% del sistema completo.** |
| **Fase 2 — Identidad Funcional** | **Jul – Sep 2026** | **Servicios de credenciales (VC Issuer, Verifier, Manager, Status), Wallet ampliada, Explorer ampliado, Observabilidad. → 50–60% del sistema.** |
| **Fase 3 — Plataforma SSI Completa** | **Oct – Dic 2026** | **Estándares SSI (DIDComm/WACI, OpenID4VC), Vault de claves, recovery de identidad, servicios asincrónicos, IPFS, batch/block services. → 60–70% del sistema.** |
| **Fase 4 — Ecosistema y Escalabilidad** | **Ene – Jun 2027** | **Alta disponibilidad, migración desde Quark 1.0, integración con aplicaciones públicas y organismos, retiro de librerías antiguas. → 80–90%.** |
| **Fase 5 — Plataforma Madura** | **2do semestre 2027** | **Interoperabilidad internacional, integraciones regionales, mejoras de seguridad, gobierno de identidad. → 100%.** |

### **2.2 MVP — Planificación Detallada por Sprints**

Duración estimada: 10–12 semanas (5–6 sprints de 2 semanas). Período sugerido: 16 de marzo → 5 de junio 2026. Equipo estimado: 5 desarrolladores.

#### **FASE 1 — Fundaciones (Semanas 1–2 \ Sprint 1)**

Objetivo: Que todo sea deployable e integrable. El SCI responde /health en todos los servicios.

| **Entregable** | **Criterio de Done** |
|---|---|
| Estructura multi-repo (8 repos creados con plantillas) | Repos creados, build reproducible en cada uno |
| CI/CD básico por repo (build/test/push/deploy) | Build + tests + Docker image en cada push |
| Docker por servicio (Dockerfile + compose/helm mínimo) | docker run y health OK por servicio |
| Logging estructurado (formato JSON, campos comunes) | Logs incluyen correlationId, servicio, endpoint, status, latencia |
| Contrato correlationId (header obligatorio o generado) | Propagado downstream en todos los servicios |
| SDK mínimo @quarkid (cliente HTTP + auth wrapper) | Wallet llama /health y endpoint auth exitosamente |
| README por repo (guía de run local + CI/CD) | Nuevo dev levanta stack en menos de 1 hora |
| Definition of Done transversal (checklist QA) | Adoptado en template de PR |

Estimación épica Plataforma: 34 Story Points

#### **FASE 2 — Seguridad y Gateway (Semanas 3–4 \ Sprint 2)**

Objetivo: SCI usable con autenticación real. Wallet puede autenticarse y consumir SCI.

| **Entregable** | **Criterio de Done** |
|---|---|
| Quark Auth: Modelo Apps/API Keys + Postgres | Crear/rotar/revocar API key con audit básico |
| Quark Auth: Emisión JWT (login/app auth) | Token válido con exp, iss y scopes correctos |
| Quark Auth: Verificación JWT + RBAC/scopes | Scopes aplican a rutas declaradas |
| Quark Auth: Cache Redis (tokens/keys) | Cache hit ratio observable, TTL definido |
| Quark Auth: Scopes mínimos (dids:create, dids:resolve, web:publish) | Scopes aplicados y testeados |
| Gateway: Routing por servicio bajo /v1 | Matriz de rutas versionadas sin rutas sin versión |
| Gateway: Middleware auth + correlationId propagado | Rechaza 401/403 correctamente, propaga downstream |
| Gateway: Rate limit básico por API key/token | 429 al exceder, configurable |
| Wallet: Login real + obtener token JWT | Token usable contra gateway |
| Threat model mínimo Auth (STRIDE-lite) | Riesgos priorizados con mitigaciones documentadas |

Estimación épica Auth: 40 SP \ Épica Gateway: 32 SP

#### **FASE 3 — Dominio DID:web (Semanas 5–8 \ Sprints 3–4)**

Objetivo: DID:web funcional end-to-end. HITO TÉCNICO MÁS IMPORTANTE del MVP.

| **Entregable** | **Criterio de Done** |
|---|---|
| Spec interna DID Document mínimo (schema + ejemplos) | Incluye id, verificationMethod, relaciones mínimas |
| Quark Web: endpoint publish/update DID | Publica y sirve el DID Document correcto |
| Quark Web: servir /.well-known/did.json (y paths) | URL devuelve documento con status 200 |
| Quark Web: versionado simple (metadata updated/versionId) | Update produce nueva versión lógica |
| Quark Index: tabla DID + JSONB + estado publicación | Lookup menor a X ms con constraints |
| Quark Index: cache Redis de resolución (TTL + métricas) | Hit/miss observable |
| Quark Resolver: GET /resolve/:did con flujo completo | Funciona end-to-end con wallet |
| Quark Resolver: negociación de Accept y contentType metadata | Responde contentType correcto |
| Quark Resolver: manejo de errores estándar (notFound, invalidDid) | Errores consistentes con registries |
| Quark Resolver: validación didDocument.id == did | Rechaza mismatch |
| Wallet: generar DID:web + DID Document JSON(-LD) | DID válido con prefijo did:web, documento válido contra schema |
| Wallet: publicar DID + resolver DID + mostrar DID Document | End-to-end funcional y demostrable |
| Checklist de seguridad did:web (TLS/DNS/CORS) | Aplicado a configuración de Web |

Estimación épica DID Domain: 60 SP (hito técnico central)

#### **FASE 4 — Wallet MVP (Semanas 9–10 \ Sprint 5)**

Objetivo: Producto demostrable con UX completa.

| **Entregable** | **Criterio de Done** |
|---|---|
| Dashboard + estado de publicación visible | Estado visible y consistente en UI |
| Manejo de errores + validaciones completas | Cubre 401/403/404/409/5xx con mensajes accionables |
| Scopes refinados (beyond mínimos) | Menor riesgo de over-permission |
| Guía de demo (script de 10 minutos) | Demo reproducible sin intervención manual |

Estimación épica Wallet: 38 SP

#### **FASE 5 — Explorer + Hardening (Semanas 11–12 \ Sprint 6)**

Objetivo: Trazabilidad operativa y MVP listo para entrega.

| **Entregable** | **Criterio de Done** |
|---|---|
| Explorer: modelo de eventos/logs (schema) | Incluye correlationId, servicio, endpoint, status, latencia |
| Explorer: ingesta de logs (push o pull) | Eventos almacenados y consultables |
| Explorer: query por correlationId (menos de X ms para 30 días) | Tiempo de respuesta aceptable |
| Explorer: vista timeline Gateway→Auth→Resolver→Web | Secuencia visible con latencias |
| Hardening: input validation (no injections triviales) | SAST básico + validaciones input principales |
| Tests E2E (E2E-01 al E2E-04 documentados) | Happy path + errores cubiertos |
| Documentación técnica por proyecto (guía + screenshots) | Cubre troubleshooting básico |
| Checklist seguridad logging (masking tokens, minimizar PII) | Tokens/JWT no logueados en claro |

Estimación épica Explorer: 28 SP

### **2.3 Repositorios a Crear (Infraestructura)**

8 repos independientes con CI/CD propio:
- quark-sdk-2.0
- quark-api-gateway
- quark-auth
- quark-index
- quark-resolver
- quark-wallet-2.0
- quark-explorer-2.0

Bases de datos / infra mínima obligatoria: postgres-gateway, redis-gateway, postgres-auth, redis-auth, postgres-quark-didweb, postgres-index, redis-index, redis-resolver, postgres-explorer, redis-explorer.

## **03. Estimaciones — Análisis y Opinión del PM**

### **3.1 Resumen de Estimaciones del MVP**

| **Épica** | **Story Points (SP)** |
|---|---|
| Plataforma (CI/CD, Docker, SDK, logging) | 34 SP |
| Auth (API Keys, JWT, RBAC, Postgres, Redis) | 40 SP |
| Gateway (routing, versionado, rate limit, auth) | 32 SP |
| DID Domain (Web + Index + Resolver) | 60 SP |
| Wallet Quark 2.0 | 38 SP |
| Explorer 2.0 | 28 SP |
| TOTAL ESTIMADO MVP | 232 SP |

Distribución en tiempo: 5–6 Sprints de 2 semanas = 10–12 semanas. Equipo base: 5 desarrolladores.

### **3.2 Análisis Crítico de las Estimaciones**

| **OPINIÓN GENERAL DEL PM: LAS ESTIMACIONES SON AJUSTADAS Y TIENEN RIESGO REAL DE DESVÍO** |
|---|
| El cronograma es técnicamente posible pero NO tiene margen de error. Un equipo de 5 devs en 12 semanas con 8 repos nuevos, CI/CD desde cero y un stack SSI complejo es ambicioso. |
| La épica DID Domain (60 SP en 2 sprints) es el cuello de botella más crítico: es el núcleo técnico más complejo y está en el centro del camino crítico. |
| La Fase 1 (Plataforma/Fundaciones) suele subestimarse sistemáticamente: setup de repos, CI/CD, convenciones y SDK es trabajo real que frecuentemente duplica su estimación inicial. |
| El MVP está bien acotado en su exclusión de VCs completos, IPFS y HA multi-región. Eso es correcto y es lo que lo hace alcanzable. |

Detalle por épica:

| **Épica** | **Estimación** | **Opinión del PM** |
|---|---|---|
| **Plataforma** | **34 SP / 2 sem.** | **Ajustada. Multi-repo + CI/CD + SDK + convenciones en 2 semanas es posible pero no tiene buffer. Si hay bloqueos de infra con ASI/OpenShift, puede extenderse a 3 semanas.** |
| **Auth** | **40 SP / 2 sem.** | **Razonable. JWT + RBAC + multi-tenancy (Apps/API Keys) es un módulo bien entendido. El riesgo está en la integración temprana con Gateway en el mismo sprint.** |
| **Gateway** | **32 SP / 2 sem.** | **Razonable. Depende de Auth, por lo que si Auth se extiende, Gateway se retrasa en cadena. Considerar paralelizar donde sea posible.** |
| **DID Domain** | **60 SP / 4 sem.** | **El mas CRITICO. Es el módulo más complejo del MVP (3 microservicios: Web + Index + Resolver). 60 SP en 4 semanas con 5 devs es posible SOLO si no hay ambiguedades funcionales al inicio del sprint.** |
| **Wallet** | **38 SP / 2 sem.** | **Razonable. Depende 100% de que DID Domain esté funcional. Si DID Domain se atrasa, Wallet no puede avanzar en las integraciones. Diseño de UI puede iniciarse antes.** |
| **Explorer** | **28 SP / 2 sem.** | **La más conservadora. Explorer básico (correlationId + timeline) es alcanzable en 2 semanas. El riesgo es que se incluya scope adicional en las últimas semanas.** |

### **3.3 Principales Alertas de Estimación**
- ALERTA 1 — Bloqueo de Infra ASI/OpenShift: Los entornos DEV/HML en OpenShift del GCBA pueden generar retrasos de días o semanas si la provisión de recursos (repos, CI/CD, bases de datos) no está gestionada proactivamente ANTES de iniciar el sprint 1.
- ALERTA 2 — DID Domain como cuello de botella: Si la épica DID Domain se extiende de 4 a 5 semanas, el impacto se propaga directamente a Wallet y al deadline del MVP.
- ALERTA 3 — Falta de definiciones funcionales al inicio: La spec interna del DID Document mínimo y las convenciones de did:web deben estar cerradas ANTES del Sprint 3. Ambigüedades en este punto son el mayor generador de retrabajo.
- ALERTA 4 — Equipo dividido 1.0/2.0: Si los mismos devs tienen soporte activo de Quark 1.0, la velocidad efectiva en 2.0 se reduce. Una estimación realista debería asumir que 5 devs dedicados 100% es optimista si hay soporte paralelo.
- ALERTA 5 — Sin buffer en el cronograma: No hay sprint de buffer ni tiempo de contingencia. Para un proyecto de esta complejidad técnica, se recomienda agregar al menos 2 semanas al cronograma comunicado al cliente o escalar las expectativas con el GCBA.

### **3.4 Recomendación de Cronograma Realista**

| **Escenario** | **Descripción** |
|---|---|
| Escenario Optimista (12 sem.) | Todo el equipo 100% dedicado, sin bloqueos de infra, definiciones funcionales cerradas al inicio. Probabilidad: 30%. |
| Escenario Realista (14–15 sem.) | Algún bloqueo de infra en Semana 1-2, un sprint de DID Domain que necesita extensión parcial. Entrega MVP: mediados a fines de junio 2026. Probabilidad: 55%. |
| Escenario Pesimista (16–18 sem.) | Soporte activo de 1.0 que reduce velocidad del equipo, bloqueos de infra ASI, ambiguedades en DID Domain. Entrega MVP: julio 2026. Probabilidad: 15%. |

Recomendación al GCBA: Comunicar el milestone de MVP para fines de junio con la aclaración de que el hito técnico clave (DID:web resoluble) puede alcanzarse antes, y que el hardening y la documentación completan el entregable.

## **04. Checklist y Tareas del PM**

Todas las responsabilidades que el PM debe gestionar para llevar adelante el proyecto de forma ordenada, desde la planificación hasta la entrega.

### **4.1 Fase de Kickoff y Planificación Inicial**

#### **Antes del Sprint 1**

| **Tarea** | **Descripción y Output Esperado** |
|---|---|
| Reunión de Kickoff con GCBA | Alinear objetivos, alcance del MVP, fechas clave, canales de comunicación y criterios de aceptación. Output: Acta de kickoff firmada. |
| Reunión de Kickoff con el equipo técnico | Presentar arquitectura 2.0, épicas del MVP, convenciones de trabajo, DoD, ceremonias de scrum. Output: Acta interna. |
| Gestión de accesos e infra con ASI | Solicitar creación de repos, pipelines CI/CD, ambientes DEV/HML, bases de datos. CRÍTICO: iniciar esto ANTES del Sprint 1 para evitar bloqueos. |
| Definir estructura de tracking (Jira/Notion/Linear) | Crear proyecto, epics, sprints, templates de tickets. Definir estados del kanban del proyecto. |
| Confirmar dedicación del equipo | Documentar % de dedicación de cada miembro entre soporte 1.0 y desarrollo 2.0. Input para ajuste de estimaciones. |
| Crear planilla de seguimiento de riesgos | Risk register inicial con los 5 riesgos identificados, probabilidad, impacto y plan de mitigación. |
| Definir cadencia de ceremonias | Sprint planning, daily standup, sprint review, retrospectiva. Definir duración, participantes y formato. |
| Mapear dependencias externas críticas | ASI (OpenShift, repos, CI/CD), GCBA (validaciones funcionales), equipo (disponibilidad). Documentar en el project charter. |

### **4.2 Gestión de Requerimientos y Backlog**

| **Tarea** | **Descripción y Output Esperado** |
|---|---|
| Cerrar spec DID Document mínimo ANTES del Sprint 3 | Documento técnico que define: estructura del DID Document JSON(-LD), tipos de verification method (JsonWebKey2020), convención de naming did:web. Owner: Arquitecto. Aprobado por PM antes de Sprint 3. |
| Crear y priorizar el backlog completo del MVP | Épicas → Historias de usuario → Tareas técnicas. Prioridad P0/P1/P2 documentada. Estimaciones en SP aprobadas por el equipo. |
| Definir criterios de aceptación por historia | Cada US debe tener: descripción, AC, DoD, dependencias, estimación. Usar template estándar. |
| Gestionar el scope del MVP activamente | Cualquier request de scope adicional (new features, "pequeñas mejoras") debe pasar por proceso de change request formal antes de ser incluido. |
| Sesiones de refinamiento de backlog | Refinement semanal o bi-semanal con el equipo técnico para estimar, clarificar y desbloquear historias del próximo sprint. |
| Documentar decisiones de arquitectura (ADRs) | Cada decisión técnica relevante (ej: Redis vs no Redis en Resolver, formato del DID Document) debe quedar documentada como ADR. Owner: Arquitecto con validación del PM. |

### **4.3 Documentación Técnica a Gestionar**

El PM es responsable de garantizar la existencia, calidad y entrega en tiempo de la documentación. No necesariamente de escribirla, pero sí de trackearlo como entregable.

| **Tipo de Documento** | **Descripción y Responsable** |
|---|---|
| README por repositorio | Guía de run local, variables de entorno, comandos CI/CD. Responsable: Dev owner del repo. Criterio: nuevo dev levanta stack en menos de 1 hora. |
| Documentación de APIs (OpenAPI/Swagger) | Spec OpenAPI 3.0 por cada microservicio. Debe incluir: endpoints, request/response schemas, códigos de error, ejemplos. Responsable: Dev backend. Revisado por QA. |
| Colecciones Postman/Bruno por microservicio | Colección con todos los endpoints del servicio, requests de ejemplo, variables de entorno por ambiente (DEV/HML). Entregable obligatorio al GCBA. |
| Documentación funcional (casos de uso) | Descripción de flujos funcionales: crear DID:web, publicar, resolver. Dirigida a stakeholders no técnicos del GCBA. Responsable: Analista funcional / PM. |
| Casos de prueba (Plan de Testing) | Casos E2E documentados (E2E-01 al E2E-04 mínimo), casos de prueba por épica, checklist de seguridad OWASP API Top 10. Responsable: QA. |
| Arquitectura del sistema (diagrama C4 o similar) | Diagrama de arquitectura actualizado del MVP: microservicios, DBs, flujos de datos, integraciones. Nivel de contexto + contenedores. Responsable: Arquitecto. |
| Guía de demo del MVP | Script de demostración reproducible en 10 minutos. Debe cubrir el flujo E2E-01. Responsable: PM con equipo técnico. |
