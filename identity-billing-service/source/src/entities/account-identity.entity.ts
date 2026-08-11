import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm'
import { Account } from './account.entity'

export type OAuthProvider = 'google' | 'github'

/**
 * Identidad OAuth vinculada a una cuenta (Google / GitHub).
 * Unique (provider, provider_subject) → una free por sub OAuth.
 */
@Entity('account_identities')
@Unique(['provider', 'providerSubject'])
export class AccountIdentity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Index()
  @Column({ name: 'account_id', type: 'uuid' })
  accountId!: string

  @ManyToOne(() => Account, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'account_id' })
  account!: Account

  @Column({ type: 'varchar', length: 32 })
  provider!: OAuthProvider

  /** `sub` OIDC (Google) o id de usuario (GitHub). */
  @Column({ name: 'provider_subject', type: 'varchar', length: 255 })
  providerSubject!: string

  @Column({ type: 'varchar', length: 255, nullable: true })
  email!: string | null

  @Column({ name: 'display_name', type: 'varchar', length: 160, nullable: true })
  displayName!: string | null

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
