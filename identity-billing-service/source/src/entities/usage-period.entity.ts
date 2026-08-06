import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm'
import { Account } from './account.entity'

@Entity('usage_periods')
@Unique(['accountId', 'periodKey'])
export class UsagePeriod {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'account_id', type: 'uuid' })
  accountId!: string

  @ManyToOne(() => Account, (account) => account.usagePeriods, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'account_id' })
  account!: Account

  /** Período UTC `YYYY-MM`. */
  @Column({ name: 'period_key', type: 'varchar', length: 7 })
  periodKey!: string

  @Column({ name: 'tx_count', type: 'int', default: 0 })
  txCount!: number

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
