# Deuda técnica: `@quarkid/identity-core` en entorno real

Lista de huecos y mejoras para operar y endurecer el paquete `packages/identity-core` fuera de un MVP (KMS interno/externo, Vault, observabilidad y documentación).

**Records Credo:** siempre inyectados en proceso (`RecordStorage` → típicamente `PostgresRecordStorage`).

---

## KMS externo (`ExternalKeyManagementService`)

1. **Autenticación al servicio**: no hay configuración de `Authorization`, API keys ni headers fijos; solo la URL base.
2. **`getPublicKey` inconsistente**: usa `fetch` directo en lugar del mismo helper que el resto de operaciones; cualquier header común habría que duplicarlo o unificar rutas.
3. **Timeouts y cancelación**: las llamadas `fetch` no usan `AbortSignal` / timeout explícito (riesgo ante KMS lento o colgado).
4. **Reintentos y backoff**: no hay política ante `5xx` o fallos de red (el KMS interno sí usa `withRetry` en la inicialización de Postgres).
5. **mTLS / trust store**: no modelado (entornos con CA interna o pin de cert suelen necesitarlo explícito o documentado en el proxy).
6. **`randomBytes` en proceso local**: en modo external, `randomBytes` se genera en el agente con `crypto.randomBytes` y no se delega al KMS; puede ser aceptable, pero debe documentarse en auditorías que buscan “todo el cripto en el HSM”.

---

## KMS interno (`InternalKeyManagementService`)

7. **Material privado en Postgres**: los JWK privados se persisten en texto (columna `private_jwk`); la protección depende sobre todo del control de acceso a la base y del entorno, no de cifrado de aplicación sobre esa columna.
8. **Documentación vs implementación**: el README habla de claves cifradas en Postgres; el código actual no refleja esa capa. Hay que ajustar la doc o implementar cifrado / envelope keys según el modelo de amenazas.

---

## Modo Vault (HashiCorp Transit)

9. **`mode: 'vault'` no cableado**: `buildKeyManagementModule` y `registerKmsConfig` solo bifurcan `external` vs el resto; `vault` termina usando el backend **internal** (Postgres).
10. **Config incompleta**: `KmsConfig` no incluye URL de Vault, token, path Transit, etc. `CredoEnvConfig` (`buildCredoConfigFromEnv`) no admite `kmsMode: 'vault'`.

---

## Configuración y despliegue

13. **Paridad env / tipos**: variables y tipos de `buildCredoConfigFromEnv` no cubren todas las capacidades declaradas en tipos o README (p. ej. Vault).
14. **Guía de producción**: falta un perfil documentado (variables obligatorias, secretos, red, separación de servicios).

---

## Observabilidad y trazabilidad

15. **`x-correlation-id`**: las llamadas HTTP al KMS externo no propagan cabecera de correlación alineada con el resto de QuarkID.
16. **Logging estructurado**: conviene registrar fallos (status, latencia, ruta) sin volcar payloads sensibles ni tokens.

---

## Seguridad y modelo de amenazas

17. **Wallet de Credo (`walletKey` + Askar)**: superficie distinta al modo KMS; el análisis de producción debe incluir wallet y KMS, no solo internal vs external.
18. **Política TLS**: no hay opciones en el paquete para TLS estricto o pin; suele delegarse al reverse proxy, pero debe quedar explícito en runbooks.

---

## Ciclo de vida y operaciones

19. **Rotación y revocación**: no hay política en el paquete para rotación del material en la tabla `keys` ni contrato formal con el kms-service.
20. **Migraciones entre backends KMS**: no hay guía ni herramientas para pasar de KMS internal a external (u otra instancia) sin procedimiento manual ad hoc.

---

## Priorización sugerida (sin implementar Vault ni cifrado en DB)

Para volver el paquete “manejable” en serio con menos esfuerzo:

1. Headers / auth unificados en todos los `fetch` del cliente KMS externo.
2. Timeouts + reintentos con backoff y errores enriquecidos (sin filtrar secretos).
3. Propagación de `x-correlation-id` y logs estructurados mínimos en fallos.

El resto es endurecimiento (Vault cableado, cifrado en internal, mTLS) y alineación honesta entre README y código.
