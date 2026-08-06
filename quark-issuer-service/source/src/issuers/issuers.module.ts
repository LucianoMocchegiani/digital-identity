import { Module } from '@nestjs/common'
import { MessagingModule } from '../messaging/messaging.module'
import { IssuersController } from './issuers.controller'
import { IssuersService } from './issuers.service'

/** Colección `POST /issuers` (alta de tenant). */
@Module({
  imports: [MessagingModule],
  controllers: [IssuersController],
  providers: [IssuersService],
  exports: [IssuersService],
})
export class IssuersModule {}
