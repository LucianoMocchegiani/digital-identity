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

/** Estado de la suscripción frente al proveedor de pago. */
export type SubscriptionStatus = 'active' | 'canceled' | 'past_due' | 'trialing'

/**
 * Historial / snapshot de suscripción vinculado a una cuenta.
 * Se crea una fila nueva en cada cambio de plan relevante.
 * Tabla: `subscriptions`.
 */
@Entity('subscriptions')
export class Subscription {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'account_id', type: 'uuid' })
  accountId!: string

  @ManyToOne(() => Account, (account) => account.subscriptions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'account_id' })
  account!: Account

  /** Nombre del PaymentProvider (`manual`, etc.). */
  @Column({ type: 'varchar', length: 32 })
  provider!: string

  /** Id externo en el PSP, si aplica. */
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
