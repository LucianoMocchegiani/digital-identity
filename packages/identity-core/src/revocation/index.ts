// Barrel del módulo de Revocación (Token Status List).
//
// Las exportaciones están organizadas de lo más genérico (orquestador
// de bajo nivel + puertos) a lo más específico (fachada de alto nivel
// para issuers + factory). Los consumidores deberían preferir
// `RevocationIssuer` cuando su caso de uso sea "crear/asignar/revocar
// credenciales"; el `RevocationService` queda disponible para casos
// genéricos o de admin.

// Orquestador de bajo nivel
export * from './revocation.service';

// Fachada de alto nivel + factory
export * from './revocation.issuer';
export * from './revocation.factory';

// Derivación de SignerMetadata para agentes Credo (helper reusable)
export * from './signer.derivation';

// Puertos
export * from './ports';

// Mensajería (puerto)
export { MESSAGING_SERVICE } from './messaging.interface';
export type { MessagingService } from './messaging.interface';

// Storage (puerto + adapter Postgres)
export * from './status-list-storage.interface'
export * from './postgres-status-list.storage'

// Tipos públicos
export * from './status-list.types'

// Errores públicos
export * from './revocation.errors';
