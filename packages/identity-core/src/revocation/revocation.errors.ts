export class RevocationError extends Error {
  constructor(message: string, public readonly code: string) {
    super(message);
    this.name = 'RevocationError';
  }
}

export class StatusListNotFoundError extends RevocationError {
  constructor(walletId: string, vct: string) {
    super(
      `StatusList not found for walletId=${walletId}, vct=${vct}`,
      'STATUS_LIST_NOT_FOUND'
    );
    this.name = 'StatusListNotFoundError';
  }
}

export class NoFreeIndexError extends RevocationError {
  constructor(walletId: string, vct: string, capacity: number) {
    super(
      `No free index available in StatusList for walletId=${walletId}, vct=${vct}. Capacity: ${capacity}`,
      'NO_FREE_INDEX'
    );
    this.name = 'NoFreeIndexError';
  }
}

export class IndexOutOfBoundsError extends RevocationError {
  constructor(index: number, capacity: number) {
    super(
      `Index ${index} is out of bounds. Capacity: ${capacity}`,
      'INDEX_OUT_OF_BOUNDS'
    );
    this.name = 'IndexOutOfBoundsError';
  }
}

export class InvalidStatusListJwtError extends RevocationError {
  constructor(reason: string) {
    super(
      `Invalid StatusList JWT: ${reason}`,
      'INVALID_STATUS_LIST_JWT'
    );
    this.name = 'InvalidStatusListJwtError';
  }
}

export class StatusListExpiredError extends RevocationError {
  constructor(expiresAt: number) {
    super(
      `StatusList JWT expired at ${new Date(expiresAt * 1000).toISOString()}`,
      'STATUS_LIST_EXPIRED'
    );
    this.name = 'StatusListExpiredError';
  }
}

export class StatusListSignatureError extends RevocationError {
  constructor(issuer: string) {
    super(
      `Failed to verify signature of StatusList JWT issued by ${issuer}`,
      'STATUS_LIST_SIGNATURE_INVALID'
    );
    this.name = 'StatusListSignatureError';
  }
}

export class CredentialAlreadyRevokedError extends RevocationError {
  constructor(index: number) {
    super(
      `Credential at index ${index} is already revoked`,
      'CREDENTIAL_ALREADY_REVOKED'
    );
    this.name = 'CredentialAlreadyRevokedError';
  }
}