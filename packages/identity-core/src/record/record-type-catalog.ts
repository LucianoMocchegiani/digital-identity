/** Rol del agente Quark; determina qué tipos de record se pueden consultar. */
export type QuarkAgentRole = 'issuer' | 'holder' | 'verifier'

/** Ámbito funcional del record dentro del agente Quark. */
export type RecordTypeCategory = 'infra' | 'identity' | 'didcomm' | 'oid4vc' | 'credential'

/**
 * Descriptor enriquecido de un tipo de record consultable vía `GET /:walletId/records`.
 *
 * Incluye la descripción funcional y el valor de `type` usado en la tabla `records` de PostgreSQL.
 */
export type RecordTypeDescriptor = {
  /** Nombre de la clase Credo (válido en query param `type`). */
  className: string
  /** Valor de `recordClass.type` en storage (también válido en `type`). */
  storageType: string
  category: RecordTypeCategory
  /** Qué representa y para qué sirve en operaciones del servicio. */
  description: string
  /** Roles de agente que pueden listar este tipo. */
  roles: QuarkAgentRole[]
}

type CatalogSeed = Omit<RecordTypeDescriptor, 'roles'> & { roles: QuarkAgentRole[] }

/**
 * Catálogo estático de tipos de record.
 *
 * Los valores de `storageType` corresponden a Credo 0.6 (`recordClass.type`).
 * Mantener sincronizado con los arrays de {@link tenant-records}.
 */
const RECORD_TYPE_CATALOG: CatalogSeed[] = [
  {
    className: 'StorageVersionRecord',
    storageType: 'StorageVersionRecord',
    category: 'infra',
    description:
      'Versión del schema de storage de Credo. Record de sistema; se inserta al inicializar la base. No modificar manualmente.',
    roles: ['issuer', 'holder', 'verifier'],
  },
  {
    className: 'DidRecord',
    storageType: 'DidRecord',
    category: 'identity',
    description:
      'Identidad del agente: DID principal (`did:web` en issuer/verifier, `did:key` en holder), claves y documento asociado. Creado en `POST /issuers|holders|verifiers`.',
    roles: ['issuer', 'holder', 'verifier'],
  },
  {
    className: 'DidCommConnectionRecord',
    storageType: 'ConnectionRecord',
    category: 'didcomm',
    description:
      'Conexión DIDComm con otro agente (estado del did-exchange, DIDs local/remoto, thread). Consultar para monitorear enlaces antes de emitir o verificar por DIDComm.',
    roles: ['issuer', 'holder', 'verifier'],
  },
  {
    className: 'DidCommCredentialExchangeRecord',
    storageType: 'CredentialExchangeRecord',
    category: 'didcomm',
    description:
      'Intercambio de credencial DIDComm (offer/request/issue, estado, vínculo a conexión). En issuer: emisiones; en holder: credenciales recibidas por DIDComm.',
    roles: ['issuer', 'holder'],
  },
  {
    className: 'DidCommProofExchangeRecord',
    storageType: 'ProofExchangeRecord',
    category: 'didcomm',
    description:
      'Intercambio de prueba presentada por DIDComm (request/presentation, estado). En holder: presentaciones enviadas; en verifier: solicitudes atendidas por DIDComm.',
    roles: ['holder', 'verifier'],
  },
  {
    className: 'DidCommOutOfBandRecord',
    storageType: 'OutOfBandRecord',
    category: 'didcomm',
    description:
      'Invitación u out-of-band DIDComm (fingerprints de claves, rol, vínculo a conexión). Útil para depurar invitaciones y reutilización de enlaces.',
    roles: ['issuer', 'holder', 'verifier'],
  },
  {
    className: 'OpenId4VcIssuerRecord',
    storageType: 'OpenId4VcIssuerRecord',
    category: 'oid4vc',
    description:
      'Metadata OID4VCI del emisor: `credentialConfigurationsSupported`, display, JWT de metadata firmado. Creado/actualizado con `POST /issuers` y `PATCH /:walletId/metadata`; lectura alternativa vía este listado.',
    roles: ['issuer'],
  },
  {
    className: 'OpenId4VcIssuanceSessionRecord',
    storageType: 'OpenId4VcIssuanceSessionRecord',
    category: 'oid4vc',
    description:
      'Sesión de emisión OID4VCI (offer, estado, credencial ofrecida). Se crea al generar offers; consultar para seguimiento de flujos con wallets.',
    roles: ['issuer'],
  },
  {
    className: 'OpenId4VcVerifierRecord',
    storageType: 'OpenId4VcVerifierRecord',
    category: 'oid4vc',
    description:
      'Metadata OID4VP del verifier (`clientMetadata`, `verifierId`). Creado/actualizado con `POST /verifiers` y `PATCH /:walletId/metadata`.',
    roles: ['verifier'],
  },
  {
    className: 'OpenId4VcVerificationSessionRecord',
    storageType: 'OpenId4VcVerificationSessionRecord',
    category: 'oid4vc',
    description:
      'Sesión de verificación OID4VP (authorization request, estado, resultado). Se crea al solicitar presentaciones; consultar para auditoría de flujos OID4VP.',
    roles: ['verifier'],
  },
  {
    className: 'SdJwtVcRecord',
    storageType: 'SdJwtVcRecord',
    category: 'credential',
    description:
      'Credencial SD-JWT VC almacenada en la wallet del holder tras una emisión exitosa (OID4VCI o DIDComm según configuración).',
    roles: ['holder'],
  },
  {
    className: 'W3cCredentialRecord',
    storageType: 'W3cCredentialRecord',
    category: 'credential',
    description: 'Credencial W3C Verifiable Credential (formato JSON-LD) en la wallet del holder.',
    roles: ['holder'],
  },
  {
    className: 'W3cV2CredentialRecord',
    storageType: 'W3cV2CredentialRecord',
    category: 'credential',
    description: 'Credencial W3C VC v2 almacenada en la wallet del holder.',
    roles: ['holder'],
  },
]

/**
 * Devuelve el catálogo de tipos de record documentados para un rol de agente.
 *
 * Usado por `GET /:walletId/records/types` en issuer, holder y verifier.
 *
 * @param role - Rol del servicio (`issuer`, `holder`, `verifier`)
 */
export function getRecordTypeDescriptors(role: QuarkAgentRole): RecordTypeDescriptor[] {
  return RECORD_TYPE_CATALOG.filter((entry) => entry.roles.includes(role)).map(
    ({ className, storageType, category, description, roles }) => ({
      className,
      storageType,
      category,
      description,
      roles,
    }),
  )
}

/**
 * Devuelve la entrada de catálogo para un tipo (clase o storage), si existe para el rol.
 */
export function findRecordTypeDescriptor(
  role: QuarkAgentRole,
  recordType: string,
): RecordTypeDescriptor | undefined {
  return getRecordTypeDescriptors(role).find(
    (d) => d.className === recordType || d.storageType === recordType,
  )
}
