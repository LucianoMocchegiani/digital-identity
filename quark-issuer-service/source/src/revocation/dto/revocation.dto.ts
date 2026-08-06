import { IsString, IsNotEmpty, IsOptional, IsIn, IsInt, Min, Max, MaxLength } from 'class-validator';

export class CreateStatusListDto {
  @IsString()
  @IsNotEmpty()
  vct!: string;

  @IsOptional()
  @IsIn([1, 2, 4, 8])
  bits?: 1 | 2 | 4 | 8 = 1;

  @IsOptional()
  @IsInt()
  @Min(1024)
  @Max(131072)
  capacity?: number = 16384;
}

export class AllocateIndexDto {
  @IsOptional()
  @IsString()
  credentialId?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  preferredIndex?: number;
}

export class RevokeCredentialDto {
  @IsInt()
  @Min(0)
  index!: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  reason?: string;
}

export class CreateStatusListResponseDto {
  listId!: string;
  uri!: string;
}

export class AllocateIndexResponseDto {
  index!: number;
  uri!: string;
}

export class RevokeCredentialResponseDto {
  revokedAt!: Date;
}

export class GetStatusResponseDto {
  status!: 0 | 1;
  updatedAt?: Date;
}