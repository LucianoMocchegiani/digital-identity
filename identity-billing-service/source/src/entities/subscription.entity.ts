import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm'
import { Account } from './account.entity'

export type SubscriptionStatus = 'active' | 'canceled' | 'past_due' | 'trialing'

@Entity('subscriptions')
export class Subscription {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'account_id', type: 'uuid' })
  accountId!: string

  @ManyToOne(() => Account, (account) => account.subscriptions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'account_id' })
  account!: Account

  @Column({ type: 'varchar', length: 32 })
  provider!: string

  @Column({ name: 'external_id', type: 'varchar', length: 255, nullable: true })
  externalId!: string | null

  @Column({ type: 'varchar', length: 32, default: 'active' })
  status!: SubscriptionStatus

  @Column({ type: 'varchar', length: 32 })
  plan!: string

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
