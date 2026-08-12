import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common'
import {
  JsonTransformer,
  UnknownRecordTypeError,
  getRecordTypeDescriptors,
  getTenantRecord,
  listTenantRecords,
  patchVerifierOid4vpMetadata,
  type ListTenantRecordsResult,
  type QuarkAgentRole,
  type RecordTypeDescriptor,
  type TenantRecordResult,
  type VerifierOid4vpMetadataPatch,
} from '@identity/core'
import { withWallet } from '../agent/agent-store'
import type { PatchVerifierMetadataDto } from './dto/patch-verifier-metadata.dto'

export type PatchVerifierMetadataResult = {
  verifierId: string
  recordType: 'OpenId4VcVerifierRecord'
  record: Record<string, unknown>
}

const ROLE: QuarkAgentRole = 'verifier'

/**
 * Orquesta la consulta de records Credo para wallets verifier vía identity-core.
 */
@Injectable()
export class RecordsService {
  /**
   * Devuelve los tipos de record permitidos para el rol verifier.
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
   * Fusiona metadata OID4VP en el `OpenId4VcVerifierRecord` del tenant (upsert).
   */
  async patchMetadata(walletId: string, dto: PatchVerifierMetadataDto): Promise<PatchVerifierMetadataResult> {
    const patch = dto as VerifierOid4vpMetadataPatch
    const record = await withWallet(walletId, (agent) =>
      patchVerifierOid4vpMetadata(agent, walletId, patch),
    )
    return {
      verifierId: walletId,
      recordType: 'OpenId4VcVerifierRecord',
      record: JsonTransformer.toJSON(record) as Record<string, unknown>,
    }
  }

  /**
   * Obtiene un record por tipo e ID dentro del tenant.
   *
   * @throws {NotFoundException} Si la wallet o el record no existen
   * @throws {BadRequestException} Si el tipo de record es inválido para verifier
   */
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
