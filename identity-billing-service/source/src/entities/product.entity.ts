import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm'
import { Account } from './account.entity'
import { Resource } from './resource.entity'

export type ProductStatus = 'active' | 'archived'

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'account_id', type: 'uuid' })
  accountId!: string

  @ManyToOne(() => Account, (account) => account.products, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'account_id' })
  account!: Account

  @Column({ type: 'varchar', length: 160 })
  name!: string

  @Column({ type: 'text', nullable: true })
  description!: string | null

  @Column({ type: 'varchar', length: 32, default: 'active' })
  status!: ProductStatus

  @OneToMany(() => Resource, (resource) => resource.product)
  resources!: Resource[]

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
