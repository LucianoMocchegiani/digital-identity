/**
 * Puerto de mensajería para los eventos emitidos por el módulo de revocación.
 *
 * El core (`@quarkid/identity-core`) no impone el transporte: el consumidor
 * decide si el adapter es RabbitMQ, Kafka, una cola in-memory, etc. Si no se
 * inyecta, el {@link RevocationService} opera en modo fire-and-forget (no-op).
 *
 * El token de DI es un `Symbol` (no string) para evitar colisiones con
 * identificadores ajenos al módulo.
 */
export interface MessagingService {
  publish(routingKey: string, payload: Record<string, unknown>): Promise<void>
}

/**
 * Token NestJS para inyectar el adapter de mensajería.
 * Espejo del patrón `RECORD_STORAGE` / `RECORD_DATABASE_POOL` del módulo `record`.
 */
export const MESSAGING_SERVICE = Symbol('MessagingService')