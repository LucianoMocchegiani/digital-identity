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
- Desde un enlace de oferta o presentación, la app ahora descarga el recurso protocolario con `credentials: omit`, sin seguir redirects y con límite de tamaño. Muestra el Credential Offer JSON o el payload del Request Object.
- El payload OID4VP se **decodifica solo para previsualizarlo**; el JWT aún no está verificado criptográficamente. La UI lo advierte y no permite compartir credenciales.

Todavía no se implementan el intercambio de tokens/solicitud de credencial OID4VCI, verificación de firma y confianza, parsing/matching DCQL, Key Binding JWT ni envío OID4VP. No usar con credenciales reales. La clave AES guardada junto a los datos no protege contra XSS o código malicioso del mismo origen; Web Crypto e IndexedDB no garantizan protección hardware. Al borrar datos del sitio se pierden claves y credenciales, sin recuperación.

Las URLs protocolarias se limitan a `issuer.kuatia.xyz` y `verifier.kuatia.xyz` y sus rutas `/openid4vc-flow/...`; CORS debe permitir el origen de la wallet. No se llaman endpoints administrativos ni se incluyen API keys. El VCT debe coincidir entre la credencial emitida y la consulta DCQL del verifier.
