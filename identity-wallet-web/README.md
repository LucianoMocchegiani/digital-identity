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
- Desde una oferta, la app descarga el Credential Offer, valida su issuer contra el tenant de Kuatia, obtiene la metadata OID4VCI y valida las configuraciones anunciadas antes de mostrarlas.
- Las llamadas no envían cookies, no siguen redirecciones y limitan las respuestas a 512 KB.
- Desde una solicitud de presentación, descarga el Request Object y decodifica el payload solo para previsualizarlo; la firma aún no está verificada.

Todavía no se implementan el intercambio de tokens/solicitud de credencial OID4VCI, verificación de firma y confianza, parsing/matching DCQL, Key Binding JWT ni envío OID4VP. La app solo reconoce ofertas preautorizadas en esta fase y no muestra el código preautorizado. No usar con credenciales reales. La clave AES guardada junto a los datos no protege contra XSS o código malicioso del mismo origen; Web Crypto e IndexedDB no garantizan protección hardware. Al borrar datos del sitio se pierden claves y credenciales.

Las URLs protocolarias se limitan a `issuer.kuatia.xyz` y `verifier.kuatia.xyz` y sus rutas `/openid4vc-flow/...`; CORS debe permitir el origen de la wallet. No se llaman endpoints administrativos ni se incluyen API keys. El VCT debe coincidir entre la credencial emitida y la consulta DCQL del verifier.
