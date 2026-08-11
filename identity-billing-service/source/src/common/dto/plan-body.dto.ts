import { IsIn } from 'class-validator'

/** Body con `plan` (incluye alias legacy `paid`). */
export class PlanBodyDto {
  @IsIn(['free', 'pro', 'pro_double', 'business', 'paid'])
  plan!: 'free' | 'pro' | 'pro_double' | 'business' | 'paid'
}
