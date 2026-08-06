import { Module } from '@nestjs/common'
import { MESSAGING_SERVICE } from '@quarkid/identity-core'
import { MessagingService } from './messaging.service'

@Module({
  providers: [
    MessagingService,
    {
      // Alias para que el `RevocationService` del core pueda inyectar este
      // adapter con el token symbol que define identity-core.
      provide: MESSAGING_SERVICE,
      useExisting: MessagingService,
    },
  ],
  exports: [MessagingService, MESSAGING_SERVICE],
})
export class MessagingModule {}