# Spike Isar 4 — cifrado SQLite

Spike de Fase 0 del plan [identity-core-pin-cifrado-plan.md](../../../../local/guides/identity-core-pin-cifrado-plan.md).

Valida si `Isar 4.0.0-dev.14` con `IsarEngine.sqlite` y `encryptionKey` rechaza claves incorrectas.

## Ejecutar (VM / CI — Windows)

```powershell
cd packages/identity-core-dart/spike/isar4_encryption
./scripts/download_isar_core_windows.ps1
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Resultados

Ver `SPIKE_RESULTS.md` — **GO condicional** (cifrado validado en Windows; falta Android).
