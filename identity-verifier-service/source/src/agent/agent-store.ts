import { NotFoundException } from '@nestjs/common'
import { withTenant, type Agent } from '@identity/core'

export let rootAgent: Agent | null = null
export const tenantMap = new Map<string, string>()

export function setRootAgent(agent: Agent, map: Map<string, string>): void {
  rootAgent = agent
  map.forEach((tenantId, walletId) => tenantMap.set(walletId, tenantId))
}

export function hasWallet(walletId: string): boolean {
  return tenantMap.has(walletId)
}

/** Pares `walletId` → `tenantId` registrados en este proceso. */
export function listWallets(): Array<{ walletId: string; tenantId: string }> {
  return [...tenantMap.entries()]
    .map(([walletId, tenantId]) => ({ walletId, tenantId }))
    .sort((a, b) => a.walletId.localeCompare(b.walletId))
}

/** Registra un tenant recién creado (`POST /verifiers`). */
export function registerTenant(walletId: string, tenantId: string): void {
  tenantMap.set(walletId, tenantId)
}

export function withWallet<T>(walletId: string, callback: (agent: Agent) => Promise<T>): Promise<T> {
  if (!rootAgent) throw new Error('Agent not initialized')
  const tenantId = tenantMap.get(walletId)
  if (!tenantId) throw new NotFoundException(`Wallet '${walletId}' not found`)
  return withTenant(rootAgent, tenantId, callback)
}
