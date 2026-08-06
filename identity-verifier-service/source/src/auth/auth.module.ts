import { Module } from '@nestjs/common'
import { APP_GUARD } from '@nestjs/core'
import { ApiKeyAuthGuard } from './api-key.guard'

@Module({
  providers: [{ provide: APP_GUARD, useClass: ApiKeyAuthGuard }],
})
export class AuthModule {}
