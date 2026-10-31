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
- Emisión OID4VCI preautorizada: intercambio del código, proof ES256 del holder, solicitud SD-JWT VC y almacenamiento cifrado. La firma ES256 del JWT recibido se verifica contra la clave autorizada en el DID document HTTPS del tenant; también se comprueban issuer, VCT, expiración y hashes de disclosures.
- OID4VP verifica la firma del Request Object y los campos del verifier, permite seleccionar una credencial coincidente y muestra solo los claims de nivel superior solicitados. La confirmación de consentimiento es local y no envía datos.

No se incluye API key ni se llaman endpoints administrativos. CORS debe permitir el origen de la wallet en issuer y verifier, incluido el DID document. Web Crypto e IndexedDB no aportan protección hardware; borrar los datos del sitio puede eliminar claves y credenciales. OID4VP todavía no verifica el binding con la clave de holder ni genera o envía presentaciones. Ejecutar `npm test` y `npm run build` antes de integrar.
