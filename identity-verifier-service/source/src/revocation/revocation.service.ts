import { Injectable, Logger } from '@nestjs/common';
import { StatusListService, StatusType } from '@identity/core';

@Injectable()
export class RevocationVerifierService {
  private readonly logger = new Logger(RevocationVerifierService.name);

  constructor(private readonly statusListService: StatusListService) {}

  async getStatusList(
    uri: string,
    options: { forceRefresh?: boolean; defaultTtl?: number } = {}
  ): Promise<{ jwt: string; cached: boolean; expiresAt: Date }> {
    const response = await fetch(uri, {
      headers: { Accept: 'application/jwt' },
      signal: AbortSignal.timeout(10000),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const jwt = await response.text();

    const { payload } = this.statusListService.decodeJwt(jwt);
    const ttl = (payload as any).ttl || options.defaultTtl || 3600;
    const expiresAt = new Date((payload as any).iat * 1000 + ttl * 1000);

    return { jwt, cached: false, expiresAt };
  }

  async getStatus(
    uri: string,
    idx: number,
    options: { forceRefresh?: boolean } = {}
  ): Promise<{ revoked: boolean; status: StatusType; updatedAt?: Date }> {
    const { jwt } = await this.getStatusList(uri, { forceRefresh: options.forceRefresh });

    const { list, payload } = this.statusListService.decodeJwt(jwt);
    const status = this.statusListService.getStatus(list, idx);

    return {
      revoked: status !== 0,
      status,
      updatedAt: new Date((payload as any).iat * 1000),
    };
  }

  async verifyCredential(
    credentialJwt: string,
    options: { issuerPublicKey?: any; expectedIssuer?: string } = {}
  ): Promise<{
    valid: boolean;
    errors: Array<{ code: string; message: string; details?: any }>;
    payload?: any;
  }> {
    const errors: Array<{ code: string; message: string; details?: any }> = [];

    try {
      const reference = this.statusListService.extractReference(credentialJwt);
      const { uri, idx } = reference;

      const { jwt } = await this.getStatusList(uri);
      const { payload } = this.statusListService.decodeJwt(jwt);
      const issuer = (payload as any).iss;

      if (options.expectedIssuer && issuer !== options.expectedIssuer) {
        errors.push({
          code: 'ISSUER_MISMATCH',
          message: `Expected issuer ${options.expectedIssuer}, got ${issuer}`,
        });
      }

      const status = this.statusListService.getStatus(
        this.statusListService.decompress(
          (payload as any).status_list.lst,
          (payload as any).status_list.bits
        ),
        idx
      );

      if (status !== 0) {
        errors.push({
          code: 'STATUS_INVALID',
          message: `Credential status is ${status} (revoked/suspended)`,
          details: { status, idx },
        });
      }

      return {
        valid: errors.length === 0,
        errors,
        payload,
      };
    } catch (error) {
      return {
        valid: false,
        errors: [
          {
            code: 'VERIFICATION_ERROR',
            message: error instanceof Error ? error.message : 'Unknown error',
          },
        ],
      };
    }
  }
}