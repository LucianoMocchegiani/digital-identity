import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm'
import { Product } from './product.entity'
import { Subscription } from './subscription.entity'
import { UsagePeriod } from './usage-period.entity'

export type AccountStatus = 'active' | 'suspended' | 'past_due'

@Entity('accounts')
export class Account {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ type: 'varchar', length: 160 })
  name!: string

  @Column({ type: 'varchar', length: 255, nullable: true, unique: true })
  email!: string | null

  /** Hash scrypt (siempre en altas vía /auth/register). */
  @Column({ name: 'password_hash', type: 'varchar', length: 255, nullable: true })
  passwordHash!: string | null

  /** free | pro | business (legacy: paid → pro vía resolvePlan). */
  @Column({ type: 'varchar', length: 32, default: 'free' })
  plan!: string

  @Column({ type: 'varchar', length: 32, default: 'active' })
  status!: AccountStatus

  /** Cupos efectivos (copiados del plan; admin puede override). */
  @Column({ name: 'max_products', type: 'int', default: 2 })
  maxProducts!: number

  @Column({ name: 'rate_limit_rpm', type: 'int', default: 30 })
  rateLimitRpm!: number

  @Column({ name: 'monthly_tx_quota', type: 'int', default: 5000 })
  monthlyTxQuota!: number

  @OneToMany(() => Product, (product) => product.account)
  products!: Product[]

  @OneToMany(() => Subscription, (subscription) => subscription.account)
  subscriptions!: Subscription[]

  @OneToMany(() => UsagePeriod, (usage) => usage.account)
  usagePeriods!: UsagePeriod[]

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
