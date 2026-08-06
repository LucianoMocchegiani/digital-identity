# Propuesta: Bridge WACI ↔ DIDComm para compatibilidad Wallet Quark

**Versión:** 1.0
**Fecha:** 2026-06-26
**Autor:** Equipo de integración
**Estado:** Borrador para revisión

---

## 1. Resumen ejecutivo

La nueva wallet Quark (basada en Credo-TS, DIDComm v2 sobre HTTP/WebSocket nativo) **no puede comunicarse con el Emisor ni con el Verificador actuales** (basados en `@quarkid/agent@1.0.0`, protocolo propietario WACI sobre Socket.IO).

Esta propuesta plantea la creación de un **servicio bridge** que actúa como traductor bidireccional entre ambos mundos, permitiendo que la wallet Quark **holdee credenciales emitidas por el Emisor WACI** y las **presente al Verificador WACI**, sin reescribir los backends existentes ni la wallet.

### Decisión recomendada
Implementar un servicio nuevo llamado `quark-bridge` dentro del stack Quark, registrándolo en `quark-api-gateway` como una ruta más. Esfuerzo estimado: 3-4 semanas. Riesgo: bajo. Compatibilidad inmediata: sí.

---

## 2. Contexto y motivación

### 2.1 El problema

Hoy coexisten dos stacks incompatibles en el repositorio:

| Componente | Stack | Protocolo | Transporte | DID method |
|---|---|---|---|---|
| Emisor (`Emisor/generic-issuer-back`) | `@quarkid/agent@1.0.0` | WACI propietario | Socket.IO | `did:quarkid` |
| Verificador (`Verificador/back-verificador-generico`) | `@quarkid/agent@1.0.0` | WACI propietario | Socket.IO | `did:quarkid` |
| Wallet Quark (`quark/quark-wallet`) | `@quarkid/identity-core` (Credo-TS) | DIDComm v2 RFC 0036/0037 | HTTP + WebSocket nativo | `did:web`, `did:key`, `did:jwk`, `did:peer:2` |
| Servicios Quark (`quark/quark-issuer-service`, etc.) | `@quarkid/identity-core` (Credo-TS) | DIDComm v2 + OID4VCI/OID4VP | HTTP + WebSocket nativo | `did:web`, `did:key`, `did:jwk` |

El usuario quiere que la wallet Quark pueda:
1. **Recibir credenciales** emitidas por el Emisor WACI.
2. **Presentar credenciales** al Verificador WACI.

Esto no es posible hoy por siete incompatibilidades técnicas documentadas (ver Anexo A).

### 2.2 Por qué importa

- Hay usuarios con credenciales emitidas por el Emisor actual que necesitan migrar a la nueva wallet.
- Hay procesos de verificación en producción que usan el Verificador actual y deben seguir funcionando.
- Reescribir el Emisor y el Verificador para usar el stack Quark tomaría meses y bloquearía otras prioridades.

### 2.3 Lo que NO es esta propuesta

- **No** es una migración del Emisor/Verificador a stack Quark (eso es la Opción C del Anexo B).
- **No** es implementar WACI dentro de la wallet Quark (eso es la Opción B del Anexo B, descartada por costo).
- **No** es una solución permanente: el bridge existe mientras Emisor y Verificador sigan en stack WACI.

---

## 3. Solución propuesta: servicio `quark-bridge`

### 3.1 Concepto

Un servicio NestJS dedicado que traduce entre los dos protocolos. El bridge:

- **Recibe** invitaciones WACI desde la wallet Quark (que las escaneó del QR del Emisor/Verificador).
- **Abre** conexiones Socket.IO contra el Emisor/Verificador para mantener el flujo WACI vivo.
- **Reenvía** los mensajes DIDComm v2 estándar entre la wallet y los backends legacy, traduciéndolos al vuelo.
- **Mantiene** estado de sesiones con TTL para correlacionar `waciInvitationId` (lado WACI) con `sessionId` (lado wallet).

### 3.2 Arquitectura

```
┌─────────────────┐
│   EMISOR        │ WACI/Socket.IO
│  @quarkid/agent │ ◄────────────────┐
│  puerto 8080    │                  │
└─────────────────┘                  │
                                     │
┌─────────────────┐                  │
│   VERIFICADOR   │ WACI/Socket.IO   │
│  @quarkid/agent │ ◄────────────┐   │
│  puerto 8081    │              │   │
└─────────────────┘              │   │
                                 │   │
         ┌───────────────────────┘   │
         │                           │
         │  ┌────────────────────────┴────────────────────┐
         │  │              QUARK-BRIDGE                   │
         │  │              (NestJS · puerto 9007)          │
         │  │                                               │
         │  │  ┌──────────────────────────────────────┐    │
         │  │  │  BridgeController                     │    │
         │  │  │  POST /bridge/issue/start             │    │
         │  │  │  POST /bridge/issue/poll              │    │
         │  │  │  POST /bridge/verify/start            │    │
         │  │  │  POST /bridge/verify/submit           │    │
         │  │  │  POST /bridge/verify/poll             │    │
         │  │  └──────────────────────────────────────┘    │
         │  │                                               │
         │  │  ┌──────────────────────────────────────┐    │
         │  │  │  WaciDecoderService                   │    │
         │  │  │  parsea didcomm://?_oob=...          │    │
         │  │  │  extrae from, id, pthid, accept, etc │    │
         │  │  └──────────────────────────────────────┘    │
         │  │                                               │
         │  │  ┌──────────────────────────────────────┐    │
         │  │  │  SocketIoClientService                │    │
         │  │  │  socket.io-client al Emisor/Verif    │    │
         │  │  │  mantiene conexión por sesión         │    │
         │  │  └──────────────────────────────────────┘    │
         │  │                                               │
         │  │  ┌──────────────────────────────────────┐    │
         │  │  │  DidCommTranslatorService             │    │
         │  │  │  envuelve VP de la wallet en          │    │
         │  │  │  presentación DIDComm v2 que el       │    │
         │  │  │  Verificador espera                   │    │
         │  │  └──────────────────────────────────────┘    │
         │  │                                               │
         │  │  ┌──────────────────────────────────────┐    │
         │  │  │  SessionsStore (Redis)                │    │
         │  │  │  waciInvitationId ↔ sessionId         │    │
         │  │  │  TTL configurable                     │    │
         │  │  └──────────────────────────────────────┘    │
         │  │                                               │
         └──┤                                               │
            │  HTTP REST (POST/GET)                        │
            │                                               │
            ▼                                               │
   ┌─────────────────┐                                     │
   │   WALLET QUARK  │ ◄───────────────────────────────────┘
   │   Credo-TS      │
   │   HTTP/DIDComm  │
   └─────────────────┘
```

### 3.3 Ubicación en el stack

El bridge se integra como un servicio más dentro de `quark/`, siguiendo el patrón del resto de componentes:

```
quark/
├── quark-api-gateway/          ← proxy HTTP stateless
├── quark-auth/
├── quark-resolver/             ← resolución DID
├── quark-issuer-service/
├── quark-verifier-service/
├── quark-holder-service/
├── quark-bridge/               ← NUEVO: WACI ↔ DIDComm
└── ...
```

Se registra como nueva ruta en `quark-api-gateway/source/src/config/routes.config.ts`:

```ts
{
  pathPrefix: '/bridge',
  serviceEnvKey: 'BRIDGE_SERVICE_URL',
  defaultUrl: 'http://quark-bridge:9007',
  timeoutMs: 10000,
  retries: 1,
  retryDelayMs: 500,
  supportsStreaming: true,    // SSE para notificaciones push
  requiresAuth: true,
},
```

---

## 4. Diseño técnico detallado

### 4.1 Stack del bridge

```json
{
  "name": "@quarkid/bridge",
  "version": "0.1.0",
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/axios": "^3.0.0",
    "socket.io-client": "^4.7.0",
    "ioredis": "^5.3.0",
    "axios": "^1.6.0",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.0",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1",
    "uuid": "^9.0.0"
  }
}
```

### 4.2 API expuesta a la wallet Quark

#### Issue (Emisor → Bridge → Wallet)

```http
POST /bridge/issue/start
Content-Type: application/json
Authorization: Bearer <jwt>

{
  "waciInvitation": "didcomm://?_oob=eyJ0eXBlIjoi...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440000"
}

→ 202 Accepted
{
  "status": "listening",
  "sessionId": "550e8400-e29b-41d4-a716-446655440000"
}
```

```http
POST /bridge/issue/poll
Content-Type: application/json
Authorization: Bearer <jwt>

{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000"
}

→ 200 OK
{
  "status": "pending" | "credential_offered" | "issued" | "ack" | "error",
  "vc": { ... } | null,
  "reason": "string" | null
}
```

Alternativa SSE (más eficiente, evita polling):

```http
GET /bridge/issue/stream/{sessionId}
Accept: text/event-stream
```

#### Verify (Wallet → Bridge → Verificador)

```http
POST /bridge/verify/start
Content-Type: application/json
Authorization: Bearer <jwt>

{
  "waciInvitation": "didcomm://?_oob=eyJ0eXBlIjoi...",
  "sessionId": "660e8400-e29b-41d4-a716-446655440001"
}

→ 200 OK
{
  "status": "listening",
  "sessionId": "660e8400-e29b-41d4-a716-446655440001",
  "presentationDefinition": {
    "format": { "ldp_vc": { "proof_type": ["BbsBlsSignature2020"] } },
    "inputDescriptors": [...],
    "submissionRequirements": [...]
  }
}
```

```http
POST /bridge/verify/submit
Content-Type: application/json
Authorization: Bearer <jwt>

{
  "sessionId": "660e8400-e29b-41d4-a716-446655440001",
  "vp": {
    "@context": ["https://www.w3.org/2018/credentials/v1"],
    "type": ["VerifiablePresentation"],
    "verifiableCredential": [...],
    "proof": { "type": "BbsBlsSignature2020", ... }
  }
}

→ 202 Accepted
{
  "status": "submitted"
}
```

```http
POST /bridge/verify/poll
{
  "sessionId": "660e8400-e29b-41d4-a716-446655440001"
}

→ 200 OK
{
  "status": "pending" | "verified" | "rejected",
  "vcs": [...] | null,
  "reason": "string" | null
}
```

### 4.3 Servicios internos

#### `WaciDecoderService`

Parsea el string `didcomm://?_oob=...` extraído del QR.

```ts
@Injectable()
export class WaciDecoderService {
  decodeInvitation(invitationMessage: string): DecodedInvitation {
    // Extrae el base64url después de "didcomm://?_oob="
    const base64 = invitationMessage.replace("didcomm://?_oob=", "");
    const decoded = Buffer.from(base64, "base64").toString("utf-8");
    const json = JSON.parse(decoded);

    return {
      id: json.id,                                      // ID de la invitación
      type: json.type,                                  // Tipo de mensaje
      from: json.from,                                  // DID del Emisor/Verificador
      pthid: json.pthid || json.id,                     // Thread parent ID
      goalCode: json.body?.goal_code,                   // "streamlined-vc" o "streamlined-vp"
      accept: json.accept || [],                        // Formatos aceptados
      attachments: json.attachments || [],              // Adjuntos (oferta/PD)
    };
  }
}
```

#### `SocketIoClientService`

Mantiene conexiones Socket.IO contra el Emisor y el Verificador.

```ts
@Injectable()
export class SocketIoClientService implements OnModuleDestroy {
  private emitterSocket: Socket | null = null;
  private verifierSocket: Socket | null = null;

  async connectToEmitter(emisorUrl: string, sessionId: string): Promise<Socket> {
    this.emitterSocket = io(`${emisorUrl}/socket.io`, {
      transports: ["websocket", "polling"],
      path: "/socket.io",
      reconnection: true,
      reconnectionAttempts: 5,
    });

    return new Promise((resolve, reject) => {
      this.emitterSocket!.on("connect", () => resolve(this.emitterSocket!));
      this.emitterSocket!.on("connect_error", reject);
    });
  }

  async sendMessage(socket: Socket, message: any): Promise<void> {
    return new Promise((resolve, reject) => {
      socket.emit("message", message, (ack: any) => {
        if (ack?.status === "received") resolve();
        else reject(new Error("No ACK received"));
      });
    });
  }
}
```

#### `SessionsStore`

Mantiene el mapeo `waciInvitationId ↔ sessionId` con TTL.

```ts
@Injectable()
export class SessionsStore {
  constructor(@InjectRedis() private readonly redis: Redis) {}

  async create(waciInvitationId: string, ttlSeconds: number): Promise<string> {
    const sessionId = uuidv4();
    const key = `bridge:session:${sessionId}`;
    await this.redis.setex(key, ttlSeconds, JSON.stringify({
      waciInvitationId,
      status: "listening",
      createdAt: Date.now(),
      messages: [],
    }));
    return sessionId;
  }

  async get(sessionId: string): Promise<SessionData | null> {
    const raw = await this.redis.get(`bridge:session:${sessionId}`);
    return raw ? JSON.parse(raw) : null;
  }

  async appendMessage(sessionId: string, message: any): Promise<void> {
    const session = await this.get(sessionId);
    if (!session) return;
    session.messages.push(message);
    const ttl = await this.redis.ttl(`bridge:session:${sessionId}`);
    await this.redis.setex(`bridge:session:${sessionId}`, ttl, JSON.stringify(session));
  }

  async updateStatus(sessionId: string, status: string, data?: any): Promise<void> {
    const session = await this.get(sessionId);
    if (!session) return;
    session.status = status;
    if (data) session.result = data;
    const ttl = await this.redis.ttl(`bridge:session:${sessionId}`);
    await this.redis.setex(`bridge:session:${sessionId}`, ttl, JSON.stringify(session));
  }
}
```

#### `DidCommTranslatorService`

Construye los mensajes DIDComm v2 que el Emisor/Verificador esperan.

```ts
@Injectable()
export class DidCommTranslatorService {
  buildIssueRequest(decoded: DecodedInvitation, walletDid: string): any {
    return {
      type: "https://didcomm.org/issue-credential/2.0/request-credential",
      id: uuidv4(),
      pthid: decoded.pthid,
      from: walletDid,
      to: decoded.from,
      created_time: Math.floor(Date.now() / 1000),
      body: {
        goal_code: "streamlined-vc",
        comment: "Requesting credential via bridge",
      },
      attachments: [],
    };
  }

  buildPresentation(decoded: DecodedInvitation, walletDid: string, vp: any): any {
    return {
      type: "https://didcomm.org/present-proof/2.0/presentation",
      id: uuidv4(),
      pthid: decoded.pthid,
      from: walletDid,
      to: decoded.from,
      created_time: Math.floor(Date.now() / 1000),
      body: {
        goal_code: "streamlined-vp",
        presentation: vp,
      },
      attachments: [
        {
          id: "presentation",
          media_type: "application/json",
          format: "ldp_vp",
          data: { json: vp },
        },
      ],
    };
  }
}
```

---

## 5. Flujos end-to-end

### 5.1 Issue: Emisor WACI → Wallet Quark

```
1. Usuario escanea QR del Emisor con la wallet Quark
   → wallet obtiene waciInvitation = "didcomm://?_oob=eyJ..."

2. Wallet genera sessionId y hace POST /bridge/issue/start
   → Bridge decodifica la invitación (WaciDecoderService)
   → Bridge abre Socket.IO contra el Emisor (SocketIoClientService)
   → Bridge crea sesión en Redis con TTL 60min (SessionsStore)

3. Emisor envía mensaje WACI "request-credential" por Socket.IO
   → Bridge lo captura y lo guarda en la sesión

4. Wallet hace GET /bridge/issue/stream/{sessionId} o POST /bridge/issue/poll
   → Recibe el mensaje "request-credential"

5. Wallet lo procesa con Credo (construye credential-request)
   → Credo negocia con el Emisor por HTTP POST /didcomm
   → ⚠️ PROBLEMA: el Emisor no escucha HTTP, sólo Socket.IO

   → SOLUCIÓN: el bridge actúa como proxy HTTP↔Socket.IO
     - Recibe el POST de Credo en http://quark-bridge:9007/didcomm-in/issue
     - Lo reenvía por Socket.IO al Emisor
     - Devuelve la respuesta al wallet
```

### 5.2 Verify: Wallet Quark → Verificador WACI

```
1. Usuario escanea QR del Verificador con la wallet Quark
   → wallet obtiene waciInvitation = "didcomm://?_oob=eyJ..."

2. Wallet hace POST /bridge/verify/start
   → Bridge decodifica la invitación
   → Bridge abre Socket.IO contra el Verificador
   → Bridge obtiene la presentation_definition del Verificador

3. Bridge devuelve la presentation_definition a la wallet
   → Wallet la muestra al usuario
   → Usuario selecciona las credenciales a presentar

4. Wallet construye el VP localmente con Credo
   → POST /bridge/verify/submit con el VP

5. Bridge envuelve el VP en un mensaje DIDComm v2 "presentation"
   → Lo envía por Socket.IO al Verificador

6. Verificador responde con "ack" o "problem-report"
   → Bridge lo traduce a {status: "verified" | "rejected"}

7. Wallet hace POST /bridge/verify/poll
   → Recibe el resultado
```

---

## 6. Por qué este enfoque y no otros

### 6.1 Por qué no modificar el Emisor/Verificador

- Tomaría 3-6 meses reescribirlos en stack Quark.
- Mientras se migra, hay que mantener WACI vivo para wallets legacy.
- Riesgo alto de romper integraciones existentes.

### 6.2 Por qué no implementar WACI en la wallet Quark

- WACI no es estándar público, requiere ingeniería inversa del SDK Extrimian.
- Tomaría 3-6 meses de un dev Flutter senior.
- Acopla la wallet a una versión vieja de un SDK propietario.

### 6.3 Por qué no meter el bridge en `quark-api-gateway` o `quark-resolver`

- `quark-api-gateway` es un proxy HTTP stateless. Meterle lógica de sesiones WACI rompe su responsabilidad.
- `quark-resolver` resuelve DIDs, no traduce protocolos SSI.
- Ambos servicios son críticos y pequeños. El bridge los convertiría en monolitos.

### 6.4 Por qué un servicio nuevo es lo correcto

- Sigue el patrón "un servicio, una responsabilidad" del stack Quark.
- Se deploya, escala y monitorea de forma independiente.
- Tiene su propio ciclo de release (no bloquea cambios en gateway/resolver).
- Se registra en el gateway como una ruta más (igual que `quark-auth`, `quark-resolver`, etc.).
- Cuando se migren Emisor/Verificador a stack Quark, el bridge se retira limpiamente.

---

## 7. Esfuerzo y cronograma

| Semana | Actividad |
|---|---|
| 1 | Setup del proyecto NestJS, configuración de Docker, CI/CD básico |
| 2 | `WaciDecoderService` + tests con invitaciones reales del Emisor/Verificador |
| 3 | `SocketIoClientService` + conexión contra Emisor/Verificador de prueba |
| 4 | `SessionsStore` (Redis) + endpoints REST + integración end-to-end |

**Total: 3-4 semanas** con un dev full-stack NestJS con experiencia en DIDComm.

---

## 8. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Cambios en Emisor/Verificador rompen el bridge | Media | Alto | Pinning de versiones + tests E2E contra cada release |
| Bridge como SPOF | Baja | Alto | Deploy HA (mínimo 2 réplicas + health checks) |
| Saturación de conexiones Socket.IO (1 por sesión) | Media | Medio | Limitar sesiones concurrentes por instancia + auto-scaling |
| Latencia por polling HTTP | Baja | Bajo | Ofrecer SSE como alternativa |
| Resolución DID `did:quarkid` en la wallet | Alta | Medio | Resolver `did:quarkid` para Credo (ver Anexo C) |

---

## 9. Criterios de éxito

- La wallet Quark puede escanear un QR del Emisor y recibir la credencial.
- La credencial recibida es verificable criptográficamente por la wallet.
- La wallet Quark puede presentar la credencial al Verificador.
- El Verificador valida la presentación exitosamente y registra la verificación en su base de datos.
- Latencia end-to-end < 5 segundos para flujos típicos.

---

## 10. Próximos pasos

1. **Aprobación del equipo**: revisar esta propuesta y decidir si se procede.
2. **Spike técnico (2 días)**: crear un POC mínimo del bridge que sólo decodifica invitaciones WACI y abre una conexión Socket.IO. Validar que la conectividad con el Emisor/Verificador reales funciona.
3. **Implementación completa**: 3-4 semanas según cronograma.
4. **Testing E2E**: con la wallet Quark real contra Emisor/Verificador reales.
5. **Despliegue gradual**: primero en entorno de QA, luego staging, luego producción con feature flag.

---

## Anexo A: Las 7 incompatibilidades técnicas

WACI y DIDComm v2 son incompatibles en siete dimensiones:

| # | Dimensión | WACI | DIDComm v2 (Quark) |
|---|---|---|---|
| 1 | Protocolo de mensaje | Propietario (`goal_code: "streamlined-vc"`) | RFC 0036/0037 (`issue-credential.v2.0`, `present-proof.v2.0`) |
| 2 | Envelope | JSON base64url sin JWE/JWS estándar | JWE/JWS según RFC 7516/7515 |
| 3 | Transporte | Socket.IO (`/socket.io`) | HTTP (`/didcomm`) + WebSocket nativo |
| 4 | Suite criptográfica | Sólo `BbsBlsSignature2020` | `BbsBlsSignature2020` + `Ed25519Signature2018/2020` |
| 5 | Eventos | Callbacks internos del SDK Extrimian | Mensajes DIDComm reales + EventEmitter Credo |
| 6 | DID method | `did:quarkid` (Modena Universal) | `did:web`, `did:key`, `did:jwk`, `did:peer:2` |
| 7 | Presentation definition | DIF-PEX con quirks de grupo | DIF-PEX puro |

El bridge ataca las dimensiones 1, 2, 3, 5 y 7. Las dimensiones 4 y 6 requieren acciones adicionales (ver Anexo C).

---

## Anexo B: Alternativas evaluadas

| Alternativa | Esfuerzo | Riesgo | Compatibilidad inmediata | Mantenimiento futuro |
|---|---|---|---|---|
| A — Bridge service | 3-4 semanas | Bajo | Sí | Bridge permanente |
| B — Implementar WACI en wallet Quark | 3-6 meses | Alto | Sí | Bridge permanente |
| C — Reescribir Emisor/Verificador en stack Quark | 3-6 meses | Alto | No (hasta terminar) | Cero bridge |
| D — Híbrido (A + C progresivo) | 3 sem + 3-6 meses | Bajo→medio | Sí | Migración gradual |

**Recomendación:** Opción D si se quiere valor inmediato + limpieza futura. Opción A si solo se necesita que funcione hoy.

---

## Anexo C: Acciones complementarias recomendadas

### C.1 Resolver `did:quarkid` para Credo (1-2 días)

Agregar una estrategia `QuarkDidStrategy` en `quark-resolver` que consulta el nodo Modena Universal para resolver `did:quarkid:Ei...`. Esto permite que la wallet Quark verifique criptográficamente las credenciales emitidas por el Emisor.

**Archivos:**
- `quark-resolver/source/src/resolver/strategies/quark-did.strategy.ts` (nuevo)
- `quark-resolver/source/src/resolver/resolver.module.ts` (registrar provider)
- `quark-resolver/source/src/resolver/resolver.service.ts` (agregar al switch)
- `quark-resolver/source/src/resolver/strategies/did-resolver.strategy.ts` (extender tipo `DidMethod`)

**Config:**
```env
resolver.quarkNodeUrl=https://node.quarkid.org
```

### C.2 Ampliar `proofFormat()` en el Verificador (1 hora)

En `Verificador/back-verificador-generico/source/src/quark/waci/waci-protocol-utils.ts`, descomentar y activar la rama completa de `proofFormat()` (líneas 63-68) para ofrecer `jwt_vp/ldp_vp/jwt_vc/ldp_vc` con BbsBls + Ed25519. Esto mejora la negociación con cualquier wallet moderna, no sólo con la wallet Quark.

### C.3 Validar `accept` del Emisor (pendiente de verificar)

Verificar si `@quarkid/agent@1.0.0` permite ampliar el `accept` de la invitación para incluir `didcomm/v2`. Si lo permite, mejora la compatibilidad. Si no, queda como deuda técnica.

---

## Anexo D: Estructura de archivos del servicio

```
quark-bridge/
├── README.md
├── package.json
├── tsconfig.json
├── docker-compose.yml
├── source/
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── common/
│   │   │   ├── filters/
│   │   │   │   └── global-exception.filter.ts
│   │   │   └── interceptors/
│   │   │       └── logging.interceptor.ts
│   │   ├── config/
│   │   │   └── environment.config.ts
│   │   ├── bridge/
│   │   │   ├── bridge.module.ts
│   │   │   ├── bridge.controller.ts
│   │   │   ├── bridge.service.ts
│   │   │   ├── waci-decoder.service.ts
│   │   │   ├── socketio-client.service.ts
│   │   │   ├── didcomm-translator.service.ts
│   │   │   └── dto/
│   │   │       ├── start-issue.dto.ts
│   │   │       ├── start-verify.dto.ts
│   │   │       ├── submit-vp.dto.ts
│   │   │       └── poll-response.dto.ts
│   │   ├── sessions/
│   │   │   ├── sessions.module.ts
│   │   │   ├── sessions.service.ts
│   │   │   └── sessions.store.ts
│   │   └── redis/
│   │       ├── redis.module.ts
│   │       └── redis.service.ts
│   └── test/
│       ├── bridge.e2e-spec.ts
│       └── waci-decoder.spec.ts
└── docs/
    ├── arquitectura.md
    └── ejemplos-flujos.md
```

---

## Anexo E: Preguntas frecuentes

### ¿Por qué no usar el `quark-holder-service` existente?

`quark-holder-service` ya tiene un agente Credo corriendo, pero mezclar dos responsabilidades (holder de usuarios + bridge de traducción) complica el modelo multi-tenant. Un servicio dedicado es más limpio.

### ¿El bridge escala?

Sí, es stateless excepto por Redis (que escala horizontalmente). Cada instancia puede manejar cientos de sesiones concurrentes. Para escalar más, agregar réplicas detrás de un load balancer.

### ¿Qué pasa si el Emisor o Verificador cambian su API?

El bridge tiene tests E2E contra cada release. Cualquier breaking change se detecta antes de producción. El contrato del bridge con la wallet (REST + JSON) es estable.

### ¿Cuánto cuesta operar el bridge?

- 1 instancia pequeña (512MB RAM, 0.5 CPU) maneja ~100 sesiones concurrentes.
- Redis compartido con el resto del stack.
- Logs y métricas estándar de NestJS + Prometheus.

### ¿Cuándo se puede retirar el bridge?

Cuando el Emisor y el Verificador hayan migrado a stack Quark nativo. En ese momento, la wallet Quark habla directamente con los servicios Quark sin intermediarios, y el bridge se apaga.

---

**Fin del documento**