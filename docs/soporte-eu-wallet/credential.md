# EUDI + SD-JWT VC: JWK, `proof.jwt` y validación en NestJS

Esta es la parte más importante para interoperar con una **EUDI Wallet** desde tu **issuer en NestJS**.

La idea central es el **holder binding**: la credencial queda ligada criptográficamente a la clave pública del holder (la wallet del teléfono).

---

## 1) La credencial queda atada a la clave del holder

Cuando la wallet solicita una credencial, no quiere que cualquiera pueda reutilizarla.

Por eso el issuer inserta dentro de la VC algo como:

```json
{
  "cnf": {
    "jwk": {
      "kty": "EC",
      "crv": "P-256",
      "x": "...",
      "y": "..."
    }
  }
}
```

* `cnf` = **confirmation claim**
* `jwk` = **public key del holder**
* la private key queda guardada en el teléfono

Resultado: **solo esa wallet puede presentar la credencial después**.

---

##  2) ¿De dónde sale esa JWK?

La **wallet genera una key pair local**.

Ejemplo de public key:

```json
{
  "kty": "EC",
  "crv": "P-256",
  "x": "TCAER19Zvu3OHF4j4W4vfSVoHIP1ILilDls7vCeGemc",
  "y": "ZxjiWWbZMQGHVWKVQ4hbSIirsVfuecCE6t4jT9F2HZQ"
}
```

Esta JWK viaja dentro del **header del `proof.jwt`** que la wallet manda al endpoint `/credential`.

---

##  3) Cómo llega al issuer: `proof.jwt`

La wallet no manda la JWK suelta.

La manda dentro del JWT proof:

### Header

```json
{
  "typ": "openid4vci-proof+jwt",
  "alg": "ES256",
  "jwk": {
    "kty": "EC",
    "crv": "P-256",
    "x": "TCAER19Zvu3OHF4j4W4vfSVoHIP1ILilDls7vCeGemc",
    "y": "ZxjiWWbZMQGHVWKVQ4hbSIirsVfuecCE6t4jT9F2HZQ"
  }
}
```

### Payload

```json
{
  "iss": "wallet-client-id",
  "aud": "https://issuer.midominio.com",
  "iat": 1770000000,
  "nonce": "c_nonce_del_issuer"
}
```

Campos importantes:

* `aud` → debe ser tu issuer
* `nonce` → debe coincidir con el generado por tu backend
* `iat` → timestamp reciente
* firma → debe validar contra la JWK del header

 Esto demuestra **proof of possession**.

---

##  4) Qué debe validar tu endpoint `/credential`

### 4.1 Extraer la JWK del header

```ts
const protectedHeader = decodeProtectedHeader(jwt)
const jwk = protectedHeader.jwk
```

---

### 4.2 Verificar la firma del JWT

```ts
const publicKey = await importJWK(jwk, 'ES256')
await jwtVerify(jwt, publicKey)
```

Si pasa:

> la wallet realmente controla la private key

---

### 4.3 Validar el nonce

```ts
if (payload.nonce !== storedNonce) {
  throw new UnauthorizedException('Invalid nonce')
}
```

Esto evita replay attacks.

---

##  5) Emitir la SD-JWT VC ligada a esa clave

Después de validar el proof, emitís la credencial incluyendo la misma JWK:

```json
{
  "iss": "https://issuer.midominio.com",
  "vct": "identity_credential",
  "cnf": {
    "jwk": {
      "kty": "EC",
      "crv": "P-256",
      "x": "...",
      "y": "..."
    }
  }
}
```

👉 Este es el paso que hace que **solo esa wallet pueda usar la credencial**.

---

##  6) Flujo mental correcto

```text
wallet genera JWK
   ↓
firma proof.jwt con private key
   ↓
issuer valida firma + nonce
   ↓
issuer inserta cnf.jwk en la VC
   ↓
wallet presenta después con la misma clave
```

---

##  7) Qué significa esto para tu issuer

Lo importante no es tanto el DID resolver.

El verdadero core para EUDI es:

* recibir `proof.jwt`
* extraer `header.jwk`
* verificar firma
* validar nonce
* emitir `cnf.jwk`

Si eso funciona, **ya estás interoperando con EUDI Wallet**.

---

##  Checklist práctico para NestJS

* [ ] endpoint `/credential`
* [ ] parsear `proof.jwt`
* [ ] leer `header.jwk`
* [ ] `jwtVerify()` con `jose`
* [ ] validar `c_nonce`
* [ ] persistir JWK holder
* [ ] emitir SD-JWT VC con `cnf.jwk`

---

## Idea clave final

La **JWK es la identidad criptográfica real del holder**.

El DID puede existir o no.

Para EUDI, lo que define la interoperabilidad real es:

> **¿tu issuer acepta `proof.jwt` y emite la VC con `cnf.jwk`?**

Si la respuesta es sí, estás del lado correcto del estándar.
