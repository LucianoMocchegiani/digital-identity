# Spike Fase 0 — Resultados (Isar 4.0.0-dev.14)

**Fecha:** 2026-06-12  
**Rama:** `feat/isar4-encryption-spike`  
**Ubicación:** `spike/isar4_encryption/`

> **Alcance del spike:** demostrar que Isar 4 dev puede cifrar una DB SQLite con `encryptionKey`. **No** constituye decisión de arquitectura ni valida mantenibilidad del proyecto Isar. Ver [`docs/deuda-tecnica/wallet-persistencia-cifrado-analisis.md`](../../../../docs/deuda-tecnica/wallet-persistencia-cifrado-analisis.md).

## Veredicto técnico: cifrado funciona en laboratorio

## Veredicto de producto: **no GO automático** a migración completa

| Escenario | Resultado |
|-----------|-----------|
| Clave correcta → escribir/leer | OK (Windows) |
| Clave incorrecta → reabrir misma DB | `EncryptionError` |
| Isar 3.1.0+1 (producción) | DB sin cifrar; clave derivada del PIN no se usa |

**Lo que el spike prueba:** el mecanismo `IsarEngine.sqlite` + `encryptionKey` de Isar 4 dev.

**Lo que el spike no prueba:** mantenimiento de Isar 4, Android en dispositivo, migración de 8 schemas reales, ni que Isar sea la mejor opción frente a SQLCipher / cifrado campo.

**Bloqueadores para adoptar Isar 4 en producción:**

1. Dependencia **pre-release** (`4.0.0-dev.14`, agosto 2023); sin stable en pub.dev.
2. Proyecto [isar/isar](https://github.com/isar/isar) con evolución mínima; v4 estable no publicada ([discusión 2025](https://github.com/isar/isar/discussions/1735)).
3. Migración grande de schemas/API + migrador v3→v4.
4. Alternativas con mejor historial de mantenimiento (Drift/SQLCipher) o menor riesgo (cifrado campo + Isar 3).

---

## Cómo se ejecutó

```powershell
cd packages/identity-core-dart/spike/isar4_encryption
# Descargar binario nativo (no incluido en pub package de isar_flutter_libs)
Invoke-WebRequest -Uri "https://github.com/isar/isar/releases/download/4.0.0-dev.14/isar_windows_x64.dll" `
  -OutFile native/isar.dll
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

**Resultado:** 2/2 tests passed (Windows x64, Flutter 3.41.8 / Dart 3.11.5).

---

## Hallazgos técnicos

### Cifrado

- Requiere `engine: IsarEngine.sqlite` + `encryptionKey: String` (no `Uint8List`).
- El SDK actual deriva `Uint8List` 32 B con Argon2id → hay que convertir a string/base64 o pasar hex en Fase 1.
- Error de clave incorrecta: `EncryptionError` (subclase de `IsarError`), no `DatabaseError`.

### Breaking changes Isar 3 → 4 (impacto en identity-core-dart)

| Isar 3 | Isar 4 |
|--------|--------|
| `Isar.open([schemas], directory:, name:)` | `Isar.openAsync(schemas:, directory:, name:, engine:)` |
| `encryptionKey: Uint8List` (ignorado) | `encryptionKey: String?` (solo SQLite) |
| `isar_generator` paquete separado | Generador integrado en `isar` (`build.yaml` auto_apply) |
| `writeTxn(() async {})` | `writeAsync((isar) {})` / `write()` sync |
| `await collection.put()` | `collection.put()` sync dentro de write |
| `@Index(replace: true)` | `@Index(unique: true)` — unique ya sobrescribe |
| `Id id = Isar.autoIncrement` | `late int id` + `collection.autoIncrement()` |
| `Isar.get(name:)` | `Isar.get(schemas:, name:)` |
| `CollectionSchema` | `IsarGeneratedSchema` |
| `Isar.initializeIsarCore(download:)` | `Isar.initialize([libraryPath])` |

### Pub.dev

- `isar` latest estable: **3.1.0+1**
- `isar` 4.x: solo **4.0.0-dev.0 … dev.14**
- `isar_generator` 4.x: **no publicado** (generador dentro de `isar`)
- `isar_flutter_libs` 4.0.0-dev.14: existe; en Windows el `.dll` hay que tomarlo del [release de GitHub](https://github.com/isar/isar/releases/tag/4.0.0-dev.14)

### Compatibilidad SDK / Flutter

- Isar 4 dev.14 declara `analyzer >=5.2.0 <7.0.0` — warning con Dart 3.11 / Flutter 3.41 (funciona, pero conviene probar build_runner en CI).
- Archivos `.isar` v3 **no son compatibles** con v4 → migrador obligatorio (Fase 2 del plan).

---

## Pendiente Fase 0

- [ ] Repetir tests en **Android** (moto e14)
- [ ] Spike comparativo: **Drift/SQLCipher** o **cifrado campo AES-GCM** (esfuerzo estimado 1–2 días c/u)
- [ ] Revisar `isar_plus` encryption + mantenimiento
- [ ] **Decisión arquitectónica** documentada en `docs/deuda-tecnica/wallet-persistencia-cifrado-analisis.md`
- [ ] Medir `build_runner` sobre los 8 schemas reales del SDK (solo si Isar 4 sigue en carrera)

---

## Referencias

- Issue cifrado Isar v4: https://github.com/isar/isar/issues/1360
- Release binarios: https://github.com/isar/isar/releases/tag/4.0.0-dev.14
- Limitaciones SDK: `docs/07-limitations.md` #1 y #2
