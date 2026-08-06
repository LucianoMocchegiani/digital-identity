import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm'

@Entity('payment_events')
export class PaymentEvent {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ type: 'varchar', length: 32 })
  provider!: string

  @Column({ type: 'varchar', length: 64 })
  type!: string

  @Column({ name: 'account_id', type: 'uuid', nullable: true })
  accountId!: string | null

  @Column({ name: 'external_id', type: 'varchar', length: 255, nullable: true })
  externalId!: string | null

  @Column({ type: 'jsonb', nullable: true })
  payload!: Record<string, unknown> | null

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date
}
