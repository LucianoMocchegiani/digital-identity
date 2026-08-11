import 'reflect-metadata'
import { ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import { WebSocketServer } from 'ws'
import { initializeRootVerifierAgent } from './agent/agent-verifier'
import { AppModule } from './app.module'
import { GlobalExceptionFilter } from './common/http-exception.filter'
import { JsonLoggerService } from './common/logger'
import { GLOBAL_PREFIX_EXCLUDE } from './common/global-prefix.config'
import { LoggingInterceptor } from './common/logging.interceptor'
import { environmentConfig } from './config'
import { RECORD_STORAGE } from './records/record-storage.tokens'
import {
  ADDITIONAL_KEY_MANAGEMENT_SERVICES,
  KEY_MANAGEMENT_SERVICE,
} from './kms/key-management.tokens'
import { ASKAR_STORE_OPTIONS } from './askar/askar-store.tokens'
import type {
  KeyManagementService,
  QuarkAskarStoreOptions,
  RecordStorage,
} from '@identity/core'
import { createPublicRateLimitMiddleware, publicRateLimitConfigFromEnv } from '@identity/core'
import { DidCommService } from './didcomm/didcomm.service'

const logger = new JsonLoggerService()

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Rejection', reason, 'Process')
})
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception', err, 'Process')
})

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { logger })

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }))
  app.useGlobalInterceptors(new LoggingInterceptor())
  app.useGlobalFilters(new GlobalExceptionFilter())
  app.setGlobalPrefix('v1', { exclude: GLOBAL_PREFIX_EXCLUDE })

  const port = environmentConfig().port
  const expressApp = app.getHttpAdapter().getInstance()
  expressApp.use(createPublicRateLimitMiddleware(publicRateLimitConfigFromEnv()))
  const httpServer = app.getHttpServer()
  const wss = new WebSocketServer({ server: httpServer })

  const recordStorage = app.get<RecordStorage>(RECORD_STORAGE)
  const keyManagementService = app.get<KeyManagementService>(KEY_MANAGEMENT_SERVICE)
  const additionalKeyManagementServices = app.get<KeyManagementService[]>(
    ADDITIONAL_KEY_MANAGEMENT_SERVICES,
  )
  const askarStore = app.get<QuarkAskarStoreOptions>(ASKAR_STORE_OPTIONS)
  const didCommService = app.get(DidCommService)

  await initializeRootVerifierAgent(
    expressApp,
    wss,
    recordStorage,
    keyManagementService,
    logger,
    (payload) => didCommService.onConnectionReady(payload),
    askarStore,
    additionalKeyManagementServices,
  )

  await app.listen(port)
  logger.log(`Listening on ${port} (HTTP API + OID4VP + DIDComm WS)`, 'Verifier')
}

bootstrap().catch((err) => {
  const cause =
    err && typeof err === 'object' && 'cause' in err
      ? (err as { cause?: unknown }).cause
      : undefined
  const nested =
    cause && typeof cause === 'object' && cause !== null && 'cause' in cause
      ? (cause as { cause?: unknown }).cause
      : undefined
  logger.error('Bootstrap failed', err, 'Verifier')
  if (cause) {
    logger.error(
      'Bootstrap cause',
      cause instanceof Error ? cause : { message: String(cause) },
      'Verifier',
    )
  }
  if (nested) {
    logger.error(
      'Bootstrap nested cause',
      nested instanceof Error ? nested : { message: String(nested) },
      'Verifier',
    )
  }
  process.exit(1)
})
