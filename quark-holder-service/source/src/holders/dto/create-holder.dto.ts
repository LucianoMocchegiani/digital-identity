import { IsString, Matches } from 'class-validator'
import { WALLET_ID_REGEX, WALLET_ID_VALIDATION_MESSAGE } from '../../common/wallet-id.validation'

/**
 * Body de `POST /holders`.
 *
 * Crea el tenant y los records `DidRecord` (`did:key`) + `StorageVersionRecord`.
 * No crea records OID4VCI/OID4VP.
 */
export class CreateHolderDto {
  /** ID lógico del holder (tenant label en Credo). */
  @IsString()
  @Matches(WALLET_ID_REGEX, { message: WALLET_ID_VALIDATION_MESSAGE })
  holderId!: string
}
