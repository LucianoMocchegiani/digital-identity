# DIDComm (issuer)

Emisión JSON-LD integrada vía Credo (espejo de OID4VCI offer).

Estructura alineada con `openid4vc/`: archivos planos en la raíz del módulo.

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/v1/issuers/:walletId/didcomm/offer` | Crea OOB + pending; al conectar se envía `offer-credential`. |
| `GET` | `/oob/:pendingOfferId` | Short URL pública (RFC 0434): mensaje OOB en JSON. |

## Componentes

| Archivo | Rol |
|---------|-----|
| `didcomm.module.ts` | Nest module |
| `didcomm.controller.ts` | `POST .../didcomm/offer` |
| `didcomm.service.ts` | Offer + auto-offer al conectar |
| `didcomm-offer.dto.ts` | Body del offer |
| `pending-didcomm-offer.store.ts` | Store en memoria del pending |
| `oob-short-url.controller.ts` | `GET /oob/:id` |
