import { Global, Module } from '@nestjs/common'
import { StatusListService } from '@quarkid/identity-core'
import { RevocationController } from './revocation.controller'
import { RevocationVerifierService } from './revocation.service'

/**
 * Módulo de revocación del verifier.
 *
 * El verifier **no** persiste StatusList ni revocaciones: solo consume
 * JWTs de StatusList vía HTTP (`getStatusList`) y decodifica el bitstring
 * para verificar el estado de una credencial (`verifyCredential`).
 *
 * Aquí solo se expone `StatusListService` del core (lógica pura de
 * compress/decompress/decode JWT) y el servicio Nest que la usa.
 */
@Global()
@Module({
  controllers: [RevocationController],
  providers: [StatusListService, RevocationVerifierService],
  exports: [StatusListService, RevocationVerifierService],
})
export class RevocationVerifierModule {}