import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm'
import { Product } from './product.entity'
import { ApiKey } from './api-key.entity'

export type ResourceService = 'issuer' | 'verifier'
export type ResourceStatus = 'active' | 'suspended' | 'pending'

@Entity('resources')
@Unique(['service', 'walletId'])
export class Resource {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'product_id', type: 'uuid' })
  productId!: string

  @ManyToOne(() => Product, (product) => product.resources, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product!: Product

  @Column({ type: 'varchar', length: 32 })
  service!: ResourceService

  /** Coincide con issuerId / verifierId / walletId en los servicios de identidad. */
  @Column({ name: 'wallet_id', type: 'varchar', length: 128 })
  walletId!: string

  @Column({ type: 'varchar', length: 32, default: 'pending' })
  status!: ResourceStatus

  @OneToMany(() => ApiKey, (apiKey) => apiKey.resource)
  apiKeys!: ApiKey[]

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
