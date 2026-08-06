import { IsIn } from 'class-validator'

export class SetStatusDto {
  @IsIn(['active', 'suspended', 'past_due'])
  status!: 'active' | 'suspended' | 'past_due'
}
