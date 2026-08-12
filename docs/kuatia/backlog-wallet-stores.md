# Kuatia Wallet — backlog stores (Play / App Store)

Backlog de **`identity-wallet`** para publicar en **Google Play** y **Apple App Store**.  
Misma forma que [backlog-mejoras.md](./backlog-mejoras.md): dos listas **fácil → difícil**.

1. **Desarrollo** — código, empaquetado, CI, UX de release  
2. **Tramiterío** — cuentas developer, legal, ficha de tienda, review  

**Estado hoy (baseline):** app Flutter funcional (OID4VCI / OID4VP / DIDComm), tema Kuatia (D10), `version: 0.1.0+1`.  
**Bloqueantes claros:** package/bundle `com.example.*`, label Android `identity_wallet`, faltan usage strings iOS (cámara / Face ID), sin firma release ni Privacy Manifest, sin URL de privacidad en stores.

Cuenta stores (org) ↔ [backlog Kuatia T8](./backlog-mejoras.md#t8-stores-wallet).  
Legal / privacidad pública ↔ [T6](./backlog-mejoras.md#t6-legalidades).

---

# A. Desarrollo

## Orden por dificultad

| # | Ítem | Dificultad | Notas |
|---|------|------------|--------|
| W1 | Identidad de app (nombre, IDs) | Baja | Fuera de `com.example`; label = Kuatia |
| W2 | Permisos y textos de sistema | Baja | Cámara, biometría; strings store-ready |
| W3 | Versión / build / Acerca de | Baja | `package_info`; no hardcode `v0.1.0` |
| W4 | Compliance iOS mínimo | Baja–media | Privacy Manifest + export encryption |
| W5 | Deep links / App Links prod | Baja–media | Schemes OK; HTTPS asociados si hace falta |
| W6 | Firma release Android + iOS | Media | Keystore / certs; nunca en git |
| W7 | Builds store (AAB / IPA) | Media | `flutter build appbundle` / ipa; flavors si aplica |
| W8 | QA release + dispositivos | Media | Matriz real; flujos QR/PIN/bio |
| W9 | Observabilidad release | Media | Crash reporting opcional; sin PII de claims |
| W10 | CI → stores (opcional v1) | Media–alta | Fastlane / Codemagic / GitHub Actions |
| W11 | Hardening store (R8, backup, secrets) | Media | Ya `allowBackup=false`; review R8/obfuscation |
| W12 | Accesibilidad + i18n store | Media–alta | A11y básica; listing EN si mercado |
| W13 | Post-1.0 store | Alta | Updates, feature flags, rate limits UX |

**Primeros candidatos (dev):** W1 → W2 → W3 → W4 → W6 → W7 → W8.  
**En paralelo con tramiterío:** W5 (dominio) + legal T6 (URL privacidad).

---

## Detalle — Desarrollo

### W1. Identidad de app (nombre, package, bundle)

Hoy:

| Plataforma | Valor actual | Objetivo típico |
|------------|--------------|-----------------|
| Android `applicationId` / `namespace` | `com.example.identity_wallet` | p. ej. `xyz.kuatia.wallet` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.example.identityWallet` | mismo esquema org |
| Android `android:label` | `identity_wallet` | **Kuatia** / **Kuatia Wallet** |
| iOS `CFBundleDisplayName` | `Identity Wallet` | alinear a Kuatia |
| UI Acerca de | «Kuatia Wallet» | coherente con stores |

- [ ] Definir **applicationId / bundle id finales** (no se pueden cambiar fácil tras publicar).
- [ ] Renombrar en `android/app/build.gradle.kts`, Xcode / `project.pbxproj`, manifests.
- [ ] Unificar display name Android + iOS + copy de tienda.
- [ ] Revisar ícono adaptive + App Icon (ya hay asset Kuatia vía `flutter_launcher_icons`).

### W2. Permisos y textos de sistema

La app usa **cámara** (QR) y **biometría** (`local_auth`). En iOS hace falta declaration + usage description o App Review rechaza.

- [x] iOS `Info.plist`: `NSCameraUsageDescription` (escaneo de códigos / ofertas).
- [x] iOS: `NSFaceIDUsageDescription` (desbloqueo de la wallet).
- [ ] Android: revisar `CAMERA` / biometría declarados por plugins; no pedir permisos de más.
- [ ] Copy en español (y EN si listing bilingüe): claro, sin jerga SSI innecesaria.
- [ ] Documentar en notas de review *por qué* cámara y biometría.

### W3. Versión, build number y pantalla Acerca de

- [ ] Fuente única: `pubspec.yaml` `version: x.y.z+build`.
- [ ] Acerca de: mostrar versión/build vía `package_info_plus` (hoy hardcode `v0.1.0`).
- [ ] Convención: bump **build** en cada upload a store; **name** semver producto.
- [ ] Changelog interno corto por release (opcional: enlace a notas públicas).

### W4. Compliance iOS mínimo (Privacy Manifest + cifrado)

- [ ] `PrivacyInfo.xcprivacy` (Privacy Manifest) con APIs “required reason” que usen Flutter/plugins.
- [ ] Declarar recopilación de datos coherente con la realidad: **holder-local**; sin cuenta cloud Kuatia en la wallet v1 salvo que se agregue.
- [ ] `ITSAppUsesNonExemptEncryption` / cuestionario export: SSI usa crypto; alinear respuesta real (suele ser exempt con cifrado estándar — validar con quien firme el submit).
- [ ] Revisar dependencias (`google_fonts` runtime, etc.) vs política de red / privacidad.

### W5. Deep links / App Links / Universal Links

Hoy: custom schemes OID4VCI / OID4VP en Android; iOS conviene espejar CFBundleURLTypes.

- [ ] iOS: URL types para los mismos schemes que Android (`openid-credential-offer`, `openid4vp`, …).
- [ ] Decidir si hace falta **HTTPS App Links / Universal Links** (dominio `kuatia.xyz` + `assetlinks.json` / `apple-app-site-association`).
- [ ] Probar cold start + app en background con offer/request reales.
- [ ] Documentar schemes en README wallet (ya parcialmente).

### W6. Firma release

- [ ] Android: keystore upload + key de firma Play App Signing; **fuera del repo**; backup offline documentado.
- [ ] Quitar `signingConfig = debug` del build `release` en `build.gradle.kts`.
- [ ] iOS: certificados Distribution + perfil; Apple Developer **organización** (T8).
- [ ] Checklist: quién tiene acceso al keystore / Apple keys (password manager equipo).

### W7. Builds listos para store

- [ ] Android: `flutter build appbundle` (AAB); no APK como artefacto principal de Play.
- [ ] iOS: archive → IPA / TestFlight.
- [ ] minSdk / targetSdk / iOS deployment target alineados a políticas vigentes de cada store.
- [ ] Splash / LaunchScreen coherentes con brand (sin flash púrpura legacy).
- [ ] (Opcional) flavors `dev` / `prod` si conviven entornos.

### W8. QA release (go / no-go)

Checklist mínimo antes del primer submit:

- [ ] Onboarding: PIN, biometría opcional, términos.
- [ ] Emisión OID4VCI por QR + deep link.
- [ ] Presentación OID4VP (selective disclosure).
- [ ] DIDComm inbox (si se declara en ficha).
- [ ] Reset wallet; reinstalación (con `allowBackup=false` no debe “revivir” wallet).
- [ ] Light / dark; rotación si se soporta.
- [ ] Dispositivos: ≥1 Android reciente + ≥1 iPhone; idealmente API baja cercana a minSdk.
- [ ] Sin crashes en happy path; mensajes de error entendibles.

### W9. Observabilidad en release

- [ ] Decidir: sin telemetría v1 **o** crash tool (Firebase Crashlytics / Sentry) **sin** claims/PII.
- [ ] Si hay analytics: declarar en Data safety / App Privacy y en política.
- [ ] Logging release: no filtrar secretos / DIDs sensibles a logcat.

### W10. CI → stores (opcional para v1)

- [ ] Pipeline: test + analyze + build AAB/IPA.
- [ ] Upload automatizado a Play internal / TestFlight (Fastlane, etc.).
- [ ] Secrets solo en CI (no committed).

### W11. Hardening

- [x] `android:allowBackup="false"` (comentario en manifest: salt en secure storage).
- [ ] Revisar ofuscación R8 / ProGuard si se habilita minify (plugins nativos).
- [ ] Inventario permisos final = mínimo necesario.
- [ ] Threat notes cortas para review: datos en dispositivo, PIN/bio, wipe = pérdida.

### W12. Accesibilidad e i18n (store)

- [ ] TalkBack / VoiceOver en flujos críticos (PIN, confirmar share).
- [ ] Contraste (ya tema Kuatia; edge cases).
- [ ] Textos UI ES estables; listing Play/App Store EN si el mercado lo pide (puede ser solo ficha, no app i18n completa).
- [ ] i18n in-app completo → más adelante (paralelo a Kuatia D11).

### W13. Post-1.0

- [ ] Política de updates (force update solo si breaking de protocolo).
- [ ] Feature flags / remote config si hace falta.
- [ ] Métricas de adopción store; respuesta a reviews.
- [ ] Roadmap producto wallet (backup social, multi-device, etc.) **fuera** del MVP store.
- [ ] Mejorar diseño de **categorías** (panel home, chips, creación/edición; alinear a tema Kuatia light/dark).
  - Parcial: contenedor con `CredentialCard` adentro + íconos del modal edit visibles en dark.
  - Parcial: panel renombrado a **Credenciales**; sin Favoritas ni listado plano; lupa + crear categoría en el panel.
- [x] **Feed de Inicio** (sliders hero Guías / Novedades / Eventos): UI + seed estático tipado + player YouTube embebido / links externos.
- [ ] **Diseñar e implementar sistema para cargar contenido a los sliders** del feed (CMS/API o panel admin): altas/edición de secciones e ítems (título, imagen, chip, YouTube o URL), sin release de app; el provider del wallet ya está listo para enchufar remoto + fallback al seed.

---

# B. Tramiterío

## Orden por dificultad

| # | Ítem | Dificultad | Notas |
|---|------|------------|--------|
| S1 | Cuentas developer org | Media | Google Play Console + Apple Developer |
| S2 | Material de ficha (assets) | Baja–media | Ícono, feature graphic, capturas |
| S3 | Copy de tienda + categoría | Baja–media | ES (+ EN); sin claims falsos |
| S4 | URLs obligatorias | Media | Privacidad, soporte; dependen T2/T6 |
| S5 | Cuestionarios store | Media | Data safety / App Privacy / rating |
| S6 | TestFlight / Play internal | Media | Círculo cerrado antes de prod |
| S7 | Review notes + primer submit | Media–alta | Explicar SSI, cámara, crypto |
| S8 | Cumplimiento continuo | Alta | Renovaciones, políticas, updates |

**Primeros candidatos (tramiterío):** S1 → S4 (legal) en paralelo a W1–W4 → S2/S3 → S5 → S6 → S7.

---

## Detalle — Tramiterío

### S1. Cuentas developer (organización)

Alineado a [T8](./backlog-mejoras.md#t8-stores-wallet) y [T1](./backlog-mejoras.md#t1-cuentas-corporativas--higiene).

| Store | Qué falta típico |
|-------|------------------|
| Google Play | Cuenta **organización**, identidad, comisión, users con roles |
| Apple | Apple Developer Program **Organization** (D-U-N-S), agreements |

- [ ] Alta Play Console a nombre de la org (no solo Gmail personal).
- [ ] Alta Apple Developer Organization; agreements vigentes.
- [ ] ≥2 personas con acceso; MFA; inventario de owners (doc interna, sin secrets).
- [ ] Impuestos / datos de pago de la cuenta developer.

### S2. Assets de ficha

- [ ] Ícono 512 (Play) / App Icon 1024 (ya base Kuatia).
- [ ] Feature graphic Play (1024×500).
- [ ] Capturas teléfono (y tablet si se declara soporte).
- [ ] (Opcional) short video preview.
- [ ] Misma estética charcoal + teal que web/app; sin mockups engañosos.

### S3. Copy de tienda

- [ ] Nombre corto, subtítulo, descripción corta/larga.
- [ ] Qué hace: recibir / guardar / presentar credenciales verificables; **sin** prometer certificaciones (eIDAS/SOC2) que no existan.
- [ ] Keywords / categoría: Productivity / Utilities / Finance según encaje real (evitar “medical” si no aplica).
- [ ] ES primero; EN si el listing apunta a mercados EN.

### S4. URLs y contacto obligatorios

Play y Apple exigen **política de privacidad** accesible por HTTPS.

- [ ] Página pública Privacy (wallet + qué datos toca la app) — suele vivir en `kuatia.xyz` (T6).
- [ ] URL de soporte / contacto (`soporte@` o form) — T2.
- [ ] (Apple) URL de marketing / sitio si se pide.
- [ ] ToS si el onboarding ya acepta términos: misma fuente canónica en web.

### S5. Cuestionarios de privacidad y rating

| Store | Formulario |
|-------|------------|
| Play | Data safety |
| Apple | App Privacy + age rating + encryption |

Declarar con honestidad (baseline esperado v1):

- Datos de credenciales **en el dispositivo**; no vendemos datos.
- Cámara: procesamiento on-device para QR.
- Biometría: API del SO; no enviamos plantillas biométricas a Kuatia.
- Red: solo hacia issuers/verifiers que el usuario inicia (y fuentes tipográficas si aplica).

- [ ] Completar Data safety (Play).
- [ ] Completar App Privacy labels (Apple).
- [ ] Content rating / age (sin UGC típico; ajustar si inbox/DIDComm implica mensajes).
- [ ] Export compliance questionnaire.

### S6. Pistas internas

- [ ] Play: testing internal / closed.
- [ ] Apple: TestFlight (internal → external si hace falta).
- [ ] Checklist W8 pasado en builds firmados (no solo debug).

### S7. Primer submit a revisión

- [ ] Notas para el reviewer: cuenta demo **o** instrucciones + issuer/verifier de prueba + QR de ejemplo.
- [ ] Explicar deep links y por qué no hay “login cloud”.
- [ ] Si rechazan: tabla de motivos → fix → resubmit (típico: permisos, privacidad, crashes, metadata).
- [ ] Decidir países / rollout gradual (staged rollout Play).

### S8. Después del publish

- [ ] Renovación Apple Developer anual.
- [ ] Monitorear políticas (Data safety changes, Privacy Manifest).
- [ ] Responder reviews; proceso de hotfix.
- [ ] Mantener alineado package id, firma y accesos al offboarding (T1).

---

# Dependencias cruzadas

```text
W1 IDs finales ──► S1 apps creadas en consolas (no com.example)
W2 permisos ──► S5 / S7 (review)
W4 Privacy Manifest + export ──► S5 / S7
W6 firma ──► W7 builds ──► S6 TestFlight / Play internal ──► S7 prod
T6 legal + T2 contacto ──► S4 URLs obligatorias ──► S7
T8 / T1 cuentas org ──► S1
D10 estilos Kuatia ──► S2 assets (hecho en app; falta ficha)
W8 QA ──► go/no-go S7
W9 telemetría ──► S5 declaraciones
```

---

# Criterio “listo para stores” (MVP)

Todo esto en verde antes de submit prod:

1. IDs y nombres finales (W1)  
2. Permisos iOS/Android correctos (W2)  
3. Privacy Manifest + respuestas crypto (W4)  
4. Firma release (W6) + AAB/IPA (W7)  
5. QA W8 en build firmado  
6. Cuentas org (S1)  
7. Privacidad + soporte HTTPS (S4)  
8. Data safety / App Privacy (S5)  
9. Assets + copy (S2–S3)  
10. Internal/TestFlight OK (S6)  

---

# Fuera de alcance de este backlog

- Reescribir protocolos SSI (ya productivos en app).
- Pasarela de pagos in-app (app free; pagos Kuatia web = otro backlog).
- i18n completa in-app (D11 web / W12 parcial).
- EUDI certification formal / eIDAS wallet notified.
