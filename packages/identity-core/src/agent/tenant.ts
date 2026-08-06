import { TenantsApi } from '@credo-ts/tenants'
import type { Agent } from '@credo-ts/core'

/** Config extendida que Quark persiste en `TenantRecord.config` (Credo solo tipa `label`). */
type QuarkTenantConfig = {
  label: string
  walletConfig?: { id?: string; key?: string }
}

function getLogicalWalletId(config: QuarkTenantConfig): string | undefined {
  return config.walletConfig?.id ?? config.label
}

/**
 * Crea un nuevo tenant en el agente root o devuelve el ID del tenant existente
 * cuyo `label` (o `walletConfig.id` legacy) coincide con `walletId`.
 *
 * @param rootAgent - Agente root con `TenantsModule` activo
 * @param walletId - ID lógico de la wallet (se usa como `label` del tenant)
 * @param _walletKey - Reservado para compatibilidad con la API de creación de wallets
 * @returns `tenantRecord.id` (UUID interno de Credo) necesario para `withTenant`
 */
export async function ensureTenant(rootAgent: Agent, walletId: string, _walletKey: string): Promise<string> {
  const api = rootAgent.dependencyManager.resolve(TenantsApi)
  const existing = (await api.getAllTenants()).find(
    (t) => getLogicalWalletId(t.config as QuarkTenantConfig) === walletId,
  )
  if (existing) return existing.id
  const record = await api.createTenant({ config: { label: walletId } })
  return record.id
}

/**
 * Ejecuta `callback` dentro del contexto aislado del tenant indicado.
 *
 * @param rootAgent - Agente root con `TenantsModule` activo
 * @param tenantId - `tenantRecord.id` devuelto por `ensureTenant`
 * @param callback - Función a ejecutar con el agente del tenant
 */
export async function withTenant<T>(
  rootAgent: Agent,
  tenantId: string,
  callback: (tenantAgent: Agent) => Promise<T>,
): Promise<T> {
  const api = rootAgent.dependencyManager.resolve(TenantsApi)
  return api.withTenantAgent({ tenantId }, callback as (agent: unknown) => Promise<T>)
}

/**
 * Carga todos los tenants registrados y devuelve un mapa `walletId → tenantRecord.id`.
 *
 * @param rootAgent - Agente root con `TenantsModule` activo
 */
export async function loadTenantMap(rootAgent: Agent): Promise<Map<string, string>> {
  const api = rootAgent.dependencyManager.resolve(TenantsApi)
  const tenants = await api.getAllTenants()
  const map = new Map<string, string>()
  for (const t of tenants) {
    const wid = getLogicalWalletId(t.config as QuarkTenantConfig)
    if (wid) map.set(wid, t.id)
  }
  return map
}
