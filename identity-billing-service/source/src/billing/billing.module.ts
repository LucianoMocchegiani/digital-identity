import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { TypeOrmModule } from '@nestjs/typeorm'
import { Account } from '../entities/account.entity'
import { AccountIdentity } from '../entities/account-identity.entity'
import { Product } from '../entities/product.entity'
import { Resource } from '../entities/resource.entity'
import { ApiKey } from '../entities/api-key.entity'
import { Subscription } from '../entities/subscription.entity'
import { PaymentEvent } from '../entities/payment-event.entity'
import { UsagePeriod } from '../entities/usage-period.entity'
import { BillingService } from './billing.service'
import { TenantProvisioner } from './tenant-provisioner'
import { PAYMENT_PROVIDER } from '../payment/payment-provider'
import { ManualPaymentProvider } from '../payment/manual.provider'
import { environmentConfig } from '../config/environment.config'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { OAuthService } from '../auth/oauth.service'

/**
 * Módulo de dominio: BillingService, provision de tenants, JWT y PaymentProvider.
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Account,
      AccountIdentity,
      Product,
      Resource,
      ApiKey,
      Subscription,
      PaymentEvent,
      UsagePeriod,
    ]),
    JwtModule.register({
      global: true,
      secret: environmentConfig().jwtSecret,
      signOptions: { expiresIn: environmentConfig().jwtExpiresIn },
    }),
  ],
  providers: [
    BillingService,
    TenantProvisioner,
    JwtAuthGuard,
    OAuthService,
    ManualPaymentProvider,
    {
      provide: PAYMENT_PROVIDER,
      useFactory: (manual: ManualPaymentProvider) => {
        const provider = environmentConfig().paymentProvider
        if (provider === 'manual') return manual
        // Fase 1: solo manual. Adaptadores mercadopago/stripe se enchufan acá después.
        return manual
      },
      inject: [ManualPaymentProvider],
    },
  ],
  exports: [BillingService, PAYMENT_PROVIDER, JwtAuthGuard, JwtModule, OAuthService],
})
export class BillingModule {}
