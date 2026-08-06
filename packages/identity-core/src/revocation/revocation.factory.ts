import { RevocationService } from './revocation.service';
import { RevocationIssuer } from './revocation.issuer';
import { StatusListService } from './status-list.service';
import type { StatusListStorage } from './status-list-storage.interface'
import type { SignerProvider, StatusListUriBuilder } from './ports';
import type { MessagingService } from './messaging.interface';

/**
 * Dependencias para armar una instancia de {@link RevocationIssuer}.
 *
 * El consumidor (típicamente el issuer de QuarkID) provee los adapters
 * concretos. El core se encarga de cablear el `StatusListService`, el
 * `RevocationService` y la fachada `RevocationIssuer` con sus puertos
 * (`SignerProvider`, `StatusListUriBuilder`) y la mensajería opcional.
 *
 * Ejemplo de wiring desde un servicio Nest:
 *
 * ```typescript
 * {
 *   provide: REVOCATION_ISSUER,
 *   inject: [STATUS_LIST_STORAGE, SIGNER_PROVIDER, STATUS_LIST_URI_BUILDER, MESSAGING_SERVICE],
 *   useFactory: (
 *     storage: StatusListStorage,
 *     signers: SignerProvider,
 *     uriBuilder: StatusListUriBuilder,
 *     messaging?: MessagingService,
 *   ): RevocationIssuer => createRevocationIssuer({ storage, signers, uriBuilder, messaging }),
 * }
 * ```
 */
export interface RevocationIssuerDeps {
  /** Adapter de persistencia de la StatusList (puerto `StatusListStorage`). */
  storage: StatusListStorage;
  /** Puerto para resolver el `SignerOptions` por tenant. */
  signers: SignerProvider;
  /** Puerto para construir la URI pública de una StatusList. */
  uriBuilder: StatusListUriBuilder;
  /**
   * Puerto de mensajería para emitir eventos (`revocation.status-list.created`,
   * `revocation.status-list.allocated`, `credential.revoked`). Opcional:
   * si se omite, los `publishEvent` se vuelven no-op.
   */
  messaging?: MessagingService;
}

/**
 * Arma y devuelve una instancia de {@link RevocationIssuer} lista para usar.
 *
 * Internamente construye el `StatusListService` (lógica pura de bitstring/JWT)
 * y el `RevocationService` (orquestador de bajo nivel con los puertos ya
 * inyectados) y los envuelve en la fachada de alto nivel.
 *
 * Llamar este factory es **equivalente** a construir las tres clases a mano:
 *
 * ```typescript
 * const statusListService = new StatusListService();
 * const revocation = new RevocationService(statusListService, deps.storage, deps.signers, deps.uriBuilder, deps.messaging);
 * const issuer = new RevocationIssuer(revocation);
 * ```
 *
 * Se provee como factory para reducir el boilerplate en el `useFactory` de
 * Nest y para que el core controle el orden de inicialización.
 *
 * @param deps - Dependencias: storage, signers, uriBuilder, mensajería opcional.
 * @returns `RevocationIssuer` listo para inyectar en el consumer.
 */
export function createRevocationIssuer(deps: RevocationIssuerDeps): RevocationIssuer {
  const statusListService = new StatusListService();
  const revocation = new RevocationService(
    statusListService,
    deps.storage,
    deps.signers,
    deps.uriBuilder,
    deps.messaging,
  );
  return new RevocationIssuer(revocation);
}
