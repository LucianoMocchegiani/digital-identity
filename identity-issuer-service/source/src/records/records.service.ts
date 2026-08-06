import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common'
import {
  IssuerOid4vcNotFoundError,
  JsonTransformer,
  UnknownRecordTypeError,
  getRecordTypeDescriptors,
  getTenantRecord,
  listTenantRecords,
  patchIssuerOid4vcMetadata,
  type IssuerOid4vcMetadataPatch,
  type ListTenantRecordsResult,
  type QuarkAgentRole,
  type RecordTypeDescriptor,
  type TenantRecordResult,
} from '@identity/core'
import { withWallet } from '../agent/agent-store'
import type { PatchIssuerMetadataDto } from './dto/patch-issuer-metadata.dto'

export type PatchIssuerMetadataResult = {
  issuerId: string
  recordType: 'OpenId4VcIssuerRecord'
  record: Record<string, unknown>
}

const ROLE: QuarkAgentRole = 'issuer'

/**
 * Orquesta la consulta de records Credo para wallets issuer vía identity-core.
 */
@Injectable()
export class RecordsService {
  /**
   * Devuelve el catálogo documentado de tipos de record para issuer.
   *
   * Cada entrada incluye `description` (qué representa) y `category` (`identity`, `didcomm`, `oid4vc`, etc.).
   */
  getTypes(): { role: QuarkAgentRole; types: RecordTypeDescriptor[] } {
    return { role: ROLE, types: getRecordTypeDescriptors(ROLE) }
  }

  /**
   * Lista records del tenant con paginación y filtro opcional por tags.
   *
   * @param walletId - ID lógico del tenant
   * @param recordType - Clase Credo o tipo en storage
   * @param queryJson - Objeto JSON serializado para `findByQuery` (opcional)
   * @param page - Página 1-based (opcional, default en identity-core)
   * @param limit - Tamaño de página (opcional, máx. 100)
   * @throws {BadRequestException} Si `query` no es JSON válido o el tipo de record es inválido
   * @throws {NotFoundException} Si la wallet no existe en el mapa de tenants
   */
  async list(
    walletId: string,
    recordType: string,
    queryJson?: string,
    page?: number,
    limit?: number,
  ): Promise<ListTenantRecordsResult> {
    const query = this.parseQuery(queryJson)
    try {
      return await withWallet(walletId, (agent) =>
        listTenantRecords(agent, ROLE, recordType, { query, page, limit }),
      )
    } catch (err) {
      this.rethrowRecordError(err)
    }
  }

  /**
   * Obtiene un record por tipo e ID dentro del tenant.
   *
   * @param walletId - ID lógico del tenant
   * @param recordType - Clase Credo o tipo en storage
   * @param recordId - ID del record
   * @throws {NotFoundException} Si la wallet o el record no existen
   * @throws {BadRequestException} Si el tipo de record es inválido para issuer
   */
  /**
   * Fusiona metadata OID4VCI en el `OpenId4VcIssuerRecord` del tenant.
   */
  async patchMetadata(walletId: string, dto: PatchIssuerMetadataDto): Promise<PatchIssuerMetadataResult> {
    const patch = dto as IssuerOid4vcMetadataPatch
    try {
      const record = await withWallet(walletId, (agent) => patchIssuerOid4vcMetadata(agent, walletId, patch))
      return {
        issuerId: walletId,
        recordType: 'OpenId4VcIssuerRecord',
        record: JsonTransformer.toJSON(record) as Record<string, unknown>,
      }
    } catch (err) {
      if (err instanceof IssuerOid4vcNotFoundError) {
        throw new NotFoundException(err.message)
      }
      throw err
    }
  }

  async get(walletId: string, recordType: string, recordId: string): Promise<TenantRecordResult> {
    try {
      const result = await withWallet(walletId, (agent) => getTenantRecord(agent, ROLE, recordType, recordId))
      if (!result) {
        throw new NotFoundException(`Record '${recordId}' de tipo '${recordType}' no encontrado`)
      }
      return result
    } catch (err) {
      this.rethrowRecordError(err)
    }
  }

  /**
   * Parsea el query param `query` como objeto JSON para filtro por tags Credo.
   *
   * @throws {BadRequestException} Si no es un objeto JSON válido
   */
  private parseQuery(queryJson?: string): Record<string, unknown> {
    if (!queryJson) return {}
    try {
      const parsed: unknown = JSON.parse(queryJson)
      if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new BadRequestException('El parámetro query debe ser un objeto JSON')
      }
      return parsed as Record<string, unknown>
    } catch (err) {
      if (err instanceof BadRequestException) throw err
      throw new BadRequestException('El parámetro query no es JSON válido')
    }
  }

  /** Mapea {@link UnknownRecordTypeError} a HTTP 400. */
  private rethrowRecordError(err: unknown): never {
    if (err instanceof UnknownRecordTypeError) {
      throw new BadRequestException(err.message)
    }
    throw err
  }
}
