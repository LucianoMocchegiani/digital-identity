# Investigación: Offline en OpenID4VC / OID4VP

## 1. Issuer

### ¿Debe estar online?

**No necesariamente.** El issuer tiene dos momentos distintos:

- **Emisión (online obligatorio):** Firma, registra revocation status, envía al holder.
- **Verificación posterior (offline posible):** La credencial lleva firma criptográfica y estado. El issuer no interviene en la verificación holder→verifier.

### Mecanismos offline del issuer

| Mecanismo | Qué hace |
|---|---|
| **Status Lists** (VC-BITSTRING-STATUS-LIST) | Lista de bits con credenciales revocadas. El verifier la cachea y verifica offline. |
| **Credential refresh** (OID4VCI) | `refresh_token` + `credential_refresh`. La credencial sigue válida sin refresh. |
| **Trusted metadata** | Claves públicas y metadata en `/.well-known/openid-credential-issuer`. Se cachea para uso offline. |

### Lo que sí requiere online

- Emisión nueva
- Rotación de claves
- Actualización de status list
- Refresh de credenciales expiradas

### Nota sobre "whitelist / allowed apps"

No es parte del estándar OID4VC, pero se implementa a nivel de configuración del issuer (`credentialConfigurationSupported` con `allowedClientIds`). Se actualiza con conexión periódica.

---

## 2. Verifier

### ¿Debe estar online?

- **Recepción de presentación:** Sí (HTTP POST, `direct_post` o `direct_post.jwt`).
- **Verificación de credencial:** Puede ser offline si tiene cacheado:
  - Clave pública del issuer
  - Status list actualizada
  - Metadata del issuer

### Flujo típico

1. Verifier solicita presentación (online) → recibe VP
2. Verifier verifica firma + status (puede ser offline con cache)
3. Verifier valida claims contra política local

### Limitación

Si la credencial fue revocada *desde* la última status list cacheada, el verifier offline no lo detecta. Por eso hay TTL de refresh de status list (ej: 24h).

---

## 3. Holder

### El único operable 100% offline

- **Almacena** credenciales localmente
- **Selecciona claims** (selective disclosure) sin conexión
- **Firma** la presentación con su clave local
- **Envía** la presentación al verifier (acá necesita online)

### mDoc (ISO 18013-5/7) y offline

- El mdoc es un CBOR document con `IssuerSigned` — firma del issuer embebida
- Verificación de firma del issuer posible offline si el holder tiene la clave pública
- La `DeviceResponse` se construye offline y se envía cuando hay conectividad
- Holder binding usa clave del dispositivo, no requiere online del issuer

### Estado en el código actual

`MdocRecord` ya almacena `issuerSignedBytes` para presentación offline, pero el parser CBOR completo (`MdocParser`) está en **Fase 4 pendiente**. Hoy no se puede verificar la firma CBOR del issuer ni construir la `DeviceResponse` sin conexión.

---

## Resumen visual

```
Issuer:    online (emisión) / offline (verificación por terceros)
Verifier:  online (recepción) / offline (verificación con cache)
Holder:    100% offline para almacenar, seleccionar, firmar
           solo necesita online para ENVIAR la presentación
```

## Referencias

- [OpenID4VP 1.0](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html)
- [W3C VC Data Model 2.0](https://www.w3.org/TR/vc-data-model-2.0/)
- [W3C VC Overview 1.0](https://www.w3.org/TR/vc-overview/)
- [ISO 18013-5 (mdoc)](https://www.iso.org/standard/72475.html)
- [VC-BITSTRING-STATUS-LIST](https://www.w3.org/TR/vc-bitstring-status-list/)