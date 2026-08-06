import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { IsNull, Repository } from 'typeorm'
import { Account } from '../entities/account.entity'
import { Product } from '../entities/product.entity'
import { Resource, type ResourceService } from '../entities/resource.entity'
import { ApiKey } from '../entities/api-key.entity'
import { Subscription } from '../entities/subscription.entity'
import { PaymentEvent } from '../entities/payment-event.entity'
import { UsagePeriod } from '../entities/usage-period.entity'
import {
  listPlans,
  normalizePlanId,
  resolvePlan,
  type PlanId,
} from './plans'
import { generateApiKey, hashApiKey } from './api-key.util'
import { API_KEY_WARNING } from '../common/api-key-warning'
import { hashPassword, verifyPassword } from '../common/password.util'
import { WALLET_ID_REGEX } from '../common/wallet-id.validation'
import type { NormalizedPaymentEvent, PaymentProvider } from '../payment/payment-provider'
import { PAYMENT_PROVIDER } from '../payment/payment-provider'
import { TenantProvisioner } from './tenant-provisioner'

type ValidateApiKeyResult = {
  accountId: string
  accountStatus: string
  plan: string
  rateLimitRpm: number
  monthlyTxQuota: number
  monthlyTxUsed: number
  maxProducts: number
  productId: string
  productName: string
  resourceId: string
  service: ResourceService
  walletId: string
  resourceStatus: string
  apiKeyId: string
  apiKeyPrefix: string
}

type ProductCreateResult = {
  product: Product
  resource: Resource
  apiKey: string
  prefix: string
}

type RateWindow = { windowStartMs: number; count: number }

@Injectable()
export class BillingService {
  /** Rate limit en memoria (fase 1, instancia única). */
  private readonly rateWindows = new Map<string, RateWindow>()

  constructor(
    @InjectRepository(Account) private readonly accounts: Repository<Account>,
    @InjectRepository(Product) private readonly products: Repository<Product>,
    @InjectRepository(Resource) private readonly resources: Repository<Resource>,
    @InjectRepository(ApiKey) private readonly apiKeys: Repository<ApiKey>,
    @InjectRepository(Subscription) private readonly subscriptions: Repository<Subscription>,
    @InjectRepository(PaymentEvent) private readonly paymentEvents: Repository<PaymentEvent>,
    @InjectRepository(UsagePeriod) private readonly usagePeriods: Repository<UsagePeriod>,
    @Inject(PAYMENT_PROVIDER) private readonly paymentProvider: PaymentProvider,
    private readonly tenantProvisioner: TenantProvisioner,
  ) {}

  listPlans() {
    return listPlans()
  }

  async listAccounts(): Promise<Account[]> {
    return this.accounts.find({ order: { createdAt: 'DESC' } })
  }

  async getAccount(accountId: string): Promise<Account> {
    return this.requireAccount(accountId)
  }

  async getAccountPublic(accountId: string) {
    const account = await this.requireAccount(accountId)
    return this.toAccountView(account)
  }

  async getUsage(accountId: string) {
    const account = await this.requireAccount(accountId)
    const periodKey = currentPeriodKey()
    const used = await this.getMonthlyTxUsed(accountId, periodKey)
    return {
      periodKey,
      monthlyTxUsed: used,
      monthlyTxQuota: account.monthlyTxQuota,
      rateLimitRpm: account.rateLimitRpm,
      maxProducts: account.maxProducts,
      plan: account.plan,
    }
  }

  /**
   * Registro self-serve: solo account free (sin issuer/verifier).
   * El usuario crea cada producto aparte vía POST /products.
   */
  async register(input: {
    name: string
    email: string
    password: string
  }): Promise<{ account: ReturnType<BillingService['toAccountView']> }> {
    const email = input.email.trim().toLowerCase()
    const existing = await this.accounts.findOne({ where: { email } })
    if (existing) {
      throw new ConflictException('Ya existe una cuenta con ese email')
    }

    const plan = resolvePlan('free')
    const account = await this.accounts.save(
      this.accounts.create({
        name: input.name.trim(),
        email,
        passwordHash: hashPassword(input.password),
        plan: plan.id,
        status: 'active',
        maxProducts: plan.maxProducts,
        rateLimitRpm: plan.rateLimitRpm,
        monthlyTxQuota: plan.monthlyTxQuota,
      }),
    )

    await this.subscriptions.save(
      this.subscriptions.create({
        accountId: account.id,
        provider: this.paymentProvider.name,
        externalId: null,
        status: 'active',
        plan: account.plan,
      }),
    )

    return { account: this.toAccountView(account) }
  }

  async login(input: { email: string; password: string }): Promise<Account> {
    const email = input.email.trim().toLowerCase()
    const account = await this.accounts.findOne({ where: { email } })
    if (!account?.passwordHash || !verifyPassword(input.password, account.passwordHash)) {
      throw new UnauthorizedException('Email o contraseña inválidos')
    }
    if (account.status === 'suspended') {
      throw new ForbiddenException('Cuenta suspendida')
    }
    return account
  }

  async setPlan(accountId: string, planInput: PlanId | 'paid'): Promise<Account> {
    const account = await this.requireAccount(accountId)
    const previous = normalizePlanId(account.plan)
    const planId = normalizePlanId(planInput)
    const plan = resolvePlan(planId)

    account.plan = planId
    account.maxProducts = plan.maxProducts
    account.rateLimitRpm = plan.rateLimitRpm
    account.monthlyTxQuota = plan.monthlyTxQuota
    await this.accounts.save(account)

    await this.enforceProductQuota(accountId, account.maxProducts)

    await this.subscriptions.save(
      this.subscriptions.create({
        accountId,
        provider: this.paymentProvider.name,
        externalId: null,
        status: 'active',
        plan: planId,
      }),
    )
    return account
  }

  async setAccountStatus(
    accountId: string,
    status: Account['status'],
  ): Promise<Account> {
    const account = await this.requireAccount(accountId)
    account.status = status
    return this.accounts.save(account)
  }

  async setQuota(
    accountId: string,
    input: {
      maxProducts?: number
      rateLimitRpm?: number
      monthlyTxQuota?: number
    },
  ): Promise<Account> {
    const account = await this.requireAccount(accountId)
    if (input.maxProducts !== undefined) account.maxProducts = input.maxProducts
    if (input.rateLimitRpm !== undefined) account.rateLimitRpm = input.rateLimitRpm
    if (input.monthlyTxQuota !== undefined) account.monthlyTxQuota = input.monthlyTxQuota
    return this.accounts.save(account)
  }

  /** ManualProvider / admin: activa plan pro. */
  async activatePaid(accountId: string): Promise<Account> {
    await this.requireAccount(accountId)
    await this.applyPaymentEvent({
      type: 'payment.succeeded',
      accountId,
      plan: 'pro',
      externalId: `manual_activate_${accountId}`,
      raw: { source: 'manual_activate' },
    })
    return this.requireAccount(accountId)
  }

  /**
   * Un producto = un issuer o un verifier + API key.
   * Luego provisiona el tenant en issuer/verifier y marca el resource `active`.
   */
  async createProduct(input: {
    accountId: string
    name: string
    description?: string
    service: ResourceService
    walletId: string
  }): Promise<ProductCreateResult> {
    const account = await this.requireAccount(input.accountId)
    if (account.status !== 'active') {
      throw new ForbiddenException('La cuenta no está activa')
    }
    await this.assertProductQuota(account)

    const product = await this.products.save(
      this.products.create({
        accountId: account.id,
        name: input.name.trim(),
        description: input.description ?? null,
        status: 'active',
      }),
    )

    const created = await this.createResourceInternal({
      productId: product.id,
      account,
      service: input.service,
      walletId: input.walletId,
    })

    try {
      await this.tenantProvisioner.provision({
        service: input.service,
        walletId: input.walletId,
        apiKey: created.apiKey,
      })
      const active = await this.markResourceActive(created.resource.id)
      return {
        product,
        resource: active,
        apiKey: created.apiKey,
        prefix: created.prefix,
      }
    } catch (err) {
      // Rollback billing si el tenant no se pudo crear.
      await this.products.delete({ id: product.id })
      throw err
    }
  }

  async listProducts(accountId: string) {
    await this.requireAccount(accountId)
    const products = await this.products.find({
      where: { accountId, status: 'active' },
      relations: { resources: { apiKeys: true } },
      order: { createdAt: 'ASC' },
    })
    return products.map((p) => this.toProductView(p))
  }

  async getProduct(accountId: string, productId: string) {
    const product = await this.requireOwnedProduct(accountId, productId)
    const full = await this.products.findOne({
      where: { id: product.id },
      relations: { resources: { apiKeys: true } },
    })
    if (!full) throw new NotFoundException('Producto no encontrado')
    return this.toProductView(full)
  }

  async patchProduct(
    accountId: string,
    productId: string,
    input: { name?: string; description?: string },
  ) {
    const product = await this.requireOwnedProduct(accountId, productId)
    if (input.name !== undefined) product.name = input.name.trim()
    if (input.description !== undefined) product.description = input.description
    await this.products.save(product)
    return this.getProduct(accountId, productId)
  }

  async archiveProduct(accountId: string, productId: string): Promise<void> {
    const product = await this.requireOwnedProduct(accountId, productId)
    product.status = 'archived'
    await this.products.save(product)

    const resources = await this.resources.find({ where: { productId } })
    for (const resource of resources) {
      resource.status = 'suspended'
      await this.resources.save(resource)
    }
  }

  async listProductResources(accountId: string, productId: string) {
    const product = await this.requireOwnedProduct(accountId, productId)
    const resources = await this.resources.find({
      where: { productId: product.id },
      relations: { apiKeys: true },
      order: { createdAt: 'ASC' },
    })
    return resources.map((r) => this.toResourceView(r))
  }

  private async markResourceActive(resourceId: string): Promise<Resource> {
    const resource = await this.resources.findOne({ where: { id: resourceId } })
    if (!resource) throw new NotFoundException('Recurso no encontrado')
    resource.status = 'active'
    return this.resources.save(resource)
  }

  async rotateApiKeyForAccount(
    accountId: string,
    resourceId: string,
    keyName?: string,
  ): Promise<{ apiKey: string; prefix: string }> {
    await this.requireOwnedResource(accountId, resourceId)
    return this.rotateApiKey(resourceId, keyName)
  }

  async rotateApiKey(
    resourceId: string,
    keyName?: string,
  ): Promise<{ apiKey: string; prefix: string }> {
    const resource = await this.resources.findOne({ where: { id: resourceId } })
    if (!resource) throw new NotFoundException('Recurso no encontrado')

    const activeKeys = await this.apiKeys.find({
      where: { resourceId, revokedAt: IsNull() },
    })
    for (const key of activeKeys) {
      key.revokedAt = new Date()
      await this.apiKeys.save(key)
    }

    const { raw, prefix } = generateApiKey(resource.service)
    await this.apiKeys.save(
      this.apiKeys.create({
        resourceId,
        prefix,
        keyHash: hashApiKey(raw),
        name: keyName ?? `rotated-${resource.walletId}`,
        revokedAt: null,
      }),
    )
    return { apiKey: raw, prefix }
  }

  async revokeApiKeyForAccount(accountId: string, apiKeyId: string): Promise<void> {
    const key = await this.apiKeys.findOne({
      where: { id: apiKeyId },
      relations: { resource: { product: true } },
    })
    if (!key) throw new NotFoundException('API key no encontrada')
    if (key.resource.product.accountId !== accountId) {
      throw new ForbiddenException('La API key no pertenece a esta cuenta')
    }
    key.revokedAt = new Date()
    await this.apiKeys.save(key)
  }

  async revokeApiKey(apiKeyId: string): Promise<void> {
    const key = await this.apiKeys.findOne({ where: { id: apiKeyId } })
    if (!key) throw new NotFoundException('API key no encontrada')
    key.revokedAt = new Date()
    await this.apiKeys.save(key)
  }

  private async validateApiKey(input: {
    apiKey: string
    service: ResourceService
    walletId?: string
  }): Promise<ValidateApiKeyResult> {
    if (!input.apiKey?.trim()) {
      throw new UnauthorizedException('Falta API key')
    }

    const keyHash = hashApiKey(input.apiKey.trim())
    const apiKey = await this.apiKeys.findOne({
      where: { keyHash, revokedAt: IsNull() },
      relations: { resource: { product: { account: true } } },
    })
    if (!apiKey) {
      throw new UnauthorizedException('API key inválida')
    }

    const resource = apiKey.resource
    const product = resource.product
    const account = product.account

    if (account.status !== 'active') {
      throw new ForbiddenException('Cuenta suspendida')
    }
    if (product.status === 'archived') {
      throw new ForbiddenException('Producto archivado')
    }
    if (resource.status === 'suspended') {
      throw new ForbiddenException('Recurso suspendido')
    }
    if (resource.service !== input.service) {
      throw new ForbiddenException(
        `La API key es de ${resource.service}, no de ${input.service}`,
      )
    }
    if (input.walletId && input.walletId !== resource.walletId) {
      throw new ForbiddenException('La API key no está vinculada a este walletId')
    }

    const periodKey = currentPeriodKey()
    const monthlyTxUsed = await this.getMonthlyTxUsed(account.id, periodKey)

    apiKey.lastUsedAt = new Date()
    await this.apiKeys.save(apiKey)

    return {
      accountId: account.id,
      accountStatus: account.status,
      plan: account.plan,
      rateLimitRpm: account.rateLimitRpm,
      monthlyTxQuota: account.monthlyTxQuota,
      monthlyTxUsed,
      maxProducts: account.maxProducts,
      productId: product.id,
      productName: product.name,
      resourceId: resource.id,
      service: resource.service,
      walletId: resource.walletId,
      resourceStatus: resource.status,
      apiKeyId: apiKey.id,
      apiKeyPrefix: apiKey.prefix,
    }
  }

  /**
   * Un solo round-trip para guards de issuer/verifier:
   * valida la API key y consume 1+ transacciones (rate limit + cuota).
   */
  async validateAndMeter(input: {
    apiKey: string
    service: ResourceService
    walletId?: string
    count?: number
  }): Promise<ValidateApiKeyResult & { periodKey: string }> {
    const auth = await this.validateApiKey({
      apiKey: input.apiKey,
      service: input.service,
      walletId: input.walletId,
    })
    const metered = await this.meter({
      accountId: auth.accountId,
      count: input.count ?? 1,
    })
    return {
      ...auth,
      monthlyTxUsed: metered.monthlyTxUsed,
      monthlyTxQuota: metered.monthlyTxQuota,
      rateLimitRpm: metered.rateLimitRpm,
      periodKey: metered.periodKey,
    }
  }

  /** Cuenta 1+ transacciones: rate limit + cuota mensual. */
  private async meter(input: {
    accountId: string
    count?: number
  }): Promise<{
    periodKey: string
    monthlyTxUsed: number
    monthlyTxQuota: number
    rateLimitRpm: number
  }> {
    const count = input.count ?? 1
    if (count < 1) throw new BadRequestException('count debe ser >= 1')

    const account = await this.requireAccount(input.accountId)
    if (account.status !== 'active') {
      throw new ForbiddenException('Cuenta suspendida')
    }

    this.assertRateLimit(account.id, account.rateLimitRpm, count)

    const periodKey = currentPeriodKey()
    let usage = await this.usagePeriods.findOne({
      where: { accountId: account.id, periodKey },
    })
    if (!usage) {
      usage = this.usagePeriods.create({
        accountId: account.id,
        periodKey,
        txCount: 0,
      })
    }

    if (usage.txCount + count > account.monthlyTxQuota) {
      throw new HttpException(
        {
          statusCode: HttpStatus.PAYMENT_REQUIRED,
          message: 'Cuota mensual de transacciones agotada',
          monthlyTxUsed: usage.txCount,
          monthlyTxQuota: account.monthlyTxQuota,
          periodKey,
        },
        HttpStatus.PAYMENT_REQUIRED,
      )
    }

    usage.txCount += count
    await this.usagePeriods.save(usage)

    return {
      periodKey,
      monthlyTxUsed: usage.txCount,
      monthlyTxQuota: account.monthlyTxQuota,
      rateLimitRpm: account.rateLimitRpm,
    }
  }

  async applyPaymentEvent(event: NormalizedPaymentEvent): Promise<void> {
    await this.paymentEvents.save(
      this.paymentEvents.create({
        provider: this.paymentProvider.name,
        type: event.type,
        accountId: event.accountId ?? null,
        externalId: event.externalId ?? null,
        payload: event.raw,
      }),
    )

    if (!event.accountId) return

    if (event.type === 'payment.succeeded') {
      await this.setPlan(event.accountId, event.plan ?? 'pro')
      await this.setAccountStatus(event.accountId, 'active')
      return
    }
    if (event.type === 'payment.failed' || event.type === 'subscription.canceled') {
      await this.setAccountStatus(event.accountId, 'suspended')
    }
  }

  async createCheckout(accountId: string, plan: PlanId | 'paid') {
    await this.requireAccount(accountId)
    return this.paymentProvider.createCheckout({
      accountId,
      plan: normalizePlanId(plan),
    })
  }

  toAccountView(account: Account) {
    return {
      id: account.id,
      name: account.name,
      email: account.email,
      plan: account.plan,
      status: account.status,
      maxProducts: account.maxProducts,
      rateLimitRpm: account.rateLimitRpm,
      monthlyTxQuota: account.monthlyTxQuota,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    }
  }

  toProductCreateResponse(created: ProductCreateResult) {
    const resource = created.resource
    return {
      product: {
        id: created.product.id,
        name: created.product.name,
        description: created.product.description,
        status: created.product.status,
        service: resource.service,
        walletId: resource.walletId,
        resourceId: resource.id,
        resourceStatus: resource.status,
        apiKey: created.apiKey,
        prefix: created.prefix,
      },
      warning: API_KEY_WARNING,
    }
  }

  private toProductView(product: Product) {
    const resource = (product.resources ?? [])[0]
    return {
      id: product.id,
      name: product.name,
      description: product.description,
      status: product.status,
      service: resource?.service ?? null,
      walletId: resource?.walletId ?? null,
      resource: resource ? this.toResourceView(resource) : null,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    }
  }

  private toResourceView(resource: Resource) {
    return {
      id: resource.id,
      service: resource.service,
      walletId: resource.walletId,
      status: resource.status,
      apiKeys: (resource.apiKeys ?? [])
        .filter((k) => !k.revokedAt)
        .map((k) => ({
          id: k.id,
          prefix: k.prefix,
          name: k.name,
          lastUsedAt: k.lastUsedAt,
          createdAt: k.createdAt,
        })),
    }
  }

  private async createResourceInternal(input: {
    productId: string
    account: Account
    service: ResourceService
    walletId: string
    keyName?: string
  }): Promise<{ resource: Resource; apiKey: string; prefix: string }> {
    if (!WALLET_ID_REGEX.test(input.walletId)) {
      throw new BadRequestException('Formato de walletId inválido')
    }

    const existing = await this.resources.findOne({
      where: { service: input.service, walletId: input.walletId },
    })
    if (existing) {
      throw new ConflictException(`${input.service}/${input.walletId} ya existe`)
    }

    const resource = await this.resources.save(
      this.resources.create({
        productId: input.productId,
        service: input.service,
        walletId: input.walletId,
        status: 'pending',
      }),
    )

    const { raw, prefix } = generateApiKey(input.service)
    await this.apiKeys.save(
      this.apiKeys.create({
        resourceId: resource.id,
        prefix,
        keyHash: hashApiKey(raw),
        name: input.keyName ?? `${input.service}-${input.walletId}`,
        revokedAt: null,
      }),
    )

    return { resource, apiKey: raw, prefix }
  }

  private async requireAccount(accountId: string): Promise<Account> {
    const account = await this.accounts.findOne({ where: { id: accountId } })
    if (!account) throw new NotFoundException('Cuenta no encontrada')
    return account
  }

  private async requireOwnedProduct(accountId: string, productId: string): Promise<Product> {
    const product = await this.products.findOne({
      where: { id: productId, accountId, status: 'active' },
    })
    if (!product) throw new NotFoundException('Producto no encontrado')
    return product
  }

  private async requireOwnedResource(accountId: string, resourceId: string): Promise<Resource> {
    const resource = await this.resources.findOne({
      where: { id: resourceId },
      relations: { product: true },
    })
    if (!resource || resource.product.accountId !== accountId) {
      throw new NotFoundException('Recurso no encontrado')
    }
    return resource
  }

  private async assertProductQuota(account: Account): Promise<void> {
    const count = await this.products.count({
      where: { accountId: account.id, status: 'active' },
    })
    if (count >= account.maxProducts) {
      throw new ForbiddenException(
        `El plan permite como máximo ${account.maxProducts} producto(s). Mejorá el plan para crear más.`,
      )
    }
  }

  /** Deja los N productos más viejos activos; archiva el resto. */
  private async enforceProductQuota(accountId: string, maxProducts: number): Promise<void> {
    const products = await this.products.find({
      where: { accountId, status: 'active' },
      relations: { resources: true },
      order: { createdAt: 'ASC' },
    })
    const extras = products.slice(Math.max(0, maxProducts))
    for (const product of extras) {
      product.status = 'archived'
      await this.products.save(product)
      for (const resource of product.resources) {
        resource.status = 'suspended'
        await this.resources.save(resource)
      }
    }
  }

  private async getMonthlyTxUsed(accountId: string, periodKey: string): Promise<number> {
    const usage = await this.usagePeriods.findOne({
      where: { accountId, periodKey },
    })
    return usage?.txCount ?? 0
  }

  private assertRateLimit(accountId: string, rpm: number, count: number): void {
    const now = Date.now()
    const windowMs = 60_000
    let entry = this.rateWindows.get(accountId)
    if (!entry || now - entry.windowStartMs >= windowMs) {
      entry = { windowStartMs: now, count: 0 }
      this.rateWindows.set(accountId, entry)
    }
    if (entry.count + count > rpm) {
      throw new HttpException(
        {
          statusCode: HttpStatus.TOO_MANY_REQUESTS,
          message: 'Rate limit excedido',
          rateLimitRpm: rpm,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      )
    }
    entry.count += count
  }
}

function currentPeriodKey(date = new Date()): string {
  const y = date.getUTCFullYear()
  const m = String(date.getUTCMonth() + 1).padStart(2, '0')
  return `${y}-${m}`
}
