import { Module } from '@nestjs/common'
import { AuditMessagingService } from './audit-messaging.service'

@Module({
  providers: [AuditMessagingService],
  exports: [AuditMessagingService],
})
export class AuditMessagingModule {}
