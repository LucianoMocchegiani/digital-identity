# Identity monorepo (snapshot)

Copia limpia (sin historial Git de los repos originales) de librerías, servicios de identidad, wallet y material de soporte.

## Contenido

| Ruta | Descripción |
|------|-------------|
| `packages/identity-core` | SDK SSI TypeScript (Credo-TS) |
| `packages/identity-core-dart` | SDK SSI Dart/Flutter |
| `identity-issuer-service` | Emisión (OID4VCI, DIDComm) — `:9001` |
| `identity-verifier-service` | Verificación (OID4VP, DIDComm) — `:9002` |
| `identity-holder-service` | Custodia / presentación — `:9005` |
| `identity-wallet` | App Flutter |
| `docs/` | Documentación del ecosistema (copia completa) |
| `postman/` | Colecciones de identidad (issuer/holder/verifier + flujos) |
| `docker-compose.yml` | Stack local: postgres, rabbitmq, issuer, verifier, holder |
| `scripts/postgres-init.sh` | Crea las DBs del compose al primer arranque |

## Arranque local (servicios)

```bash
# Copiar env de ejemplo si no tenés .env
cp identity-issuer-service/source/.env.example identity-issuer-service/source/.env
cp identity-verifier-service/source/.env.example identity-verifier-service/source/.env
cp identity-holder-service/source/.env.example identity-holder-service/source/.env

docker compose up -d --build
```

- Issuer: http://localhost:9001  
- Verifier: http://localhost:9002  
- Holder: http://localhost:9005  
- RabbitMQ UI: http://localhost:15672 (`identity` / `identity`)  
- pgAdmin: http://localhost:5050  

Postman: importar `postman/` y el environment `Identity-Local-Docker`.
