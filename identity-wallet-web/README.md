# Kuatia Web Wallet PoC

SPA estática independiente para validar Vite, Web Crypto e IndexedDB sin agregar un backend ni tocar la wallet Flutter existente.

## Ejecutar

```bash
cd identity-wallet-web
npm install
npm run dev
```

Pruebas y build:

```bash
npm test
npm run build
```

## Estado

- Las rutas `/issue` y `/present` aceptan deep links OID4VCI/OID4VP y validan los hosts/rutas de Kuatia.
- La clave P-256 no exportable del holder se persiste en IndexedDB; las credenciales se cifran con AES-GCM.
- La oferta OID4VCI y metadata se obtienen desde el issuer. Para grants preautorizados, la wallet solicita confirmación, intercambia el código por un token, firma el proof ES256 con la clave del holder, solicita SD-JWT VC y guarda la respuesta cifrada.
- La presentación OID4VP continúa siendo solo una previsualización no verificada.

La credencial recibida se marca explícitamente como **no verificada**. Esta PoC no valida la firma del emisor ni la confianza del issuer, por lo que no debe usarse ni presentarse como una credencial confiable. Se limita a `dc+sd-jwt`, P-256/ES256, binding `jwk` y el grant preautorizado. No implementa `tx_code` opcional, authorization-code, deferred issuance, backup ni recuperación.

No se incluyen API keys ni se llaman endpoints administrativos. CORS debe permitir el origen de la wallet en issuer y verifier. Web Crypto e IndexedDB no aportan protección hardware; borrar los datos del sitio puede eliminar claves y credenciales. Ejecutar `npm test` y `npm run build` antes de integrar.
