# Colecciones Postman — servicios de identidad

Colecciones para issuer / holder / verifier (puertos `9001` / `9002` / `9005`). No incluyen SCI (gateway, auth, index, etc.).

## Archivos

| Archivo | Uso |
|---------|-----|
| `Quark-Issuer.postman_collection.json` | API issuer |
| `Quark-Holder.postman_collection.json` | API holder |
| `Quark-Verifier.postman_collection.json` | API verifier |
| `Quark-Flujos-DIDComm-OID4VC.postman_collection.json` | Flujos E2E DIDComm + OID4VCI/OID4VP |
| `Quark-Demo-Multi-tenant.postman_collection.json` | Demo multi-tenant (emisión/verificación + QR) |
| `Quark-Local-Docker.postman_environment.json` | `localhost:9001/9002/9005` |
| `Quark-Tunnel-Dominios.postman_environment.json` | HTTPS vía tunnel |
| `assets/demo-credentials/` | Logos/fondos de referencia para el demo |
| `scripts/generate-multi-tenant-collection.mjs` | Regenerar la colección multi-tenant |

## Uso rápido

1. Importar colecciones + environment en Postman.
2. Seleccionar **Quark Local Docker** (o Tunnel).
3. En **Flujos DIDComm y OID4VC**: ejecutar **00.A** (provision tenants) y seguir las carpetas en orden.
4. En offers/requests con QR: tras **Send**, abrir la pestaña **Visualize**.

## URLs (Docker Compose de este monorepo)

| Servicio | URL |
|----------|-----|
| Issuer | `http://localhost:9001` |
| Verifier | `http://localhost:9002` |
| Holder | `http://localhost:9005` |

Rutas con prefijo `/:walletId` (`issuerId`, `holderId`, `verifierId` en el environment).

Regenerar demo multi-tenant:

```bash
node postman/scripts/generate-multi-tenant-collection.mjs
```
