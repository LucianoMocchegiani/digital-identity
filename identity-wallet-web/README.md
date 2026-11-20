# Kuatia Web Wallet

Wallet web independiente para recibir y presentar credenciales verificables desde el navegador. La interfaz es una SPA de React/Vite y usa Web Crypto e IndexedDB, sin agregar un backend ni modificar la wallet Flutter.

## Ejecutar localmente

```bash
cd identity-wallet-web
npm install
npm run dev
```

La app queda disponible normalmente en `http://localhost:5173`. Pruebas y build:

```bash
npm test
npm run build
```

## Docker / despliegue

El servicio `identity-wallet-web` del `docker-compose.yml` construye la SPA y la sirve con Nginx en el puerto 80 del contenedor, publicado como `http://localhost:3005` en el host. En producción está publicada en [https://wallet.kuatia.xyz](https://wallet.kuatia.xyz). Nginx configura el fallback de la SPA, así que `/issue` y `/present` cargan también en acceso directo y al recargar.

En producción, publicala detrás de HTTPS. Si `cloudflared` corre como servicio en la VPS, su origen normalmente será `http://127.0.0.1:3005`; si el proxy corre en la red Docker, puede usar `identity-wallet-web:80`. Configurá `https://wallet.kuatia.xyz` en `CORS_ORIGINS` tanto en el `.env` del issuer como en el del verifier: la wallet hace las llamadas protocolarias desde el navegador directamente a esos servicios. Ver [`docs/deploy-contabo-phase1.md`](../docs/deploy-contabo-phase1.md) para el paso a paso.

## Funcionalidad actual

- Las rutas `/issue` y `/present` reciben deep links OID4VCI/OID4VP y validan los hosts y rutas de Kuatia.
- La clave P-256 no exportable del holder se conserva en IndexedDB; las credenciales se cifran con AES-GCM. La clave se inicializa automáticamente al empezar una emisión o verificación, o se puede inicializar desde la página principal de la wallet.
- La emisión preautorizada verifica la firma ES256 del issuer contra su DID document, comprueba issuer, VCT, expiración y disclosures, y guarda la credencial cifrada.
- La presentación verifica el Request Object del verifier, ofrece credenciales coincidentes con la clave del holder y muestra los datos solicitados antes del consentimiento. Al confirmar, genera y envía una presentación SD-JWT con prueba de posesión.
- El detalle de la credencial muestra sus atributos revelados únicamente cuando la firma del issuer se verifica contra una clave autorizada por su DID document. Esto verifica la firma criptográfica; no valida la identidad legal del issuer contra un registro externo.

## Seguridad y límites

No se incluyen claves administrativas ni endpoints de administración. El navegador no ofrece protección hardware para las claves de esta aplicación. Las claves y credenciales permanecen en el almacenamiento del navegador para ese origen; borrar los datos del sitio o perder acceso al dispositivo puede hacerlas irrecuperables, porque todavía no hay recuperación o backup. HTTPS es necesario en producción para las APIs criptográficas del navegador. El flujo no debe usarse con credenciales reales.
