import { IsString, IsNotEmpty, IsInt, Min } from 'class-validator';

export class GetStatusListDto {
  @IsString()
  @IsNotEmpty()
  uri!: string;
}

export class GetStatusDto {
  @IsString()
  @IsNotEmpty()
  uri!: string;

  @IsInt()
  @Min(0)
  idx!: number;
}

export class VerifyCredentialDto {
  @IsString()
  @IsNotEmpty()
  credentialJwt!: string;
}

export class GetStatusListResponseDto {
  jwt!: string;
  cached!: boolean;
  expiresAt!: Date;
}

export class GetStatusResponseDto {
  revoked!: boolean;
  status!: number;
  updatedAt?: Date;
}

export class VerifyCredentialResponseDto {
  valid!: boolean;
  errors!: Array<{ code: string; message: string; details?: any }>;
  payload?: any;
}