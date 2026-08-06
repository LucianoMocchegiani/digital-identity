import { Controller, Get, NotFoundException, Param, ServiceUnavailableException } from '@nestjs/common'
import { DidsApi } from '@identity/core'
import { rootAgent, withWallet } from './agent/agent-store'

@Controller()
export class AppController {
  @Get('health')
  health() {
    return { ok: true }
  }

  @Get('health/ready')
  ready() {
    if (!rootAgent) throw new ServiceUnavailableException('Agent not initialized')
    return { ready: true, timestamp: new Date().toISOString() }
  }

  @Get(':walletId/did.json')
  async walletDid(@Param('walletId') walletId: string) {
    return withWallet(walletId, async (agent) => {
      const records = await agent.dependencyManager.resolve(DidsApi).getCreatedDids({ method: 'web' })
      const didDocument = records[0]?.didDocument
      if (!didDocument) throw new NotFoundException('DID Document not available')
      return didDocument.toJSON()
    })
  }
}
