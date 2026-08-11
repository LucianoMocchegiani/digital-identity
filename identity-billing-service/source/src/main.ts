import 'reflect-metadata'
import { RequestMethod, ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { createBillingPublicRateLimitMiddleware } from './common/public-rate-limit'
import { environmentConfig } from './config/environment.config'

/**
 * Arranca el microservicio identity-billing (NestJS).
 * Prefijo global `/v1` excepto `GET /health`.
 */
async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule)
  app.use(createBillingPublicRateLimitMiddleware())
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }))
  app.setGlobalPrefix('v1', {
    exclude: [{ path: 'health', method: RequestMethod.GET }],
  })
  const port = environmentConfig().port
  await app.listen(port)
  // eslint-disable-next-line no-console
  console.log(`identity-billing escuchando en ${port}`)
}

bootstrap().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Fallo al iniciar billing', err)
  process.exit(1)
})
