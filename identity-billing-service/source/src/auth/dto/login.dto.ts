import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator'

/** Credenciales de login self-serve. */
export class LoginDto {
  @IsEmail()
  email!: string

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password!: string
}
