/** Módulo raíz del issuer. */
import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { APP_INTERCEPTOR } from '@nestjs/core'
import { AppController } from './app.controller'
import { environmentConfig } from './config/environment.config'
import { DidCommModule } from './didcomm/didcomm.module'
import { OpenId4VcModule } from './openid4vc/openid4vc.module'
import { IssuersModule } from './issuers/issuers.module'
import { RecordsModule } from './records/records.module'
import { AuditMessagingModule } from './messaging/audit-messaging.module'
import { AuditInterceptor } from './messaging/audit.interceptor'
import { RevocationIssuerModule } from './revocation/revocation.module'
import { DatabaseModule } from './database/database.module'
import { AskarStoreModule } from './askar/askar-store.module'
import { RecordStorageModule } from './records/record-storage.module'
import { StatusListStorageModule } from './revocation/status-list-storage.module'
import { KeyManagementModule } from './kms/key-management.module'
import { AuthModule } from './auth/auth.module'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [environmentConfig] }),
    AuthModule,
    DatabaseModule,
    AskarStoreModule,
    RecordStorageModule,
    StatusListStorageModule,
    KeyManagementModule,
    IssuersModule,
    DidCommModule,
    OpenId4VcModule,
    RecordsModule,
    AuditMessagingModule,
    RevocationIssuerModule,
  ],
  controllers: [AppController],
  providers: [{ provide: APP_INTERCEPTOR, useClass: AuditInterceptor }],
})
export class AppModule {}
