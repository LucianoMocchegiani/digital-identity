# Tech Stack Homologado — ASI GCABA
**ES0901 v6.2 — Anexo II — Marzo 2026**

> Referencia rápida de tecnologías permitidas. Las versiones patch iguales o superiores a la mínima homologada son válidas dentro de la misma rama `X.Y.x`. Se tolera **1 versión de estándar anterior** con notificación; 2 versiones atrás bloquea el despliegue.

---

## Lenguajes

| Lenguaje | Versiones Homologadas | Scope |
|----------|-----------------------|-------|
| PHP | 8.2.30 · 8.3.29 | Web |
| Python | 3.11.13 · 3.12.12 | Web + Mobile |
| Java (OpenJDK) | 17.0.17 · 21.0.9 | Web + Mobile |
| Node.js | 20.20.0 · 22.22.0 · 24.13.0 | Web |
| Kotlin | 2.2.21 · 2.3.0 | Mobile |
| Swift | 6.0 · 6.1 · 6.2 | Mobile (solo nativo iOS) |

> **Node.js:** Gestor de paquetes homologado = **NPM**. YARN no está autorizado.
> **Kotlin:** Verificar compatibilidad con las versiones homologadas de Java.

---

## Frameworks Frontend

| Framework | Versiones Homologadas | Tipo |
|-----------|-----------------------|------|
| Angular | 19.2.18 (LTS) · 20.3.16 (LTS) | Web |
| Next.js | 15.5.9 · 16.1.1 | Web |
| Ionic | 8.7.16 | PWA |
| Capacitor | 8.0.0 | Híbrida |

---

## Frameworks Backend

| Framework | Versiones Homologadas |
|-----------|-----------------------|
| NestJS | 10.4.22 · 11.1.11 |
| Django | 5.2.10 (LTS) |
| FastAPI | 0.128.0 |
| Laravel | 12.47.0 |
| Livewire (sobre Laravel) | 3.7.4 |
| Express.js | 4.22.1 · 5.2.1 |
| Fastify.js | 4.29.1 · 5.6.2 |
| Spring Boot | 3.4.13 · 3.5.9 |
| .NET | 8.0.23 (LTS) · 9.0.12 |
| Kotlin (backend) | 2.2.21 · 2.3.0 |

> **.NET:** Requiere justificación del motivo de elección.

---

## Motores de Base de Datos

| Motor | Versiones Homologadas | Notas |
|-------|-----------------------|-------|
| Oracle | 19c (LTR) | Default para SOA y microservicios |
| PostgreSQL | 15.15 · 17.7 | Solo cuando sea obligatorio (PostGIS, X-Road, múltiples esquemas, etc.) — requiere justificación |
| MariaDB | 10.11.2 · 11.4.2 | — |
| MongoDB | 8.0 | Solo para alta escalabilidad/variabilidad; no reemplaza BD relacional |
| Redis | 7.2 | Cache de datos |

> Validar versión a utilizar previamente con **DGISIS** y **DGINFRA**.

---

## Plataformas de Búsqueda

| Plataforma | Versión Homologada |
|------------|-------------------|
| Apache Solr | 9.10.0 |
| Elasticsearch | 8.17 |

---

## Bibliotecas Android

| Biblioteca | Versión Homologada |
|------------|--------------------|
| core | 1.17.0 |
| material-components | 1.13.0 |
| Maps | 18.2.0 · 19.0 |
| Places | 3.5.0 · 4.4.1 · 5.1.1 |
| Compose | 1.4.0 · 1.5.15 · 1.9.5 |
| ViewPager2 | 1.1.0 |
| Compose Navigation | 2.9.6 |
| WorkManager | 2.11.0 |
| RXJava3 | 3.1.11 |
| CameraX | 1.5.2 |
| Retrofit | 2.12.0 · 3.0.0 |
| OkHttp3 | 5.3.2 |
| Paging Runtime | 3.3.6 |
| LiveData | 2.10.0 |
| Dagger Hilt | 2.57.2 |
| Room | 2.8.4 |
| Coil | 2.7.0 · 3.3.0 |
| Three | 0.170.0 |
| Lottie Android | 6.7.1 |

---

## Bibliotecas Java

| Biblioteca | Versión Homologada |
|------------|--------------------|
| Spring Cloud | 2023.0.9 · 2024.0.3 · 2025.0.1 |
| OkHttp3 | 5.3.2 |
| Retrofit | 2.12.0 · 3.0.0 |
| JUnit Jupiter API | 5.14.2 · 6.0.2 |
| ModelMapper | 3.2.6 |
| Hibernate | 7.2.1 |
| ojdbc11 | 21.20.0 · 23.26.0 |
| Mockito Core | 5.21.0 |
| Apache POI | 5.5.1 |
| AWS Java SDK Core | 2.41.0 |
| Unirest Java Core | 4.7.0 |
| MapStruct | 1.6.3 |
| Gson | 2.13.2 |
| Lombok | 1.18.42 |
| Commons Codec | 1.20.0 |
| Commons Lang3 | 3.20.0 |

---

## Bibliotecas Python

| Biblioteca | Versión Homologada |
|------------|--------------------|
| Matplotlib | 3.10.8 |
| Bokeh | 3.8.2 |
| NumPy | 2.4.1 |
| SciPy | 1.17.0 |
| SpaCy | 3.8.11 |
| Pandas | 2.3.3 |
| PyTorch | 2.9.1 |
| NLTK | 3.9.2 |
| Gensim | 4.4.0 |
| Transformers | 4.57.6 |
| Pillow | 11.3.0 · 12.0.0 |
| Scrapy | 2.14.0 |
| TensorFlow | 2.20.0 |
| oracledb *(solo conector vía ORM)* | 3.3.0 |
| mysql-connector-python *(solo conector vía ORM)* | 9.5.0 |

---

## Bibliotecas Angular

| Biblioteca | Versión Homologada |
|------------|--------------------|
| ngx-extended-pdf-viewer | 21.4.0 · 25.6.4 |
| ngx-permissions | 19.0.0 |
| ngx-spinner | depende de la versión Angular |
| PrimeNG | 19.1.4 · 20.3.0 |

---

## Bibliotecas JavaScript

| Biblioteca | Versión Homologada |
|------------|--------------------|
| React | 18.3.1 · 19.2.3 |
| React-Redux | 9.2.0 |
| @reduxjs/toolkit | 2.11.2 |
| Maps | quarterly 3.63 |
| jwt-decode | 4.0.0 |
| Chart.js | 4.5.1 |
| Anime.js | 4.3.5 |
| Apache ECharts | 5.6.0 · 6.0.0 |
| ApexCharts | 4.7.0 · 5.3.6 |
| JOSE | 5.10.0 · 6.1.3 |
| Modernizr | 3.13.1 |
| OpenLayers.js | 9.2.4 · 10.7.0 |
| Day.js | 1.11.19 |
| @fullcalendar/core | 6.1.19 |
| Helmet | 7.2.0 · 8.1.0 |
| core-js | 3.48.0 |
| dotenv | 17.2.3 |
| express-fileupload | 1.5.0 |
| Underscore | 1.13.7 |
| Backbone.js | 1.6.1 |
| Quill *(editor de texto enriquecido)* | 2.0.3 |

> **Editor de texto enriquecido:** Solo Quill está homologado. CKEditor 5 y TinyMCE requieren assessment técnico-legal específico por sus limitaciones de licencia.

---

## Bibliotecas .NET

| Biblioteca | Versión Homologada |
|------------|--------------------|
| Quartz.NET | 3.15.1 |
| NUnit | 4.4.0 |
| FluentValidation | 12.1.0 |
| NLog | 6.0.5 |
| Log4Net | 3.2.1 |
| NServiceBus | 9.2.8 |
| MimeKit | 4.14.0 |
| Polly | 8.6.5 |
| Hangfire | 1.8.22 |

---

## Otras Bibliotecas

| Biblioteca | Versión Homologada |
|------------|--------------------|
| OpenCV | 4.13.0 |
| libpng | 1.6.54 |
| zlib-ng | 2.3.2 |

---

## Sistema de Diseño

| Sistema | Versión Homologada | Notas |
|---------|--------------------|-------|
| Obelisco V2 | 1.6.2 · 1.8.4 | **Obligatorio** por RES-94-SECITD-23 |
| Bootstrap | 5.3.8 | Utilizado por Obelisco internamente |

---

## Sistemas de Gestión

### CMS

| Sistema | Versión Homologada |
|---------|--------------------|
| WordPress | 6.6.4 · 6.7.4 · 6.8.3 |
| Drupal | 10.6 · 11.3 |

### LMS

| Sistema | Versión Homologada |
|---------|--------------------|
| Moodle | 4.5.8 (LTS) · 5.1.1 |

### DMS

| Sistema | Versión Homologada |
|---------|--------------------|
| CKAN | 2.10.9 · 2.11.4 |
| GeoServer | 2.28.1 |

---

## Administradores de Migración de BD

| Herramienta | Versión Homologada |
|-------------|--------------------|
| Flyway | 11.13.2 |
| Laravel Migrations | ligada al framework |
| Django Migrations | ligada al framework |
| Entity Framework Core Migrations | ligada al framework |
| Alembic | 1.17.2 |
| TypeORM | 0.3.28 |
| Sequelize Migrations | 6.37.7 |

---

## BPM (Gestión de Procesos de Negocio)

| Herramienta | Versión Homologada | Licencia |
|-------------|--------------------|----------|
| CIB Seven | 1.1.0 CE · 2.1.0 CE | Apache License 2.0 (Community Edition) |

---

## Gestión de Colas de Mensajes

| Herramienta | Versión Homologada | Notas |
|-------------|--------------------|-------|
| Apache Kafka | 4.0 | **Default** |
| Apache ActiveMQ Artemis | 2.40.0 | Solo en escenarios puntuales justificados |

---

## Servidores Web

| Servidor | Versión Homologada | Notas |
|----------|--------------------|-------|
| Apache HTTP Server | 2.4.62 | **Default preferente** |
| Apache Tomcat | 10.1.48 | — |
| Nginx | 1.29 | Solo cuando no exista otra alternativa viable |
| JWS (JBoss Web Server) | 6.0 SP1 · 6.1 | — |

---

## Sistemas Operativos

| SO | Versión Homologada |
|----|--------------------|
| Red Hat Enterprise Linux (RHEL) | 8.7 · 9.6 |
| Android | 13 · 14 · 15 · 16 |
| iOS | 18 · 26 |

> Android e iOS indican las versiones sobre las que se debe validar el funcionamiento de las apps móviles.

---

## Seguridad

| Herramienta | Versión Homologada |
|-------------|--------------------|
| OpenSSL | 3.5 (LTS) |
| PrimeKey EJBCA | 9.3.6 |
| OpenID Connect (OIDC) | provista por DGSEI |
| Keycloak | provista por DGSEI |

---

## Arquitecturas y Sus Stacks Recomendados (Resumen)

| Arquitectura | Complejidad | Backend | Frontend | DB |
|-------------|-------------|---------|----------|----|
| Monolítica estructurada (MVC) | Baja | Laravel (PHP) | Laravel/Blade/Livewire | MariaDB |
| Monolítica modular | Baja-Media | Spring Boot · Django · NestJS | Angular · Laravel | Oracle · MariaDB |
| SOA | Media-Alta | Spring Boot · NestJS · Django/FastAPI | Next.js · Angular · React | Oracle |
| Microservicios | Media-Alta | Spring Boot · Django/FastAPI | Next.js · Angular · React | Oracle · políglota |
| EDA | Media-Alta | Spring Boot + Cloud Stream · FastAPI | Next.js · Angular · React | desacoplada por servicio |
| CMS | N/A | Drupal | — | — |
| Mobile nativo Android | Cualquiera | — | Jetpack Compose + Android Jetpack | Room |
| Mobile nativo iOS | Cualquiera | — | SwiftUI | Core Data |
| Mobile híbrido | Baja-Media | — | Ionic + Capacitor | — |

---

## Autenticación (Resumen)

| Caso de uso | Mecanismo | Protocolo |
|-------------|-----------|-----------|
| Aplicaciones ciudadanas | miBA / BAID | OpenID Connect |
| Aplicaciones internas / no ciudadanas | Keycloak (DGSEI) | OpenID Connect |
| Portal de autenticación interno | https://identidad-gcaba.apps.buenosaires.gob.ar/ | OpenID Connect |

---

## Servicios de Plataforma (Resumen)

| Necesidad | Solución |
|-----------|----------|
| Caché de contenido (HTML/CSS/estáticos) | **Varnish** |
| Caché de datos | **Redis** (provisto por ASI) |
| Almacenamiento de archivos | **S3/HCP** (protocolo S3) |
| Reportes analíticos | **SAC** (SAP Analytics Cloud) |
| BD documental | **MongoDB** |
| BPM | **CIB Seven** |
| Motor de reglas | **Drools** |
| ChatBot ciudadano | **BOTI** |
| Monitoreo/logs | **ELK** (ElasticSearch, Logstash, Kibana) |
| Georeferenciación | **API GEO** del GCABA + Mapa GCABA |
| Integración entre sistemas | **ESB** del GCABA |
| CD / contenedores | **OpenShift** |
| IaC Cloud | **Terraform** / **CloudFormation** |
| Automatización de deploy | **ANSIBLE** |
