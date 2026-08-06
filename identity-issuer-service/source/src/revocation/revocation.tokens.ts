/**
 * Provider NestJS para la fachada de alto nivel `RevocationIssuer` del core.
 *
 * El core (`@identity/core`) no impone un nombre de inyección: el
 * issuer define su propio token y lo asocia vía `useFactory` a una instancia
 * de `RevocationIssuer` creada con `createRevocationIssuer({...})` y los
 * adapters del módulo (`CredoWalletSignerProvider`, `HttpStatusListUriBuilder`).
 *
 * Análogo al patrón `STATUS_LIST_STORAGE = Symbol('StatusListStorage')`:
 * el símbolo evita colisiones con identificadores ajenos al módulo.
 */
export const REVOCATION_ISSUER = Symbol('RevocationIssuer')
