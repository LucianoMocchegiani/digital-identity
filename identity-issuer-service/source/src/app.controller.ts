import { Controller, Get, NotFoundException, Param, ServiceUnavailableException } from '@nestjs/common'
import { DidsApi } from '@identity/core'
import { rootAgent, withWallet } from './agent/agent-store'
import { Public } from './auth/public.decorator'

@Controller()
export class AppController {
  @Public()
  @Get('health')
  health() {
    return { ok: true }
  }

  @Public()
  @Get('health/ready')
  ready() {
    if (!rootAgent) throw new ServiceUnavailableException('Agent not initialized')
    return { ready: true, timestamp: new Date().toISOString() }
  }

  @Public()
  @Get(':walletId/did.json')
  async walletDid(@Param('walletId') walletId: string) {
    return withWallet(walletId, async (agent) => {
      const records = await agent.dependencyManager.resolve(DidsApi).getCreatedDids({ method: 'web' })
      const didDocument = records[0]?.didDocument
      if (!didDocument) throw new NotFoundException('DID Document no disponible')
      return didDocument.toJSON()
    })
  }
}
