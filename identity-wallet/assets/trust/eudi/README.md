# Certificados raíz EUDI (OID4VP trust)

PEMs copiados del repositorio oficial de la EUDI Android Wallet:

[eu-digital-identity-wallet/eudi-app-android-wallet-ui](https://github.com/eu-digital-identity-wallet/eudi-app-android-wallet-ui) — carpeta `resources-logic/src/main/res/raw/`.

Se usan en [EudiTrustConfigLoader](../../../lib/core/trust/eudi_trust_config_loader.dart) para validar verifiers OID4VP con `x5c` (por ejemplo `verifier.eudiw.dev`).

| Archivo | Entidad |
|---|---|
| `pidissuerca02_eu.pem` | Unión Europea |
| `pidissuerca02_ut.pem` | Desarrollo / UT |
| `pidissuerca02_*.pem` | CAs nacionales (CZ, EE, LU, NL, PT) |
| `dc4eu.pem` | DC4EU |
| `r45_staging.pem` | R45 Staging |

Actualizar estos archivos si el upstream de EUDI agrega o rota CAs.
