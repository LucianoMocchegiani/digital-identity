import { Module } from '@nestjs/common'
import { MessagingModule } from '../messaging/messaging.module'
import { VerifiersController } from './verifiers.controller'
import { VerifiersService } from './verifiers.service'

/** Colección `POST /verifiers`. */
@Module({
  imports: [MessagingModule],
  controllers: [VerifiersController],
  providers: [VerifiersService],
  exports: [VerifiersService],
})
export class VerifiersModule {}
