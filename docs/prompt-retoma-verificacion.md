# Prompt de retoma — Verificación EUDI wallet

Pegar esto al inicio de la próxima sesión:

---

Estamos trabajando en el proyecto `ba-quark-2.0` en `D:\Workspace\projects\Phinx\ba-quark-2.0`.

## Contexto

Tenemos dos objetivos en orden:

**Fase 1 (activa):** Lograr que `quark-verifier-service` pueda verificar credentials en la EUDI wallet Android (`local/eudi-app-android-wallet-ui`). La emisión con `quark-issuer-service` ya funciona.

**Fase 2 (después):** Usar el issuer y verifier EUDI de producción con nuestra `quark-wallet`.

## Repos clave

| Repo | Path | Descripción |
|------|------|-------------|
| quark-issuer-service | `quark-issuer-service/` | NestJS + Credo-TS. Emite SD-JWT VC firmando con did:web. Ya funciona con la EUDI wallet. |
| quark-verifier-service | `quark-verifier-service/` | NestJS + Credo-TS. Hace OID4VP. Soporta x5c via env vars. **Este es el que falla.** |
| EUDI wallet Android | `local/eudi-app-android-wallet-ui/` | Android. Solo acepta verifiers con X509SanDns o X509Hash. Trust store en `WalletCoreConfigImpl.kt`. |
| quark-wallet | `quark-wallet/` | Nuestra wallet. Para Fase 2. |

## Causa raíz del problema

La EUDI wallet Android está configurada en:
`core-logic/src/dev/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`

Solo acepta estos client_id schemes para OID4VP:
```kotlin
withClientIdSchemes(listOf(
    ClientIdScheme.X509SanDns,
    ClientIdScheme.X509Hash
))
```

El quark-verifier corre en modo `did` (default) → la wallet rechaza el request.

El quark-verifier SÍ soporta x5c configurando estas env vars:
```
OID4VP_X5C_CERTIFICATES_BASE64=<base64-cert>
OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID=<key-id>
OID4VP_X5C_CLIENT_ID_PREFIX=x509_san_dns
```

## Plan (ver docs/plan-verificacion-eudi-wallet.md)

### Paso 1 — Generar certificados self-signed
```bash
openssl req -x509 -newkey rsa:2048 -keyout quark-ca.key -out quark-ca.pem \
  -days 3650 -nodes -subj "/CN=Quark Local CA"

openssl req -newkey rsa:2048 -keyout quark-verifier.key -out quark-verifier.csr \
  -nodes -subj "/CN=localhost"

openssl x509 -req -in quark-verifier.csr -CA quark-ca.pem -CAkey quark-ca.key \
  -CAcreateserial -out quark-verifier.pem -days 3650 \
  -extfile <(echo "subjectAltName=DNS:localhost,IP:127.0.0.1")

cat quark-verifier.pem | base64 -w 0  # para el .env
```

### Paso 2 — Configurar quark-verifier
En `.env` de `quark-verifier-service`:
```
OID4VP_X5C_CLIENT_ID_PREFIX=x509_san_dns
OID4VP_X5C_CERTIFICATES_BASE64=<output del base64 anterior>
OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID=<pendiente: investigar cómo importar la clave privada al KMS de Credo-TS>
```

**Pendiente investigar:** cómo importar `quark-verifier.key` en el KMS interno de Credo-TS en `quark-verifier-service`.

### Paso 3 — Agregar CA a la EUDI wallet
1. Copiar `quark-ca.pem` → `local/eudi-app-android-wallet-ui/resources-logic/src/main/res/raw/quark_ca.pem`
2. Agregar `R.raw.quark_ca` al `configureReaderTrustStore()` en `WalletCoreConfigImpl.kt` (dev y demo flavors)
3. Recompilar y reinstalar la wallet

### Paso 4 — Test e2e
1. Levantar quark-issuer-service y quark-verifier-service
2. Emitir credential (ya funciona)
3. Verificar — la wallet debe aceptar el request con client_id=localhost

## Lo primero que hay que hacer al retomar

1. Leer `quark-verifier-service` para entender cómo funciona el KMS interno de Credo-TS y cómo se importa una clave privada externa
2. Ejecutar los comandos OpenSSL del Paso 1
3. Continuar con Pasos 2, 3 y 4
