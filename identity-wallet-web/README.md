# Kuatia Web Wallet

Wallet web independiente para recibir y presentar credenciales verificables desde el navegador. La interfaz es una SPA de React/Vite y usa Web Crypto e IndexedDB, sin agregar un backend ni modificar la wallet Flutter.

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

## Funcionalidad actual

- Las rutas `/issue` y `/present` aceptan deep links OID4VCI/OID4VP y validan los hosts y rutas de Kuatia.
- La clave P-256 no exportable del holder se conserva en IndexedDB; las credenciales se cifran con AES-GCM.
- La emisión preautorizada verifica la firma ES256 del issuer contra su DID document, comprueba issuer, VCT, expiración y disclosures, y guarda la credencial cifrada.
- La presentación verifica el Request Object del verifier, ofrece credenciales coincidentes con la clave del holder y muestra los datos solicitados antes del consentimiento. Al confirmar, genera y envía una presentación SD-JWT con prueba de posesión.

No se incluyen claves administrativas ni endpoints de administración. El navegador no ofrece protección hardware para las claves de esta aplicación. Borrar los datos del sitio puede eliminar las claves y credenciales; todavía no hay recuperación o backup. El flujo no debe usarse con credenciales reales.
