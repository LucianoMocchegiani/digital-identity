import { Module } from '@nestjs/common'
import { DomainKeyController } from './domain-key.controller'
import { DomainKeyService } from './domain-key.service'

@Module({
  controllers: [DomainKeyController],
  providers: [DomainKeyService],
})
export class DomainKeyModule {}
