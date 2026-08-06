# DIDComm (verifier)

Verificación JSON-LD integrada vía Credo (espejo de OID4VP request).

Estructura alineada con `openid4vc/`: archivos planos en la raíz del módulo.

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/v1/verifiers/:walletId/didcomm/request` | Crea OOB + pending; al conectar se envía `request-presentation`. |
| `GET` | `/v1/verifiers/:walletId/didcomm/request/:pendingRequestId` | Estado / resultado del request. |
| `GET` | `/v1/verifiers/:walletId/didcomm/proofs/:proofExchangeRecordId` | Detalle del proof exchange Credo. |
| `GET` | `/oob/:pendingRequestId` | Short URL pública (RFC 0434): mensaje OOB en JSON. |

## Componentes

| Archivo | Rol |
|---------|-----|
| `didcomm.module.ts` | Nest module |
| `didcomm.controller.ts` | `POST/GET .../didcomm/request`, `GET .../proofs/:id` |
| `didcomm.service.ts` | Request + auto-request al conectar |
| `didcomm-request.dto.ts` | Body del request |
| `pending-didcomm-proof.store.ts` | Store en memoria del pending |
| `oob-short-url.controller.ts` | `GET /oob/:id` |
