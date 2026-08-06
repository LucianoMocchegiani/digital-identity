# Deuda Tecnica: Soporte Dual ES256 + EdDSA en OID4VCI/OID4VP

## Contexto

Actualmente el flujo funciona de forma estable cuando el issuer publica solo:

- `proof_signing_alg_values_supported: ['EdDSA']`

Cuando se publica soporte dual:

- `proof_signing_alg_values_supported: ['ES256', 'EdDSA']`

en algunos escenarios la wallet negocia `ES256`, pero el issuer no logra completar la generacion de la credential response y falla con:

- `Failed to create a credential response`

Esto indica una brecha entre lo que se declara como soportado en metadata y lo que efectivamente esta operativo en runtime.

## Problema tecnico

El ecosistema declara compatibilidad con dos algoritmos de prueba (`ES256` y `EdDSA`), pero la implementacion actual no garantiza de extremo a extremo:

1. seleccion correcta de clave segun algoritmo negociado,
2. resolucion de `didUrl` compatible con `ES256`,
3. emision y verificacion consistente para ambos algoritmos.

Resultado: la metadata puede anunciar `ES256`, pero el pipeline de emision/verificacion queda sesgado a `EdDSA`.

## Impacto

- Riesgo de fallos intermitentes segun wallet y estrategia de negociacion.
- Incompatibilidad con wallets que prefieren o fuerzan `ES256`.
- Dificultad de interoperabilidad EUDI al anunciar capacidades no validadas.

## Objetivo de la deuda

Habilitar soporte dual real `ES256 + EdDSA` sin romper el flujo actual funcional con `EdDSA`.

## Alcance tecnico sugerido

### 1) Material criptografico y DID Document

- Verificar que el issuer mantenga claves activas para ambos casos:
  - P-256 para `ES256`
  - Ed25519 para `EdDSA`
- Confirmar que ambas claves esten publicadas y resolubles en el DID Document con `id` y `controller` correctos.

### 2) Seleccion de clave de firma por algoritmo

- Introducir estrategia explicita de seleccion de `didUrl` segun algoritmo de proof negociado.
- Evitar fallback implicito que termine usando una unica clave para todos los casos.

### 3) Metadata de capacidad

- Publicar `proof_signing_alg_values_supported` en funcion de capacidades reales del runtime.
- Si `ES256` no esta completamente operativo, no anunciarlo en metadata productiva.

### 4) Flujo OID4VCI (issuer)

- Validar que `credentialRequestToCredentialMapper` y `createSdJwtOffer` acepten y procesen proof `ES256`.
- Confirmar que la respuesta de credencial se firma con la clave/algoritmo correcto segun negociacion.

### 5) Flujo OID4VP (verifier)

- Asegurar verificacion consistente para respuestas con `dc+sd-jwt` y variaciones de `kid` (absoluto/relativo), sin degradar soporte existente.
- Evitar hacks de formato que rompan `presentation_submission`.

## Plan incremental recomendado

1. Mantener `EdDSA` como baseline estable en produccion.
2. Implementar soporte `ES256` detras de flag/config de entorno.
3. Agregar suite de pruebas de interoperabilidad por algoritmo:
   - issuer + verifier internos
   - wallet de referencia A
   - wallet de referencia B
4. Habilitar metadata dual solo cuando las pruebas pasen en matriz completa.

## Criterios de aceptacion

- Emision OID4VCI exitosa con proof `EdDSA`.
- Emision OID4VCI exitosa con proof `ES256`.
- Verificacion OID4VP exitosa para credenciales emitidas con ambos algoritmos.
- Metadata publica consistente con capacidades reales.
- Sin regresion del flujo actual con EasyPID/Paradym.

## Riesgos y mitigaciones

- **Riesgo:** regresion en flujo estable `EdDSA`.
  - **Mitigacion:** rollout por flag y pruebas de regresion obligatorias.
- **Riesgo:** diferencias de implementacion entre wallets.
  - **Mitigacion:** pruebas por wallet + logs diagnosticos controlados por nivel `DEBUG`.
- **Riesgo:** deuda de compatibilidad en `kid` relativo.
  - **Mitigacion:** validar resolucion de claves contra DID Document antes de activar dual.

## Nota operativa actual

Hasta completar esta deuda, la configuracion recomendada para estabilidad es:

- `proof_signing_alg_values_supported: ['EdDSA']`

y no anunciar `ES256` en entornos donde no este validado end-to-end.
