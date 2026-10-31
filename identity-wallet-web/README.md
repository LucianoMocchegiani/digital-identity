# Kuatia Web Wallet PoC

SPA estática independiente para validar el uso de Vite, Web Crypto e IndexedDB sin agregar un backend ni tocar la wallet Flutter existente.

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

## Estado de este incremento

- Las rutas `/issue` y `/present` aceptan los deep links HTTPS de la wallet y los URI custom scheme devueltos por Kuatia.
- Se validan HTTPS, host y patrón de ruta antes de aceptar el endpoint del protocolo.
- Se puede generar una clave ECDSA P-256 no exportable y persistirla como `CryptoKey` en IndexedDB.
- Las funciones de almacenamiento cifran el SD-JWT con AES-GCM y guardan el ciphertext en IndexedDB.
- La interfaz informa explícitamente que las solicitudes todavía no se descargan ni se verifican, y no permite autorizar ni compartir credenciales.

Todavía **no implementa OpenID4VCI/OpenID4VP end-to-end**, verificación de firmas, selección DCQL, Key Binding JWT, lectura de cámara ni backup. No usar con credenciales reales. La clave AES persistida junto a los datos protege contra lectura casual del registro, pero no contra XSS o código malicioso del mismo origen; Web Crypto e IndexedDB no garantizan protección hardware. Al borrar los datos del sitio se pierden claves y credenciales, sin recuperación.

Las URLs protocolarias se limitan por ahora a `issuer.kuatia.xyz` y `verifier.kuatia.xyz` y a sus rutas `/openid4vc-flow/...`; cambiar esos dominios requiere actualizar `src/protocol-link.ts` y sus pruebas. Antes de conectar los endpoints, confirmar CORS y usar los VCT coincidentes entre oferta y DCQL.
