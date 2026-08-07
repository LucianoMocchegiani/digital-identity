import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator'

/** Alta self-serve: nombre + email + password (mín. 8). */
export class RegisterDto {
  @IsString()
  @MinLength(2)
  @MaxLength(160)
  name!: string

  @IsEmail()
  email!: string

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password!: string
}
