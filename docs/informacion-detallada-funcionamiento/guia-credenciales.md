# Guía detallada: los dos caminos de credenciales en SSI

**W3C VC + JSON-LD + Data Integrity + BBS+**  
vs  
**SD-JWT VC + OpenID4VCI + OpenID4VP**

---

## 1) Idea central

Cuando hablamos de los dos caminos en SSI, no estamos hablando necesariamente de protocolos distintos.

La diferencia principal está en:

- cómo se representa la credencial
- cómo se firma
- cómo se revela al verifier
- cómo se valida
- qué complejidad operativa introduce

La misma credencial de negocio, por ejemplo:

- nombre
- rol
- employeeId
- empresa

puede emitirse por cualquiera de los dos caminos.

**Lo que cambia es la serialización y la prueba criptográfica.**

---

## 2) Modelo mental por capas

Separar estas capas evita muchísimo acoplamiento.

### Dominio

La credencial a nivel negocio.

Ejemplo:

**EmployeeCredential**

Contiene:

- nombre
- rol
- legajo
- fecha de alta
- permisos

Esta capa debería ser **agnóstica al formato**.

### Serialización

Convierte el modelo de dominio en un formato estándar.

Acá aparecen los dos caminos:

- **Camino A**  
  W3C VC + JSON-LD

- **Camino B**  
  SD-JWT VC

### Transporte

Cómo viaja.

Puede ser el mismo para ambos:

- OpenID4VCI
- OpenID4VP
- REST interno
- QR
- deeplink

**Mismo transporte, distinto payload.**

---

## 3) Camino A — Ecosistema W3C puro

**W3C VC + JSON-LD + Data Integrity + BBS+**

Este camino trata la credencial como un **documento semántico rico**.

### Estructura

```json
{
  "@context": ["https://www.w3.org/ns/credentials/v2"],
  "type": ["VerifiableCredential", "EmployeeCredential"],
  "issuer": "did:web:issuer",
  "credentialSubject": {
    "employeeId": "123",
    "role": "Engineer"
  },
  "proof": {
    "type": "Ed25519Signature2020"
  }
}
```

### Firma

La firma suele ir en `proof`.

Opciones comunes:

- Ed25519Signature2020
- ECDSA
- BBS+
- Data Integrity suites

### Punto fuerte

Con **BBS+** permite:

- selective disclosure
- derived proofs
- unlinkability fuerte
- zero-knowledge avanzado

### Manejo operativo

Este camino requiere manejar:

- DID resolution
- JSON-LD contexts
- remote context caching
- canonicalization
- Data Integrity suites
- vocabularios
- credentialSchema
- status lists
- derived proof generation

### Costos operativos

Es más complejo por:

- errores de context
- canonicalization failures
- proofs difíciles de debuggear
- payloads más grandes
- dependencia de vocabularios

### Dónde brilla

Ideal para:

- gobierno
- diplomas
- títulos
- registros notariales
- supply chain
- semántica rica
- evidencia legal
- interoperabilidad institucional

---

## 4) Camino B — Ecosistema OAuth / IETF

**SD-JWT VC + OpenID4VCI + OpenID4VP**

Este camino trata la credencial como un:

**token firmado con disclosures selectivas**

Muy alineado a OAuth / OIDC.

### Estructura

Formato conceptual:

```
JWT~disclosure1~disclosure2~kb-jwt
```

El JWT principal guarda hashes.

```json
{
  "iss": "did:web:issuer",
  "_sd": ["hash_nombre", "hash_rol"]
}
```

Las disclosures reales viajan aparte.

### Firma

Se firma el JWT principal con JOSE.

Normalmente:

- ES256
- EdDSA
- JWK / DID keys

Además puede agregarse:

- KB-JWT

para probar posesión de la clave del holder.

### Manejo operativo

Necesitás:

- JOSE / JWT verification
- disclosure parser
- digest recomputation
- key binding verification
- nonce validation
- audience validation
- OpenID request / response handling

### Ventajas operativas

Mucho más simple en backend:

- logs legibles
- debug fácil
- payload compacto
- menos dependencia externa
- excelente DX
- ideal para NestJS / microservicios

### Dónde brilla

Ideal para:

- login
- onboarding
- KYC
- employee access
- IAM enterprise
- mobile wallets
- flows EUDI
- integraciones bancarias

---

## 5) Diferencias prácticas en presentación

Esta es la diferencia más importante.

### W3C VC

**Presentación simple**

Se manda la VC completa.

**Presentación avanzada**

Con BBS+ podés revelar:

- solo edad
- solo rol
- solo empresa

sin exponer el resto.

**Trade-off**

Más privacidad fuerte, más complejidad.

### SD-JWT VC

El holder selecciona qué disclosures mandar.

Ejemplo:

- mostrar edad
- ocultar DNI
- ocultar domicilio

**Trade-off**

Más simple, más práctico, menos complejidad criptográfica.

---

## 6) Qué cambia a nivel arquitectura

### Recomendación de diseño

- Dominio único: `EmployeeCredential`
- Dos serializadores:
  - `toW3cVc()`
  - `toSdJwtVc()`
- Un mismo protocolo:
  - OID4VCI
  - OID4VP

**Así evitás duplicar lógica.**

---

## 7) Impacto en issuer / holder / verifier

### Issuer

Debe elegir formato según:

- wallet capabilities
- credential_configuration_id
- canal
- regulation

### Holder

Debe soportar:

**W3C**

- storage de VC JSON
- proofs derivadas
- context support

**SD-JWT**

- JWT storage
- disclosures
- key binding keys

### Verifier

Debe hacer format negotiation.

```ts
if (format === 'dc+sd-jwt') verifySdJwt()
if (format === 'ldp_vc') verifyJsonLd()
```

---

## 8) Tabla de diferencias

| Aspecto | W3C VC | SD-JWT VC |
|--------|--------|-----------|
| Modelo | Documento | Token |
| Firma | Proof / Data Integrity | JWT signature |
| Selective disclosure | BBS+ | Native disclosures |
| Complejidad | Alta | Media / Baja |
| DX backend | Media | Alta |
| Semántica | Excelente | Buena |
| Enterprise IAM | Buena | Excelente |
| Gobierno / legal | Excelente | Buena |
| Mobile wallet | Buena | Excelente |

---

## 9) Regla práctica final

La mejor forma de pensarlo es:

- una sola credencial de negocio
- dos formas estándar de serializarla y probarla

### W3C

Cuando priorizás:

- semántica
- linked data
- evidencia fuerte
gobierno
diplomas

### SD-JWT

Cuando priorizás:

- OpenID
auth
- UX
- mobile
- onboarding
- DX

---

## 10) Recomendación para arquitectura híbrida

La estrategia más sólida hoy:

- Canonical domain model = W3C-like
- Remote exchange = SD-JWT + OID4VC
- Institutional archive = JSON-LD VC
- Physical exchange = mdoc

Esto sigue el patrón de EUDI y evita reescribir el core.

---

## 11) Lifecycle y control del Selective Disclosure

El selective disclosure participa en tres momentos distintos del ciclo de vida de una credencial.

### Emisión

En la emisión, el issuer decide si la credencial será compatible con selective disclosure.

**W3C**

- firma SD-capable (ej. BBS+)
- capacidad de derivación incluida en la proof base

**SD-JWT**

- incorporación de `_sd` digests
- disclosures futuras preparadas

### Presentación

El verifier define qué necesita probar. El holder decide qué revelar.

### Verificación

El verifier valida:

- subset recibido
- proof derivada o disclosures
- nonce / audience
- issuer trust

---

## Conclusión

Los dos caminos no son dos negocios distintos, sino:

**dos formas estándar de representar, firmar, intercambiar y verificar la misma credencial**

La arquitectura correcta separa dominio, serialización, transporte y verificación.
