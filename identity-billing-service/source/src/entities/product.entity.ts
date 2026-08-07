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

/** `active` = usable; `archived` = soft-deleted (no cuenta para cupo). */
export type ProductStatus = 'active' | 'archived'

/**
 * Producto lógico del cliente: agrupa un resource (issuer o verifier).
 * Modelo: 1 producto ≈ 1 service + walletId + API key.
 * Tabla: `products`.
 */
@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  /** FK a la cuenta dueña. */
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
