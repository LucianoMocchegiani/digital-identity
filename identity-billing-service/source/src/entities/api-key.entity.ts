import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm'
import { Resource } from './resource.entity'

@Entity('api_keys')
export class ApiKey {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ name: 'resource_id', type: 'uuid' })
  resourceId!: string

  @ManyToOne(() => Resource, (resource) => resource.apiKeys, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'resource_id' })
  resource!: Resource

  /** Prefijo visible, p. ej. iss_live_ab12 o ver_live_cd34 */
  @Column({ type: 'varchar', length: 32 })
  prefix!: string

  @Column({ name: 'key_hash', type: 'varchar', length: 128 })
  keyHash!: string

  @Column({ type: 'varchar', length: 80, nullable: true })
  name!: string | null

  @Column({ name: 'revoked_at', type: 'timestamptz', nullable: true })
  revokedAt!: Date | null

  @Column({ name: 'last_used_at', type: 'timestamptz', nullable: true })
  lastUsedAt!: Date | null

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
