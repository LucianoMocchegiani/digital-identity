import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { APP_INTERCEPTOR } from '@nestjs/core'
import { AppController } from './app.controller'
import { DidCommModule } from './didcomm/didcomm.module'
import { OpenId4VcModule } from './openid4vc/openid4vc.module'
import { VerifiersModule } from './verifiers/verifiers.module'
import { RecordsModule } from './records/records.module'
import { AuditMessagingModule } from './messaging/audit-messaging.module'
import { AuditInterceptor } from './messaging/audit.interceptor'
import { DomainKeyModule } from './domain-key/domain-key.module'
import { RevocationVerifierModule } from './revocation/revocation.module'
import { DatabaseModule } from './database/database.module'
import { AskarStoreModule } from './askar/askar-store.module'
import { RecordStorageModule } from './records/record-storage.module'
import { KeyManagementModule } from './kms/key-management.module'
import { environmentConfig } from './config/environment.config'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [environmentConfig] }),
    DatabaseModule,
    AskarStoreModule,
    RecordStorageModule,
    KeyManagementModule,
    DomainKeyModule,
    VerifiersModule,
    DidCommModule,
    OpenId4VcModule,
    RecordsModule,
    AuditMessagingModule,
    RevocationVerifierModule,
  ],
  controllers: [AppController],
  providers: [{ provide: APP_INTERCEPTOR, useClass: AuditInterceptor }],
})
export class AppModule {}
