import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { environmentConfig } from './config/environment.config'
import { Account } from './entities/account.entity'
import { Product } from './entities/product.entity'
import { Resource } from './entities/resource.entity'
import { ApiKey } from './entities/api-key.entity'
import { Subscription } from './entities/subscription.entity'
import { PaymentEvent } from './entities/payment-event.entity'
import { UsagePeriod } from './entities/usage-period.entity'
import { BillingModule } from './billing/billing.module'
import { AdminController } from './admin/admin.controller'
import { InternalController } from './internal/internal.controller'
import { WebhooksController } from './webhooks/webhooks.controller'
import { HealthController } from './health.controller'
import { AuthController } from './auth/auth.controller'
import { MeController } from './me/me.controller'
import { ProductsController } from './products/products.controller'
import { ResourcesController } from './resources/resources.controller'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [environmentConfig] }),
    TypeOrmModule.forRootAsync({
      useFactory: () => ({
        type: 'postgres' as const,
        url: environmentConfig().databaseUrl,
        entities: [
          Account,
          Product,
          Resource,
          ApiKey,
          Subscription,
          PaymentEvent,
          UsagePeriod,
        ],
        synchronize: true,
      }),
    }),
    BillingModule,
  ],
  controllers: [
    HealthController,
    AuthController,
    MeController,
    ProductsController,
    ResourcesController,
    AdminController,
    InternalController,
    WebhooksController,
  ],
})
export class AppModule {}
