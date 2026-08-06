export const INDEX_EXCHANGE = 'quarkid.index'

export const ROUTING_KEYS = {
  DID_CREATED:  'did.created',
  DID_RESOLVED: 'did.resolved',
  DID_REPORTED: 'did.reported',
  CREDENTIAL_REVOKED: 'credential.revoked',
  STATUS_LIST_CREATED: 'revocation.status-list.created',
  STATUS_LIST_ALLOCATED: 'revocation.status-list.allocated',
} as const

export const AUDIT_EXCHANGE = 'quarkid.audit'

export const AUDIT_ROUTING_KEYS = {
  OPERATION: 'audit.operation',
} as const

export interface DidEventPayload {
  did: string
  didDocument: Record<string, unknown>
  /** Format: "<service>-<tenantId|userId>" e.g. "issuer-tenantX", "wallet-alice" */
  source: string
  correlationId?: string
  timestamp: string
}

export interface AuditEventPayload {
  correlationId: string
  source: string
  operation: string
  status: 'success' | 'error'
  durationMs: number
  timestamp: string
  tenantId?: string
  appId?: string
  apiKeyId?: string
  method?: string
  path?: string
  statusCode?: number
  ip?: string
  parentSource?: string
  metadata?: Record<string, unknown>
}
