# Request bodies de referencia — OID4VCI + OID4VP

Bodies para los **servicios de identidad multi-tenant** (`quark-issuer-service`, `quark-holder-service`, `quark-verifier-service`).

Todas las rutas de protocolo llevan el **wallet id** en el path:

- Issuer: `{{issuerBaseUrl}}/{{issuerId}}/openid4vc/...`
- Holder: `{{holderBaseUrl}}/{{holderId}}/openid4vc/...`
- Verifier: `{{verifierBaseUrl}}/{{verifierId}}/openid4vc/...`

Environments Postman: `postman/Quark-Local-Docker.postman_environment.json`, `postman/Quark-Tunnel-Dominios.postman_environment.json`.

---

## Alta de tenants (admin)

Ejecutar antes del flujo OID4VC si el servicio se reinició o `GET /issuers` devuelve `[]`.

Documentación completa (respuestas, errores, records): [api-tenants-y-records.md](./api-tenants-y-records.md).

### Listado — `GET /issuers` | `GET /holders` | `GET /verifiers`

Sin body. Devuelve wallets del proceso con `tenantId` y `did`.

```json
{
  "issuers": [
    {
      "issuerId": "issuer-wallet-oid4vc",
      "tenantId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "did": "did:web:localhost%3A9001:issuer-wallet-oid4vc"
    }
  ]
}
```

### Issuer — `POST /issuers`

```json
{
  "issuerId": "issuer-wallet-oid4vc",
  "oid4vc": {
    "display": [{ "name": "Issuer", "locale": "es" }],
    "dpopSigningAlgValuesSupported": ["ES256"],
    "credentialConfigurationsSupported": {
      "quarkid_demo": {
        "format": "dc+sd-jwt",
        "vct": "QuarkCredential",
        "cryptographic_binding_methods_supported": ["did:jwk", "jwk"],
        "credential_signing_alg_values_supported": ["ES256"],
        "proof_types_supported": {
          "jwt": { "proof_signing_alg_values_supported": ["ES256"] }
        },
        "display": [{
          "name": "QuarkCredential",
          "locale": "en",
          "background_color": "#1a1a2e",
          "text_color": "#ffffff"
        }]
      }
    }
  }
}
```

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `issuerId` | Sí | Id lógico del tenant (rutas y `did:web:...:issuerId`). Sin `{{variables}}`. |
| `oid4vc` | No | Si se omite, solo `DidRecord` + `StorageVersionRecord`. |

**Respuesta:** `issuerId`, `tenantId`, `did`, `recordsCreated[]` (`DidRecord`, `StorageVersionRecord`, opcional `OpenId4VcIssuerRecord`).

### Holder — `POST /holders`

```json
{
  "holderId": "holder-wallet"
}
```

**Respuesta:** `holderId`, `tenantId`, `did` (`did:key`), `recordsCreated`: `DidRecord`, `StorageVersionRecord`.

### Verifier — `POST /verifiers`

```json
{
  "verifierId": "verifier-wallet",
  "oid4vp": {
    "clientMetadata": {
      "client_name": "Quark Verifier"
    }
  }
}
```

**Respuesta:** `verifierId`, `tenantId`, `did`, `recordsCreated` (incluye `OpenId4VcVerifierRecord` si hubo `oid4vp`).

### Metadata — `PATCH /:walletId/metadata` (issuer / verifier)

Issuer (merge en `OpenId4VcIssuerRecord`):

```json
{
  "credentialConfigurationsSupported": {
    "quarkid_demo": {
      "format": "dc+sd-jwt",
      "vct": "QuarkCredential",
      "display": [{ "name": "Quark Credential (actualizado)", "locale": "es" }]
    }
  }
}
```

Verifier (merge en `OpenId4VcVerifierRecord.clientMetadata`):

```json
{
  "clientMetadata": {
    "client_name": "Quark Verifier (actualizado)"
  }
}
```

---

## Consulta de records (solo lectura)

Rutas bajo `/:walletId/records`. Ver [api-tenants-y-records.md](./api-tenants-y-records.md).

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/:walletId/records/types` | Catálogo de tipos con `description` por rol |
| `GET` | `/:walletId/records?type=&page=&limit=&query=` | Listado paginado |
| `GET` | `/:walletId/records/:recordType/:recordId` | Un record por UUID |

**Query `type` (ejemplos por rol)**

| Rol | Tipos útiles tras un flujo |
|-----|---------------------------|
| Issuer | `ConnectionRecord`, `OpenId4VcIssuanceSessionRecord`, `OpenId4VcIssuerRecord` |
| Holder | `W3cCredentialRecord`, `ConnectionRecord`, `ProofExchangeRecord` |
| Verifier | `OpenId4VcVerificationSessionRecord`, `ConnectionRecord`, `OpenId4VcVerifierRecord` |

**Filtro opcional** — `query` como string JSON URL-encoded:

```http
GET /issuer-wallet-oid4vc/records?type=ConnectionRecord&query=%7B%22state%22%3A%22completed%22%7D
```

(`{"state":"completed"}`)

---

## Emisión — `POST /{{issuerId}}/openid4vc/offer`

```json
{
  "credentialConfigurationId": "QuarkCredential",
  "vct": "QuarkCredential",
  "claims": {
    "name": "Juan Perez",
    "email": "juan@example.com",
    "role": "member",
    "organization": "Quark Demo",
    "validFrom": "2026-05-09"
  },
  "disclosureFrame": {
    "_sd": ["email", "role", "organization", "validFrom"]
  },
  "claimsDisplay": {
    "name":         { "name": "Nombre completo",    "locale": "es" },
    "email":        { "name": "Correo electrónico", "locale": "es" },
    "role":         { "name": "Rol",               "locale": "es" },
    "organization": { "name": "Organización",       "locale": "es" },
    "validFrom":    { "name": "Válido desde",       "locale": "es" }
  },
  "preAuthorizedCode": "quark-demo-2026"
}
```

| Campo | Obligatorio | Descripción |
|---|---|---|
| `credentialConfigurationId` | Sí | ID de la configuración registrada en el issuer. Debe coincidir con el `well-known`. |
| `vct` | Sí | Tipo semántico de la credencial. Se almacena en el claim `vct` del SD-JWT. |
| `claims` | Sí | Datos a certificar. Se insertan directamente en el payload del SD-JWT. |
| `disclosureFrame._sd` | No | Claims que el titular puede revelar o no al presentar. `name` queda siempre visible porque no está en `_sd`. |
| `claimsDisplay` | No | Etiquetas legibles que la wallet (ej. EUDI) muestra al usuario para cada campo. |
| `preAuthorizedCode` | No | Código fijo para demos predecibles. Si se omite, Credo genera uno aleatorio. |

---

## Verificación DCQL — `POST /{{verifierId}}/openid4vc/request`

```json
{
  "dcqlQuery": {
    "credentials": [
      {
        "id": "quark-credential",
        "format": "dc+sd-jwt",
        "meta": {
          "vct_values": ["QuarkCredential"]
        },
        "claims": [
          { "path": ["name"] },
          { "path": ["email"] },
          { "path": ["role"] },
          { "path": ["organization"] },
          { "path": ["validFrom"] }
        ]
      }
    ]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}
```

| Campo | Obligatorio | Descripción |
|---|---|---|
| `credentials[].id` | Sí | Identificador interno del descriptor. Se usa en el `presentation_submission` de la respuesta. |
| `credentials[].format` | Sí | Formato esperado. `dc+sd-jwt` para SD-JWT DC (estándar EUDI), `vc+sd-jwt` para la variante VC. |
| `meta.vct_values` | No | Filtra por tipo exacto de credencial. Sin este campo acepta cualquier `vct`. |
| `claims[].path` | No | Claims que se solicitan al titular. Puede reducirse a los que realmente se necesitan para la demo. |
| `responseMode` | No | `direct_post` (default) o `direct_post.jwt` (respuesta cifrada JARM). |
| `requestSignerMethod` | No | `did` firma con el DID del verifier · `none` sin firma · `x5c` con certificado X.509. |

> **Nota:** `meta.vct_values` debe estar dentro del objeto `meta`, no al nivel raíz del descriptor.
> El motor DCQL lo lee de `credentialQuery.meta.vct_values`; si no está ahí, ignora el filtro.

---

## Verificación PEX — `POST /{{verifierId}}/openid4vc/request`

```json
{
  "presentationDefinition": {
    "id": "pd-quark-sdjwt",
    "input_descriptors": [
      {
        "id": "quark-credential",
        "name": "Quark Credential",
        "purpose": "Verificar identidad en Quark Demo",
        "constraints": {
          "limit_disclosure": "required",
          "fields": [
            {
              "path": ["$.vct"],
              "filter": { "const": "QuarkCredential" }
            },
            { "path": ["$.name"] },
            { "path": ["$.email"] },
            { "path": ["$.role"] },
            { "path": ["$.organization"] },
            { "path": ["$.validFrom"] }
          ]
        }
      }
    ]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}
```

| Campo | Obligatorio | Descripción |
|---|---|---|
| `id` | Sí | ID único de la presentation definition. Aparece en el `definition_id` del `presentation_submission`. |
| `input_descriptors[].id` | Sí | ID del descriptor. Referenciado en el `descriptor_map` de la respuesta. |
| `purpose` | No | Texto que la wallet muestra al usuario explicando para qué se solicita la credencial. |
| `constraints.limit_disclosure` | No | `"required"` obliga al titular a revelar **solo** los campos listados. Sin esto podría presentar todos. |
| `fields[].path` | Sí | Ruta JSONPath al campo dentro del SD-JWT (ej. `$.name`). |
| `fields[].filter` | No | Restricción sobre el valor. `{ "const": "QuarkCredential" }` exige ese valor exacto. Necesario para filtrar por tipo. |
| `responseMode` | No | Igual que en DCQL. |
| `requestSignerMethod` | No | Igual que en DCQL. |

## Verificación DCQL con múltiples tipos (OR) — `POST /{{verifierId}}/openid4vc/request`

Cuando se quiere aceptar cualquiera de dos tipos de credencial. Usa `credential_sets` para definir la lógica OR.

```json
{
  "dcqlQuery": {
    "credentials": [
      {
        "id": "cred-v1",
        "format": "dc+sd-jwt",
        "meta": { "vct_values": ["QuarkCredential"] },
        "claims": [
          { "path": ["name"] },
          { "path": ["email"] },
          { "path": ["role"] }
        ]
      },
      {
        "id": "cred-v2",
        "format": "dc+sd-jwt",
        "meta": { "vct_values": ["QuarkCredential2"] },
        "claims": [
          { "path": ["name"] },
          { "path": ["email"] },
          { "path": ["role"] }
        ]
      }
    ],
    "credential_sets": [
      {
        "options": [["cred-v1"], ["cred-v2"]],
        "required": true
      }
    ]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}
```

| Campo | Descripción |
|---|---|
| `credentials[].id` | Cada descriptor debe tener un ID único. |
| `credential_sets[].options` | Array de combinaciones válidas. Cada elemento es una lista de IDs que el holder debe presentar juntos. Acá: `["cred-v1"]` ó `["cred-v2"]`, cualquiera alcanza. |
| `credential_sets[].required` | `true` = el holder debe satisfacer alguna de las opciones. `false` = la presentación es opcional. |

> **Sin `credential_sets`:** tener dos entradas en `credentials` implica lógica AND (el holder debe presentar ambas a la vez).
> **Con `credential_sets`:** cada elemento de `options` es una combinación válida → lógica OR entre opciones.

## Verificación PEX con múltiples tipos (OR) — `POST /{{verifierId}}/openid4vc/request`

Equivalente al DCQL con `credential_sets`. En PEX el OR se expresa con `submission_requirements` + `group` en cada descriptor.

```json
{
  "presentationDefinition": {
    "id": "pd-quark-multi",
    "submission_requirements": [
      {
        "name": "Quark Credential (cualquier versión)",
        "purpose": "Se acepta QuarkCredential o QuarkCredential2",
        "rule": "pick",
        "count": 1,
        "from": "quark-group"
      }
    ],
    "input_descriptors": [
      {
        "id": "cred-v1",
        "name": "Quark Credential",
        "group": ["quark-group"],
        "constraints": {
          "limit_disclosure": "required",
          "fields": [
            { "path": ["$.vct"], "filter": { "const": "QuarkCredential" } },
            { "path": ["$.name"] },
            { "path": ["$.email"] },
            { "path": ["$.role"] }
          ]
        }
      },
      {
        "id": "cred-v2",
        "name": "Quark Credential 2",
        "group": ["quark-group"],
        "constraints": {
          "limit_disclosure": "required",
          "fields": [
            { "path": ["$.vct"], "filter": { "const": "QuarkCredential2" } },
            { "path": ["$.name"] },
            { "path": ["$.email"] },
            { "path": ["$.role"] }
          ]
        }
      }
    ]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}
```

| Campo | Descripción |
|---|---|
| `input_descriptors[].group` | Asigna el descriptor a un grupo. El holder elige cualquier descriptor del mismo grupo para satisfacer el requirement. |
| `submission_requirements[].rule` | `"pick"` = elegir N del grupo · `"all"` = presentar todos. |
| `submission_requirements[].count` | Cuántos descriptores del grupo debe presentar el holder. `1` = OR entre todos los del grupo. |
| `submission_requirements[].from` | Nombre del grupo al que aplica la regla. Debe coincidir con `group[]` de los descriptores. |

> **Sin `submission_requirements`:** todos los `input_descriptors` son AND (el holder debe satisfacer todos).
> **Con `submission_requirements` + `count: 1`:** el holder elige uno del grupo → lógica OR.

## Verificación PEX con múltiples credenciales (AND) — `POST /{{verifierId}}/openid4vc/request`

El holder debe presentar **ambas** credenciales a la vez. Sin `submission_requirements`, todos los `input_descriptors` son obligatorios.

```json
{
  "presentationDefinition": {
    "id": "pd-quark-and",
    "input_descriptors": [
      {
        "id": "cred-v1",
        "name": "Quark Credential",
        "purpose": "Credencial principal Quark",
        "constraints": {
          "limit_disclosure": "required",
          "fields": [
            { "path": ["$.vct"], "filter": { "const": "QuarkCredential" } },
            { "path": ["$.name"] },
            { "path": ["$.email"] },
            { "path": ["$.role"] }
          ]
        }
      },
      {
        "id": "cred-v2",
        "name": "Quark Credential 2",
        "purpose": "Credencial secundaria Quark",
        "constraints": {
          "limit_disclosure": "required",
          "fields": [
            { "path": ["$.vct"], "filter": { "const": "QuarkCredential2" } },
            { "path": ["$.name"] },
            { "path": ["$.email"] },
            { "path": ["$.role"] }
          ]
        }
      }
    ]
  },
  "responseMode": "direct_post",
  "requestSignerMethod": "did"
}
```

> El holder debe tener **las dos** credenciales en su wallet para poder responder. Si le falta una, la presentación falla.

---

## DCQL vs PEX — cuándo usar cada uno

| | DCQL | PEX |
|---|---|---|
| Sintaxis | Más simple y directa | Más expresiva |
| Filtro de tipo | `meta.vct_values` | `$.vct filter const` |
| Selective disclosure | `claims[].path` | `fields[].path` + `limit_disclosure` |
| `vp_token` en respuesta | JSON object `{ "id": ["compact..."] }` | Compact SD-JWT plano `"eyJ..."` |
| Estándar recomendado | OID4VP v1 (EUDI ARF 1.5+) | OID4VP v1.draft21 |
