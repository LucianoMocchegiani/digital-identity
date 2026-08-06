import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { APP_INTERCEPTOR } from '@nestjs/core'
import { AppController } from './app.controller'
import { environmentConfig } from './config/environment.config'
import { DidCommModule } from './didcomm/didcomm.module'
import { MetricsModule } from './metrics/metrics.module'
import { OpenId4VcModule } from './openid4vc/openid4vc.module'
import { HoldersModule } from './holders/holders.module'
import { RecordsModule } from './records/records.module'
import { AuditMessagingModule } from './messaging/audit-messaging.module'
import { AuditInterceptor } from './messaging/audit.interceptor'
import { DatabaseModule } from './database/database.module'
import { AskarStoreModule } from './askar/askar-store.module'
import { RecordStorageModule } from './records/record-storage.module'
import { KeyManagementModule } from './kms/key-management.module'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [environmentConfig] }),
    DatabaseModule,
    AskarStoreModule,
    RecordStorageModule,
    KeyManagementModule,
    HoldersModule,
    DidCommModule,
    MetricsModule,
    OpenId4VcModule,
    RecordsModule,
    AuditMessagingModule,
  ],
  controllers: [AppController],
  providers: [{ provide: APP_INTERCEPTOR, useClass: AuditInterceptor }],
})
export class AppModule {}
