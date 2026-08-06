# DIDComm (holder)

Recepción de invitaciones OOB vía Credo (consumidor del offer/request integrado de issuer/verifier).

Estructura alineada con `openid4vc/` e issuer/verifier: archivos planos en la raíz del módulo.

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/v1/holders/:walletId/didcomm/receive-invitation` | Acepta OOB (short URL `/oob/:id` o URL con `oob=`). |

Offer, credential y present-proof se completan automáticamente vía listeners de `@quarkid/identity-core`.

Conexiones y credenciales: `GET /v1/holders/:walletId/records?type=...`.

## Componentes

| Archivo | Rol |
|---------|-----|
| `didcomm.module.ts` | Nest module |
| `didcomm.controller.ts` | `POST .../didcomm/receive-invitation` |
| `didcomm.service.ts` | Wrapper de `receiveInvitation` |
| `didcomm-receive-invitation.dto.ts` | Body `{ invitationUrl }` |

## Eliminado (alineación con issuer/verifier)

- `GET .../didcomm/connections`, `GET .../didcomm/connection/:id`
- `POST .../didcomm/propose-credential`
- `GET .../didcomm/credentials`, `credentials-status`, `credential-status/:id`
