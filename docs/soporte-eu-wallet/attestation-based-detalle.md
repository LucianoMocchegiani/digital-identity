# AttestationBased en OID4VCI (detalle práctico)

## Resumen ejecutivo

`AttestationBased` en OID4VCI es un modo de autenticación de cliente donde la wallet (o app cliente) demuestra, mediante evidencia criptográfica, que es un cliente legítimo y ejecuta en un entorno de confianza.  
Es más seguro que `None("client-id")`, pero exige soporte explícito del emisor en dos capas:

- **Metadata del Authorization Server / Issuer** (capabilities anunciadas).
- **Validación server-side** de la attestation (tokens, certificados, confianza, políticas).

Si el emisor no soporta ese modo de forma completa, la wallet falla antes o durante el token flow.

---

## Qué significa `AttestationBased`

En términos simples:

- El cliente no solo se identifica con un `client_id`.
- También presenta una **prueba de atestación** (por ejemplo un JWT/cadena de confianza) que el servidor debe validar.
- El servidor decide si acepta al cliente según políticas (issuer, app permitida, dispositivo, confianza, expiración, etc.).

Esto se usa para reducir abuso, automatización maliciosa y suplantación de apps cliente.

---

## Qué cambia respecto de `None("client-id")`

### `None("client-id")`

- **Ventaja**: interopera rápido.
- **Costo**: menos garantías sobre quién es el cliente real.
- Útil para entornos de prueba, pilotos o bootstrap de compatibilidad.

### `AttestationBased`

- **Ventaja**: autenticación de cliente más fuerte.
- **Costo**: integración más compleja (metadata + validadores + trust anchors + observabilidad).
- Recomendable para producción cuando el ecosistema y la wallet lo soportan de punta a punta.

---

## Requisitos para soportarlo bien en el issuer

## 1) Metadata correcta y consistente

El issuer/AS debe publicar metadata que refleje que soporta client attestation y los métodos/algoritmos esperados.  
La wallet toma decisiones con base en esa metadata; si falta o es inconsistente, puede abortar el flujo.

Checklist:

- Endpoints OID4VCI/OAuth correctos.
- Capacidades de client auth alineadas al modo attestation.
- Algoritmos y parámetros criptográficos compatibles.
- Sin campos parcialmente declarados (evitar metadata “incompleta” que rompa parseo del cliente).

## 2) Validación server-side de attestation

No alcanza con “declarar soporte” en metadata. El backend debe:

- Verificar firma y estructura de la attestation.
- Validar cadena de confianza/certificados o mecanismo equivalente.
- Validar temporalidad (exp, nbf, iat), audiencia, emisor y claims críticos.
- Aplicar política de aceptación (allow-list, issuer policy, revocación, riesgo).

## 3) Manejo de errores y trazabilidad

Para debug y operación:

- Logs estructurados sin exponer secretos.
- Mensajes de error diferenciados (metadata, parseo, firma, confianza, policy).
- Correlación por `x-correlation-id` entre gateway/auth/issuer.

---

## Fallas típicas cuando no está completo

- Wallet indica que el AS no soporta attestation.
- Flujo corta luego de metadata/offer y no llega a token.
- Errores de parseo o validación por parámetros cripto faltantes.
- Incompatibilidades por algoritmos/campos declarados pero no implementados.

---

## Relación con DPoP (importante)

`AttestationBased` y `DPoP` no son lo mismo:

- **Attestation**: prueba identidad/legitimidad del cliente.
- **DPoP**: prueba posesión de clave para el token/HTTP request.

Pueden coexistir. Que uno funcione no implica que el otro esté bien configurado.

---

## Estrategia recomendada de adopción

1. **Fase compatibilidad**: `None("client-id")` + DPoP + observabilidad completa.
2. **Fase endurecimiento**: agregar attestation en entorno controlado.
3. **Fase producción**: habilitar `AttestationBased` con validación real y políticas.
4. **Fallback operativo**: feature flag para volver temporalmente a `None` ante incidentes.

---

## Estado aplicado en este contexto (Quark + EUDI)

En el troubleshooting actual:

- EUDI wallet intentó `AttestationBased`.
- Quark issuer no lo soportaba de manera completa.
- Se usó `None("client-id")` para recuperar interoperabilidad y avanzar en emisión.

Conclusión práctica:

- `AttestationBased` aporta seguridad, pero no conviene activarlo “a medias”.
- Si metadata y validación server-side no están ambos listos, es mejor mantener modo compatible hasta completar la implementación.
