import { IsNotEmpty, IsString } from 'class-validator'

/** Body de `POST .../didcomm/receive-invitation`. */
export class ReceiveInvitationDto {
  /** Short URL `/oob/:id` o URL OOB con query `oob=`. */
  @IsString()
  @IsNotEmpty({ message: 'invitationUrl is required' })
  invitationUrl!: string
}
