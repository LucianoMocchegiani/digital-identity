import { Global, Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { ConfigModule, ConfigService } from '@nestjs/config'
import {
  MESSAGING_SERVICE,
  createRevocationIssuer,
  type MessagingService,
  type RevocationIssuer,
  type SignerProvider,
  type StatusListStorage,
  type StatusListUriBuilder,
} from '@quarkid/identity-core'
import { RevocationController } from './revocation.controller'
import { IssuerScopesGuard } from '../common/guards/issuer-scopes.guard'
import { RevocationIssuerService } from './revocation.service'
import { STATUS_LIST_STORAGE } from './status-list-storage.tokens'
import { REVOCATION_ISSUER } from './revocation.tokens'
import { CredoWalletSignerProvider } from './signer.provider'
import { HttpStatusListUriBuilder } from './uri.builder'
import { MessagingModule } from '../messaging/messaging.module'
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard'

/**
 * Módulo de revocación del issuer.
 *
 * Wiring fino sobre puertos de identity-core:
 *
 *  - `STATUS_LIST_STORAGE` lo provee `StatusListStorageModule` en este mismo
 *    directorio `revocation/` (importado desde `AppModule`).
 *  - `CredoWalletSignerProvider` resuelve el `SignerOptions` desde el agente Credo del tenant.
 *  - `HttpStatusListUriBuilder` construye la URI HTTP pública de la StatusList.
 *  - `MessagingModule` provee el `MessagingService` (puerto de eventos).
 *  - El `useFactory` de `REVOCATION_ISSUER` cablea todo con `createRevocationIssuer(...)`
 *    y el resultado se inyecta en `RevocationIssuerService` (fachada fina a nivel Nest).
 *
 * El servicio Nest local (`RevocationIssuerService`) ya no conoce los detalles
 * de firma, persistencia o URI: solo delega a la fachada de alto nivel del core.
 */
@Global()
@Module({
  imports: [
    MessagingModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('jwt.secret'),
        verifyOptions: {
          issuer: config.get<string>('jwt.issuer'),
          audience: config.get<string>('jwt.audience'),
        },
      }),
    }),
  ],
  controllers: [RevocationController],
  providers: [
    JwtAuthGuard,
    IssuerScopesGuard,
    CredoWalletSignerProvider,
    HttpStatusListUriBuilder,
    {
      provide: REVOCATION_ISSUER,
      inject: [STATUS_LIST_STORAGE, CredoWalletSignerProvider, HttpStatusListUriBuilder, MESSAGING_SERVICE],
      useFactory: (
        storage: StatusListStorage,
        signers: SignerProvider,
        uriBuilder: StatusListUriBuilder,
        messaging: MessagingService,
      ): RevocationIssuer =>
        createRevocationIssuer({ storage, signers, uriBuilder, messaging }),
    },
    RevocationIssuerService,
  ],
  exports: [RevocationIssuerService, REVOCATION_ISSUER],
})
export class RevocationIssuerModule {}
