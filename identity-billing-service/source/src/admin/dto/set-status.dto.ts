import { IsIn } from 'class-validator'

/** Body para cambiar el status de una cuenta (admin). */
export class SetStatusDto {
  @IsIn(['active', 'suspended', 'past_due'])
  status!: 'active' | 'suspended' | 'past_due'
}
