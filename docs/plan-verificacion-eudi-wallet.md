# Plan: Verificación en EUDI Wallet con Quark

## Estado actual

- Emisión con `quark-issuer-service` → EUDI wallet: **funciona**
- Verificación con `quark-verifier-service` → EUDI wallet: **funciona** (con verifier en modo x5c; ver [quark-verifier-x5c.md](./soporte-eu-wallet/quark-verifier-x5c.md))

### Histórico (Fase 1 — resuelto)

La verificación fallaba porque la EUDI wallet solo acepta verifiers con `X509SanDns` o `X509Hash` como `client_id`, y el quark-verifier no tenía certificado X.509 configurado. Se resolvió configurando `OID4VP_X5C_*` en el verifier y agregando la CA Quark al trust store de la EUDI Wallet.

## Repos involucrados

| Repo | Path | Stack |
|------|------|-------|
| Quark Issuer | `quark-issuer-service` | NestJS + Credo-TS, firma con did:web |
| Quark Verifier | `quark-verifier-service` | NestJS + Credo-TS, soporta x5c via env |
| EUDI Wallet Android | `local/eudi-app-android-wallet-ui` | Android + eudi-lib-android-wallet-core |
| Quark Wallet | `quark-wallet` | (Fase 2) |

---

## Fase 1 — quark-verifier + quark-issuer con EUDI wallet

### Problema

La EUDI wallet tiene configurado en `WalletCoreConfigImpl.kt` (dev flavor):
```kotlin
configureOpenId4Vp {
    withClientIdSchemes(listOf(
        ClientIdScheme.X509SanDns,
        ClientIdScheme.X509Hash
    ))
}
configureReaderTrustStore(context, R.raw.pidissuerca02_ut, ...)
```

El quark-verifier en modo `did` (default) no cumple ninguno de esos esquemas.
El quark-verifier **sí soporta x5c** vía estas env vars:
```
OID4VP_X5C_CERTIFICATES_BASE64=<base64-cert1>,<base64-cert2>
OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID=<key-id>
OID4VP_X5C_CLIENT_ID_PREFIX=x509_san_dns | x509_hash
```

### Paso 1 — Generar certificados (sin dominio real)

```bash
# 1. CA self-signed
openssl req -x509 -newkey rsa:2048 \
  -keyout quark-ca.key -out quark-ca.pem \
  -days 3650 -nodes \
  -subj "/CN=Quark Local CA"

# 2. Clave y CSR para el verifier
openssl req -newkey rsa:2048 \
  -keyout quark-verifier.key -out quark-verifier.csr \
  -nodes -subj "/CN=localhost"

# 3. Firmar con la CA incluyendo SAN (requerido para X509SanDns)
openssl x509 -req \
  -in quark-verifier.csr \
  -CA quark-ca.pem -CAkey quark-ca.key -CAcreateserial \
  -out quark-verifier.pem -days 3650 \
  -extfile <(echo "subjectAltName=DNS:localhost,IP:127.0.0.1")

# 4. Verificar el cert
openssl x509 -in quark-verifier.pem -text -noout | grep -A2 "Subject Alternative"
```

Para el `.env` del verifier necesitás el cert en base64 (sin newlines):
```bash
# Cert en base64 para el .env
cat quark-verifier.pem | base64 -w 0
```

### Paso 2 — Configurar quark-verifier en modo x5c

En el `.env` de `quark-verifier-service`:
```env
OID4VP_X5C_CLIENT_ID_PREFIX=x509_san_dns
OID4VP_X5C_CERTIFICATES_BASE64=<base64 de quark-verifier.pem>
OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID=<key-id de la clave en KMS>
```

El `client_id` resultante va a ser `localhost` (el SAN DNS del cert).

> **Pendiente investigar:** cómo importar la clave privada `quark-verifier.key` al KMS interno de Credo-TS. Revisar si hay un endpoint o si se puede pasar directo como env var.

### Paso 3 — Agregar CA a la EUDI wallet

1. Copiar `quark-ca.pem` a:
   ```
   local/eudi-app-android-wallet-ui/resources-logic/src/main/res/raw/quark_ca.pem
   ```

2. Editar `core-logic/src/dev/java/eu/europa/ec/corelogic/config/WalletCoreConfigImpl.kt`:
   ```kotlin
   configureReaderTrustStore(
       context,
       R.raw.pidissuerca02_cz,
       R.raw.pidissuerca02_ee,
       R.raw.pidissuerca02_eu,
       R.raw.pidissuerca02_lu,
       R.raw.pidissuerca02_nl,
       R.raw.pidissuerca02_pt,
       R.raw.pidissuerca02_ut,
       R.raw.dc4eu,
       R.raw.r45_staging,
       R.raw.quark_ca          // ← agregar
   )
   ```

3. Recompilar y reinstalar la wallet en el device.

### Paso 4 — Test end-to-end

1. Levantar `quark-issuer-service`
2. Levantar `quark-verifier-service` con las nuevas env vars
3. Emitir credential desde la EUDI wallet (ya funciona)
4. Iniciar flujo de verificación desde el quark-verifier
5. La wallet recibe el authorization request — verificar que acepta el `client_id=localhost`
6. La wallet presenta la credential
7. El quark-verifier valida la presentación

### Posibles problemas adicionales

- **Credential verification en quark-verifier:** El quark-issuer firma con `did:web` (sin x5c), el quark-verifier usa Credo-TS que soporta did:web — debería funcionar, pero hay que verificar.
- **HTTPS local:** Si la wallet requiere HTTPS para el verifier endpoint, usar ngrok o un proxy local.
- **KMS key import:** Investigar cómo Credo-TS maneja la importación de claves privadas externas en modo `internal`.

---

## Fase 2 — EUDI issuer/verifier (prod) con quark-wallet

> Comenzar después de que Fase 1 esté funcionando.

### Objetivo

Usar los servicios de producción de EUDI:
- Issuer: `https://dev.issuer-backend.eudiw.dev`
- Verifier: `https://dev.verifier-backend.eudiw.dev`

Con la quark-wallet (`quark-wallet`).

### Pendiente investigar antes de arrancar

1. **quark-wallet tech stack** — qué SDK usa (Credo-TS, EUDI lib, propio?)
2. **Cómo configura issuers confiables** — equivalente al `issuersConfig` de la EUDI wallet
3. **Cómo configura verifiers confiables** — equivalente al `configureReaderTrustStore`
4. **Trust anchors para el issuer EUDI** — el issuer de EUDI firma con x5c (PKI de EUDI), la quark-wallet tiene que tener esos certs

### Pasos tentativos

1. Explorar `quark-wallet` para entender su trust model
2. Agregar los certificados raíz de EUDI como confiables en quark-wallet
3. Registrar el issuer EUDI en la config de la quark-wallet
4. Probar issuance completo
5. Configurar trust del verifier EUDI en quark-wallet
6. Probar verification completo
