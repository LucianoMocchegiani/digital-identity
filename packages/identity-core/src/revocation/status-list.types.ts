import { StatusList } from '@sd-jwt/jwt-status-list';

export const STATUS_TYPE_VALID = 0;
export const STATUS_TYPE_INVALID = 1;
export const STATUS_TYPE_SUSPENDED = 2;
export const STATUS_TYPE_UNRECOGNIZED = 15;

export type StatusType = 0 | 1 | 2 | 15;

export type BitsPerStatus = 1 | 2 | 4 | 8;

export interface StatusListEntry {
  idx: number;
  uri: string;
}

export interface StatusListReference {
  idx: number;
  uri: string;
}

export interface StatusListInfo {
  id: string;
  walletId: string;
  vct: string;
  bits: BitsPerStatus;
  capacity: number;
  compressedBitstring: string;
  nextIndex: number;
  revokedCount: number;
  lastUpdatedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface StatusListJwtPayload {
  iss: string;
  sub: string;
  iat: number;
  ttl?: number;
  exp?: number;
  status_list: {
    bits: BitsPerStatus;
    lst: string;
  };
}

export interface CreateStatusListParams {
  walletId: string;
  vct: string;
  bits?: BitsPerStatus;
  capacity?: number;
}

export interface AllocateIndexParams {
  walletId: string;
  vct: string;
  credentialId?: string;
  preferredIndex?: number;
}

export interface RevokeParams {
  walletId: string;
  vct: string;
  index: number;
  reason?: string;
  revokedBy?: string;
}

/**
 * Identidad del firmante, derivable del estado del agente: DID emisor, clave
 * KMS, `kid` publicado en el DID Document y algoritmo JWS.
 *
 * No incluye el KMS: quién puede firmar y durante cuánto tiempo es una decisión
 * del consumidor (ver {@link SignerOptions}).
 */
export interface SignerMetadata {
  did: string;
  keyId: string;
  kid: string;
  alg?: string;
}

/**
 * Firmante completo que consume `StatusListService.signAsJwt`.
 *
 * El `kms` debe seguir siendo válido después de que `SignerProvider.resolveSigner`
 * retorne: el core firma más tarde, dentro de la misma operación.
 */
export interface SignerOptions extends SignerMetadata {
  kms: {
    sign(options: { keyId: string; algorithm: string; data: Uint8Array }): Promise<{ signature: Uint8Array }>;
  };
}

export interface GetStatusResult {
  status: StatusType;
  updatedAt?: Date;
}

export interface GetStatusListJwtResult {
  jwt: string;
  uri: string;
}

export {
  StatusList,
};