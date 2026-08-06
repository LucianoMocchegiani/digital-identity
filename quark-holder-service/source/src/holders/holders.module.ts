import { Module } from '@nestjs/common'
import { MessagingModule } from '../messaging/messaging.module'
import { HoldersController } from './holders.controller'
import { HoldersService } from './holders.service'

@Module({
  imports: [MessagingModule],
  controllers: [HoldersController],
  providers: [HoldersService],
})
export class HoldersModule {}
