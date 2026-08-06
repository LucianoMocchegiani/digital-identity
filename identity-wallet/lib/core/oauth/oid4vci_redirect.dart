/// Redirect URI registrado para el flujo OID4VCI authorization_code.
///
/// Debe coincidir con el intent filter / URL scheme de la app si se usa browser
/// externo. La WebView in-app intercepta esta URI sin salir de la app.
const kOid4VciRedirectUri = 'com.Identity.wallet://oid4vci/callback';
