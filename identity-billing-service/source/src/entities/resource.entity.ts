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

/** Servicio de identidad al que apunta el resource. */
export type ResourceService = 'issuer' | 'verifier'

/**
 * `pending` = creado en billing, esperando provision;
 * `active` = tenant listo; `suspended` = bloqueado.
 */
export type ResourceStatus = 'active' | 'suspended' | 'pending'

/**
 * Vínculo 1:1 con un tenant remoto (issuerId/verifierId = walletId).
 * Único por (`service`, `walletId`). Tabla: `resources`.
 */
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
