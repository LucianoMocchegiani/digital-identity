
Status quark 2.0

(pendiente)
- conectar explorer con servicios
- actualizacion de ui quark-wallet

(pendiente no entra en mvp)

- wallet tamaño de contenedor creedenciales y favoritas.
- compatibilidad en openid4vc con eudi issuer, verifier desde quark-wallet y quark-holder (ver carpeta quark/docs/deuda-tecnica)
- revisar flujo de domain-key en KMS: la implementación actual usa una función utilitaria con Pool propio en `identity-core/kms/domain-key.ts`. Evaluar integración nativa en `InternalKeyManagementService`, `ExternalKeyManagementService` y `ExternalVaultKeyManagementService` para que el import al scope `domain-key` pase por la misma interfaz `Kms.KeyManagementService` que el resto de operaciones. Buscar optimizaciones (pool compartido, soporte en external/vault KMS, posible endpoint de rotación).
- cablear vault en identity core (ver carpeta quark/docs/deuda-tecnica)
- pruebas de estres issuer, verifier, holder.
- pruebas de estres index, resolver.
- soporte y documentacion para protocolo DIDComm (orientado a soportar Quark v1 / Extrimian).
actualmente hay un desarrollo incompleto del mismo (involucra a identity-core, identity-core-dart , issuer, verifier, holder, wallet).
- registrar dids creados desde la quark-wallet en index.
- registrar dids web/kwk/key externos resueltos en index, lo que sean de blokchain se registran desde  el resolver.
- revocacion Didcomm (involucra identity-core, identity-core-dart, issuer, verifier, notificar credencial revocada a holder y wallet).
- nodo(rsk, vcsl) 2.0 revicion y planificacion.


- (finalizado)revocacion Openid4vc (involucra identity-core, identity-core-dart, issuer, verifier, notificar credencial revocada a holder y wallet).
- (finalizado) wallet PIN / cifrado por campo (Ruta C) — `identity-core-dart` PR1–PR2 (`feat/field-cipher-pin-hash`): `FieldCipher` `enc:v1:`, hash PIN Argon2id, stores sensibles; QA manual en `quark-wallet` (jun 2026). Pendiente opcional: PR3 migración legacy, `allowBackup=false` Android. Ver `local/guides/identity-core-cifrado-campo-pr-checklist.md`.
(finalizado)
- (desestimado para mvp) Desarrollo del Observer.
- (finalizado) Utilidad para enviar DID y JWK recién creados (holders, emisores, verificadores) al Observer / Index.


- wallet ajustar colores de botones muy claros en  categorias y dejar color default para el corazon is favorite
- wallet credencial en categoria redirige a credencial detalle
- wallet vistas de emision viejas alinear con la ui nueva
- wallet vistas de verificacion viejas alinear con la ui nueva
- wallet propuesta de diseño, en categorias "x" y ">" se ve raro propuesta un arrow up y down.
- wallet propuesta de diseño, en credcial card usar el color del texto para el ojo y el corazon, por el image background.
- wallet propuesta de diseño, credencial mustra datos del usuario en la card y el hero de el detalle